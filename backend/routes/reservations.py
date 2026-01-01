# Reservation Routes
from flask import Blueprint, jsonify, request
from models.database import execute_query, execute_insert_update

reservations_bp = Blueprint('reservations', __name__, url_prefix='/api/reservations')

@reservations_bp.route('', methods=['GET'])
def get_reservations():
    """Tüm rezervasyonları getir"""
    query = """
    SELECT r.reservation_id, c.full_name as customer_name, t.table_id,
           r.reservation_time, r.party_size, r.status
    FROM RESERVATIONS r
    JOIN CUSTOMERS c ON r.customer_id = c.customer_id
    JOIN TABLES t ON r.table_id = t.table_id
    ORDER BY r.reservation_time DESC
    """
    data = execute_query(query)
    if data:
        return jsonify(data)
    else:
        return jsonify({"error": "Rezervasyon alınamadı"}), 500

@reservations_bp.route('/pending', methods=['GET'])
def get_pending_reservations():
    """Beklemede olan rezervasyonları getir"""
    query = """
    SELECT r.reservation_id, c.full_name, t.table_id,
           r.reservation_time, r.party_size
    FROM RESERVATIONS r
    JOIN CUSTOMERS c ON r.customer_id = c.customer_id
    JOIN TABLES t ON r.table_id = t.table_id
    WHERE r.status = 'Pending'
    ORDER BY r.reservation_time ASC
    """
    data = execute_query(query)
    if data:
        return jsonify(data)
    else:
        return jsonify([])

@reservations_bp.route('', methods=['POST'])
def create_reservation():
    """Yeni rezervasyon oluştur"""
    data = request.json
    query = """
    INSERT INTO RESERVATIONS (customer_id, table_id, reservation_time, party_size, status)
    VALUES (%s, %s, %s, %s, 'Pending')
    """
    success = execute_insert_update(query, (
        data['customer_id'],
        data['table_id'],
        data['reservation_time'],
        data['party_size']
    ))
    
    if success:
        return jsonify({"message": "Rezervasyon oluşturuldu"}), 201
    else:
        return jsonify({"error": "Rezervasyon oluşturulamadı"}), 500
