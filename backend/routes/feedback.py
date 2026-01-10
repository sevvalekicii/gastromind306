# Feedback Routes
from flask import Blueprint, jsonify, request
from models.database import execute_query, execute_insert_update

feedback_bp = Blueprint('feedback', __name__, url_prefix='/api/feedback')

@feedback_bp.route('', methods=['GET'])
def get_feedback():
    """Get all feedback with customer info"""
    query = """
    SELECT f.feedback_id, 
           COALESCE(c.full_name, 'Anonymous') as full_name, 
           COALESCE(f.rating, 0) as rating, 
           COALESCE(f.comment, '') as comment, 
           ds.start_time
    FROM FEEDBACK f
    LEFT JOIN DININGSESSIONS ds ON f.session_id = ds.session_id
    LEFT JOIN RESERVATIONS r ON ds.reservation_id = r.reservation_id
    LEFT JOIN CUSTOMERS c ON r.customer_id = c.customer_id
    ORDER BY ds.start_time DESC
    """
    data = execute_query(query)
    return jsonify(data if data is not None else [])

@feedback_bp.route('/rating-summary', methods=['GET'])
def get_rating_summary():
    """Get average rating and statistics"""
    query = """
    SELECT COALESCE(COUNT(*), 0) as total_feedback,
           COALESCE(AVG(rating), 0) as avg_rating,
           COALESCE(COUNT(CASE WHEN rating = 5 THEN 1 END), 0) as five_star,
           COALESCE(COUNT(CASE WHEN rating = 4 THEN 1 END), 0) as four_star,
           COALESCE(COUNT(CASE WHEN rating = 3 THEN 1 END), 0) as three_star,
           COALESCE(COUNT(CASE WHEN rating <= 2 THEN 1 END), 0) as low_rating
    FROM FEEDBACK
    """
    data = execute_query(query)
    if data and len(data) > 0:
        return jsonify(data[0])
    else:
        # Return default values if no feedback exists
        return jsonify({
            "total_feedback": 0,
            "avg_rating": 0,
            "five_star": 0,
            "four_star": 0,
            "three_star": 0,
            "low_rating": 0
        })

@feedback_bp.route('', methods=['POST'])
def create_feedback():
    """Create new feedback"""
    data = request.json
    
    # Validate required fields
    if not data:
        return jsonify({"error": "No data provided"}), 400
    
    if 'session_id' not in data:
        return jsonify({"error": "session_id is required"}), 400
    
    if 'rating' not in data:
        return jsonify({"error": "rating is required"}), 400
    
    # Validate rating is between 1 and 5
    rating = int(data['rating'])
    if rating < 1 or rating > 5:
        return jsonify({"error": "Rating must be between 1 and 5"}), 400
    
    # Check if session exists
    session_check = execute_query(
        "SELECT session_id FROM DININGSESSIONS WHERE session_id = %s", 
        (data['session_id'],)
    )
    if not session_check:
        return jsonify({"error": "Invalid session_id - session does not exist"}), 400
    
    query = """
    INSERT INTO FEEDBACK (session_id, rating, comment)
    VALUES (%s, %s, %s)
    """
    success = execute_insert_update(query, (
        data['session_id'],
        rating,
        data.get('comment', '')
    ))
    
    if success:
        return jsonify({"message": "Feedback saved successfully"}), 201
    else:
        return jsonify({"error": "Failed to save feedback"}), 500
