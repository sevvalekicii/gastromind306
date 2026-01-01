-- 1. TEMİZLİK VE KURULUM
DROP DATABASE IF EXISTS GastroMind_DB;
CREATE DATABASE GastroMind_DB;
USE GastroMind_DB;

-- ---------------------------------------------------------
-- 2. TABLO TASARIMLARI (SCHEMA)
-- ---------------------------------------------------------

CREATE TABLE CUSTOMERS (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    total_ltv DECIMAL(10, 2) DEFAULT 0.00,
    vip_status BOOLEAN DEFAULT FALSE
);

CREATE TABLE DIETARYRESTRICTIONS (
    restriction_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    restriction_type VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

CREATE TABLE TABLES (
    table_id INT AUTO_INCREMENT PRIMARY KEY,
    capacity INT NOT NULL,
    location_zone VARCHAR(50),
    is_combinable BOOLEAN DEFAULT FALSE
);

-- HOCANIN DİKKAT EDECEĞİ TABLO: MASA BİRLEŞTİRME
CREATE TABLE TABLECOMBINATIONS (
    combination_id INT AUTO_INCREMENT PRIMARY KEY,
    parent_table_id INT,
    child_table_id INT,
    FOREIGN KEY (parent_table_id) REFERENCES TABLES(table_id),
    FOREIGN KEY (child_table_id) REFERENCES TABLES(table_id)
);

CREATE TABLE STAFF (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50),
    hire_date DATE
);

CREATE TABLE SHIFTSCHEDULES (
    shift_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT,
    shift_start DATETIME,
    shift_end DATETIME,
    FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id)
);

CREATE TABLE CATEGORIES (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    target_margin DECIMAL(5, 2)
);

CREATE TABLE MENUITEMS (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    prep_time_minutes INT,
    FOREIGN KEY (category_id) REFERENCES CATEGORIES(category_id)
);

CREATE TABLE RESERVATIONS (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    table_id INT,
    reservation_time DATETIME NOT NULL,
    party_size INT,
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (table_id) REFERENCES TABLES(table_id)
);

CREATE TABLE DININGSESSIONS (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT,
    start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME,
    total_amount DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS(reservation_id)
);

CREATE TABLE ORDERS (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT,
    staff_id INT,
    order_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES DININGSESSIONS(session_id),
    FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id)
);

CREATE TABLE ORDERDETAILS (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    item_id INT,
    quantity INT DEFAULT 1,
    special_note VARCHAR(255),
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
    FOREIGN KEY (item_id) REFERENCES MENUITEMS(item_id)
);

CREATE TABLE FEEDBACK (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT,
    rating INT,
    comment TEXT,
    FOREIGN KEY (session_id) REFERENCES DININGSESSIONS(session_id)
);

-- ---------------------------------------------------------
-- VERİ GİRİŞLERİ (INSERT DATA)
-- ---------------------------------------------------------

-- 1. MÜŞTERİLER (SENİN LİSTEN)
INSERT INTO CUSTOMERS (full_name, phone, email, total_ltv, vip_status) VALUES
('Hakan Çalhanoğlu', '532-101-1010', 'hakan.c@tff.org', 45000.00, TRUE),   -- ID: 1
('Arda Güler', '532-102-2020', 'arda.guler@realmadrid.com', 22000.00, TRUE), -- ID: 2
('Cenk Tosun', '533-103-3030', 'cenk.tosun@bjk.com', 15000.00, TRUE),      -- ID: 3
('Mert Günok', '542-104-4040', 'mert.gunok@bjk.com', 12500.00, TRUE),      -- ID: 4
('Kerem Aktürkoğlu', '555-201-5050', 'kerem@benfica.pt', 8500.00, FALSE),  -- ID: 5
('Ferdi Kadıoğlu', '535-202-6060', 'ferdi@brighton.uk', 9200.00, TRUE),    -- ID: 6
('Barış Alper Yılmaz', '536-203-7070', 'bay@gs.org', 7800.00, FALSE),      -- ID: 7
('Merih Demiral', '537-204-8080', 'merih@mail.com', 11000.00, TRUE),       -- ID: 8
('Abdülkerim Bardakcı', '538-205-9090', 'apo@gs.org', 6500.00, FALSE),     -- ID: 9
('Kenan Yıldız', '541-301-1111', 'kenan@juve.it', 1200.00, FALSE),         -- ID: 10
('Semih Kılıçsoy', '543-302-2222', 'semih@bjk.com', 800.00, FALSE),        -- ID: 11
('İsmail Yüksek', '544-303-3333', 'ismail@fb.org', 3200.00, FALSE),        -- ID: 12
('Salih Özcan', '545-304-4444', 'salih@mail.com', 4500.00, FALSE),         -- ID: 13
('Altay Bayındır', '546-305-5555', 'altay@manutd.com', 2100.00, FALSE),    -- ID: 14
('İrfan Can Kahveci', '547-306-6666', 'irfan@fb.org', 9800.00, TRUE);      -- ID: 15

