// API Base URL
const API_BASE = 'http://localhost:5000/api';

// Sayfa göster/gizle
function showPage(pageId) {
    document.querySelectorAll('.page').forEach(page => {
        page.classList.remove('active');
    });
    document.getElementById(pageId).classList.add('active');

    // İlgili verileri yükle
    if (pageId === 'menu') loadMenu();
    if (pageId === 'customers') loadCustomers();
    if (pageId === 'reservations') loadReservations();
    if (pageId === 'orders') loadOrders();
    if (pageId === 'feedback') loadFeedback();
}

// Navigation click listeners
document.querySelectorAll('.navbar a').forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const pageId = link.getAttribute('href').substring(1);
        showPage(pageId);
    });
});

// === MENU SAYFASI ===
async function loadMenu() {
    try {
        const response = await fetch(`${API_BASE}/menu`);
        const data = await response.json();
        
        let html = '<table><thead><tr><th>Yemek</th><th>Kategori</th><th>Fiyat</th><th>Hazırlama Süresi</th></tr></thead><tbody>';
        
        if (data.length > 0) {
            data.forEach(item => {
                html += `<tr>
                    <td>${item.Yemek}</td>
                    <td>${item.Kategori}</td>
                    <td>₺${parseFloat(item.Fiyat).toFixed(2)}</td>
                    <td>${item.Hazirlanma} dk</td>
                </tr>`;
            });
        } else {
            html += '<tr><td colspan="4">Menü bulunamadı</td></tr>';
        }
        
        html += '</tbody></table>';
        document.getElementById('menu-list').innerHTML = html;
    } catch (error) {
        document.getElementById('menu-list').innerHTML = `<div class="error">Hata: ${error.message}</div>`;
    }
}

// === MÜŞTERILER SAYFASI ===
async function loadCustomers() {
    try {
        const response = await fetch(`${API_BASE}/customers`);
        const data = await response.json();
        
        let html = '<table><thead><tr><th>Adı Soyadı</th><th>Telefon</th><th>Email</th><th>Toplam Harcama</th><th>VIP Status</th></tr></thead><tbody>';
        
        if (data.length > 0) {
            data.forEach(customer => {
                const vipStatus = customer.vip_status ? '⭐ VIP' : 'Regular';
                html += `<tr>
                    <td>${customer.full_name}</td>
                    <td>${customer.phone || 'N/A'}</td>
                    <td>${customer.email || 'N/A'}</td>
                    <td>₺${parseFloat(customer.total_ltv).toFixed(2)}</td>
                    <td>${vipStatus}</td>
                </tr>`;
            });
        } else {
            html += '<tr><td colspan="5">Müşteri bulunamadı</td></tr>';
        }
        
        html += '</tbody></table>';
        document.getElementById('customers-list').innerHTML = html;
    } catch (error) {
        document.getElementById('customers-list').innerHTML = `<div class="error">Hata: ${error.message}</div>`;
    }
}

// === REZERVASYONLAR SAYFASI ===
async function loadReservations() {
    try {
        const response = await fetch(`${API_BASE}/reservations`);
        const data = await response.json();
        
        let html = '<table><thead><tr><th>Müşteri</th><th>Masa No</th><th>Tarih/Saat</th><th>Kişi Sayısı</th><th>Durum</th></tr></thead><tbody>';
        
        if (data.length > 0) {
            data.forEach(res => {
                const date = new Date(res.reservation_time).toLocaleString('tr-TR');
                html += `<tr>
                    <td>${res.customer_name}</td>
                    <td>${res.table_id}</td>
                    <td>${date}</td>
                    <td>${res.party_size}</td>
                    <td>${res.status}</td>
                </tr>`;
            });
        } else {
            html += '<tr><td colspan="5">Rezervasyon bulunamadı</td></tr>';
        }
        
        html += '</tbody></table>';
        document.getElementById('reservations-list').innerHTML = html;
    } catch (error) {
        document.getElementById('reservations-list').innerHTML = `<div class="error">Hata: ${error.message}</div>`;
    }
}

