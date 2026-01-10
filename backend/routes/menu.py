# Menu Routes
from flask import Blueprint, jsonify
from models.database import execute_query

menu_bp = Blueprint('menu', __name__, url_prefix='/api/menu')

@menu_bp.route('', methods=['GET'])
def get_menu():
    """Get menu with category names"""
    query = """
    SELECT m.item_id, 
           COALESCE(m.name, 'Unknown Item') as Yemek, 
           COALESCE(m.price, 0) as Fiyat, 
           COALESCE(c.category_name, 'Uncategorized') as Kategori, 
           COALESCE(m.prep_time_minutes, 0) as Hazirlanma
    FROM MENUITEMS m
    LEFT JOIN CATEGORIES c ON m.category_id = c.category_id
    ORDER BY m.price DESC
    """
    data = execute_query(query)
    # Return empty array if no menu items (not an error)
    return jsonify(data if data is not None else [])

@menu_bp.route('/category/<int:category_id>', methods=['GET'])
def get_menu_by_category(category_id):
    """Get menu items for a specific category"""
    query = """
    SELECT m.item_id, 
           COALESCE(m.name, 'Unknown Item') as name, 
           COALESCE(m.price, 0) as price, 
           COALESCE(c.category_name, 'Uncategorized') as category_name
    FROM MENUITEMS m
    LEFT JOIN CATEGORIES c ON m.category_id = c.category_id
    WHERE m.category_id = %s
    ORDER BY m.price ASC
    """
    data = execute_query(query, (category_id,))
    # Return empty array if no items in category (not necessarily an error)
    return jsonify(data if data is not None else [])

@menu_bp.route('/categories', methods=['GET'])
def get_categories():
    """Get all menu categories"""
    query = """
    SELECT category_id, 
           COALESCE(category_name, 'Uncategorized') as category_name,
           COALESCE(target_margin, 0) as target_margin
    FROM CATEGORIES
    ORDER BY category_id
    """
    data = execute_query(query)
    return jsonify(data if data is not None else [])