-- 2. DİYET KISITLAMALARI (FUTBOLCU BESLENMESİ)
INSERT INTO DIETARYRESTRICTIONS (customer_id, restriction_type) VALUES
(2, 'Gluten Free'),       -- Arda Güler
(10, 'Vegan'),            -- Kenan Yıldız (Örnek)
(1, 'Lactose Intolerant'), -- Hakan Çalhanoğlu
(5, 'Nut Allergy');       -- Kerem Aktürkoğlu

-- 3. MASALAR VE BÖLGELER
INSERT INTO TABLES (capacity, location_zone, is_combinable) VALUES
(2, 'Cam Kenarı A', TRUE),  -- ID: 1
(2, 'Cam Kenarı A', TRUE),  -- ID: 2
(4, 'Salon Merkez', TRUE),  -- ID: 3 (Parent Masa)
(4, 'Salon Merkez', TRUE),  -- ID: 4 (Child Masa)
(6, 'VIP Loca', FALSE),     -- ID: 5
(8, 'Teras', FALSE),        -- ID: 6
(2, 'Bar', FALSE),          -- ID: 7
(10, 'Bahçe', TRUE),        -- ID: 8
(10, 'Bahçe', TRUE);        -- ID: 9

-- 4. MASA KOMBİNASYONU (ÖNEMLİ)
-- Hakan Çalhanoğlu takımı getirdiğinde 3 ve 4 birleşecek.
INSERT INTO TABLECOMBINATIONS (parent_table_id, child_table_id) VALUES 
(1, 2), -- İki küçük masa
(3, 4); -- İki orta masa (8 kişilik büyük masa oluyor)

-- 5. PERSONEL
INSERT INTO STAFF (name, role, hire_date) VALUES
('Mehmet Yalçınkaya', 'Head Chef', '2020-01-01'),
('Somer Sivrioğlu', 'Tadımcı', '2021-05-15'),
('Danilo Zanna', 'Host', '2022-03-10'),
('Garson Ali', 'Garson', '2023-01-15'), -- ID: 4
('Garson Ayşe', 'Garson', '2023-03-10'); -- ID: 5

-- 6. VARDİYA (UNUTULMAMALI)
INSERT INTO SHIFTSCHEDULES (staff_id, shift_start, shift_end) VALUES
(4, '2025-12-15 16:00:00', '2025-12-15 23:59:00'), -- Garson Ali'nin vardiyası
(5, '2025-12-16 10:00:00', '2025-12-16 18:00:00'); -- Garson Ayşe'nin vardiyası

-- 7. KATEGORİLER
INSERT INTO CATEGORIES (category_name, target_margin) VALUES
('Başlangıçlar', 35.00),      -- ID: 1
('Ana Yemek (Et)', 25.00),    -- ID: 2
('Ana Yemek (Deniz)', 20.00), -- ID: 3
('Makarna & Risotto', 45.00), -- ID: 4
('Tatlılar', 55.00),          -- ID: 5
('İçecekler (Premium)', 65.00); -- ID: 6

