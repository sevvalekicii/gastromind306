# Menu Routes
from flask import Blueprint, jsonify
from models.database import execute_query

menu_bp = Blueprint('menu', __name__, url_prefix='/api/menu')

@menu_bp.route('', methods=['GET'])
def get_menu():
    """Menüyü kategori isimleriyle birlikte getir"""
    query = """
    SELECT m.item_id, m.name as Yemek, m.price as Fiyat, 
           c.category_name as Kategori, m.prep_time_minutes as Hazirlanma
    FROM MENUITEMS m
    JOIN CATEGORIES c ON m.category_id = c.category_id
    ORDER BY m.price DESC
    """
    data = execute_query(query)
    if data:
        return jsonify(data)
    else:
        return jsonify({"error": "Menü alınamadı"}), 500

@menu_bp.route('/category/<int:category_id>', methods=['GET'])
def get_menu_by_category(category_id):
    """Belirli bir kategorideki menü ürünlerini getir"""
    query = """
    SELECT m.item_id, m.name, m.price, c.category_name
    FROM MENUITEMS m
    JOIN CATEGORIES c ON m.category_id = c.category_id
    WHERE m.category_id = %s
    ORDER BY m.price ASC
    """
    data = execute_query(query, (category_id,))
    if data:
        return jsonify(data)
    else:
        return jsonify({"error": "Kategori bulunamadı"}), 404
