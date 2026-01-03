# Advanced Reports/Queries Routes
# 5 Sophisticated SQL Queries
from flask import Blueprint, jsonify
from models.database import execute_query

reports_bp = Blueprint('reports', __name__, url_prefix='/api/reports')

# 1. NESTED QUERY: En çok harcayan müşterinin tüm siparişlerini getir
@reports_bp.route('/top-customer-orders', methods=['GET'])
def get_top_customer_orders():
    """En yüksek tutarlı dining session'ı getir"""
    query = """
    SELECT ds.session_id, c.full_name, ds.total_amount, ds.start_time
    FROM DININGSESSIONS ds
    JOIN RESERVATIONS r ON ds.reservation_id = r.reservation_id
    JOIN CUSTOMERS c ON r.customer_id = c.customer_id
    ORDER BY ds.total_amount DESC LIMIT 1
    """
    data = execute_query(query)
    return jsonify(data if data else [])

# 2. GROUP BY - HAVING: Kategorilerin toplam satış ve sipariş sayısı (500 TL üzeri)
@reports_bp.route('/category-revenue', methods=['GET'])
def get_category_revenue():
    """Her kategorinin toplam satışını ve sipariş sayısını getir"""
    query = """
    SELECT c.category_name, 
           SUM(m.price * od.quantity) as total_revenue,
           COUNT(DISTINCT o.order_id) as order_count,
           ROUND(AVG(m.price * od.quantity), 2) as avg_order_value
    FROM ORDERDETAILS od
    JOIN MENUITEMS m ON od.item_id = m.item_id
    JOIN CATEGORIES c ON m.category_id = c.category_id
    JOIN ORDERS o ON od.order_id = o.order_id
    GROUP BY c.category_id, c.category_name
    HAVING SUM(m.price * od.quantity) > 0
    ORDER BY total_revenue DESC
    """
    data = execute_query(query)
    return jsonify(data if data else [])

# 3. COMPLEX JOIN + AGGREGATION: Müşteri başına harcanan toplam
@reports_bp.route('/customer-spending', methods=['GET'])
def get_customer_spending():
    """Müşteri başına toplam harcama, ziyaret sayısı ve ortalama"""
    query = """
    SELECT cust.customer_id, cust.full_name, cust.vip_status,
           COUNT(ds.session_id) as visit_count,
           SUM(ds.total_amount) as total_spent,
           ROUND(AVG(ds.total_amount), 2) as avg_per_visit,
           DATE_FORMAT(MAX(ds.start_time), '%Y-%m-%d') as last_visit
    FROM CUSTOMERS cust
    LEFT JOIN RESERVATIONS res ON cust.customer_id = res.customer_id
    LEFT JOIN DININGSESSIONS ds ON res.reservation_id = ds.reservation_id
    WHERE ds.session_id IS NOT NULL
    GROUP BY cust.customer_id, cust.full_name, cust.vip_status
    ORDER BY total_spent DESC
    """
    data = execute_query(query)
    return jsonify(data if data else [])

# 4. CASE STATEMENT: Müşteri sınıflandırması (Platinum, Gold, Regular, Inactive)
@reports_bp.route('/customer-classification', methods=['GET'])
def classify_customers():
    """Müşterileri harcamalarına göre sınıflandır"""
    query = """
    SELECT customer_id, full_name, vip_status, total_ltv,
           CASE 
              WHEN total_ltv > 40000 AND vip_status = TRUE THEN 'Platinum'
              WHEN total_ltv > 10000 AND vip_status = TRUE THEN 'Gold'
              WHEN total_ltv > 1000 THEN 'Silver'
              WHEN total_ltv > 0 THEN 'Regular'
              ELSE 'Inactive'
           END as customer_tier
    FROM CUSTOMERS
    ORDER BY total_ltv DESC
    """
    data = execute_query(query)
    return jsonify(data if data else [])

# 5. COMPLEX JOIN: Masa performansı (kapasitesi, rezervasyon sayısı, ortalama ciro)
@reports_bp.route('/table-performance', methods=['GET'])
def get_table_performance():
    """Her masanın performansını analiz et"""
    query = """
    SELECT t.table_id, t.capacity, t.location_zone,
           COUNT(r.reservation_id) as total_bookings,
           COUNT(ds.session_id) as completed_sessions,
           ROUND(AVG(ds.total_amount), 2) as avg_revenue,
           SUM(ds.total_amount) as total_revenue,
           ROUND(COUNT(ds.session_id) / COUNT(r.reservation_id) * 100, 1) as completion_rate
    FROM TABLES t
    LEFT JOIN RESERVATIONS r ON t.table_id = r.table_id
    LEFT JOIN DININGSESSIONS ds ON r.reservation_id = ds.reservation_id
    GROUP BY t.table_id, t.capacity, t.location_zone
    ORDER BY total_revenue DESC
    """
    data = execute_query(query)
    return jsonify(data if data else [])

