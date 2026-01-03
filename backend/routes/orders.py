# Orders Routes
from flask import Blueprint, jsonify, request
from models.database import execute_query, execute_insert_update

orders_bp = Blueprint('orders', __name__, url_prefix='/api/orders')

@orders_bp.route('', methods=['GET'])
def get_orders():
    """Tüm siparişleri getir, opsiyonel tarih filtresi"""
    date_filter = request.args.get('date')
    query = """
    SELECT o.order_id, ds.session_id, c.full_name as customer_name,
           o.order_time, COUNT(od.detail_id) as item_count
    FROM ORDERS o
    JOIN DININGSESSIONS ds ON o.session_id = ds.session_id
    JOIN RESERVATIONS r ON ds.reservation_id = r.reservation_id
    JOIN CUSTOMERS c ON r.customer_id = c.customer_id
    LEFT JOIN ORDERDETAILS od ON o.order_id = od.order_id
    """
    params = []
    if date_filter:
        query += " WHERE DATE(o.order_time) = %s"
        params.append(date_filter)
    query += " GROUP BY o.order_id ORDER BY o.order_time DESC"
    data = execute_query(query, params)
    if data:
        return jsonify(data)
    else:
        return jsonify([])

@orders_bp.route('/<int:order_id>/details', methods=['GET'])
def get_order_details(order_id):
    """Sipariş detaylarını getir"""
    query = """
    SELECT od.detail_id, m.name as item_name, od.quantity, m.price,
           (od.quantity * m.price) as total_price, od.special_note
    FROM ORDERDETAILS od
    JOIN MENUITEMS m ON od.item_id = m.item_id
    WHERE od.order_id = %s
    """
    data = execute_query(query, (order_id,))
    if data:
        return jsonify(data)
    else:
        return jsonify([])

@orders_bp.route('', methods=['POST'])
def create_order():
    """Yeni sipariş oluştur"""
    data = request.json
    query = """
    INSERT INTO ORDERS (session_id, staff_id, order_time)
    VALUES (%s, %s, NOW())
    """
    success = execute_insert_update(query, (
        data['session_id'],
        data['staff_id']
    ))
    
    if success:
        return jsonify({"message": "Sipariş oluşturuldu"}), 201
    else:
        return jsonify({"error": "Sipariş oluşturulamadı"}), 500
