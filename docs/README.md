# 🍽️ GastroMind - Restoran Yönetim Sistemi

**Grup Projesi | COMP 306: Database Management Systems**

---

## 📋 Proje Açıklaması

GastroMind, yüksek-kaliteli bir restoran zincirinin işletmesini yönetmek için tasarlanmış kapsamlı bir **DBMS-powered yazılım sistemidir**. Proje, müşteri yönetimi, menü yönetimi, rezervasyon sistemi, sipariş yönetimi ve gelişmiş raporlama özellikleri sunmaktadır.

**Tema:** Milli futbol takımını (15 oyuncu) müşteri olarak kullanan premium bir restoran.

---

## 🏗️ Proje Yapısı

```
gastromind/
├── backend/                    # Flask Backend
│   ├── app.py                 # Main application
│   ├── config.py              # Database configuration
│   ├── requirements.txt        # Python dependencies
│   ├── routes/                # API endpoints
│   │   ├── menu.py            # Menu operations
│   │   ├── customers.py       # Customer management
│   │   ├── reservations.py    # Reservation system
│   │   ├── orders.py          # Order management
│   │   ├── reports.py         # Advanced queries (5 sophisticated)
│   │   └── feedback.py        # Feedback system
│   └── models/
│       └── database.py        # Database utilities
│
├── frontend/                   # Web Frontend (HTML/CSS/JS)
│   ├── index.html             # Main page
│   ├── css/style.css          # Styling
│   ├── js/script.js           # Frontend logic
│   └── pages/                 # Additional pages (future)
│
├── database/                   # Database files
│   ├── gastromind.sql         # Schema + sample data
│   └── ER_DIAGRAM.pdf         # ER diagram (to be created)
│
└── docs/                       # Documentation
    ├── README.md              # This file
    ├── API_DOCUMENTATION.md   # API endpoints
    └── TASK_DISTRIBUTION.md   # Team task assignments
```

---

## 📊 Grading Criteria Alignment

| Kriter | Durum | Açıklama |
|--------|-------|----------|
| **[2%] ER & Relational Design** | ✅ | 13 tablo, multiple relationships, PK/FK constraints |
| **[1%] Database Population** | ✅ | 15 müşteri + realistic data |
| **[3%] Advanced SQL Queries** | ✅ | 5 sophisticated queries integrated |
| **[4%] Working Prototype** | 🔄 | Professional GUI + Backend connection |

---

## 🔧 Kurulum Talimatları

### Ön Koşullar
- Python 3.9+
- MySQL Server (localhost:3306)
- Node.js (optional, for frontend enhancements)

### Adım 1: MySQL Database Kurulumu

**⚠️ ÖNEMLİ: MySQL'de kullanıcı adı ve şifre ayarlarını kontrol edin!**

```bash
# MySQL Workbench'te çalıştır veya:
mysql -u root -p < database/gastromind.sql
# Şifrenizi girin
```

### Adım 2: Backend Kurulumu

**⚠️ ÖNEMLİ: `backend/config.py` dosyasında MySQL şifrenizi güncelleyin!**

```bash
cd backend

# config.py dosyasını düzenle:
# DB_CONFIG['password'] = 'SENIN_MYSQL_SIFREN'

pip install -r requirements.txt
python app.py
```

Backend şu adreste başlayacak: `http://localhost:5000`

### Adım 3: Frontend Açma

