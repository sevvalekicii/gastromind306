# Customer Routes
from flask import Blueprint, jsonify
from models.database import execute_query

customers_bp = Blueprint('customers', __name__, url_prefix='/api/customers')

@customers_bp.route('', methods=['GET'])
def get_customers():
    """VIP'leri en üste koyarak müşterileri getir"""
    query = """
    SELECT customer_id, full_name, phone, email, total_ltv, vip_status
    FROM CUSTOMERS
    ORDER BY vip_status DESC, total_ltv DESC
    """
    data = execute_query(query)
    if data:
        return jsonify(data)
    else:
        return jsonify({"error": "Müşteriler alınamadı"}), 500

@customers_bp.route('/vip', methods=['GET'])
def get_vip_customers():
    """Sadece VIP müşterileri getir"""
    query = """
    SELECT customer_id, full_name, phone, email, total_ltv
    FROM CUSTOMERS
    WHERE vip_status = TRUE
    ORDER BY total_ltv DESC
    """
    data = execute_query(query)
    if data:
        return jsonify(data)
    else:
        return jsonify({"error": "VIP müşterisi bulunamadı"}), 404

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
