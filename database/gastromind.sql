-- 1. CLEANUP AND SETUP
DROP DATABASE IF EXISTS GastroMind_DB;
CREATE DATABASE GastroMind_DB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE GastroMind_DB;

-- ---------------------------------------------------------
-- 2. TABLE DEFINITIONS (SCHEMA)
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
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id) ON DELETE CASCADE
);

CREATE TABLE TABLES (
    table_id INT AUTO_INCREMENT PRIMARY KEY,
    capacity INT NOT NULL,
    location_zone VARCHAR(50),
    is_combinable BOOLEAN DEFAULT FALSE
);

-- TABLE COMBINATIONS - For combining tables for large groups
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
    FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id) ON DELETE CASCADE
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
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (table_id) REFERENCES TABLES(table_id)
);

CREATE TABLE DININGSESSIONS (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT,
    start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME,
    total_amount DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS(reservation_id) ON DELETE CASCADE
);

CREATE TABLE ORDERS (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT,
    staff_id INT,
    order_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES DININGSESSIONS(session_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id)
);

CREATE TABLE ORDERDETAILS (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    item_id INT,
    quantity INT DEFAULT 1,
    special_note VARCHAR(255),
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES MENUITEMS(item_id)
);

CREATE TABLE FEEDBACK (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    FOREIGN KEY (session_id) REFERENCES DININGSESSIONS(session_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- DATA INSERTS
-- ---------------------------------------------------------

-- 1. CUSTOMERS (Turkish National Team Players)
INSERT INTO CUSTOMERS (full_name, phone, email, total_ltv, vip_status) VALUES
('Hakan Calhanoglu', '532-101-1010', 'hakan.c@tff.org', 45000.00, TRUE),
('Arda Guler', '532-102-2020', 'arda.guler@realmadrid.com', 22000.00, TRUE),
('Cenk Tosun', '533-103-3030', 'cenk.tosun@bjk.com', 15000.00, TRUE),
('Mert Gunok', '542-104-4040', 'mert.gunok@bjk.com', 12500.00, TRUE),
('Kerem Akturkoglu', '555-201-5050', 'kerem@benfica.pt', 8500.00, FALSE),
('Ferdi Kadioglu', '535-202-6060', 'ferdi@brighton.uk', 9200.00, TRUE),
('Baris Alper Yilmaz', '536-203-7070', 'bay@gs.org', 7800.00, FALSE),
('Merih Demiral', '537-204-8080', 'merih@mail.com', 11000.00, TRUE),
('Abdulkerim Bardakci', '538-205-9090', 'apo@gs.org', 6500.00, FALSE),
('Kenan Yildiz', '541-301-1111', 'kenan@juve.it', 1200.00, FALSE),
('Semih Kilicsoy', '543-302-2222', 'semih@bjk.com', 800.00, FALSE),
('Ismail Yuksek', '544-303-3333', 'ismail@fb.org', 3200.00, FALSE),
('Salih Ozcan', '545-304-4444', 'salih@mail.com', 4500.00, FALSE),
('Altay Bayindir', '546-305-5555', 'altay@manutd.com', 2100.00, FALSE),
('Irfan Can Kahveci', '547-306-6666', 'irfan@fb.org', 9800.00, TRUE);

-- 2. DIETARY RESTRICTIONS
INSERT INTO DIETARYRESTRICTIONS (customer_id, restriction_type) VALUES
(2, 'Gluten Free'),
(10, 'Vegan'),
(1, 'Lactose Intolerant'),
(5, 'Nut Allergy');

-- 3. TABLES AND ZONES
INSERT INTO TABLES (capacity, location_zone, is_combinable) VALUES
(2, 'Window Side A', TRUE),
(2, 'Window Side A', TRUE),
(4, 'Main Hall', TRUE),
(4, 'Main Hall', TRUE),
(6, 'VIP Lounge', FALSE),
(8, 'Terrace', FALSE),
(2, 'Bar', FALSE),
(10, 'Garden', TRUE),
(10, 'Garden', TRUE);

-- 4. TABLE COMBINATIONS
INSERT INTO TABLECOMBINATIONS (parent_table_id, child_table_id) VALUES 
(1, 2),
(3, 4);

-- 5. STAFF
INSERT INTO STAFF (name, role, hire_date) VALUES
('Mehmet Yalcinkaya', 'Head Chef', '2020-01-01'),
('Somer Sivrioglu', 'Taster', '2021-05-15'),
('Danilo Zanna', 'Host', '2022-03-10'),
('Waiter Ali', 'Waiter', '2023-01-15'),
('Waiter Ayse', 'Waiter', '2023-03-10'),
('Waiter Deniz', 'Waiter', '2023-01-15'),
('Waiter Ahmet', 'Waiter', '2023-01-15'),
('Waiter Lucia', 'Waiter', '2023-01-15'),
('Waiter Elif', 'Waiter', '2023-01-15'),
('Waiter Murat', 'Waiter', '2023-01-15'),
('Waiter Samet', 'Waiter', '2023-01-15'),
('Waiter Ozan', 'Waiter', '2023-01-15'),
('Waiter Esra', 'Waiter', '2023-01-15'),
('Waiter Leo', 'Waiter', '2023-01-15'),
('Waiter Charlotte', 'Waiter', '2023-01-15'),
('Waiter Mustafa', 'Waiter', '2023-01-15'),
('Waiter Muhammet', 'Waiter', '2023-01-15');

-- 6. SHIFT SCHEDULES
INSERT INTO SHIFTSCHEDULES (staff_id, day_of_week, start_time, end_time) VALUES
(4, 'Sunday', '08:00:00', '16:00:00'),
(5, 'Sunday', '16:00:00', '23:59:00'),
(6, 'Monday', '08:00:00', '16:00:00'),
(7, 'Monday', '16:00:00', '23:59:00'),
(8, 'Tuesday', '08:00:00', '16:00:00'),
(9, 'Tuesday', '16:00:00', '23:59:00'),
(10, 'Wednesday', '08:00:00', '16:00:00'),
(11, 'Wednesday', '16:00:00', '23:59:00'),
(12, 'Thursday', '08:00:00', '16:00:00'),
(13, 'Thursday', '16:00:00', '23:59:00'),
(14, 'Friday', '08:00:00', '16:00:00'),
(15, 'Friday', '16:00:00', '23:59:00'),
(16, 'Saturday', '08:00:00', '16:00:00'),
(17, 'Saturday', '16:00:00', '23:59:00');

-- 7. CATEGORIES
INSERT INTO CATEGORIES (category_name, target_margin) VALUES
('Appetizers', 35.00),
('Main Course (Meat)', 25.00),
('Main Course (Seafood)', 20.00),
('Pasta & Risotto', 45.00),
('Desserts', 55.00),
('Beverages (Premium)', 65.00);

-- 8. MENU ITEMS (High Ticket Items)
INSERT INTO MENUITEMS (category_id, name, price, prep_time_minutes) VALUES
(1, 'Beef Carpaccio', 450.00, 10),
(1, 'Truffle Potatoes', 320.00, 15),
(2, 'Wagyu Burger', 950.00, 25),
(2, 'Lamb Rack (For 2)', 1800.00, 40),
(3, 'Grilled Sea Bass', 650.00, 25),
(3, 'Jumbo Shrimp', 800.00, 20),
(4, 'Truffle Risotto', 550.00, 25),
(4, 'Seafood Linguine', 600.00, 20),
(5, 'San Sebastian Cheesecake', 250.00, 5),
(5, 'Chocolate Souffle', 280.00, 15),
(6, 'Chateau Margaux (Bottle)', 12000.00, 5),
(6, 'Homemade Lemonade', 120.00, 5);

-- 9. RESERVATIONS
INSERT INTO RESERVATIONS (customer_id, table_id, reservation_time, party_size, status) VALUES
-- Hakan Calhanoglu (ID 1) Team Dinner - Table 3 (combined with Table 4)
(1, 3, '2025-12-15 20:00:00', 8, 'Completed'), 
-- Arda Guler (ID 2) & Kenan Yildiz - Lunch
(2, 1, '2025-12-16 13:00:00', 2, 'Completed'),
-- Ferdi Kadioglu (ID 6) - Cancelled due to injury
(6, 6, '2025-12-20 19:30:00', 4, 'Cancelled'),
-- Baris Alper Yilmaz (ID 7) - No show
(7, 7, '2025-12-21 21:00:00', 2, 'No-Show'),
-- Cenk Tosun (ID 3) - Next week with family
(3, 5, '2026-01-10 19:00:00', 6, 'Confirmed'),
-- Additional Reservations
(4, 5, '2025-12-17 19:00:00', 4, 'Completed'),
(5, 2, '2025-12-18 12:30:00', 2, 'Completed'),
(8, 8, '2025-12-19 18:00:00', 6, 'Completed'),
(9, 7, '2025-12-20 20:00:00', 2, 'Completed'),
(10, 1, '2025-12-21 14:00:00', 1, 'Completed'),
(11, 4, '2025-12-22 19:30:00', 3, 'Completed'),
(12, 6, '2025-12-23 20:00:00', 4, 'Completed'),
(13, 9, '2025-12-24 18:30:00', 8, 'Completed'),
(14, 5, '2025-12-25 19:00:00', 2, 'Completed'),
(15, 3, '2025-12-26 20:00:00', 5, 'Completed'),
(1, 5, '2025-12-27 19:00:00', 6, 'Completed'),
(2, 8, '2025-12-28 17:00:00', 4, 'Completed'),
(3, 1, '2025-12-29 13:00:00', 3, 'Completed'),
(6, 9, '2025-12-30 18:00:00', 7, 'Completed'),
(7, 4, '2025-12-31 20:00:00', 2, 'Completed');

-- 10. DINING SESSIONS (Only for Completed Reservations)
INSERT INTO DININGSESSIONS (reservation_id, start_time, end_time, total_amount) VALUES
(1, '2025-12-15 20:15:00', '2025-12-15 23:30:00', 16500.00),
(2, '2025-12-16 13:10:00', '2025-12-16 14:30:00', 1800.00),
(6, '2025-12-17 19:15:00', '2025-12-17 22:00:00', 4200.00),
(7, '2025-12-18 12:45:00', '2025-12-18 14:15:00', 1200.00),
(8, '2025-12-19 18:15:00', '2025-12-19 21:30:00', 5800.00),
(9, '2025-12-20 20:15:00', '2025-12-20 22:00:00', 950.00),
(10, '2025-12-21 14:15:00', '2025-12-21 15:30:00', 650.00),
(11, '2025-12-22 19:45:00', '2025-12-22 21:30:00', 1800.00),
(12, '2025-12-23 20:15:00', '2025-12-23 23:00:00', 3200.00),
(13, '2025-12-24 18:45:00', '2025-12-24 22:15:00', 7200.00),
(14, '2025-12-25 19:15:00', '2025-12-25 21:00:00', 1400.00),
(15, '2025-12-26 20:15:00', '2025-12-26 23:45:00', 4500.00),
(16, '2025-12-27 19:15:00', '2025-12-27 22:30:00', 8900.00),
(17, '2025-12-28 17:15:00', '2025-12-28 20:00:00', 3600.00),
(18, '2025-12-29 13:15:00', '2025-12-29 15:00:00', 2100.00),
(19, '2025-12-30 18:15:00', '2025-12-30 21:30:00', 6200.00),
(20, '2025-12-31 20:15:00', '2025-12-31 23:00:00', 1800.00);

-- 11. ORDERS
INSERT INTO ORDERS (session_id, staff_id, order_time) VALUES
(1, 7, '2025-12-15 20:30:00'),
(1, 7, '2025-12-15 21:15:00'),
(2, 8, '2025-12-16 13:20:00'),
(3, 11, '2025-12-17 19:30:00'),
(3, 11, '2025-12-17 20:15:00'),
(4, 12, '2025-12-18 12:50:00'),
(5, 15, '2025-12-19 18:30:00'),
(5, 15, '2025-12-19 19:30:00'),
(6, 17, '2025-12-20 20:30:00'),
(7, 4, '2025-12-21 14:20:00'),
(8, 7, '2025-12-22 19:50:00'),
(8, 7, '2025-12-22 20:30:00'),
(9, 9, '2025-12-23 20:30:00'),
(9, 9, '2025-12-23 21:15:00'),
(10, 11, '2025-12-24 18:50:00'),
(10, 11, '2025-12-24 19:45:00'),
(11, 13, '2025-12-25 19:30:00'),
(12, 15, '2025-12-26 20:30:00'),
(12, 15, '2025-12-26 21:30:00'),
(13, 17, '2025-12-27 19:30:00'),
(13, 17, '2025-12-27 20:30:00'),
(14, 5, '2025-12-28 17:30:00'),
(14, 5, '2025-12-28 18:30:00'),
(15, 6, '2025-12-29 13:30:00'),
(16, 9, '2025-12-30 18:30:00'),
(16, 9, '2025-12-30 19:30:00'),
(17, 11, '2025-12-31 20:30:00');

-- 12. ORDER DETAILS
INSERT INTO ORDERDETAILS (order_id, item_id, quantity, special_note) VALUES
-- Hakan's Table (Appetizers & Drinks)
(1, 1, 4, 'Shared for the table'),
(1, 2, 4, NULL),
(1, 11, 1, 'Please decant'),
-- Hakan's Table (Main Course)
(2, 4, 3, 'Medium Rare'),
(2, 3, 2, 'Well Done'),
-- Arda's Table (Diet)
(3, 5, 1, 'No sauce, grilled vegetables'),
(3, 7, 1, 'With vegan cheese'),
(3, 12, 2, 'No sugar'),
-- Mert Gunok VIP
(4, 1, 2, 'VIP service'),
(4, 11, 1, 'Best vintage'),
(5, 3, 2, 'VIP'),
-- Kerem Akturkoglu Lunch
(6, 5, 1, NULL),
(6, 12, 1, NULL),
-- Merih Demiral Garden
(7, 2, 3, NULL),
(7, 6, 2, NULL),
(8, 4, 2, NULL),
-- Apo Bar
(9, 12, 2, 'No ice'),
-- Kenan Yildiz Solo
(10, 7, 1, 'Vegan'),
(10, 12, 1, NULL),
-- Semih Kilicsoy
(11, 1, 1, NULL),
(12, 8, 1, NULL),
-- Ismail Yuksek
(13, 2, 2, NULL),
(14, 3, 1, NULL),
(14, 9, 1, NULL),
-- Salih Ozcan
(15, 1, 3, NULL),
(15, 11, 1, NULL),
(16, 4, 2, NULL),
-- Altay Bayindir
(17, 5, 1, NULL),
(17, 10, 1, NULL),
-- Irfan Can Kahveci
(18, 2, 2, NULL),
(19, 6, 2, NULL),
(19, 9, 2, NULL),
-- Hakan Again
(20, 1, 3, NULL),
(20, 11, 1, NULL),
(21, 4, 2, NULL),
-- Arda Garden
(22, 2, 2, NULL),
(23, 5, 2, NULL),
-- Cenk Lunch
(24, 7, 1, NULL),
(24, 12, 1, NULL),
-- Ferdi Garden
(25, 1, 3, NULL),
(26, 3, 2, NULL),
(26, 10, 2, NULL),
-- Baris New Year's Eve
(27, 8, 1, NULL),
(27, 12, 1, NULL);

-- 13. FEEDBACK
INSERT INTO FEEDBACK (session_id, rating, comment) VALUES
(1, 5, 'We were very well hosted as the national team. The table combination was excellent. - Hakan'),
(2, 4, 'The food was delicious but vegan options could be increased. - Arda & Kenan'),
(3, 5, 'VIP service was perfect, staff very attentive. - Mert'),
(4, 4, 'Fast service, delicious food. - Kerem'),
(5, 5, 'Garden atmosphere was amazing, food was superb. - Merih'),
(6, 3, 'Bar was crowded but service was good. - Apo'),
(7, 4, 'Ideal for solo dining, peaceful environment. - Kenan'),
(8, 4, 'Service was a bit slow but food was good. - Semih'),
(9, 5, 'VIP lounge is very stylish, everything was perfect. - Ismail'),
(10, 5, 'Very suitable for group dining, large table. - Salih'),
(11, 4, 'Food was fresh and delicious. - Altay'),
(12, 5, 'Professional service, high quality. - Irfan'),
(13, 5, 'Happy to come again. - Hakan'),
(14, 4, 'Garden is beautiful, food is good. - Arda'),
(15, 4, 'Ideal for lunch. - Cenk'),
(16, 5, 'Perfect venue for groups. - Ferdi'),
(17, 4, 'New Year atmosphere was nice. - Baris');

-- ---------------------------------------------------------
-- ADDITIONAL DATA (JANUARY 2026) - For richer reports
-- ---------------------------------------------------------

-- Additional Reservations (January 2026)
INSERT INTO RESERVATIONS (customer_id, table_id, reservation_time, party_size, status) VALUES
-- January 2026 - Post New Year rush
(1, 5, '2026-01-02 19:00:00', 6, 'Completed'),
(2, 1, '2026-01-03 13:00:00', 2, 'Completed'),
(3, 6, '2026-01-04 20:00:00', 8, 'Completed'),
(4, 5, '2026-01-05 19:30:00', 4, 'Completed'),
(5, 2, '2026-01-06 12:30:00', 2, 'Completed'),
(6, 8, '2026-01-07 18:00:00', 6, 'Completed'),
(7, 3, '2026-01-08 20:00:00', 4, 'Completed'),
(8, 9, '2026-01-09 19:00:00', 8, 'Completed'),
(9, 7, '2026-01-10 21:00:00', 2, 'Pending'),
(10, 1, '2026-01-11 14:00:00', 1, 'Pending'),
(11, 4, '2026-01-12 19:30:00', 3, 'Pending'),
(12, 6, '2026-01-13 20:00:00', 4, 'Confirmed'),
(13, 9, '2026-01-14 18:30:00', 10, 'Confirmed'),
(14, 5, '2026-01-15 19:00:00', 2, 'Confirmed'),
(15, 3, '2026-01-16 20:00:00', 5, 'Confirmed'),
(1, 8, '2026-01-17 18:00:00', 4, 'Completed'),
(2, 5, '2026-01-18 19:30:00', 3, 'Completed'),
(3, 1, '2026-01-19 13:00:00', 2, 'Completed'),
(6, 6, '2026-01-20 20:00:00', 6, 'Completed'),
(8, 5, '2026-01-21 19:00:00', 4, 'Completed');

-- Additional Dining Sessions (January 2026 Completed)
INSERT INTO DININGSESSIONS (reservation_id, start_time, end_time, total_amount) VALUES
(21, '2026-01-02 19:15:00', '2026-01-02 22:30:00', 14200.00),
(22, '2026-01-03 13:10:00', '2026-01-03 14:45:00', 2100.00),
(23, '2026-01-04 20:15:00', '2026-01-04 23:30:00', 9800.00),
(24, '2026-01-05 19:45:00', '2026-01-05 22:15:00', 5600.00),
(25, '2026-01-06 12:45:00', '2026-01-06 14:30:00', 1450.00),
(26, '2026-01-07 18:15:00', '2026-01-07 21:45:00', 7200.00),
(27, '2026-01-08 20:15:00', '2026-01-08 23:00:00', 4100.00),
(28, '2026-01-09 19:15:00', '2026-01-09 22:45:00', 11500.00),
(36, '2026-01-17 18:15:00', '2026-01-17 21:30:00', 6800.00),
(37, '2026-01-18 19:45:00', '2026-01-18 22:30:00', 8900.00),
(38, '2026-01-19 13:15:00', '2026-01-19 15:00:00', 1800.00),
(39, '2026-01-20 20:15:00', '2026-01-20 23:30:00', 7500.00),
(40, '2026-01-21 19:15:00', '2026-01-21 22:00:00', 5200.00);

-- Additional Orders (January 2026)
INSERT INTO ORDERS (session_id, staff_id, order_time) VALUES
-- Hakan VIP (session 18)
(18, 4, '2026-01-02 19:30:00'),
(18, 4, '2026-01-02 20:30:00'),
(18, 4, '2026-01-02 21:30:00'),
-- Arda lunch (session 19)
(19, 5, '2026-01-03 13:20:00'),
-- Cenk terrace (session 20)
(20, 6, '2026-01-04 20:30:00'),
(20, 6, '2026-01-04 21:30:00'),
-- Mert VIP (session 21)
(21, 7, '2026-01-05 20:00:00'),
(21, 7, '2026-01-05 21:00:00'),
-- Kerem lunch (session 22)
(22, 8, '2026-01-06 12:50:00'),
-- Ferdi garden (session 23)
(23, 9, '2026-01-07 18:30:00'),
(23, 9, '2026-01-07 19:30:00'),
-- Baris (session 24)
(24, 10, '2026-01-08 20:30:00'),
(24, 10, '2026-01-08 21:30:00'),
-- Merih garden (session 25)
(25, 11, '2026-01-09 19:30:00'),
(25, 11, '2026-01-09 20:30:00'),
(25, 11, '2026-01-09 21:30:00'),
-- Hakan garden (session 26)
(26, 12, '2026-01-17 18:30:00'),
(26, 12, '2026-01-17 19:30:00'),
-- Arda VIP (session 27)
(27, 13, '2026-01-18 20:00:00'),
(27, 13, '2026-01-18 21:00:00'),
-- Cenk lunch (session 28)
(28, 14, '2026-01-19 13:30:00'),
-- Ferdi terrace (session 29)
(29, 15, '2026-01-20 20:30:00'),
(29, 15, '2026-01-20 21:30:00'),
-- Merih VIP (session 30)
(30, 16, '2026-01-21 19:30:00'),
(30, 16, '2026-01-21 20:30:00');

-- Additional Order Details (January 2026)
INSERT INTO ORDERDETAILS (order_id, item_id, quantity, special_note) VALUES
-- Hakan VIP Appetizers (order 28)
(28, 1, 3, 'VIP service'),
(28, 2, 3, NULL),
(28, 11, 2, 'Please decant'),
-- Hakan VIP Main (order 29)
(29, 4, 2, 'Medium Rare'),
(29, 3, 2, NULL),
-- Hakan VIP Dessert (order 30)
(30, 9, 4, NULL),
(30, 10, 2, NULL),
-- Arda lunch (order 31)
(31, 5, 1, 'Gluten free'),
(31, 7, 1, NULL),
(31, 12, 2, 'No sugar'),
-- Cenk terrace Appetizers (order 32)
(32, 1, 4, NULL),
(32, 6, 4, NULL),
-- Cenk terrace Main (order 33)
(33, 4, 3, NULL),
(33, 11, 1, NULL),
-- Mert VIP Appetizers (order 34)
(34, 2, 2, 'VIP'),
(34, 1, 2, 'VIP'),
-- Mert VIP Main (order 35)
(35, 3, 2, 'Well Done'),
(35, 5, 2, NULL),
-- Kerem lunch (order 36)
(36, 8, 1, NULL),
(36, 12, 1, NULL),
-- Ferdi garden Appetizers (order 37)
(37, 1, 3, NULL),
(37, 2, 2, NULL),
-- Ferdi garden Main (order 38)
(38, 6, 3, NULL),
(38, 4, 2, NULL),
-- Baris Appetizers (order 39)
(39, 2, 2, NULL),
-- Baris Main (order 40)
(40, 3, 2, NULL),
(40, 9, 2, NULL),
-- Merih garden Appetizers (order 41)
(41, 1, 4, 'Shared'),
(41, 11, 1, NULL),
-- Merih garden Main (order 42)
(42, 4, 3, NULL),
(42, 6, 2, NULL),
-- Merih garden Dessert (order 43)
(43, 9, 4, NULL),
(43, 10, 4, NULL),
-- Hakan garden Appetizers (order 44)
(44, 2, 2, NULL),
(44, 1, 2, NULL),
-- Hakan garden Main (order 45)
(45, 4, 2, 'Rare'),
(45, 11, 1, NULL),
-- Arda VIP Appetizers (order 46)
(46, 7, 2, 'Vegan cheese'),
(46, 2, 2, NULL),
-- Arda VIP Main (order 47)
(47, 5, 2, 'Gluten free'),
(47, 11, 1, 'Best vintage'),
-- Cenk lunch (order 48)
(48, 8, 1, NULL),
(48, 12, 2, NULL),
-- Ferdi terrace Appetizers (order 49)
(49, 1, 3, NULL),
(49, 6, 2, NULL),
-- Ferdi terrace Main (order 50)
(50, 4, 2, NULL),
(50, 9, 3, NULL),
-- Merih VIP Appetizers (order 51)
(51, 2, 2, 'VIP service'),
(51, 1, 2, NULL),
-- Merih VIP Main (order 52)
(52, 3, 2, 'Medium'),
(52, 10, 2, NULL);

-- Additional Feedback (January 2026)
INSERT INTO FEEDBACK (session_id, rating, comment) VALUES
(18, 5, 'Wonderful dinner after New Year. VIP service as excellent as always. - Hakan'),
(19, 4, 'Ideal for lunch, fast service. Gluten-free options are great. - Arda'),
(20, 5, 'Terrace was amazing, our group of 8 was very well hosted. - Cenk'),
(21, 5, 'VIP lounge is always magnificent. Staff very professional. - Mert'),
(22, 4, 'Ideal for those looking for a light lunch. Prices are reasonable. - Kerem'),
(23, 5, 'Garden section is very enjoyable, food is delicious. - Ferdi'),
(24, 4, 'Service was fast, food was good. Will come again. - Baris'),
(25, 5, 'Perfect organization for large group. Everything was flawless. - Merih'),
(26, 5, 'Had a great evening in the garden. Wine was superb. - Hakan'),
(27, 5, 'VIP experience is always top-notch. Thank you! - Arda'),
(28, 4, 'Lunch menu is very filling. Lemonade is fresh and tasty. - Cenk'),
(29, 5, 'Terrace view and food in perfect harmony. - Ferdi'),
(30, 5, 'VIP service always exceeds my expectations. - Merih');

-- ---------------------------------------------------------
-- ADDITIONAL DATA - MORE CUSTOMERS, RESERVATIONS, FEEDBACK
-- ---------------------------------------------------------

-- Additional Customers (Famous personalities, business people, celebrities)
INSERT INTO CUSTOMERS (full_name, phone, email, total_ltv, vip_status) VALUES
('Elon Musk', '555-100-0001', 'elon@tesla.com', 85000.00, TRUE),
('Jeff Bezos', '555-100-0002', 'jeff@amazon.com', 72000.00, TRUE),
('Cristiano Ronaldo', '555-100-0003', 'cr7@mail.com', 55000.00, TRUE),
('Lionel Messi', '555-100-0004', 'messi@psg.com', 48000.00, TRUE),
('Emma Watson', '555-100-0005', 'emma.w@mail.com', 32000.00, TRUE),
('Leonardo DiCaprio', '555-100-0006', 'leo@mail.com', 41000.00, TRUE),
('Taylor Swift', '555-100-0007', 'taylor@mail.com', 38000.00, TRUE),
('Bill Gates', '555-100-0008', 'bill@microsoft.com', 62000.00, TRUE),
('Oprah Winfrey', '555-100-0009', 'oprah@own.com', 35000.00, TRUE),
('David Beckham', '555-100-0010', 'beckham@mail.com', 28000.00, TRUE),
('Sarah Johnson', '555-200-0001', 'sarah.j@gmail.com', 4500.00, FALSE),
('Michael Chen', '555-200-0002', 'mchen@outlook.com', 3200.00, FALSE),
('Emily Rodriguez', '555-200-0003', 'emily.r@yahoo.com', 5800.00, FALSE),
('James Wilson', '555-200-0004', 'jwilson@gmail.com', 2100.00, FALSE),
('Sophia Martinez', '555-200-0005', 'smartinez@mail.com', 6700.00, FALSE),
('Oliver Brown', '555-200-0006', 'obrown@gmail.com', 1800.00, FALSE),
('Isabella Garcia', '555-200-0007', 'igarcia@mail.com', 4200.00, FALSE),
('William Taylor', '555-200-0008', 'wtaylor@outlook.com', 3900.00, FALSE),
('Ava Anderson', '555-200-0009', 'ava.a@gmail.com', 5100.00, FALSE),
('Ethan Thomas', '555-200-0010', 'ethomas@mail.com', 2800.00, FALSE);

-- Additional Dietary Restrictions for new customers
INSERT INTO DIETARYRESTRICTIONS (customer_id, restriction_type) VALUES
(16, 'Vegan'),           -- Elon Musk
(18, 'Gluten Free'),     -- Cristiano Ronaldo
(20, 'Pescatarian'),     -- Emma Watson
(22, 'Vegetarian'),      -- Taylor Swift
(24, 'Keto'),            -- Oprah Winfrey
(26, 'Lactose Intolerant'), -- Sarah Johnson
(30, 'Nut Allergy');     -- Sophia Martinez

-- Additional Reservations (February 2026)
INSERT INTO RESERVATIONS (customer_id, table_id, reservation_time, party_size, status) VALUES
-- VIP Celebrities
(16, 5, '2026-02-01 19:00:00', 4, 'Completed'),   -- Elon Musk VIP
(17, 5, '2026-02-02 20:00:00', 6, 'Completed'),   -- Jeff Bezos VIP
(18, 8, '2026-02-03 19:30:00', 8, 'Completed'),   -- Cristiano Ronaldo Garden
(19, 9, '2026-02-04 20:00:00', 6, 'Completed'),   -- Lionel Messi Garden
(20, 5, '2026-02-05 19:00:00', 2, 'Completed'),   -- Emma Watson VIP
(21, 6, '2026-02-06 20:30:00', 4, 'Completed'),   -- Leonardo DiCaprio Terrace
(22, 5, '2026-02-07 19:00:00', 3, 'Completed'),   -- Taylor Swift VIP
(23, 5, '2026-02-08 19:30:00', 4, 'Completed'),   -- Bill Gates VIP
(24, 6, '2026-02-09 20:00:00', 2, 'Completed'),   -- Oprah Winfrey Terrace
(25, 8, '2026-02-10 19:00:00', 6, 'Completed'),   -- David Beckham Garden
-- Regular customers
(26, 1, '2026-02-11 12:30:00', 2, 'Completed'),   -- Sarah Johnson lunch
(27, 2, '2026-02-11 13:00:00', 2, 'Completed'),   -- Michael Chen lunch
(28, 3, '2026-02-12 19:00:00', 4, 'Completed'),   -- Emily Rodriguez dinner
(29, 4, '2026-02-12 19:30:00', 3, 'Completed'),   -- James Wilson dinner
(30, 1, '2026-02-13 12:00:00', 2, 'Completed'),   -- Sophia Martinez lunch
(31, 7, '2026-02-13 21:00:00', 2, 'Completed'),   -- Oliver Brown bar
(32, 2, '2026-02-14 19:00:00', 2, 'Completed'),   -- Isabella Garcia Valentine's
(33, 3, '2026-02-14 19:30:00', 2, 'Completed'),   -- William Taylor Valentine's
(34, 1, '2026-02-15 12:30:00', 2, 'Completed'),   -- Ava Anderson lunch
(35, 4, '2026-02-15 20:00:00', 3, 'Completed'),   -- Ethan Thomas dinner
-- Pending and Confirmed for upcoming
(16, 5, '2026-02-20 19:00:00', 4, 'Confirmed'),   -- Elon return
(18, 8, '2026-02-21 19:30:00', 6, 'Confirmed'),   -- Ronaldo return
(20, 5, '2026-02-22 19:00:00', 2, 'Pending'),     -- Emma return
(22, 6, '2026-02-23 20:00:00', 4, 'Pending'),     -- Taylor return
(26, 1, '2026-02-24 12:30:00', 2, 'Pending');     -- Sarah return

-- Dining Sessions for February completed reservations
INSERT INTO DININGSESSIONS (reservation_id, start_time, end_time, total_amount) VALUES
(41, '2026-02-01 19:15:00', '2026-02-01 22:30:00', 24500.00),  -- Elon VIP (session 31)
(42, '2026-02-02 20:15:00', '2026-02-02 23:45:00', 18900.00),  -- Bezos VIP (session 32)
(43, '2026-02-03 19:45:00', '2026-02-03 23:00:00', 15600.00),  -- Ronaldo Garden (session 33)
(44, '2026-02-04 20:15:00', '2026-02-04 23:30:00', 14200.00),  -- Messi Garden (session 34)
(45, '2026-02-05 19:15:00', '2026-02-05 21:30:00', 8500.00),   -- Emma VIP (session 35)
(46, '2026-02-06 20:45:00', '2026-02-07 00:00:00', 12800.00),  -- Leo Terrace (session 36)
(47, '2026-02-07 19:15:00', '2026-02-07 22:00:00', 9200.00),   -- Taylor VIP (session 37)
(48, '2026-02-08 19:45:00', '2026-02-08 22:30:00', 16500.00),  -- Gates VIP (session 38)
(49, '2026-02-09 20:15:00', '2026-02-09 22:30:00', 7800.00),   -- Oprah Terrace (session 39)
(50, '2026-02-10 19:15:00', '2026-02-10 22:45:00', 11200.00),  -- Beckham Garden (session 40)
(51, '2026-02-11 12:45:00', '2026-02-11 14:00:00', 1450.00),   -- Sarah lunch (session 41)
(52, '2026-02-11 13:15:00', '2026-02-11 14:30:00', 1280.00),   -- Michael lunch (session 42)
(53, '2026-02-12 19:15:00', '2026-02-12 21:45:00', 3200.00),   -- Emily dinner (session 43)
(54, '2026-02-12 19:45:00', '2026-02-12 21:30:00', 2100.00),   -- James dinner (session 44)
(55, '2026-02-13 12:15:00', '2026-02-13 13:30:00', 1650.00),   -- Sophia lunch (session 45)
(56, '2026-02-13 21:15:00', '2026-02-13 23:00:00', 950.00),    -- Oliver bar (session 46)
(57, '2026-02-14 19:15:00', '2026-02-14 22:00:00', 4500.00),   -- Isabella Valentine's (session 47)
(58, '2026-02-14 19:45:00', '2026-02-14 22:30:00', 4800.00),   -- William Valentine's (session 48)
(59, '2026-02-15 12:45:00', '2026-02-15 14:00:00', 1350.00),   -- Ava lunch (session 49)
(60, '2026-02-15 20:15:00', '2026-02-15 22:30:00', 2800.00);   -- Ethan dinner (session 50)

-- Orders for February sessions
INSERT INTO ORDERS (session_id, staff_id, order_time) VALUES
-- Elon Musk VIP (session 31)
(31, 4, '2026-02-01 19:30:00'),
(31, 4, '2026-02-01 20:30:00'),
(31, 4, '2026-02-01 21:30:00'),
-- Jeff Bezos VIP (session 32)
(32, 5, '2026-02-02 20:30:00'),
(32, 5, '2026-02-02 21:30:00'),
-- Cristiano Ronaldo Garden (session 33)
(33, 6, '2026-02-03 20:00:00'),
(33, 6, '2026-02-03 21:00:00'),
-- Lionel Messi Garden (session 34)
(34, 7, '2026-02-04 20:30:00'),
(34, 7, '2026-02-04 21:30:00'),
-- Emma Watson VIP (session 35)
(35, 8, '2026-02-05 19:30:00'),
(35, 8, '2026-02-05 20:30:00'),
-- Leonardo DiCaprio Terrace (session 36)
(36, 9, '2026-02-06 21:00:00'),
(36, 9, '2026-02-06 22:00:00'),
-- Taylor Swift VIP (session 37)
(37, 10, '2026-02-07 19:30:00'),
(37, 10, '2026-02-07 20:30:00'),
-- Bill Gates VIP (session 38)
(38, 11, '2026-02-08 20:00:00'),
(38, 11, '2026-02-08 21:00:00'),
-- Oprah Terrace (session 39)
(39, 12, '2026-02-09 20:30:00'),
-- David Beckham Garden (session 40)
(40, 13, '2026-02-10 19:30:00'),
(40, 13, '2026-02-10 20:30:00'),
-- Regular customers
(41, 14, '2026-02-11 12:50:00'),  -- Sarah
(42, 15, '2026-02-11 13:20:00'),  -- Michael
(43, 16, '2026-02-12 19:30:00'),  -- Emily
(43, 16, '2026-02-12 20:30:00'),
(44, 17, '2026-02-12 20:00:00'),  -- James
(45, 4, '2026-02-13 12:20:00'),   -- Sophia
(46, 5, '2026-02-13 21:30:00'),   -- Oliver
(47, 6, '2026-02-14 19:30:00'),   -- Isabella Valentine's
(47, 6, '2026-02-14 20:30:00'),
(48, 7, '2026-02-14 20:00:00'),   -- William Valentine's
(48, 7, '2026-02-14 21:00:00'),
(49, 8, '2026-02-15 12:50:00'),   -- Ava
(50, 9, '2026-02-15 20:30:00'),   -- Ethan
(50, 9, '2026-02-15 21:30:00');

-- Order Details for February
INSERT INTO ORDERDETAILS (order_id, item_id, quantity, special_note) VALUES
-- Elon Musk VIP (orders 53-55)
(53, 1, 4, 'Vegan preparation'),
(53, 2, 4, NULL),
(53, 11, 2, 'Best vintage available'),
(54, 7, 4, 'Vegan cheese only'),
(54, 5, 2, NULL),
(55, 9, 4, NULL),
(55, 10, 4, NULL),
-- Jeff Bezos VIP (orders 56-57)
(56, 1, 6, 'VIP presentation'),
(56, 6, 6, NULL),
(56, 11, 1, 'Decant 2 hours before'),
(57, 4, 4, 'Medium rare'),
(57, 9, 6, NULL),
-- Cristiano Ronaldo Garden (orders 58-59)
(58, 1, 8, 'Athlete diet - low fat'),
(58, 5, 4, 'Grilled, no butter'),
(59, 5, 4, 'Extra vegetables'),
(59, 12, 8, 'No sugar'),
-- Lionel Messi Garden (orders 60-61)
(60, 2, 6, NULL),
(60, 6, 4, NULL),
(61, 4, 3, NULL),
(61, 9, 6, NULL),
-- Emma Watson VIP (orders 62-63)
(62, 7, 2, 'Pescatarian - seafood risotto'),
(62, 12, 2, NULL),
(63, 9, 2, NULL),
-- Leonardo DiCaprio Terrace (orders 64-65)
(64, 1, 4, NULL),
(64, 11, 1, NULL),
(65, 4, 2, 'Well done'),
(65, 10, 4, NULL),
-- Taylor Swift VIP (orders 66-67)
(66, 7, 3, 'Vegetarian'),
(66, 2, 3, NULL),
(67, 9, 3, NULL),
(67, 12, 3, NULL),
-- Bill Gates VIP (orders 68-69)
(68, 1, 4, 'VIP service'),
(68, 11, 2, 'Premium selection'),
(69, 3, 4, NULL),
(69, 9, 4, NULL),
-- Oprah Terrace (order 70)
(70, 5, 2, 'Keto friendly'),
(70, 12, 2, 'No sugar'),
-- David Beckham Garden (orders 71-72)
(71, 1, 6, NULL),
(71, 6, 4, NULL),
(72, 4, 3, 'Medium'),
(72, 10, 6, NULL),
-- Regular customers orders
(73, 5, 1, NULL),      -- Sarah
(73, 12, 2, NULL),
(74, 8, 1, NULL),      -- Michael
(74, 12, 1, NULL),
(75, 2, 2, NULL),      -- Emily appetizer
(75, 6, 2, NULL),
(76, 4, 1, NULL),      -- Emily main
(77, 3, 1, NULL),      -- James
(77, 12, 2, NULL),
(78, 7, 1, NULL),      -- Sophia
(78, 12, 1, NULL),
(79, 12, 3, 'No ice'), -- Oliver bar
(80, 1, 2, 'Valentine special'),  -- Isabella appetizer
(80, 11, 1, 'Romantic setup'),
(81, 4, 1, NULL),      -- Isabella main
(81, 10, 2, NULL),
(82, 2, 2, 'Valentine special'),  -- William appetizer
(82, 11, 1, NULL),
(83, 3, 2, NULL),      -- William main
(83, 9, 2, NULL),
(84, 8, 1, NULL),      -- Ava
(84, 12, 1, NULL),
(85, 1, 2, NULL),      -- Ethan appetizer
(85, 2, 2, NULL),
(86, 3, 1, NULL),      -- Ethan main
(86, 10, 2, NULL);

-- Feedback for February sessions
INSERT INTO FEEDBACK (session_id, rating, comment) VALUES
(31, 5, 'Absolutely incredible experience. The vegan options were outstanding. Best restaurant I have visited this year. - Elon'),
(32, 5, 'World-class service and exceptional wine selection. The private dining experience was perfect. - Jeff'),
(33, 5, 'Perfect for athletes. Healthy options that actually taste amazing. Great atmosphere. - Cristiano'),
(34, 5, 'Reminded me of the best restaurants in Barcelona. Food was exceptional. - Leo'),
(35, 5, 'Loved the pescatarian options. Intimate setting, perfect for a quiet dinner. - Emma'),
(36, 5, 'The terrace view was breathtaking. Food matched the ambiance perfectly. - Leonardo'),
(37, 5, 'Vegetarian menu was creative and delicious. Staff was incredibly accommodating. - Taylor'),
(38, 5, 'Impressive technology integration with classic fine dining. A unique experience. - Bill'),
(39, 4, 'Keto-friendly options were limited but what they had was excellent. Great service. - Oprah'),
(40, 5, 'Brought my family here and everyone loved it. Perfect for groups. - David'),
(41, 4, 'Great lunch spot. Quick service and fresh ingredients. Will return. - Sarah'),
(42, 4, 'Delicious pasta. Good value for the quality. - Michael'),
(43, 5, 'Perfect dinner date location. Romantic atmosphere and amazing seafood. - Emily'),
(44, 4, 'Solid meal, friendly staff. A bit pricey but worth it for special occasions. - James'),
(45, 4, 'Love the healthy options available. Fresh and tasty. - Sophia'),
(46, 3, 'Bar area was nice but could use more drink variety. Food was good though. - Oliver'),
(47, 5, 'Best Valentine dinner ever! The special menu was romantic and delicious. - Isabella'),
(48, 5, 'Incredible Valentine experience. The wine pairing was exceptional. - William'),
(49, 4, 'Nice lunch break. Fresh salads and quick service. - Ava'),
(50, 4, 'Good food, nice atmosphere. Would recommend for casual dinners. - Ethan');