// === SİPARİŞLER SAYFASI ===
async function loadOrders(date = null) {
    try {
        // Tarihe göre filtreleme için URL oluşturma
        let url = `${API_BASE}/orders`;
        if (date) {
            url += `?date=${date}`;
        }
        const response = await fetch(url);
        const data = await response.json();
        
        let html = '<table><thead><tr><th>Sipariş No</th><th>Müşteri</th><th>Tarih/Saat</th><th>Ürün Sayısı</th></tr></thead><tbody>';
        
        if (data.length > 0) {
            data.forEach(order => {
                const date = new Date(order.order_time).toLocaleString('tr-TR');
                html += `<tr>
                    <td>#${order.order_id}</td>
                    <td>${order.customer_name}</td>
                    <td>${date}</td>
                    <td>${order.item_count}</td>
                </tr>`;
            });
        } else {
            html += '<tr><td colspan="4">Sipariş bulunamadı</td></tr>';
        }
        
        html += '</tbody></table>';
        document.getElementById('orders-list').innerHTML = html;
    } catch (error) {
        document.getElementById('orders-list').innerHTML = `<div class="error">Hata: ${error.message}</div>`;
    }
}

// Tarihe göre sipariş filtreleme
async function filterOrdersByDate() {
    const dateInput = document.getElementById('order-date').value;
    if (dateInput) {
        await loadOrders(dateInput);
    } else {
        alert('Lütfen bir tarih seçin.');
    }
}

