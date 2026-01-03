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
    day_of_week VARCHAR(20),
    start_time TIME,
    end_time TIME,
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
('Garson Ayşe', 'Garson', '2023-03-10'), -- ID: 5
('Garson Deniz', 'Garson', '2023-01-15'), -- ID: 6
('Garson Ahmet', 'Garson', '2023-01-15'), -- ID: 7
('Garson Lucia', 'Garson', '2023-01-15'), -- ID: 8
('Garson Elif', 'Garson', '2023-01-15'), -- ID: 9
('Garson Murat', 'Garson', '2023-01-15'), -- ID: 10
('Garson Samet', 'Garson', '2023-01-15'), -- ID: 11
('Garson Ozan', 'Garson', '2023-01-15'), -- ID: 12
('Garson Esra', 'Garson', '2023-01-15'), -- ID: 13
('Garson Leo', 'Garson', '2023-01-15'), -- ID: 14
('Garson Charlotte', 'Garson', '2023-01-15'), -- ID: 15
('Garson Mustafa', 'Garson', '2023-01-15'), -- ID: 16
('Garson Muhammet', 'Garson', '2023-01-15'); -- ID: 17

-- 6. VARDİYA (UNUTULMAMALI)
INSERT INTO SHIFTSCHEDULES (staff_id, day_of_week, start_time, end_time) VALUES
(4, 'Pazar', '08:00:00', '16:00:00'), -- Garson Ali'nin vardiyası
(5, 'Pazar', '16:00:00', '23:59:00'), -- Garson Ayşe'nin vardiyası
(6, 'Pazartesi', '08:00:00', '16:00:00'), -- Garson 1 Pazartesi sabah
(7, 'Pazartesi', '16:00:00', '23:59:00'), -- Garson 2 Pazartesi akşam
(8, 'Salı', '08:00:00', '16:00:00'), -- Garson 3 Salı sabah
(9, 'Salı', '16:00:00', '23:59:00'), -- Garson 4 Salı akşam
(10, 'Çarşamba', '08:00:00', '16:00:00'), -- Garson 5 Çarşamba sabah
(11, 'Çarşamba', '16:00:00', '23:59:00'), -- Garson 6 Çarşamba akşam
(12, 'Perşembe', '08:00:00', '16:00:00'), -- Garson 7 Perşembe sabah
(13, 'Perşembe', '16:00:00', '23:59:00'), -- Garson 8 Perşembe akşam
(14, 'Cuma', '08:00:00', '16:00:00'), -- Garson 9 Cuma sabah
(15, 'Cuma', '16:00:00', '23:59:00'), -- Garson 10 Cuma akşam
(16, 'Cumartesi', '08:00:00', '16:00:00'), -- Garson 11 Cumartesi sabah
(17, 'Cumartesi', '16:00:00', '23:59:00'); -- Garson 12 Cumartesi akşam


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
(3, 5, '2026-01-10 19:00:00', 6, 'Confirmed'),

-- Ek Rezervasyonlar (Daha fazla veri için)
(4, 5, '2025-12-17 19:00:00', 4, 'Completed'), -- Mert Günok VIP
(5, 2, '2025-12-18 12:30:00', 2, 'Completed'), -- Kerem Aktürkoğlu öğle
(8, 8, '2025-12-19 18:00:00', 6, 'Completed'), -- Merih Demiral bahçe
(9, 7, '2025-12-20 20:00:00', 2, 'Completed'), -- Abdülkerim Bardakcı bar
(10, 1, '2025-12-21 14:00:00', 1, 'Completed'), -- Kenan Yıldız solo
(11, 4, '2025-12-22 19:30:00', 3, 'Completed'), -- Semih Kılıçsoy
(12, 6, '2025-12-23 20:00:00', 4, 'Completed'), -- İsmail Yüksek
(13, 9, '2025-12-24 18:30:00', 8, 'Completed'), -- Salih Özcan bahçe
(14, 5, '2025-12-25 19:00:00', 2, 'Completed'), -- Altay Bayındır
(15, 3, '2025-12-26 20:00:00', 5, 'Completed'), -- İrfan Can Kahveci
(1, 5, '2025-12-27 19:00:00', 6, 'Completed'), -- Hakan tekrar
(2, 8, '2025-12-28 17:00:00', 4, 'Completed'), -- Arda bahçe
(3, 1, '2025-12-29 13:00:00', 3, 'Completed'), -- Cenk öğle
(6, 9, '2025-12-30 18:00:00', 7, 'Completed'), -- Ferdi bahçe
(7, 4, '2025-12-31 20:00:00', 2, 'Completed'); -- Barış Alper Yılmaz yılbaşı

