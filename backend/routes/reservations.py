# Reservation Routes
from flask import Blueprint, jsonify, request
from models.database import execute_query, execute_insert_update

reservations_bp = Blueprint('reservations', __name__, url_prefix='/api/reservations')

@reservations_bp.route('', methods=['GET'])
def get_reservations():
    """Get all reservations with customer and table info"""
    query = """
    SELECT r.reservation_id, 
           COALESCE(c.full_name, 'Unknown') as customer_name, 
           r.table_id,
           r.reservation_time, 
           COALESCE(r.party_size, 1) as party_size, 
           COALESCE(r.status, 'Pending') as status
    FROM RESERVATIONS r
    LEFT JOIN CUSTOMERS c ON r.customer_id = c.customer_id
    LEFT JOIN TABLES t ON r.table_id = t.table_id
    ORDER BY r.reservation_time DESC
    """
    data = execute_query(query)
    # Return empty array if no data (not an error)
    return jsonify(data if data is not None else [])

@reservations_bp.route('/pending', methods=['GET'])
def get_pending_reservations():
    """Get pending reservations"""
    query = """
    SELECT r.reservation_id, 
           COALESCE(c.full_name, 'Unknown') as full_name, 
           r.table_id,
           r.reservation_time, 
           COALESCE(r.party_size, 1) as party_size
    FROM RESERVATIONS r
    LEFT JOIN CUSTOMERS c ON r.customer_id = c.customer_id
    LEFT JOIN TABLES t ON r.table_id = t.table_id
    WHERE r.status = 'Pending'
    ORDER BY r.reservation_time ASC
    """
    data = execute_query(query)
    return jsonify(data if data is not None else [])

@reservations_bp.route('/confirmed', methods=['GET'])
def get_confirmed_reservations():
    """Get confirmed reservations"""
    query = """
    SELECT r.reservation_id, 
           COALESCE(c.full_name, 'Unknown') as full_name, 
           r.table_id,
           r.reservation_time, 
           COALESCE(r.party_size, 1) as party_size
    FROM RESERVATIONS r
    LEFT JOIN CUSTOMERS c ON r.customer_id = c.customer_id
    WHERE r.status = 'Confirmed'
    ORDER BY r.reservation_time ASC
    """
    data = execute_query(query)
    return jsonify(data if data is not None else [])

@reservations_bp.route('', methods=['POST'])
def create_reservation():
    """Create a new reservation"""
    data = request.json
    
    # Validate required fields
    if not data:
        return jsonify({"error": "No data provided"}), 400
    
    required_fields = ['customer_id', 'table_id', 'reservation_time', 'party_size']
    for field in required_fields:
        if field not in data or data[field] is None:
            return jsonify({"error": f"Missing required field: {field}"}), 400
    
    # Validate party_size is positive
    if int(data['party_size']) < 1:
        return jsonify({"error": "Party size must be at least 1"}), 400
    
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
        return jsonify({"message": "Reservation created successfully"}), 201
    else:
        return jsonify({"error": "Failed to create reservation"}), 500

@reservations_bp.route('/<int:reservation_id>', methods=['PUT'])
def update_reservation_status(reservation_id):
    """Update reservation status"""
    data = request.json
    
    if not data or 'status' not in data:
        return jsonify({"error": "Status is required"}), 400
    
    valid_statuses = ['Pending', 'Confirmed', 'Completed', 'Cancelled', 'No-Show']
    if data['status'] not in valid_statuses:
        return jsonify({"error": f"Invalid status. Must be one of: {', '.join(valid_statuses)}"}), 400
    
    query = "UPDATE RESERVATIONS SET status = %s WHERE reservation_id = %s"
    success = execute_insert_update(query, (data['status'], reservation_id))
    
    if success:
        return jsonify({"message": "Reservation updated successfully"})
    else:
        return jsonify({"error": "Failed to update reservation"}), 500