// === RAPORLAR SAYFASI ===
async function loadReport(reportType) {
    try {
        let endpoint = '';
        let tableHeaders = '';
        
        switch(reportType) {
            case 'top-customer-orders':
                endpoint = '/reports/top-customer-orders';
                tableHeaders = '<tr><th>Session ID</th><th>Müşteri</th><th>Toplam Tutar</th><th>Başlangıç Zamanı</th></tr>';
                break;
            case 'category-revenue':
                endpoint = '/reports/category-revenue';
                tableHeaders = '<tr><th>Kategori</th><th>Toplam Satış</th><th>Sipariş Sayısı</th><th>Ort. Sipariş</th></tr>';
                break;
            case 'customer-spending':
                endpoint = '/reports/customer-spending';
                tableHeaders = '<tr><th>Müşteri</th><th>Ziyaret</th><th>Toplam Harcama</th><th>Ort. Harcama</th><th>Son Ziyaret</th></tr>';
                break;
            case 'customer-classification':
                endpoint = '/reports/customer-classification';
                tableHeaders = '<tr><th>Müşteri</th><th>VIP</th><th>Toplam LTV</th><th>Sınıf</th></tr>';
                break;
            case 'table-performance':
                endpoint = '/reports/table-performance';
                tableHeaders = '<tr><th>Masa No</th><th>Kapasite</th><th>Bölge</th><th>Ort. Ciro</th><th>Toplam Ciro</th></tr>';
                break;
            case 'customer-first-last-visit':
                endpoint = '/reports/customer-first-last-visit';
                tableHeaders = '<tr><th>Müşteri</th><th>İlk Ziyaret</th><th>Son Ziyaret</th><th>Gün Farkı</th></tr>';
                break;
            case 'top-menu-items':
                endpoint = '/reports/top-menu-items';
                tableHeaders = '<tr><th>Ürün</th><th>Kategori</th><th>Toplam Adet</th><th>Sipariş Sayısı</th><th>Ort. Fiyat</th></tr>';
                break;
            case 'staff-performance':
                endpoint = '/reports/staff-performance';
                tableHeaders = '<tr><th>Personel</th><th>Rol</th><th>Toplam Sipariş</th><th>Toplam Ciro</th><th>Ort. Sipariş</th></tr>';
                break;
            case 'daily-revenue':
                endpoint = '/reports/daily-revenue';
                tableHeaders = '<tr><th>Tarih</th><th>Oturum Sayısı</th><th>Günlük Ciro</th><th>Ort. Oturum</th></tr>';
                break;
            case 'reservation-status-analysis':
                endpoint = '/reports/reservation-status-analysis';
                tableHeaders = '<tr><th>Durum</th><th>Toplam Rezervasyon</th><th>Yüzde</th><th>Ort. Kişi</th></tr>';
                break;
            case 'dietary-preferences':
                endpoint = '/reports/dietary-preferences';
                tableHeaders = '<tr><th>Kısıtlama</th><th>Kategori</th><th>Sipariş Sayısı</th><th>Toplam Adet</th></tr>';
                break;
        }
        
        const response = await fetch(`${API_BASE}${endpoint}`);
        const data = await response.json();
        
        let html = `<table><thead>${tableHeaders}</thead><tbody>`;
        
        if (data && data.length > 0) {
            data.forEach(item => {
                if (reportType === 'top-customer-orders') {
                    const date = new Date(item.start_time).toLocaleString('tr-TR');
                    html += `<tr><td>#${item.session_id}</td><td>${item.full_name}</td><td>₺${parseFloat(item.total_amount).toFixed(2)}</td><td>${date}</td></tr>`;
                } else if (reportType === 'category-revenue') {
                    html += `<tr><td>${item.category_name}</td><td>₺${parseFloat(item.total_revenue).toFixed(2)}</td><td>${item.order_count}</td><td>₺${parseFloat(item.avg_order_value).toFixed(2)}</td></tr>`;
                } else if (reportType === 'customer-spending') {
                    const date = new Date(item.last_visit).toLocaleDateString('tr-TR');
                    html += `<tr><td>${item.full_name}</td><td>${item.visit_count}</td><td>₺${parseFloat(item.total_spent).toFixed(2)}</td><td>₺${parseFloat(item.avg_per_visit).toFixed(2)}</td><td>${date}</td></tr>`;
                } else if (reportType === 'customer-classification') {
                    html += `<tr><td>${item.full_name}</td><td>${item.vip_status ? 'Evet' : 'Hayır'}</td><td>₺${parseFloat(item.total_ltv).toFixed(2)}</td><td><strong>${item.customer_tier}</strong></td></tr>`;
                } else if (reportType === 'table-performance') {
                    html += `<tr><td>${item.table_id}</td><td>${item.capacity}</td><td>${item.location_zone}</td><td>₺${parseFloat(item.avg_revenue).toFixed(2)}</td><td>₺${parseFloat(item.total_revenue).toFixed(2)}</td></tr>`;
                } else if (reportType === 'customer-first-last-visit') {
                    html += `<tr><td>${item.full_name}</td><td>${new Date(item.first_visit).toLocaleDateString('tr-TR')}</td><td>${new Date(item.last_visit).toLocaleDateString('tr-TR')}</td><td>${item.customer_lifetime_days} gün</td></tr>`;
                } else if (reportType === 'top-menu-items') {
                    html += `<tr><td>${item.item_name}</td><td>${item.category_name}</td><td>${item.total_quantity}</td><td>${item.order_count}</td><td>₺${parseFloat(item.avg_price).toFixed(2)}</td></tr>`;
                } else if (reportType === 'staff-performance') {
                    html += `<tr><td>${item.name}</td><td>${item.role}</td><td>${item.total_orders}</td><td>₺${parseFloat(item.total_revenue).toFixed(2)}</td><td>₺${parseFloat(item.avg_order_value).toFixed(2)}</td></tr>`;
                } else if (reportType === 'daily-revenue') {
                    html += `<tr><td>${new Date(item.date).toLocaleDateString('tr-TR')}</td><td>${item.total_sessions}</td><td>₺${parseFloat(item.daily_revenue).toFixed(2)}</td><td>₺${parseFloat(item.avg_session_revenue).toFixed(2)}</td></tr>`;
                } else if (reportType === 'reservation-status-analysis') {
                    html += `<tr><td>${item.status}</td><td>${item.total_reservations}</td><td>%${parseFloat(item.percentage).toFixed(2)}</td><td>${parseFloat(item.avg_party_size).toFixed(1)}</td></tr>`;
                } else if (reportType === 'dietary-preferences') {
                    html += `<tr><td>${item.restriction_type}</td><td>${item.category_name}</td><td>${item.total_orders}</td><td>${item.total_quantity}</td></tr>`;
                }
            });
        } else {
            html += '<tr><td colspan="5">Veri bulunamadı</td></tr>';
        }
        
        html += '</tbody></table>';
        document.getElementById('reports-content').innerHTML = html;
    } catch (error) {
        document.getElementById('reports-content').innerHTML = `<div class="error">Hata: ${error.message}</div>`;
    }
}

// === GERİ BİLDİRİM SAYFASI ===
async function loadFeedback() {
    try {
        const response = await fetch(`${API_BASE}/feedback`);
        const data = await response.json();
        
        let html = '<table><thead><tr><th>Müşteri</th><th>Rating</th><th>Yorum</th><th>Tarih</th></tr></thead><tbody>';
        
        if (data.length > 0) {
            data.forEach(fb => {
                const date = new Date(fb.start_time).toLocaleString('tr-TR');
                const stars = '⭐'.repeat(fb.rating);
                html += `<tr>
                    <td>${fb.full_name}</td>
                    <td>${stars}</td>
                    <td>${fb.comment || 'Yorum yapılmamış'}</td>
                    <td>${date}</td>
                </tr>`;
            });
        } else {
            html += '<tr><td colspan="4">Geri bildirim bulunamadı</td></tr>';
        }
        
        html += '</tbody></table>';
        document.getElementById('feedback-list').innerHTML = html;
    } catch (error) {
        document.getElementById('feedback-list').innerHTML = `<div class="error">Hata: ${error.message}</div>`;
    }
}

// Sayfa yüklendiğinde menüyü göster
window.addEventListener('load', () => {
    showPage('menu');
});