# 6: Her müşterinin ilk ve son ziyareti + aradaki gün farkı
@reports_bp.route('/customer-first-last-visit', methods=['GET'])
def get_customer_first_last_visit():
    """Her müşterinin ilk ve son ziyareti + aradaki gün farkı"""
    query = """
    SELECT cust.customer_id,
        cust.full_name,
        MIN(ds.start_time) AS first_visit,
        MAX(ds.start_time) AS last_visit,
        DATEDIFF(MAX(ds.start_time), MIN(ds.start_time)) AS customer_lifetime_days
    FROM CUSTOMERS cust
    JOIN RESERVATIONS r ON cust.customer_id = r.customer_id
    JOIN DININGSESSIONS ds ON r.reservation_id = ds.reservation_id
    GROUP BY cust.customer_id, cust.full_name;

    """
    data = execute_query(query)
    return jsonify(data if data else [])

# 7. GROUP BY - HAVING: En çok sipariş edilen menü öğeleri (Top 10)
@reports_bp.route('/top-menu-items', methods=['GET'])
def get_top_menu_items():
    """En çok sipariş edilen menü öğelerini getir (top 10)"""
    query = """
    SELECT m.name AS item_name,
           c.category_name,
           SUM(od.quantity) AS total_quantity,
           COUNT(DISTINCT o.order_id) AS order_count,
           ROUND(AVG(m.price), 2) AS avg_price
    FROM ORDERDETAILS od
    JOIN MENUITEMS m ON od.item_id = m.item_id
    JOIN CATEGORIES c ON m.category_id = c.category_id
    JOIN ORDERS o ON od.order_id = o.order_id
    GROUP BY m.item_id, m.name, c.category_name
    HAVING SUM(od.quantity) > 0
    ORDER BY total_quantity DESC
    LIMIT 10
    """
    data = execute_query(query)
    return jsonify(data if data else [])

# 8. NESTED QUERY + GROUP BY: Personel satış performansı
@reports_bp.route('/staff-performance', methods=['GET'])
def get_staff_performance():
    """Her personelin toplam sipariş sayısı ve cirosu"""
    query = """
    SELECT s.staff_id, s.name, s.role,
           COUNT(DISTINCT o.order_id) AS total_orders,
           SUM(ds.total_amount) AS total_revenue,
           ROUND(AVG(ds.total_amount), 2) AS avg_order_value
    FROM STAFF s
    LEFT JOIN ORDERS o ON s.staff_id = o.staff_id
    LEFT JOIN DININGSESSIONS ds ON o.session_id = ds.session_id
    WHERE s.role IN ('Garson', 'Host')
    GROUP BY s.staff_id, s.name, s.role
    HAVING COUNT(DISTINCT o.order_id) > 0
    ORDER BY total_revenue DESC
    """
    data = execute_query(query)
    return jsonify(data if data else [])

# 9. GROUP BY - HAVING: Günlük ciro raporu
@reports_bp.route('/daily-revenue', methods=['GET'])
def get_daily_revenue():
    """Tarihe göre günlük toplam ciro"""
    query = """
    SELECT DATE(ds.start_time) AS date,
           COUNT(DISTINCT ds.session_id) AS total_sessions,
           SUM(ds.total_amount) AS daily_revenue,
           ROUND(AVG(ds.total_amount), 2) AS avg_session_revenue
    FROM DININGSESSIONS ds
    GROUP BY DATE(ds.start_time)
    HAVING SUM(ds.total_amount) > 0
    ORDER BY date DESC
    """
    data = execute_query(query)
    return jsonify(data if data else [])

# 10. NESTED QUERY: Rezervasyon durumu analizi
@reports_bp.route('/reservation-status-analysis', methods=['GET'])
def get_reservation_status_analysis():
    """Rezervasyon durumlarına göre analiz"""
    query = """
    SELECT r.status,
           COUNT(*) AS total_reservations,
           ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM RESERVATIONS), 2) AS percentage,
           AVG(r.party_size) AS avg_party_size
    FROM RESERVATIONS r
    GROUP BY r.status
    ORDER BY total_reservations DESC
    """
    data = execute_query(query)
    return jsonify(data if data else [])

# 11. COMPLEX JOIN + GROUP BY: Diyet kısıtlamalı müşterilerin tercihleri
@reports_bp.route('/dietary-preferences', methods=['GET'])
def get_dietary_preferences():
    """Diyet kısıtlamalı müşterilerin en çok tercih ettikleri kategoriler"""
    query = """
    SELECT dr.restriction_type,
           c.category_name,
           COUNT(DISTINCT od.detail_id) AS total_orders,
           SUM(od.quantity) AS total_quantity
    FROM DIETARYRESTRICTIONS dr
    JOIN CUSTOMERS cust ON dr.customer_id = cust.customer_id
    JOIN RESERVATIONS r ON cust.customer_id = r.customer_id
    JOIN DININGSESSIONS ds ON r.reservation_id = ds.reservation_id
    JOIN ORDERS o ON ds.session_id = o.session_id
    JOIN ORDERDETAILS od ON o.order_id = od.order_id
    JOIN MENUITEMS m ON od.item_id = m.item_id
    JOIN CATEGORIES c ON m.category_id = c.category_id
    GROUP BY dr.restriction_type, c.category_name
    HAVING COUNT(DISTINCT od.detail_id) > 0
    ORDER BY dr.restriction_type, total_orders DESC
    """
    data = execute_query(query)
    return jsonify(data if data else [])