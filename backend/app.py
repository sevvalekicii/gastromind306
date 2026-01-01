# Main Flask Application
from flask import Flask, jsonify
from flask_cors import CORS
from decimal import Decimal
import json

# Import Routes
from routes.menu import menu_bp
from routes.customers import customers_bp
from routes.reservations import reservations_bp
from routes.orders import orders_bp
from routes.reports import reports_bp
from routes.feedback import feedback_bp

app = Flask(__name__)
CORS(app)  # Frontend'den API çağrıları için

# JSON Encoder - Decimal'ı float'a çevir
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super().default(obj)

app.json_encoder = DecimalEncoder

# --- ROUTES REGISTER ---
app.register_blueprint(menu_bp)
app.register_blueprint(customers_bp)
app.register_blueprint(reservations_bp)
app.register_blueprint(orders_bp)
app.register_blueprint(reports_bp)
app.register_blueprint(feedback_bp)

# --- HOME ENDPOINT ---
@app.route('/')
def home():
    return jsonify({
        "message": "GastroMind Backend Çalışıyor! 🍽️",
        "version": "1.0",
        "endpoints": {
            "menu": "/api/menu",
            "customers": "/api/customers",
            "reservations": "/api/reservations",
            "orders": "/api/orders",
            "reports": "/api/reports",
            "feedback": "/api/feedback"
        }
    })

@app.route('/health', methods=['GET'])
def health_check():
    """API sağlık kontrolü"""
    return jsonify({"status": "healthy"}), 200

# --- ERROR HANDLERS ---
@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Endpoint bulunamadı"}), 404

@app.errorhandler(500)
def server_error(error):
    return jsonify({"error": "Sunucu hatası"}), 500

# --- SUNUCUYU BAŞLAT ---
if __name__ == '__main__':
    print("GastroMind Backend başlatılıyor...")
    print("http://localhost:5000 adresinde erişebilirsiniz")
    app.run(debug=True, host='0.0.0.0', port=5000)
