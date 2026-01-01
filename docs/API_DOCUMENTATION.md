# 📡 GastroMind API Documentation

**Base URL:** `http://localhost:5000/api`

---

## 🏠 Health Check

### `GET /health`
Backend'in çalışıp çalışmadığını kontrol et.

**Response:**
```json
{
  "status": "healthy"
}
```

---

## 📖 Menu API

### `GET /menu`
Tüm menü ürünlerini kategorileriyle birlikte getir.

**Response:**
```json
[
  {
    "item_id": 1,
    "Yemek": "Dana Carpaccio",
    "Fiyat": 450.00,
    "Kategori": "Başlangıçlar",
    "Hazirlanma": 10
  },
  ...
]
```

### `GET /menu/category/<category_id>`
Belirli bir kategorideki ürünleri getir.

**Parameters:**
- `category_id` (int): Kategori ID'si

**Example:** `/menu/category/2`

**Response:**
```json
[
  {
    "item_id": 3,
    "name": "Wagyu Burger",
    "price": 950.00,
    "category_name": "Ana Yemek (Et)"
  },
  ...
]
```

---

## 👥 Customers API

### `GET /customers`
Tüm müşterileri VIP statusuna göre sıralanmış şekilde getir.

**Response:**
```json
[
  {
    "customer_id": 1,
    "full_name": "Hakan Çalhanoğlu",
    "phone": "532-101-1010",
    "email": "hakan.c@tff.org",
    "total_ltv": 45000.00,
    "vip_status": true
  },
  ...
]
```

### `GET /customers/vip`
Sadece VIP müşterileri getir.

**Response:**
```json
[
  {
    "customer_id": 1,
    "full_name": "Hakan Çalhanoğlu",
    "phone": "532-101-1010",
    "email": "hakan.c@tff.org",
    "total_ltv": 45000.00
  },
  ...
]
```

### `GET /customers/dietary/<customer_id>`
Müşterinin diyet kısıtlamalarını getir.

**Parameters:**
- `customer_id` (int): Müşteri ID'si

**Response:**
```json
[
  {
    "restriction_id": 1,
    "restriction_type": "Gluten Free"
  }
]
```

---

## 📅 Reservations API

### `GET /reservations`
Tüm rezervasyonları getir.

**Response:**
```json
[
  {
    "reservation_id": 1,
    "customer_name": "Hakan Çalhanoğlu",
    "table_id": 3,
    "reservation_time": "2025-12-15 20:00:00",
    "party_size": 8,
    "status": "Completed"
  },
  ...
]
```

### `GET /reservations/pending`
Beklemede olan (Pending) rezervasyonları getir.

**Response:**
```json
[
  {
    "reservation_id": 5,
    "customer_name": "Cenk Tosun",
    "table_id": 5,
    "reservation_time": "2026-01-10 19:00:00",
    "party_size": 6
  }
]
```

### `POST /reservations`
Yeni bir rezervasyon oluştur.

**Request Body:**
```json
{
  "customer_id": 3,
  "table_id": 5,
  "reservation_time": "2026-01-15 19:30:00",
  "party_size": 4
}
```

**Response (Success):**
```json
{
  "message": "Rezervasyon oluşturuldu"
}
```
**Status Code:** 201

---

## 🛒 Orders API

### `GET /orders`
Tüm siparişleri getir.

**Response:**
```json
[
  {
    "order_id": 1,
    "session_id": 1,
    "customer_name": "Hakan Çalhanoğlu",
    "order_time": "2025-12-15 20:30:00",
    "item_count": 5
  },
  ...
]
```

### `GET /orders/<order_id>/details`
Sipariş detaylarını getir.

**Parameters:**
- `order_id` (int): Sipariş ID'si

**Response:**
```json
[
  {
    "detail_id": 1,
    "item_name": "Dana Carpaccio",
    "quantity": 4,
    "price": 450.00,
    "total_price": 1800.00,
    "special_note": "Ortaya paylaşımlı"
  },
  ...
]
```

### `POST /orders`
Yeni sipariş oluştur.

**Request Body:**
```json
{
  "session_id": 1,
  "staff_id": 4
}
```

**Response (Success):**
```json
{
  "message": "Sipariş oluşturuldu"
}
```
**Status Code:** 201

---

## 📊 Reports API (Advanced Queries)

