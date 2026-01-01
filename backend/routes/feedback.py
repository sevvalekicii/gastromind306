# Feedback Routes
from flask import Blueprint, jsonify, request
from models.database import execute_query, execute_insert_update

feedback_bp = Blueprint('feedback', __name__, url_prefix='/api/feedback')

@feedback_bp.route('', methods=['GET'])
def get_feedback():
    """Tüm geri bildirimleri getir"""
    query = """
    SELECT f.feedback_id, c.full_name, f.rating, f.comment, ds.start_time
    FROM FEEDBACK f
    JOIN DININGSESSIONS ds ON f.session_id = ds.session_id
    JOIN RESERVATIONS r ON ds.reservation_id = r.reservation_id
    JOIN CUSTOMERS c ON r.customer_id = c.customer_id
    ORDER BY ds.start_time DESC
    """
    data = execute_query(query)
    if data:
        return jsonify(data)
    else:
        return jsonify([])

@feedback_bp.route('/rating-summary', methods=['GET'])
def get_rating_summary():
    """Ortalama rating ve istatistikleri getir"""
    query = """
    SELECT COUNT(*) as total_feedback,
           AVG(rating) as avg_rating,
           COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star,
           COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star,
           COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star,
           COUNT(CASE WHEN rating <= 2 THEN 1 END) as low_rating
    FROM FEEDBACK
    """
    data = execute_query(query)
    if data:
        return jsonify(data[0])
    else:
        return jsonify({"error": "İstatistik alınamadı"}), 500

@feedback_bp.route('', methods=['POST'])
def create_feedback():
    """Yeni geri bildirim oluştur"""
    data = request.json
    query = """
    INSERT INTO FEEDBACK (session_id, rating, comment)
    VALUES (%s, %s, %s)
    """
    success = execute_insert_update(query, (
        data['session_id'],
        data['rating'],
        data.get('comment', '')
    ))
    
    if success:
        return jsonify({"message": "Geri bildirim kaydedildi"}), 201
    else:
        return jsonify({"error": "Geri bildirim kaydedilmedi"}), 500