-- 8. ZENGİN MENÜ (High Ticket Items)
INSERT INTO MENUITEMS (category_id, name, price, prep_time_minutes) VALUES
(1, 'Dana Carpaccio', 450.00, 10),     -- ID: 1
(1, 'Trüflü Patates', 320.00, 15),     -- ID: 2
(2, 'Wagyu Burger', 950.00, 25),       -- ID: 3
(2, 'Kuzu Kafes (2 Kişilik)', 1800.00, 40), -- ID: 4
(3, 'Izgara Levrek', 650.00, 25),      -- ID: 5
(3, 'Jumbo Karides', 800.00, 20),      -- ID: 6
(4, 'Trüflü Risotto', 550.00, 25),     -- ID: 7
(4, 'Deniz Mahsullü Linguine', 600.00, 20), -- ID: 8
(5, 'San Sebastian Cheesecake', 250.00, 5), -- ID: 9
(5, 'Çikolatalı Sufle', 280.00, 15),   -- ID: 10
(6, 'Château Margaux (Şişe)', 12000.00, 5), -- ID: 11 (Ciro arttırıcı)
(6, 'Ev Yapımı Limonata', 120.00, 5);  -- ID: 12

-- 9. REZERVASYONLAR (SENARYOLAR)
INSERT INTO RESERVATIONS (customer_id, table_id, reservation_time, party_size, status) VALUES
-- Hakan Çalhanoğlu (ID 1) Takım Yemeği - Masa 3 (Masa 4 ile birleşiyor)
(1, 3, '2025-12-15 20:00:00', 8, 'Completed'), 

-- Arda Güler (ID 2) & Kenan Yıldız - Öğle Yemeği
(2, 1, '2025-12-16 13:00:00', 2, 'Completed'),

-- Ferdi Kadıoğlu (ID 6) - Sakatlık dolayısıyla iptal
(6, 6, '2025-12-20 19:30:00', 4, 'Cancelled'),

-- Barış Alper Yılmaz (ID 7) - Gelmedi
(7, 7, '2025-12-21 21:00:00', 2, 'No-Show'),

-- Cenk Tosun (ID 3) - Gelecek hafta ailesiyle
(3, 5, '2026-01-10 19:00:00', 6, 'Confirmed');

-- 10. YEMEK OTURUMLARI (Sadece Completed Olanlar)
INSERT INTO DININGSESSIONS (reservation_id, start_time, end_time, total_amount) VALUES
(1, '2025-12-15 20:15:00', '2025-12-15 23:30:00', 16500.00), -- Hakan'ın masası
(2, '2025-12-16 13:10:00', '2025-12-16 14:30:00', 1800.00);  -- Arda'nın masası

-- 11. SİPARİŞLER
INSERT INTO ORDERS (session_id, staff_id, order_time) VALUES
(1, 4, '2025-12-15 20:30:00'), -- Hakan Başlangıç
(1, 4, '2025-12-15 21:15:00'), -- Hakan Ana Yemek
(2, 5, '2025-12-16 13:20:00'); -- Arda Sipariş

-- 12. SİPARİŞ DETAYLARI (OrderDetails)
INSERT INTO ORDERDETAILS (order_id, item_id, quantity, special_note) VALUES
-- Hakan'ın Masası (Başlangıç & İçki)
(1, 1, 4, 'Ortaya paylaşımlı'), -- 4 Carpaccio
(1, 2, 4, NULL), -- 4 Trüflü Patates
(1, 11, 1, 'Dekante edilsin'), -- 1 Şişe Pahalı Şarap

-- Hakan'ın Masası (Ana Yemek)
(2, 4, 3, 'Az Orta Pişmiş'), -- 3 Adet Kuzu Kafes (2 kişilikten 6 porsiyon eder)
(2, 3, 2, 'Well Done'), -- 2 Wagyu Burger

-- Arda'nın Masası (Diyet)
(3, 5, 1, 'Sossuz, Izgara Sebzeli'), -- Levrek (Glutensiz)
(3, 7, 1, 'Vegan Peynir ile'), -- Trüflü Risotto
(3, 12, 2, 'Şekersiz'); -- 2 Limonata

-- 13. GERİ BİLDİRİM (FEEDBACK)
INSERT INTO FEEDBACK (session_id, rating, comment) VALUES
(1, 5, 'Milli takım olarak çok iyi ağırlandık. Masaların birleştirilmesi harikaydı. - Hakan'),
(2, 4, 'Yemekler lezzetliydi ama vegan seçenekler arttırılabilir. - Arda & Kenan');