### `GET /reports/top-customer-orders`
**Sophisticated Query 1 (Nested Query):** En çok harcayan müşterinin siparişlerini getir.

**Response:**
```json
[
  {
    "order_id": 1,
    "full_name": "Hakan Çalhanoğlu",
    "session_id": 1,
    "order_time": "2025-12-15 20:30:00",
    "total_amount": 16500.00
  },
  ...
]
```

---

### `GET /reports/category-revenue`
**Sophisticated Query 2 (GROUP BY - HAVING):** Her kategorinin toplam satışı ve sipariş sayısı.

**Response:**
```json
[
  {
    "category_name": "Ana Yemek (Et)",
    "total_revenue": 8100.00,
    "order_count": 2,
    "avg_order_value": "4050.00"
  },
  ...
]
```

---

### `GET /reports/customer-spending`
**Sophisticated Query 3 (Complex JOIN + Aggregation):** Müşteri başına harcama analizi.

**Response:**
```json
[
  {
    "customer_id": 1,
    "full_name": "Hakan Çalhanoğlu",
    "vip_status": true,
    "visit_count": 1,
    "total_spent": 16500.00,
    "avg_per_visit": "16500.00",
    "last_visit": "2025-12-15 23:30:00"
  },
  ...
]
```

---

### `GET /reports/customer-classification`
**Sophisticated Query 4 (CASE Statement):** Müşteri sınıflandırması (Platinum/Gold/Silver/Regular).

**Response:**
```json
[
  {
    "customer_id": 1,
    "full_name": "Hakan Çalhanoğlu",
    "vip_status": true,
    "total_ltv": 45000.00,
    "customer_tier": "Platinum"
  },
  {
    "customer_id": 2,
    "full_name": "Arda Güler",
    "vip_status": true,
    "total_ltv": 22000.00,
    "customer_tier": "Gold"
  },
  ...
]
```

---

### `GET /reports/table-performance`
**Sophisticated Query 5 (Complex JOIN + Analysis):** Masa performans analizi.

**Response:**
```json
[
  {
    "table_id": 3,
    "capacity": 4,
    "location_zone": "Salon Merkez",
    "total_bookings": 1,
    "completed_sessions": 1,
    "avg_revenue": "16500.00",
    "total_revenue": 16500.00,
    "completion_rate": "100.0"
  },
  ...
]
```

---

## ⭐ Feedback API

### `GET /feedback`
Tüm geri bildirimleri getir.

**Response:**
```json
[
  {
    "feedback_id": 1,
    "full_name": "Hakan Çalhanoğlu",
    "rating": 5,
    "comment": "Milli takım olarak çok iyi ağırlandık.",
    "start_time": "2025-12-15 20:15:00"
  },
  ...
]
```

### `GET /feedback/rating-summary`
Rating istatistiklerini getir.

**Response:**
```json
{
  "total_feedback": 2,
  "avg_rating": 4.5,
  "five_star": 1,
  "four_star": 1,
  "three_star": 0,
  "low_rating": 0
}
```

### `POST /feedback`
Yeni geri bildirim oluştur.

**Request Body:**
```json
{
  "session_id": 1,
  "rating": 5,
  "comment": "Harika bir deneyim!"
}
```

**Response (Success):**
```json
{
  "message": "Geri bildirim kaydedildi"
}
```
**Status Code:** 201

---

## ❌ Error Responses

### 404 Not Found
```json
{
  "error": "Endpoint bulunamadı"
}
```

### 500 Server Error
```json
{
  "error": "Sunucu hatası"
}
```

### 400 Bad Request
```json
{
  "error": "Geçersiz istek parametreleri"
}
```

---

## 🧪 Test Commands

### cURL ile API Test

```bash
# Menüyü getir
curl http://localhost:5000/api/menu

# Müşterileri getir
curl http://localhost:5000/api/customers

# VIP müşterileri getir
curl http://localhost:5000/api/customers/vip

# Tüm raporları getir
curl http://localhost:5000/api/reports/customer-spending
curl http://localhost:5000/api/reports/category-revenue
curl http://localhost:5000/api/reports/customer-classification
curl http://localhost:5000/api/reports/table-performance
curl http://localhost:5000/api/reports/top-customer-orders

# Health check
curl http://localhost:5000/health
```

### Postman ile Test
1. Postman'i aç
2. Base URL: `http://localhost:5000/api`
3. Endpoints'i test et

---

**Last Updated:** 1 Ocak 2026
