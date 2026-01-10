# Customer Routes
from flask import Blueprint, jsonify, request
from models.database import execute_query, execute_insert_update

customers_bp = Blueprint('customers', __name__, url_prefix='/api/customers')

@customers_bp.route('', methods=['GET'])
def get_customers():
    """Get customers, VIPs first"""
    query = """
    SELECT customer_id, full_name, 
           COALESCE(phone, '') as phone, 
           COALESCE(email, '') as email, 
           COALESCE(total_ltv, 0) as total_ltv, 
           COALESCE(vip_status, FALSE) as vip_status
    FROM CUSTOMERS
    ORDER BY vip_status DESC, total_ltv DESC
    """
    data = execute_query(query)
    # Return empty array if no data (not an error)
    return jsonify(data if data is not None else [])

# CREATE - Yeni müşteri ekle
@customers_bp.route('', methods=['POST'])
def create_customer():
    """Yeni müşteri ekle (INSERT)"""
    data = request.get_json()
    
    if not data or 'full_name' not in data:
        return jsonify({"error": "full_name alanı zorunludur"}), 400
    
    query = """
    INSERT INTO CUSTOMERS (full_name, phone, email, vip_status, total_ltv)
    VALUES (%s, %s, %s, %s, 0)
    """
    params = (
        data.get('full_name'),
        data.get('phone'),
        data.get('email'),
        data.get('vip_status', False)
    )
    
    result = execute_insert_update(query, params)
    if result:
        return jsonify({"message": "Müşteri başarıyla eklendi", "success": True}), 201
    else:
        return jsonify({"error": "Müşteri eklenemedi"}), 500

# DELETE - Müşteri sil
@customers_bp.route('/<int:customer_id>', methods=['DELETE'])
def delete_customer(customer_id):
    """Müşteri sil (DELETE)"""
    try:
        # Önce müşterinin var olduğunu kontrol et
        check_query = "SELECT customer_id FROM CUSTOMERS WHERE customer_id = %s"
        exists = execute_query(check_query, (customer_id,))
        
        if not exists:
            return jsonify({"error": "Müşteri bulunamadı"}), 404
        
        # 1. Önce diyet kısıtlamalarını sil
        delete_dietary = "DELETE FROM DIETARYRESTRICTIONS WHERE customer_id = %s"
        execute_insert_update(delete_dietary, (customer_id,))
        
        # 2. Müşterinin rezervasyonlarına bağlı dining sessions'ları bul
        find_sessions = """
            SELECT ds.session_id FROM DININGSESSIONS ds
            JOIN RESERVATIONS r ON ds.reservation_id = r.reservation_id
            WHERE r.customer_id = %s
        """
        sessions = execute_query(find_sessions, (customer_id,))
        
        if sessions:
            session_ids = [s['session_id'] for s in sessions]
            for sid in session_ids:
                # Feedback sil
                execute_insert_update("DELETE FROM FEEDBACK WHERE session_id = %s", (sid,))
                # Orders ve OrderDetails
                orders = execute_query("SELECT order_id FROM ORDERS WHERE session_id = %s", (sid,))
                if orders:
                    for o in orders:
                        execute_insert_update("DELETE FROM ORDERDETAILS WHERE order_id = %s", (o['order_id'],))
                    execute_insert_update("DELETE FROM ORDERS WHERE session_id = %s", (sid,))
                # Session sil
                execute_insert_update("DELETE FROM DININGSESSIONS WHERE session_id = %s", (sid,))
        
        # 3. Rezervasyonları sil
        delete_reservations = "DELETE FROM RESERVATIONS WHERE customer_id = %s"
        execute_insert_update(delete_reservations, (customer_id,))
        
        # 4. Son olarak müşteriyi sil
        delete_query = "DELETE FROM CUSTOMERS WHERE customer_id = %s"
        result = execute_insert_update(delete_query, (customer_id,))
        
        if result:
            return jsonify({"message": "Müşteri başarıyla silindi", "success": True}), 200
        else:
            return jsonify({"error": "Müşteri silinemedi"}), 500
    except Exception as e:
        print(f"Delete error: {e}")
        return jsonify({"error": str(e)}), 500

@customers_bp.route('/vip', methods=['GET'])
def get_vip_customers():
    """Get VIP customers only"""
    query = """
    SELECT customer_id, full_name, 
           COALESCE(phone, '') as phone, 
           COALESCE(email, '') as email, 
           COALESCE(total_ltv, 0) as total_ltv
    FROM CUSTOMERS
    WHERE vip_status = TRUE
    ORDER BY total_ltv DESC
    """
    data = execute_query(query)
    # Return empty array if no VIP customers (not an error)
    return jsonify(data if data is not None else [])

@customers_bp.route('/dietary/<int:customer_id>', methods=['GET'])
def get_customer_dietary_restrictions(customer_id):
    """Müşterinin diyet kısıtlamalarını getir"""
    query = """
    SELECT dr.restriction_id, dr.restriction_type
    FROM DIETARYRESTRICTIONS dr
    WHERE dr.customer_id = %s
    """
    data = execute_query(query, (customer_id,))
    if data:
        return jsonify(data)
    else:
        return jsonify([])  # Kısıtlama yoksa boş array döndür
