# Database Configuration - EXAMPLE FILE
# Copy this file to config.py and update with your MySQL credentials

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'YOUR_MYSQL_PASSWORD_HERE',
    'database': 'GastroMind_DB',
    'unix_socket': '/tmp/mysql.sock'  # May need to adjust based on your MySQL setup
}

# Flask Config
FLASK_ENV = 'development'
DEBUG = True
TESTING = False