`frontend/index.html` dosyasını web tarayıcısında aç (veya Live Server kullan VS Code'da).

---

## 📡 API Endpoints

### Base URL: `http://localhost:5000/api`

#### Menu Routes
- `GET /menu` - Tüm menüyü getir
- `GET /menu/category/<id>` - Kategoriye göre menü

#### Customer Routes
- `GET /customers` - Tüm müşteriler
- `GET /customers/vip` - VIP müşteriler
- `GET /customers/dietary/<id>` - Müşterinin diyet kısıtlamaları

#### Reservation Routes
- `GET /reservations` - Tüm rezervasyonlar
- `GET /reservations/pending` - Beklemede olan rezervasyonlar
- `POST /reservations` - Yeni rezervasyon (JSON body gerekli)

#### Order Routes
- `GET /orders` - Tüm siparişler
- `GET /orders/<id>/details` - Sipariş detayları
- `POST /orders` - Yeni sipariş

#### Reports (Advanced Queries)
- `GET /reports/top-customer-orders` - En çok harcayan müşterinin siparişleri
- `GET /reports/category-revenue` - Kategorilere göre satış analizi
- `GET /reports/customer-spending` - Müşteri başına harcama analizi
- `GET /reports/customer-classification` - Müşteri sınıflandırması (Platinum/Gold/Silver)
- `GET /reports/table-performance` - Masa performans analizi

#### Feedback Routes
- `GET /feedback` - Tüm geri bildirimler
- `GET /feedback/rating-summary` - Rating istatistikleri
- `POST /feedback` - Yeni geri bildirim

---

## 🔍 Advanced SQL Queries (5 Sophisticated)

### 1. **Nested Query**: En Çok Harcayan Müşterinin Siparişleri
```sql
SELECT * FROM ORDERS WHERE session_id IN (
  SELECT session_id FROM DININGSESSIONS WHERE reservation_id IN (
    SELECT reservation_id FROM RESERVATIONS WHERE customer_id = 
      (SELECT customer_id FROM CUSTOMERS ORDER BY total_ltv DESC LIMIT 1)
  )
)
```

### 2. **GROUP BY - HAVING**: Kategorilere Göre Satış
```sql
SELECT category_name, SUM(price * quantity) as revenue
FROM ORDERDETAILS od
JOIN MENUITEMS m ON od.item_id = m.item_id
JOIN CATEGORIES c ON m.category_id = c.category_id
GROUP BY c.category_id
HAVING SUM(price * quantity) > 500
```

### 3. **Complex JOIN + Aggregation**: Müşteri Harcamaları
```sql
SELECT customer_id, COUNT(session_id) as visits,
       SUM(total_amount) as spent
FROM CUSTOMERS
LEFT JOIN RESERVATIONS ON customer_id = customer_id
LEFT JOIN DININGSESSIONS ON reservation_id = reservation_id
GROUP BY customer_id
```

### 4. **CASE Statement**: Müşteri Sınıflandırması
```sql
SELECT full_name, total_ltv,
  CASE 
    WHEN total_ltv > 40000 THEN 'Platinum'
    WHEN total_ltv > 10000 THEN 'Gold'
    ELSE 'Regular'
  END as tier
FROM CUSTOMERS
```

### 5. **Complex Analysis**: Masa Performansı
```sql
SELECT table_id, COUNT(session_id) as bookings,
       AVG(total_amount) as avg_revenue
FROM RESERVATIONS
LEFT JOIN DININGSESSIONS ON reservation_id = reservation_id
GROUP BY table_id
ORDER BY avg_revenue DESC
```

---

## 📝 Database Schema Özeti

### Tablolar (13)
1. **CUSTOMERS** - Müşteri bilgileri
2. **DIETARYRESTRICTIONS** - Diyet kısıtlamaları
3. **TABLES** - Restoran masaları
4. **TABLECOMBINATIONS** - Masa birleştirmeleri
5. **STAFF** - Personel
6. **SHIFTSCHEDULES** - Vardiya programı
7. **CATEGORIES** - Menü kategorileri
8. **MENUITEMS** - Menü ürünleri
9. **RESERVATIONS** - Rezervasyonlar
10. **DININGSESSIONS** - Yemek oturumları
11. **ORDERS** - Siparişler
12. **ORDERDETAILS** - Sipariş detayları
13. **FEEDBACK** - Müşteri geri bildirimleri

---

## 🎯 Development Roadmap

- [ ] Database kurulumu ve test
- [x] Backend API endpoints
- [x] Frontend basic interface
- [ ] Frontend ↔ Backend integration test
- [ ] ER Diagram çizmek
- [ ] Advanced features (filtering, pagination)
- [ ] Error handling improvements
- [ ] Project report yazımı
- [ ] Demo Day presentation

---

## 🚀 Çalıştırma Checklist

### Sunucuları Başlat
```bash
# Terminal 1: Backend
cd backend
python app.py

# Terminal 2: Frontend (basit HTTP server)
cd frontend
python -m http.server 8000
```

### Tarayıcı
- Frontend: `http://localhost:8000`
- Backend Health: `http://localhost:5000/health`

### Test API Endpoints
```bash
# Menüyü test et
curl http://localhost:5000/api/menu

# Müşterileri test et
curl http://localhost:5000/api/customers

# Reports test et
curl http://localhost:5000/api/reports/customer-spending
```

---

## 📚 Kaynaklar

- [Flask Documentation](https://flask.palletsprojects.com/)
- [MySQL Python Connector](https://dev.mysql.com/doc/connector-python/en/)
- [REST API Best Practices](https://restfulapi.net/)

---

**Son Güncelleme:** 1 Ocak 2026
**Proje Durumu:** 🔄 Development
**Demo Day:** Finalin 2. Haftası (Zoom)