-- 10. YEMEK OTURUMLARI (Sadece Completed Olanlar)
INSERT INTO DININGSESSIONS (reservation_id, start_time, end_time, total_amount) VALUES
(1, '2025-12-15 20:15:00', '2025-12-15 23:30:00', 16500.00), -- Hakan'ın masası
(2, '2025-12-16 13:10:00', '2025-12-16 14:30:00', 1800.00),  -- Arda'nın masası
(6, '2025-12-17 19:15:00', '2025-12-17 22:00:00', 4200.00),  -- Mert Günok
(7, '2025-12-18 12:45:00', '2025-12-18 14:15:00', 1200.00),  -- Kerem Aktürkoğlu
(8, '2025-12-19 18:15:00', '2025-12-19 21:30:00', 5800.00),  -- Merih Demiral
(9, '2025-12-20 20:15:00', '2025-12-20 22:00:00', 950.00),   -- Apo
(10, '2025-12-21 14:15:00', '2025-12-21 15:30:00', 650.00),  -- Kenan Yıldız
(11, '2025-12-22 19:45:00', '2025-12-22 21:30:00', 1800.00), -- Semih Kılıçsoy
(12, '2025-12-23 20:15:00', '2025-12-23 23:00:00', 3200.00), -- İsmail Yüksek
(13, '2025-12-24 18:45:00', '2025-12-24 22:15:00', 7200.00), -- Salih Özcan
(14, '2025-12-25 19:15:00', '2025-12-25 21:00:00', 1400.00), -- Altay Bayındır
(15, '2025-12-26 20:15:00', '2025-12-26 23:45:00', 4500.00), -- İrfan Can Kahveci
(16, '2025-12-27 19:15:00', '2025-12-27 22:30:00', 8900.00), -- Hakan tekrar
(17, '2025-12-28 17:15:00', '2025-12-28 20:00:00', 3600.00), -- Arda bahçe
(18, '2025-12-29 13:15:00', '2025-12-29 15:00:00', 2100.00), -- Cenk öğle
(19, '2025-12-30 18:15:00', '2025-12-30 21:30:00', 6200.00), -- Ferdi bahçe
(20, '2025-12-31 20:15:00', '2025-12-31 23:00:00', 1800.00); -- Barış yılbaşı

