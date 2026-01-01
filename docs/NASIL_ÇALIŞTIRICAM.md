# 1. MySQL'de database oluştur
mysql -u root -p < database/gastromind.sql

# 2. Config'i düzenle
# backend/config.py → password'ü değiştir

# 3. Dependencies yükle
cd backend
pip install -r requirements.txt

# 4. Backend başlat
python app.py

# 5. Frontend başlat (yeni terminal)
cd ../frontend
python -m http.server 8000

# 6. Tarayıcıda aç
http://localhost:8000