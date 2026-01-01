# Database Connection Module
import mysql.connector
from config import DB_CONFIG

def get_db_connection():
    """Database bağlantısı oluştur"""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except mysql.connector.Error as err:
        print(f"Veritabanı Hatası: {err}")
        return None

def execute_query(query, params=None):
    """Query'yi execute et ve sonuç döndür"""
    conn = get_db_connection()
    if not conn:
        return None
    
    try:
        cursor = conn.cursor(dictionary=True)
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        result = cursor.fetchall()
        conn.close()
        return result
    except mysql.connector.Error as err:
        print(f"Query Hatası: {err}")
        return None

def execute_insert_update(query, params=None):
    """INSERT/UPDATE/DELETE işlemleri için"""
    conn = get_db_connection()
    if not conn:
        return False
    
    try:
        cursor = conn.cursor()
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        conn.commit()
        conn.close()
        return True
    except mysql.connector.Error as err:
        print(f"Insert/Update Hatası: {err}")
        return False