-- 11. SİPARİŞLER
INSERT INTO ORDERS (session_id, staff_id, order_time) VALUES
(1, 7, '2025-12-15 20:30:00'), -- Hakan Başlangıç
(1, 7, '2025-12-15 21:15:00'), -- Hakan Ana Yemek
(2, 8, '2025-12-16 13:20:00'), -- Arda Sipariş
(3, 11, '2025-12-17 19:30:00'), -- Mert Başlangıç
(3, 11, '2025-12-17 20:15:00'), -- Mert Ana Yemek
(4, 12, '2025-12-18 12:50:00'), -- Kerem Öğle
(5, 15, '2025-12-19 18:30:00'), -- Merih Başlangıç
(5, 15, '2025-12-19 19:30:00'), -- Merih Ana Yemek
(6, 17, '2025-12-20 20:30:00'), -- Apo Bar
(7, 4, '2025-12-21 14:20:00'), -- Kenan Öğle
(8, 7, '2025-12-22 19:50:00'), -- Semih Başlangıç
(8, 7, '2025-12-22 20:30:00'), -- Semih Ana Yemek
(9, 9, '2025-12-23 20:30:00'), -- İsmail Başlangıç
(9, 9, '2025-12-23 21:15:00'), -- İsmail Ana Yemek
(10, 11, '2025-12-24 18:50:00'), -- Salih Başlangıç
(10, 11, '2025-12-24 19:45:00'), -- Salih Ana Yemek
(11, 13, '2025-12-25 19:30:00'), -- Altay Sipariş
(12, 15, '2025-12-26 20:30:00'), -- İrfan Başlangıç
(12, 15, '2025-12-26 21:30:00'), -- İrfan Ana Yemek
(13, 17, '2025-12-27 19:30:00'), -- Hakan Tekrar Başlangıç
(13, 17, '2025-12-27 20:30:00'), -- Hakan Tekrar Ana Yemek
(14, 5, '2025-12-28 17:30:00'), -- Arda Bahçe Başlangıç
(14, 5, '2025-12-28 18:30:00'), -- Arda Bahçe Ana Yemek
(15, 6, '2025-12-29 13:30:00'), -- Cenk Öğle
(16, 9, '2025-12-30 18:30:00'), -- Ferdi Başlangıç
(16, 9, '2025-12-30 19:30:00'), -- Ferdi Ana Yemek
(17, 11, '2025-12-31 20:30:00'); -- Barış Yılbaşı

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
(3, 12, 2, 'Şekersiz'), -- 2 Limonata

-- Mert Günok VIP
(4, 1, 2, 'VIP servis'), -- 2 Carpaccio
(4, 11, 1, 'En iyisi'), -- 1 Şişe Şarap
(5, 3, 2, 'VIP'), -- 2 Wagyu Burger

-- Kerem Aktürkoğlu Öğle
(6, 5, 1, NULL), -- 1 Levrek
(6, 12, 1, NULL), -- 1 Limonata

-- Merih Demiral Bahçe
(7, 2, 3, NULL), -- 3 Trüflü Patates
(7, 6, 2, NULL), -- 2 Jumbo Karides
(8, 4, 2, NULL), -- 2 Kuzu Kafes

-- Apo Bar
(9, 12, 2, 'Buzsuz'), -- 2 Limonata

-- Kenan Yıldız Solo
(10, 7, 1, 'Vegan'), -- 1 Trüflü Risotto
(10, 12, 1, NULL), -- 1 Limonata

-- Semih Kılıçsoy
(11, 1, 1, NULL), -- 1 Carpaccio
(12, 8, 1, NULL), -- 1 Linguine

-- İsmail Yüksek
(13, 2, 2, NULL), -- 2 Trüflü Patates
(14, 3, 1, NULL), -- 1 Wagyu Burger
(14, 9, 1, NULL), -- 1 Cheesecake

-- Salih Özcan
(15, 1, 3, NULL), -- 3 Carpaccio
(15, 11, 1, NULL), -- 1 Şişe Şarap
(16, 4, 2, NULL), -- 2 Kuzu Kafes

-- Altay Bayındır
(17, 5, 1, NULL), -- 1 Levrek
(17, 10, 1, NULL), -- 1 Sufle

-- İrfan Can Kahveci
(18, 2, 2, NULL), -- 2 Trüflü Patates
(19, 6, 2, NULL), -- 2 Jumbo Karides
(19, 9, 2, NULL), -- 2 Cheesecake

-- Hakan Tekrar
(20, 1, 3, NULL), -- 3 Carpaccio
(20, 11, 1, NULL), -- 1 Şişe Şarap
(21, 4, 2, NULL), -- 2 Kuzu Kafes

-- Arda Bahçe
(22, 2, 2, NULL), -- 2 Trüflü Patates
(23, 5, 2, NULL), -- 2 Levrek

-- Cenk Öğle
(24, 7, 1, NULL), -- 1 Risotto
(24, 12, 1, NULL), -- 1 Limonata

-- Ferdi Bahçe
(25, 1, 3, NULL), -- 3 Carpaccio
(26, 3, 2, NULL), -- 2 Wagyu Burger
(26, 10, 2, NULL), -- 2 Sufle

-- Barış Yılbaşı
(27, 8, 1, NULL), -- 1 Linguine
(27, 12, 1, NULL); -- 1 Limonata

-- 13. GERİ BİLDİRİM (FEEDBACK)
INSERT INTO FEEDBACK (session_id, rating, comment) VALUES
(1, 5, 'Milli takım olarak çok iyi ağırlandık. Masaların birleştirilmesi harikaydı. - Hakan'),
(2, 4, 'Yemekler lezzetliydi ama vegan seçenekler arttırılabilir. - Arda & Kenan'),
(3, 5, 'VIP servis mükemmeldi, personel çok ilgili. - Mert'),
(4, 4, 'Hızlı servis, lezzetli yemekler. - Kerem'),
(5, 5, 'Bahçe atmosferi harikaydı, yemekler muhteşem. - Merih'),
(6, 3, 'Bar kalabalıktı ama servis iyiydi. - Apo'),
(7, 4, 'Solo yemek için ideal, huzurlu ortam. - Kenan'),
(8, 4, 'Servis biraz yavaş ama yemekler iyi. - Semih'),
(9, 5, 'VIP loca çok şık, her şey mükemmel. - İsmail'),
(10, 5, 'Grup yemeği için çok uygun, büyük masa. - Salih'),
(11, 4, 'Yemekler taze ve lezzetli. - Altay'),
(12, 5, 'Profesyonel servis, yüksek kalite. - İrfan'),
(13, 5, 'Tekrar geldiğim için memnunum. - Hakan'),
(14, 4, 'Bahçe çok güzel, yemekler iyi. - Arda'),
(15, 4, 'Öğle yemeği için ideal. - Cenk'),
(16, 5, 'Grup için mükemmel mekan. - Ferdi'),
(17, 4, 'Yılbaşı atmosferi güzeldi. - Barış');

-- 14. TRIGGER: DININGSESSION TAMAMLANDIĞINDA MÜŞTERİ LTV GÜNCELLEME
DELIMITER //
CREATE TRIGGER trg_update_customer_ltv
AFTER INSERT ON DININGSESSIONS
FOR EACH ROW
BEGIN
    UPDATE CUSTOMERS
    SET total_ltv = total_ltv + NEW.total_amount
    WHERE customer_id = (
        SELECT customer_id 
        FROM RESERVATIONS r
        WHERE r.reservation_id = NEW.reservation_id
        );
END;
//
 DELIMITER ;


-- 15. TRIGGER: ORDER EKLERKEN GARSON VARDIYA KONTROLÜ 
DELIMITER //
CREATE TRIGGER trg_check_staff_shift
BEFORE INSERT ON ORDERS
FOR EACH ROW
BEGIN
    DECLARE order_day VARCHAR(20);
    DECLARE shift_count INT;
    
    -- Sipariş gününü belirle (1=Pazar, 2=Pazartesi, vb.)
    SET order_day = CASE DAYOFWEEK(NEW.order_time)
        WHEN 1 THEN 'Pazar'
        WHEN 2 THEN 'Pazartesi'
        WHEN 3 THEN 'Salı'
        WHEN 4 THEN 'Çarşamba'
        WHEN 5 THEN 'Perşembe'
        WHEN 6 THEN 'Cuma'
        WHEN 7 THEN 'Cumartesi'
        ELSE 'Bilinmiyor'
    END;
    
    -- Vardiya kontrolü
    SELECT COUNT(*) INTO shift_count
    FROM SHIFTSCHEDULES
    WHERE staff_id = NEW.staff_id
      AND day_of_week = order_day
      AND TIME(NEW.order_time) BETWEEN start_time AND end_time;
    
    IF shift_count = 0 THEN
        -- Uyarı ver 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Garson bu tarihte vardiyada değil, başka garson atandı.';
       
    END IF;
END;
//
DELIMITER ;

