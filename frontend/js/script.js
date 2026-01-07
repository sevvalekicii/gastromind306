/**
 * GastroMind - Restaurant Management System
 * Professional Dashboard JavaScript
 */

// =====================================================
// CONFIGURATION
// =====================================================
const API_BASE = 'http://localhost:5000/api';

// Global data storage
let allCustomers = [];
let allReservations = [];
let allOrders = [];
let allMenuItems = [];
let notifications = [];

// =====================================================
// INITIALIZATION
// =====================================================
document.addEventListener('DOMContentLoaded', () => {
    initNavigation();
    initSidebar();
    initModals();
    initRatingInput();
    loadDashboard();
    loadNotifications();
    
    // Close notification dropdown when clicking outside
    document.addEventListener('click', (e) => {
        const dropdown = document.getElementById('notificationDropdown');
        const bell = document.querySelector('.notification-btn');
        if (dropdown && !dropdown.contains(e.target) && !bell?.contains(e.target)) {
            dropdown.classList.remove('active');
        }
    });
});

// =====================================================
// GLOBAL SEARCH
// =====================================================
function globalSearchHandler(event) {
    const searchTerm = event.target.value.toLowerCase().trim();
    
    if (event.key === 'Enter' && searchTerm.length > 0) {
        performGlobalSearch(searchTerm);
    }
}

async function performGlobalSearch(searchTerm) {
    // Önce tüm verilerin yüklendiğinden emin ol
    if (allMenuItems.length === 0) {
        try {
            const menuData = await fetchAPI('/menu');
            allMenuItems = menuData || [];
        } catch (e) { console.error(e); }
    }
    if (allCustomers.length === 0) {
        try {
            const customersData = await fetchAPI('/customers');
            allCustomers = customersData || [];
        } catch (e) { console.error(e); }
    }
    if (allReservations.length === 0) {
        try {
            const reservationsData = await fetchAPI('/reservations');
            allReservations = reservationsData || [];
        } catch (e) { console.error(e); }
    }

    // Search across all data
    const results = {
        customers: allCustomers.filter(c => 
            c.full_name?.toLowerCase().includes(searchTerm) || 
            c.email?.toLowerCase().includes(searchTerm) ||
            c.phone?.includes(searchTerm)
        ),
        reservations: allReservations.filter(r => 
            r.customer_name?.toLowerCase().includes(searchTerm) ||
            r.status?.toLowerCase().includes(searchTerm)
        ),
        menuItems: allMenuItems.filter(m => 
            m.Yemek?.toLowerCase().includes(searchTerm) ||
            m.Kategori?.toLowerCase().includes(searchTerm)
        )
    };
    
    // Show results based on what was found
    if (results.menuItems.length > 0) {
        showPage('menu');
        updateNavActive('menu');
        // Filtrele ve göster
        document.getElementById('menuSearch').value = searchTerm;
        filterMenu();
        showToast(`${results.menuItems.length} menü ürünü bulundu: "${searchTerm}"`, 'success');
    } else if (results.customers.length > 0) {
        showPage('customers');
        updateNavActive('customers');
        document.getElementById('customerSearch').value = searchTerm;
        filterCustomers();
        showToast(`${results.customers.length} müşteri bulundu: "${searchTerm}"`, 'success');
    } else if (results.reservations.length > 0) {
        showPage('reservations');
        updateNavActive('reservations');
        showToast(`${results.reservations.length} rezervasyon bulundu: "${searchTerm}"`, 'success');
    } else {
        showToast(`"${searchTerm}" için sonuç bulunamadı`, 'warning');
    }
}

function updateNavActive(pageId) {
    const navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(nav => {
        nav.classList.remove('active');
        if (nav.dataset.page === pageId) nav.classList.add('active');
    });
}

// =====================================================
// NOTIFICATIONS
// =====================================================
let notificationIdCounter = 10;

function loadNotifications() {
    // LocalStorage'dan bildirimleri yükle veya boş başla
    const saved = localStorage.getItem('gastromind_notifications');
    if (saved) {
        notifications = JSON.parse(saved);
    } else {
        notifications = [];
    }
    
    updateNotificationBadge();
    renderNotifications();
}

function saveNotifications() {
    localStorage.setItem('gastromind_notifications', JSON.stringify(notifications));
}

function addNotification(type, title, message, targetPage = null, targetId = null) {
    const newNotif = {
        id: ++notificationIdCounter,
        type: type,
        title: title,
        message: message,
        time: 'Şimdi',
        read: false,
        targetPage: targetPage,
        targetId: targetId,
        timestamp: Date.now()
    };
    
    // En başa ekle
    notifications.unshift(newNotif);
    
    // Maximum 20 bildirim tut
    if (notifications.length > 20) {
        notifications = notifications.slice(0, 20);
    }
    
    saveNotifications();
    updateNotificationBadge();
    renderNotifications();
    
    // Toast göster
    showToast(`🔔 ${title}: ${message}`, 'info');
}

function updateNotificationBadge() {
    const badge = document.querySelector('.notification-badge');
    const unreadCount = notifications.filter(n => !n.read).length;
    
    if (badge) {
        badge.textContent = unreadCount;
        badge.style.display = unreadCount > 0 ? 'flex' : 'none';
    }
}

function renderNotifications() {
    const container = document.getElementById('notificationList');
    if (!container) return;
    
    if (notifications.length === 0) {
        container.innerHTML = '<div class="notification-empty">Bildirim yok</div>';
        return;
    }
    
    // Zaman güncellemesi
    notifications.forEach(n => {
        const diff = Date.now() - n.timestamp;
        if (diff < 60000) n.time = 'Şimdi';
        else if (diff < 3600000) n.time = Math.floor(diff / 60000) + ' dk önce';
        else if (diff < 86400000) n.time = Math.floor(diff / 3600000) + ' saat önce';
        else n.time = Math.floor(diff / 86400000) + ' gün önce';
    });
    
    container.innerHTML = notifications.map(n => `
        <div class="notification-item ${n.read ? 'read' : 'unread'}" onclick="handleNotificationClick(${n.id})">
            <div class="notification-icon ${n.type}">
                ${getNotificationIcon(n.type)}
            </div>
            <div class="notification-content">
                <div class="notification-title">${n.title}</div>
                <div class="notification-message">${n.message}</div>
                <div class="notification-time">${n.time}</div>
            </div>
        </div>
    `).join('');
}

function getNotificationIcon(type) {
    const icons = {
        reservation: '📅',
        order: '🍽️',
        feedback: '⭐',
        alert: '⚠️',
        customer: '👤',
        menu: '🍕',
        table: '🪑'
    };
    return icons[type] || '📌';
}

function toggleNotifications() {
    const dropdown = document.getElementById('notificationDropdown');
    if (dropdown) {
        dropdown.classList.toggle('active');
    }
}

function handleNotificationClick(id) {
    const notification = notifications.find(n => n.id === id);
    if (!notification) return;
    
    // Okundu olarak işaretle
    notification.read = true;
    saveNotifications();
    updateNotificationBadge();
    renderNotifications();
    
    // İlgili sayfaya git
    if (notification.targetPage) {
        showPage(notification.targetPage);
        updateNavActive(notification.targetPage);
        
        // Dropdown'u kapat
        document.getElementById('notificationDropdown')?.classList.remove('active');
    }
}

function markAsRead(id) {
    const notification = notifications.find(n => n.id === id);
    if (notification) {
        notification.read = true;
        saveNotifications();
        updateNotificationBadge();
        renderNotifications();
    }
}

function clearNotifications() {
    notifications = [];
    saveNotifications();
    updateNotificationBadge();
    renderNotifications();
    showToast('Tüm bildirimler temizlendi', 'success');
}

// =====================================================
// NAVIGATION
// =====================================================
function initNavigation() {
    const navItems = document.querySelectorAll('.nav-item');
    const viewAllLinks = document.querySelectorAll('.view-all');
    
    navItems.forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            const pageId = item.dataset.page;
            showPage(pageId);
            
            // Update active nav
            navItems.forEach(nav => nav.classList.remove('active'));
            item.classList.add('active');
        });
    });
    
    viewAllLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const pageId = link.dataset.page;
            if (pageId) {
                showPage(pageId);
                navItems.forEach(nav => {
                    nav.classList.remove('active');
                    if (nav.dataset.page === pageId) nav.classList.add('active');
                });
            }
        });
    });
}

function showPage(pageId) {
    const pages = document.querySelectorAll('.page');
    pages.forEach(page => page.classList.remove('active'));
    
    const targetPage = document.getElementById(pageId);
    if (targetPage) {
        targetPage.classList.add('active');
        updatePageTitle(pageId);
        loadPageData(pageId);
    }
}

function updatePageTitle(pageId) {
    const titles = {
        'dashboard': { title: 'Dashboard', breadcrumb: 'Genel Bakış' },
        'menu': { title: 'Menü Yönetimi', breadcrumb: 'Menü' },
        'customers': { title: 'Müşteriler', breadcrumb: 'Müşteri Listesi' },
        'reservations': { title: 'Rezervasyonlar', breadcrumb: 'Rezervasyon Listesi' },
        'orders': { title: 'Siparişler', breadcrumb: 'Sipariş Listesi' },
        'tables': { title: 'Masa Durumu', breadcrumb: 'Masa Analizi' },
        'reports': { title: 'Raporlar', breadcrumb: 'Analitik Raporlar' },
        'feedback': { title: 'Geri Bildirimler', breadcrumb: 'Müşteri Yorumları' },
        'staff': { title: 'Personel', breadcrumb: 'Personel Performansı' }
    };
    
    const pageInfo = titles[pageId] || { title: pageId, breadcrumb: pageId };
    document.getElementById('currentPageTitle').textContent = pageInfo.title;
    document.getElementById('breadcrumbCurrent').textContent = pageInfo.breadcrumb;
}

function loadPageData(pageId) {
    switch(pageId) {
        case 'dashboard': loadDashboard(); break;
        case 'menu': loadMenu(); break;
        case 'customers': loadCustomers(); break;
        case 'reservations': loadReservations(); break;
        case 'orders': loadOrders(); break;
        case 'tables': loadTables(); break;
        case 'reports': loadReport('category-revenue'); break;
        case 'feedback': loadFeedback(); break;
        case 'staff': loadStaff(); break;
    }
}

// =====================================================
// SIDEBAR
// =====================================================
function initSidebar() {
    const menuToggle = document.getElementById('menuToggle');
    const sidebar = document.querySelector('.sidebar');
    const appContainer = document.querySelector('.app-container');
    
    // Toggle sidebar on button click
    menuToggle?.addEventListener('click', () => {
        sidebar.classList.toggle('collapsed');
        appContainer.classList.toggle('sidebar-collapsed');
        
        // Save state to localStorage
        const isCollapsed = sidebar.classList.contains('collapsed');
        localStorage.setItem('sidebarCollapsed', isCollapsed);
    });
    
    // Restore sidebar state from localStorage
    const savedState = localStorage.getItem('sidebarCollapsed');
    if (savedState === 'true') {
        sidebar.classList.add('collapsed');
        appContainer.classList.add('sidebar-collapsed');
    }
    
    // Close sidebar on outside click (mobile)
    document.addEventListener('click', (e) => {
        if (window.innerWidth <= 992) {
            if (!sidebar.contains(e.target) && !menuToggle.contains(e.target)) {
                sidebar.classList.add('collapsed');
                appContainer.classList.add('sidebar-collapsed');
            }
        }
    });
    
    // Refresh button
    document.getElementById('refreshData')?.addEventListener('click', () => {
        const activePage = document.querySelector('.page.active');
        if (activePage) {
            loadPageData(activePage.id);
            showToast('Veriler yenilendi', 'success');
        }
    });
}

// =====================================================
// DASHBOARD
// =====================================================
async function loadDashboard() {
    try {
        // Load all dashboard data in parallel
        const [customers, reservations, orders, feedback, vipCustomers, pendingRes] = await Promise.all([
            fetchAPI('/customers'),
            fetchAPI('/reservations'),
            fetchAPI('/orders'),
            fetchAPI('/feedback/rating-summary'),
            fetchAPI('/customers/vip'),
            fetchAPI('/reservations/pending')
        ]);
        
        // Store globally
        allCustomers = customers || [];
        allReservations = reservations || [];
        allOrders = orders || [];
        
        // Update stats
        document.getElementById('totalCustomers').textContent = customers?.length || 0;
        document.getElementById('totalReservations').textContent = reservations?.length || 0;
        
        // Calculate total revenue from customer LTV
        const totalRevenue = customers?.reduce((sum, c) => sum + parseFloat(c.total_ltv || 0), 0) || 0;
        document.getElementById('totalRevenue').textContent = formatCurrency(totalRevenue);
        
        // Average rating
        document.getElementById('avgRating').textContent = feedback?.avg_rating 
            ? parseFloat(feedback.avg_rating).toFixed(1) + ' ★' 
            : '-';
        
        // Recent orders
        renderRecentOrders(orders?.slice(0, 5) || []);
        
        // VIP customers
        renderVipCustomers(vipCustomers?.slice(0, 5) || []);
        
        // Rating distribution
        renderRatingDistribution(feedback);
        
        // Pending reservations
        renderPendingReservations(pendingRes?.slice(0, 4) || []);
        
    } catch (error) {
        console.error('Dashboard error:', error);
        showToast('Dashboard yüklenirken hata oluştu', 'error');
    }
}

function renderRecentOrders(orders) {
    const container = document.getElementById('recentOrdersList');
    if (!orders.length) {
        container.innerHTML = '<div class="no-data">Henüz sipariş yok</div>';
        return;
    }
    
    container.innerHTML = orders.map(order => `
        <div class="list-item">
            <div class="list-item-info">
                <div class="list-item-avatar">#${order.order_id}</div>
                <div class="list-item-text">
                    <h4>${order.customer_name || 'Misafir'}</h4>
                    <span>${formatDate(order.order_time)}</span>
                </div>
            </div>
            <span class="list-item-value">${order.item_count} ürün</span>
        </div>
    `).join('');
}

function renderVipCustomers(customers) {
    const container = document.getElementById('vipCustomersList');
    if (!customers.length) {
        container.innerHTML = '<div class="no-data">VIP müşteri bulunamadı</div>';
        return;
    }
    
    container.innerHTML = customers.map(customer => {
        const photoUrl = getCustomerPhoto(customer.full_name);
        return `
        <div class="list-item">
            <div class="list-item-info">
                ${photoUrl 
                    ? `<img src="${photoUrl}" alt="${customer.full_name}" class="customer-photo" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex'"><div class="list-item-avatar" style="display:none">${getInitials(customer.full_name)}</div>`
                    : `<div class="list-item-avatar">${getInitials(customer.full_name)}</div>`
                }
                <div class="list-item-text">
                    <h4>${customer.full_name}</h4>
                    <span>VIP Üye</span>
                </div>
            </div>
            <span class="list-item-value">${formatCurrency(customer.total_ltv)}</span>
        </div>
    `}).join('');
}

function renderRatingDistribution(feedback) {
    const container = document.getElementById('ratingDistribution');
    if (!feedback) {
        container.innerHTML = '<div class="no-data">Veri yok</div>';
        return;
    }
    
    const total = feedback.total_feedback || 1;
    const ratings = [
        { stars: 5, count: feedback.five_star || 0 },
        { stars: 4, count: feedback.four_star || 0 },
        { stars: 3, count: feedback.three_star || 0 },
        { stars: 2, count: feedback.low_rating || 0 },
        { stars: 1, count: 0 }
    ];
    
    container.innerHTML = ratings.map(r => `
        <div class="rating-bar-item">
            <span class="rating-bar-label"><span class="star">★</span> ${r.stars}</span>
            <div class="rating-bar-track">
                <div class="rating-bar-fill" style="width: ${(r.count / total) * 100}%"></div>
            </div>
            <span class="rating-bar-count">${r.count}</span>
        </div>
    `).join('');
}

function renderPendingReservations(reservations) {
    const container = document.getElementById('pendingReservationsList');
    if (!reservations.length) {
        container.innerHTML = '<div class="no-data">Bekleyen rezervasyon yok</div>';
        return;
    }
    
    container.innerHTML = reservations.map(res => {
        const photoUrl = getCustomerPhoto(res.full_name);
        return `
        <div class="list-item">
            <div class="list-item-info">
                ${photoUrl 
                    ? `<img src="${photoUrl}" alt="${res.full_name}" class="customer-photo" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex'"><div class="list-item-avatar" style="display:none">${getInitials(res.full_name)}</div>`
                    : `<div class="list-item-avatar">${getInitials(res.full_name)}</div>`
                }
                <div class="list-item-text">
                    <h4>${res.full_name}</h4>
                    <span>Masa ${res.table_id} • ${res.party_size} kişi</span>
                </div>
            </div>
            <span class="status-badge pending">Bekliyor</span>
        </div>
    `}).join('');
}

// =====================================================
// MENU
// =====================================================
async function loadMenu() {
    try {
        const data = await fetchAPI('/menu');
        allMenuItems = data || [];
        renderMenuTable(data);
        loadCategories();
        initMenuFilters();
    } catch (error) {
        console.error('Menu error:', error);
        document.getElementById('menuGrid').innerHTML = 
            '<div class="loading-cell">Menü yüklenemedi</div>';
    }
}

function renderMenuTable(items) {
    const menuGrid = document.getElementById('menuGrid');
    
    // API'den error dönerse veya array değilse
    if (!items || items.error || !Array.isArray(items) || items.length === 0) {
        menuGrid.innerHTML = '<div class="loading-cell">Menü öğesi bulunamadı veya veritabanı bağlantı hatası</div>';
        return;
    }
    
    menuGrid.innerHTML = items.map(item => {
        const imageUrl = getMenuItemImage(item.Kategori, item.Yemek);
        return `
            <div class="menu-card" onclick="showMenuItemImage('${item.Yemek}', '${imageUrl}', '${item.Kategori}', '${formatCurrency(item.Fiyat)}')">
                <div class="menu-card-image">
                    <img src="${imageUrl}" alt="${item.Yemek}" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop'">
                    <span class="menu-card-category">${item.Kategori}</span>
                </div>
                <div class="menu-card-content">
                    <h3 class="menu-card-title">${item.Yemek}</h3>
                    <div class="menu-card-info">
                        <span class="menu-card-time">⏱️ ${item.Hazirlanma} dk</span>
                        <span class="status-badge active">Aktif</span>
                    </div>
                    <div class="menu-card-price">${formatCurrency(item.Fiyat)}</div>
                </div>
            </div>
        `;
    }).join('');
}

// Menü fotoğrafını modal'da göster
function showMenuItemImage(yemekAdi, imageUrl, kategori, fiyat) {
    const existingModal = document.getElementById('menuImageModal');
    if (existingModal) existingModal.remove();
    
    const modal = document.createElement('div');
    modal.id = 'menuImageModal';
    modal.className = 'table-image-modal';
    modal.innerHTML = `
        <div class="table-image-overlay" onclick="closeMenuImageModal()"></div>
        <div class="table-image-content menu-image-content">
            <button class="table-image-close" onclick="closeMenuImageModal()">&times;</button>
            <img src="${imageUrl}" alt="${yemekAdi}" class="table-image-img" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop'">
            <div class="menu-image-info">
                <h3>${yemekAdi}</h3>
                <span class="menu-image-category">${kategori}</span>
                <span class="menu-image-price">${fiyat}</span>
            </div>
        </div>
    `;
    document.body.appendChild(modal);
    
    setTimeout(() => modal.classList.add('active'), 10);
}

function closeMenuImageModal() {
    const modal = document.getElementById('menuImageModal');
    if (modal) {
        modal.classList.remove('active');
        setTimeout(() => modal.remove(), 300);
    }
}
function getMenuItemImage(kategori, yemekAdi) {
    // Yemek bazlı fotoğraflar (dosya adı = yemek adı)
    const menuPhotos = {
        'Dana Carpaccio': 'Dana Carpaccio.webp',
        'Trüflü Patates': 'Trüflü Patates.jpg',
        'Wagyu Burger': 'Wagyu Burger.jpg',
        'Kuzu Kafes (2 Kişilik)': 'Kuzu Kafes (2 Kişilik).webp',
        'Izgara Levrek': 'Izgara Levrek.jpg',
        'Jumbo Karides': 'Jumbo Karides.jpg',
        'Trüflü Risotto': 'Trüflü Risotto.jpg',
        'Deniz Mahsullü Linguine': 'Deniz Mahsullü Linguine.jpg',
        'San Sebastian Cheesecake': 'San Sebastian Cheesecake.jpg',
        'Çikolatalı Sufle': 'Çikolatalı Sufle.webp',
        'Château Margaux (Şişe)': 'Château Margaux (Şişe).jpg',
        'Ev Yapımı Limonata': 'Ev Yapımı Limonata.jpg'
    };
    
    // Önce yemek bazlı fotoğraf var mı kontrol et
    if (menuPhotos[yemekAdi]) {
        return `images/menu/${menuPhotos[yemekAdi]}`;
    }
    
    // Yoksa kategoriye göre varsayılan görsel URL'leri (Unsplash)
    const categoryImages = {
        'Başlangıçlar': 'https://images.unsplash.com/photo-1541014741259-de529411b96a?w=400&h=300&fit=crop',
        'Ana Yemekler': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&h=300&fit=crop',
        'Salatalar': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop',
        'Tatlılar': 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400&h=300&fit=crop',
        'İçecekler': 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&h=300&fit=crop',
        'Corbalar': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&h=300&fit=crop',
        'Çorbalar': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&h=300&fit=crop',
        'Pizzalar': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=300&fit=crop',
        'Burgerler': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop',
        'Makarnalar': 'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=400&h=300&fit=crop',
        'Deniz Ürünleri': 'https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?w=400&h=300&fit=crop',
        'Izgara': 'https://images.unsplash.com/photo-1558030006-450675393462?w=400&h=300&fit=crop',
        'Kahvaltı': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400&h=300&fit=crop'
    };
    
    return categoryImages[kategori] || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop';
}

async function loadCategories() {
    const select = document.getElementById('categoryFilter');
    const categories = [...new Set(allMenuItems.map(item => item.Kategori))];
    
    select.innerHTML = '<option value="">Tüm Kategoriler</option>' + 
        categories.map(cat => `<option value="${cat}">${cat}</option>`).join('');
}

function initMenuFilters() {
    const categoryFilter = document.getElementById('categoryFilter');
    const searchInput = document.getElementById('menuSearch');
    
    categoryFilter?.addEventListener('change', filterMenu);
    searchInput?.addEventListener('input', filterMenu);
}

function filterMenu() {
    const category = document.getElementById('categoryFilter').value;
    const search = document.getElementById('menuSearch').value.toLowerCase();
    
    let filtered = allMenuItems;
    
    if (category) {
        filtered = filtered.filter(item => item.Kategori === category);
    }
    
    if (search) {
        filtered = filtered.filter(item => 
            item.Yemek.toLowerCase().includes(search)
        );
    }
    
    renderMenuTable(filtered);
}

// =====================================================
// CUSTOMERS
// =====================================================
async function loadCustomers() {
    try {
        const data = await fetchAPI('/customers');
        allCustomers = data || [];
        renderCustomersTable(data);
        initCustomerFilters();
        populateCustomerSelect();
    } catch (error) {
        console.error('Customers error:', error);
    }
}

function renderCustomersTable(customers) {
    const tbody = document.getElementById('customersTableBody');
    if (!customers?.length) {
        tbody.innerHTML = '<tr><td colspan="6" class="loading-cell">Müşteri bulunamadı</td></tr>';
        return;
    }
    
    tbody.innerHTML = customers.map(c => {
        const photoUrl = getCustomerPhoto(c.full_name);
        return `
        <tr>
            <td>
                <div style="display: flex; align-items: center; gap: 12px;">
                    ${photoUrl 
                        ? `<img src="${photoUrl}" alt="${c.full_name}" class="customer-photo" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex'"><div class="list-item-avatar" style="display:none">${getInitials(c.full_name)}</div>`
                        : `<div class="list-item-avatar">${getInitials(c.full_name)}</div>`
                    }
                    <strong>${c.full_name}</strong>
                </div>
            </td>
            <td>
                <div>${c.phone || '-'}</div>
                <small style="color: var(--text-muted)">${c.email || '-'}</small>
            </td>
            <td><strong>${formatCurrency(c.total_ltv)}</strong></td>
            <td>
                <span class="status-badge ${c.vip_status ? 'vip' : 'active'}">
                    ${c.vip_status ? 'VIP' : 'Regular'}
                </span>
            </td>
            <td>
                <button class="btn btn-sm btn-outline" onclick="showDietaryInfo(${c.customer_id})">
                    Görüntüle
                </button>
            </td>
            <td>
                <div class="action-buttons">
                    <button class="btn btn-sm btn-primary" onclick="openReservationForCustomer(${c.customer_id})" title="Rezervasyon">
                        📅
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="deleteCustomer(${c.customer_id})" title="Sil (DELETE)">
                        🗑️
                    </button>
                </div>
            </td>
        </tr>
    `}).join('');
}

// Müşteri fotoğrafı al - isim bazlı
function getCustomerPhoto(fullName) {
    // Fotoğrafı olan müşteriler (dosya adı = tam isim.webp)
    const customerPhotos = {
        'Hakan Çalhanoğlu': 'Hakan Çalhanoğlu.webp',
        'Arda Güler': 'Arda Güler.webp',
        'Cenk Tosun': 'Cenk Tosun.webp',
        'Mert Günok': 'Mert Günok.webp',
        'Kerem Aktürkoğlu': 'Kerem Aktürkoğlu.webp',
        'Ferdi Kadıoğlu': 'Ferdi Kadıoğlu.webp',
        'Barış Alper Yılmaz': 'Barış Alper Yılmaz.webp',
        'Merih Demiral': 'Merih Demiral.webp',
        'Abdülkerim Bardakcı': 'Abdülkerim Bardakcı.webp',
        'Kenan Yıldız': 'Kenan Yıldız.webp',
        'Semih Kılıçsoy': 'Semih Kılıçsoy.webp',
        'İsmail Yüksek': 'İsmail Yüksek.webp',
        'Salih Özcan': 'Salih Özcan.webp',
        'Altay Bayındır': 'Altay Bayındır.webp',
        'İrfan Can Kahveci': 'İrfan Can Kahveci.webp'
    };
    
    if (customerPhotos[fullName]) {
        return `images/customers/${customerPhotos[fullName]}`;
    }
    return null;
}

function initCustomerFilters() {
    const filterBtns = document.querySelectorAll('#customers .filter-btn');
    const searchInput = document.getElementById('customerSearch');
    
    filterBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            filterBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            filterCustomers();
        });
    });
    
    searchInput?.addEventListener('input', filterCustomers);
}

function filterCustomers() {
    const activeFilter = document.querySelector('#customers .filter-btn.active')?.dataset.filter || 'all';
    const search = document.getElementById('customerSearch')?.value.toLowerCase() || '';
    
    let filtered = allCustomers;
    
    if (activeFilter === 'vip') {
        filtered = filtered.filter(c => c.vip_status);
    } else if (activeFilter === 'regular') {
        filtered = filtered.filter(c => !c.vip_status);
    }
    
    if (search) {
        filtered = filtered.filter(c => 
            c.full_name.toLowerCase().includes(search) ||
            (c.email && c.email.toLowerCase().includes(search))
        );
    }
    
    renderCustomersTable(filtered);
}

async function showDietaryInfo(customerId) {
    try {
        const data = await fetchAPI(`/customers/dietary/${customerId}`);
        const content = document.getElementById('dietaryContent');
        
        if (data?.length) {
            content.innerHTML = `
                <div class="dietary-tags">
                    ${data.map(d => `<span class="dietary-tag">${d.restriction_type}</span>`).join('')}
                </div>
            `;
        } else {
            content.innerHTML = '<p class="no-data">Bu müşterinin diyet kısıtlaması bulunmuyor.</p>';
        }
        
        openModal('dietaryModal');
    } catch (error) {
        showToast('Bilgiler yüklenemedi', 'error');
    }
}

function openReservationForCustomer(customerId) {
    openModal('reservationModal');
    setTimeout(() => {
        document.getElementById('resCustomerId').value = customerId;
    }, 100);
}

function populateCustomerSelect() {
    const select = document.getElementById('resCustomerId');
    if (select && allCustomers.length) {
        select.innerHTML = '<option value="">Müşteri Seçin</option>' +
            allCustomers.map(c => `<option value="${c.customer_id}">${c.full_name}</option>`).join('');
    }
}

// =====================================================
// RESERVATIONS
// =====================================================
async function loadReservations() {
    try {
        const data = await fetchAPI('/reservations');
        allReservations = data || [];
        renderReservationsTable(data);
        initReservationFilters();
        loadTablesForSelect();
    } catch (error) {
        console.error('Reservations error:', error);
    }
}

function renderReservationsTable(reservations) {
    const tbody = document.getElementById('reservationsTableBody');
    if (!reservations?.length) {
        tbody.innerHTML = '<tr><td colspan="5" class="loading-cell">Rezervasyon bulunamadı</td></tr>';
        return;
    }
    
    tbody.innerHTML = reservations.map(r => `
        <tr>
            <td><strong>${r.customer_name}</strong></td>
            <td>Masa ${r.table_id}</td>
            <td>${formatDateTime(r.reservation_time)}</td>
            <td>${r.party_size} kişi</td>
            <td><span class="status-badge ${r.status}">${translateStatus(r.status)}</span></td>
        </tr>
    `).join('');
}

function initReservationFilters() {
    const filterBtns = document.querySelectorAll('#reservations .filter-btn');
    
    filterBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            filterBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            
            const filter = btn.dataset.filter;
            const filtered = filter === 'all' 
                ? allReservations 
                : allReservations.filter(r => r.status === filter);
            
            renderReservationsTable(filtered);
        });
    });
}

async function loadTablesForSelect() {
    try {
        const tables = await fetchAPI('/reports/table-performance');
        const select = document.getElementById('resTableId');
        if (select && tables?.length) {
            select.innerHTML = '<option value="">Masa Seçin</option>' +
                tables.map(t => `<option value="${t.table_id}">Masa ${t.table_id} (${t.capacity} kişilik - ${t.location_zone})</option>`).join('');
        }
    } catch (error) {
        console.error('Tables load error:', error);
    }
}

async function submitReservation(event) {
    event.preventDefault();
    
    const data = {
        customer_id: parseInt(document.getElementById('resCustomerId').value),
        table_id: parseInt(document.getElementById('resTableId').value),
        party_size: parseInt(document.getElementById('resPartySize').value),
        reservation_time: document.getElementById('resDateTime').value
    };
    
    try {
        const response = await fetch(`${API_BASE}/reservations`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        
        if (response.ok) {
            // Bildirim ekle
            const selectedCustomer = document.getElementById('resCustomerId');
            const customerName = selectedCustomer.options[selectedCustomer.selectedIndex]?.text || 'Misafir';
            
            addNotification(
                'reservation',
                'Yeni Rezervasyon',
                `${customerName} - Masa ${data.table_id}, ${data.party_size} kişi`,
                'reservations'
            );
            
            closeModal('reservationModal');
            document.getElementById('reservationForm').reset();
            loadReservations();
        } else {
            showToast('Rezervasyon oluşturulamadı', 'error');
        }
    } catch (error) {
        showToast('Bir hata oluştu', 'error');
    }
}

// =====================================================
// ORDERS
// =====================================================
async function loadOrders(date = null) {
    try {
        let url = '/orders';
        if (date) url += `?date=${date}`;
        
        const data = await fetchAPI(url);
        allOrders = data || [];
        renderOrdersTable(data);
    } catch (error) {
        console.error('Orders error:', error);
    }
}

function renderOrdersTable(orders) {
    const tbody = document.getElementById('ordersTableBody');
    if (!orders?.length) {
        tbody.innerHTML = '<tr><td colspan="5" class="loading-cell">Sipariş bulunamadı</td></tr>';
        return;
    }
    
    tbody.innerHTML = orders.map(o => `
        <tr>
            <td><strong>#${o.order_id}</strong></td>
            <td>${o.customer_name || 'Misafir'}</td>
            <td>${formatDateTime(o.order_time)}</td>
            <td>${o.item_count} ürün</td>
            <td>
                <button class="btn btn-sm btn-outline" onclick="showOrderDetails(${o.order_id})">
                    Detay
                </button>
            </td>
        </tr>
    `).join('');
}

function filterOrders() {
    const date = document.getElementById('orderDateFilter').value;
    if (date) {
        loadOrders(date);
    } else {
        showToast('Lütfen bir tarih seçin', 'warning');
    }
}

async function showOrderDetails(orderId) {
    try {
        const data = await fetchAPI(`/orders/${orderId}/details`);
        const content = document.getElementById('orderDetailsContent');
        
        if (data?.length) {
            const total = data.reduce((sum, item) => sum + parseFloat(item.total_price || 0), 0);
            
            content.innerHTML = `
                <table class="order-details-table">
                    <thead>
                        <tr>
                            <th>Ürün</th>
                            <th>Adet</th>
                            <th>Birim Fiyat</th>
                            <th>Toplam</th>
                            <th>Not</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${data.map(item => `
                            <tr>
                                <td><strong>${item.item_name}</strong></td>
                                <td>${item.quantity}</td>
                                <td>${formatCurrency(item.price)}</td>
                                <td><strong>${formatCurrency(item.total_price)}</strong></td>
                                <td><em>${item.special_note || '-'}</em></td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
                <div class="order-total">
                    Toplam: <span>${formatCurrency(total)}</span>
                </div>
            `;
        } else {
            content.innerHTML = '<p class="no-data">Sipariş detayı bulunamadı.</p>';
        }
        
        openModal('orderDetailsModal');
    } catch (error) {
        showToast('Detaylar yüklenemedi', 'error');
    }
}

// =====================================================
// TABLES
// =====================================================
async function loadTables() {
    try {
        const data = await fetchAPI('/reports/table-performance');
        renderTablesGrid(data);
    } catch (error) {
        console.error('Tables error:', error);
    }
}

function renderTablesGrid(tables) {
    const container = document.getElementById('tablesGrid');
    if (!tables?.length) {
        container.innerHTML = '<div class="no-data">Masa verisi bulunamadı</div>';
        return;
    }
    
    container.innerHTML = tables.map(t => {
        const bgImage = getTableBackgroundImage(t.location_zone);
        return `
        <div class="table-card" onclick="showTableImage('${t.location_zone}', '${bgImage}')" style="background-image: linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.4)), url('${bgImage}'); background-size: cover; background-position: center; cursor: pointer;">
            <div class="table-card-header">
                <h4>Masa ${t.table_id}</h4>
                <span class="status-badge ${t.completed_sessions > 0 ? 'active' : 'pending'}">
                    ${t.completed_sessions > 0 ? 'Aktif' : 'Boş'}
                </span>
            </div>
            <div class="table-card-body">
                <div class="table-info-row">
                    <span>Kapasite</span>
                    <span>${t.capacity} kişi</span>
                </div>
                <div class="table-info-row">
                    <span>Bölge</span>
                    <span>${t.location_zone}</span>
                </div>
                <div class="table-info-row">
                    <span>Toplam Rezervasyon</span>
                    <span>${t.total_bookings}</span>
                </div>
                <div class="table-info-row">
                    <span>Ortalama Ciro</span>
                    <span>${formatCurrency(t.avg_revenue || 0)}</span>
                </div>
                <div class="table-info-row">
                    <span>Toplam Ciro</span>
                    <span><strong>${formatCurrency(t.total_revenue || 0)}</strong></span>
                </div>
            </div>
        </div>
    `}).join('');
}

// Masa fotoğrafını modal'da göster
function showTableImage(locationZone, imageUrl) {
    // Modal oluştur
    const existingModal = document.getElementById('tableImageModal');
    if (existingModal) existingModal.remove();
    
    const modal = document.createElement('div');
    modal.id = 'tableImageModal';
    modal.className = 'table-image-modal';
    modal.innerHTML = `
        <div class="table-image-overlay" onclick="closeTableImageModal()"></div>
        <div class="table-image-content">
            <button class="table-image-close" onclick="closeTableImageModal()">&times;</button>
            <h3 class="table-image-title">${locationZone}</h3>
            <img src="${imageUrl}" alt="${locationZone}" class="table-image-img">
        </div>
    `;
    document.body.appendChild(modal);
    
    // Animasyon için küçük gecikme
    setTimeout(() => modal.classList.add('active'), 10);
}

function closeTableImageModal() {
    const modal = document.getElementById('tableImageModal');
    if (modal) {
        modal.classList.remove('active');
        setTimeout(() => modal.remove(), 300);
    }
}

// Masa bölgesine göre arka plan fotoğrafı
function getTableBackgroundImage(locationZone) {
    const tableImages = {
        'Cam Kenarı A': 'images/tables/Cam Kenarı A.webp',
        'Salon Merkez': 'images/tables/Salon Merkez.webp',
        'VIP Loca': 'images/tables/VIP Loca.webp',
        'Teras': 'images/tables/Teras.webp',
        'Bar': 'images/tables/Bar.webp',
        'Bahçe': 'images/tables/Bahçe.webp'
    };
    
    return tableImages[locationZone] || 'images/tables/Salon Merkez.webp';
}

// =====================================================
// REPORTS
// =====================================================
document.querySelectorAll('.report-tab').forEach(tab => {
    tab.addEventListener('click', () => {
        document.querySelectorAll('.report-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        loadReport(tab.dataset.report);
    });
});

async function loadReport(reportType) {
    const reportConfigs = {
        'category-revenue': {
            title: 'Kategori Bazlı Satış Raporu',
            headers: ['Kategori', 'Toplam Satış', 'Sipariş Sayısı', 'Ort. Sipariş'],
            render: (item) => `
                <tr>
                    <td><strong>${item.category_name}</strong></td>
                    <td>${formatCurrency(item.total_revenue)}</td>
                    <td>${item.order_count}</td>
                    <td>${formatCurrency(item.avg_order_value)}</td>
                </tr>
            `
        },
        'customer-spending': {
            title: 'Müşteri Harcama Analizi',
            headers: ['Müşteri', 'VIP', 'Ziyaret', 'Toplam Harcama', 'Ort. Harcama', 'Son Ziyaret'],
            render: (item) => `
                <tr>
                    <td><strong>${item.full_name}</strong></td>
                    <td><span class="status-badge ${item.vip_status ? 'vip' : 'active'}">${item.vip_status ? 'VIP' : 'Regular'}</span></td>
                    <td>${item.visit_count}</td>
                    <td><strong>${formatCurrency(item.total_spent)}</strong></td>
                    <td>${formatCurrency(item.avg_per_visit)}</td>
                    <td>${formatDate(item.last_visit)}</td>
                </tr>
            `
        },
        'customer-classification': {
            title: 'Müşteri Sınıflandırması',
            headers: ['Müşteri', 'VIP Durumu', 'Toplam LTV', 'Sınıf'],
            render: (item) => `
                <tr>
                    <td><strong>${item.full_name}</strong></td>
                    <td>${item.vip_status ? 'Evet' : 'Hayır'}</td>
                    <td>${formatCurrency(item.total_ltv)}</td>
                    <td><span class="tier-badge ${item.customer_tier.toLowerCase()}">${item.customer_tier}</span></td>
                </tr>
            `
        },
        'table-performance': {
            title: 'Masa Performans Analizi',
            headers: ['Masa', 'Kapasite', 'Bölge', 'Rezervasyon', 'Ort. Ciro', 'Toplam Ciro'],
            render: (item) => `
                <tr>
                    <td><strong>Masa ${item.table_id}</strong></td>
                    <td>${item.capacity} kişi</td>
                    <td>${item.location_zone}</td>
                    <td>${item.total_bookings}</td>
                    <td>${formatCurrency(item.avg_revenue || 0)}</td>
                    <td><strong>${formatCurrency(item.total_revenue || 0)}</strong></td>
                </tr>
            `
        },
        'top-menu-items': {
            title: 'En Popüler Menü Öğeleri',
            headers: ['Ürün', 'Kategori', 'Toplam Adet', 'Sipariş Sayısı', 'Ort. Fiyat'],
            render: (item) => `
                <tr>
                    <td><strong>${item.item_name}</strong></td>
                    <td>${item.category_name}</td>
                    <td>${item.total_quantity}</td>
                    <td>${item.order_count}</td>
                    <td>${formatCurrency(item.avg_price)}</td>
                </tr>
            `
        },
        'staff-performance': {
            title: 'Personel Performans Raporu',
            headers: ['Personel', 'Rol', 'Toplam Sipariş', 'Toplam Ciro', 'Ort. Sipariş Değeri'],
            render: (item) => `
                <tr>
                    <td><strong>${item.name}</strong></td>
                    <td>${item.role}</td>
                    <td>${item.total_orders}</td>
                    <td><strong>${formatCurrency(item.total_revenue)}</strong></td>
                    <td>${formatCurrency(item.avg_order_value)}</td>
                </tr>
            `
        },
        'daily-revenue': {
            title: 'Günlük Ciro Raporu',
            headers: ['Tarih', 'Oturum Sayısı', 'Günlük Ciro', 'Ort. Oturum Değeri'],
            render: (item) => `
                <tr>
                    <td><strong>${formatDate(item.date)}</strong></td>
                    <td>${item.total_sessions}</td>
                    <td><strong>${formatCurrency(item.daily_revenue)}</strong></td>
                    <td>${formatCurrency(item.avg_session_revenue)}</td>
                </tr>
            `
        },
        'customer-first-last-visit': {
            title: 'Müşteri Yaşam Döngüsü',
            headers: ['Müşteri', 'İlk Ziyaret', 'Son Ziyaret', 'Müşteri Yaşı (Gün)'],
            render: (item) => `
                <tr>
                    <td><strong>${item.full_name}</strong></td>
                    <td>${formatDate(item.first_visit)}</td>
                    <td>${formatDate(item.last_visit)}</td>
                    <td>${item.customer_lifetime_days} gün</td>
                </tr>
            `
        },
        'reservation-status-analysis': {
            title: 'Rezervasyon Durum Analizi',
            headers: ['Durum', 'Toplam', 'Yüzde', 'Ort. Kişi Sayısı'],
            render: (item) => `
                <tr>
                    <td><span class="status-badge ${item.status}">${translateStatus(item.status)}</span></td>
                    <td>${item.total_reservations}</td>
                    <td>%${parseFloat(item.percentage).toFixed(1)}</td>
                    <td>${parseFloat(item.avg_party_size).toFixed(1)}</td>
                </tr>
            `
        },
        'dietary-preferences': {
            title: 'Diyet Tercihi Analizi',
            headers: ['Kısıtlama Türü', 'Kategori', 'Sipariş Sayısı', 'Toplam Adet'],
            render: (item) => `
                <tr>
                    <td><strong>${item.restriction_type}</strong></td>
                    <td>${item.category_name}</td>
                    <td>${item.total_orders}</td>
                    <td>${item.total_quantity}</td>
                </tr>
            `
        }
    };
    
    const config = reportConfigs[reportType];
    if (!config) return;
    
    document.getElementById('reportTitle').textContent = config.title;
    document.getElementById('reportTableHead').innerHTML = 
        `<tr>${config.headers.map(h => `<th>${h}</th>`).join('')}</tr>`;
    document.getElementById('reportTableBody').innerHTML = 
        '<tr><td colspan="6" class="loading-cell">Yükleniyor...</td></tr>';
    
    try {
        const data = await fetchAPI(`/reports/${reportType}`);
        
        if (data?.length) {
            document.getElementById('reportTableBody').innerHTML = data.map(config.render).join('');
        } else {
            document.getElementById('reportTableBody').innerHTML = 
                `<tr><td colspan="${config.headers.length}" class="loading-cell">Veri bulunamadı</td></tr>`;
        }
    } catch (error) {
        document.getElementById('reportTableBody').innerHTML = 
            `<tr><td colspan="${config.headers.length}" class="loading-cell">Rapor yüklenemedi</td></tr>`;
    }
}

// =====================================================
// FEEDBACK
// =====================================================
async function loadFeedback() {
    try {
        const [feedbacks, summary] = await Promise.all([
            fetchAPI('/feedback'),
            fetchAPI('/feedback/rating-summary')
        ]);
        
        renderFeedbackStats(summary);
        renderFeedbackGrid(feedbacks);
    } catch (error) {
        console.error('Feedback error:', error);
    }
}

function renderFeedbackStats(summary) {
    const container = document.getElementById('feedbackStats');
    if (!summary) return;
    
    container.innerHTML = `
        <div class="feedback-stat-item">
            <div class="stat-icon blue">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                </svg>
            </div>
            <div class="stat-content">
                <span class="stat-value">${summary.total_feedback || 0}</span>
                <span class="stat-label">Toplam Yorum</span>
            </div>
        </div>
        <div class="feedback-stat-item">
            <div class="stat-icon orange">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
                </svg>
            </div>
            <div class="stat-content">
                <span class="stat-value">${summary.avg_rating ? parseFloat(summary.avg_rating).toFixed(1) : '-'}</span>
                <span class="stat-label">Ortalama Puan</span>
            </div>
        </div>
        <div class="feedback-stat-item">
            <div class="stat-icon green">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                    <polyline points="22 4 12 14.01 9 11.01"></polyline>
                </svg>
            </div>
            <div class="stat-content">
                <span class="stat-value">${summary.five_star || 0}</span>
                <span class="stat-label">5 Yıldız</span>
            </div>
        </div>
    `;
}

function renderFeedbackGrid(feedbacks) {
    const container = document.getElementById('feedbackGrid');
    if (!feedbacks?.length) {
        container.innerHTML = '<div class="no-data">Henüz geri bildirim yok</div>';
        return;
    }
    
    container.innerHTML = feedbacks.map(fb => {
        const photoUrl = getCustomerPhoto(fb.full_name);
        return `
        <div class="feedback-card">
            <div class="feedback-card-header">
                <div class="feedback-user">
                    ${photoUrl 
                        ? `<img src="${photoUrl}" alt="${fb.full_name}" class="customer-photo feedback-photo" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex'"><div class="feedback-avatar" style="display:none">${getInitials(fb.full_name)}</div>`
                        : `<div class="feedback-avatar">${getInitials(fb.full_name)}</div>`
                    }
                    <div class="feedback-user-info">
                        <h4>${fb.full_name}</h4>
                        <span>${formatDate(fb.start_time)}</span>
                    </div>
                </div>
                <div class="feedback-rating">${'★'.repeat(fb.rating)}${'☆'.repeat(5 - fb.rating)}</div>
            </div>
            <p class="feedback-comment">${fb.comment || 'Yorum yapılmamış.'}</p>
        </div>
    `}).join('');
}

async function submitFeedback(event) {
    event.preventDefault();
    
    const rating = parseInt(document.getElementById('fbRating').value);
    if (rating < 1) {
        showToast('Lütfen bir puan seçin', 'warning');
        return;
    }
    
    const data = {
        session_id: parseInt(document.getElementById('fbSessionId').value),
        rating: rating,
        comment: document.getElementById('fbComment').value
    };
    
    try {
        const response = await fetch(`${API_BASE}/feedback`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        
        if (response.ok) {
            // Bildirim ekle
            addNotification(
                'feedback',
                'Yeni Geri Bildirim',
                `${rating} yıldız değerlendirme alındı`,
                'feedback'
            );
            
            closeModal('feedbackModal');
            document.getElementById('feedbackForm').reset();
            resetRatingInput();
            loadFeedback();
        } else {
            showToast('Geri bildirim kaydedilemedi', 'error');
        }
    } catch (error) {
        showToast('Bir hata oluştu', 'error');
    }
}

// =====================================================
// STAFF
// =====================================================
async function loadStaff() {
    try {
        const data = await fetchAPI('/reports/staff-performance');
        renderStaffTable(data);
    } catch (error) {
        console.error('Staff error:', error);
    }
}

function renderStaffTable(staff) {
    const tbody = document.getElementById('staffTableBody');
    if (!staff?.length) {
        tbody.innerHTML = '<tr><td colspan="5" class="loading-cell">Personel verisi bulunamadı</td></tr>';
        return;
    }
    
    tbody.innerHTML = staff.map(s => `
        <tr>
            <td><strong>${s.name}</strong></td>
            <td>${s.role}</td>
            <td>${s.total_orders}</td>
            <td><strong>${formatCurrency(s.total_revenue)}</strong></td>
            <td>${formatCurrency(s.avg_order_value)}</td>
        </tr>
    `).join('');
}

// =====================================================
// MODALS
// =====================================================
function initModals() {
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) {
                overlay.classList.remove('active');
            }
        });
    });
    
    // ESC key to close
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-overlay.active').forEach(modal => {
                modal.classList.remove('active');
            });
        }
    });
}

function openModal(modalId) {
    document.getElementById(modalId)?.classList.add('active');
}

function closeModal(modalId) {
    document.getElementById(modalId)?.classList.remove('active');
}

// =====================================================
// RATING INPUT
// =====================================================
function initRatingInput() {
    const stars = document.querySelectorAll('#ratingInput .star');
    
    stars.forEach(star => {
        star.addEventListener('click', () => {
            const value = parseInt(star.dataset.value);
            document.getElementById('fbRating').value = value;
            
            stars.forEach(s => {
                s.classList.toggle('active', parseInt(s.dataset.value) <= value);
            });
        });
        
        star.addEventListener('mouseenter', () => {
            const value = parseInt(star.dataset.value);
            stars.forEach(s => {
                s.style.color = parseInt(s.dataset.value) <= value ? 'var(--warning)' : '';
            });
        });
    });
    
    document.getElementById('ratingInput')?.addEventListener('mouseleave', () => {
        const currentValue = parseInt(document.getElementById('fbRating').value);
        stars.forEach(s => {
            s.style.color = parseInt(s.dataset.value) <= currentValue ? 'var(--warning)' : '';
        });
    });
}

function resetRatingInput() {
    document.getElementById('fbRating').value = 0;
    document.querySelectorAll('#ratingInput .star').forEach(s => {
        s.classList.remove('active');
        s.style.color = '';
    });
}

// =====================================================
// UTILITIES
// =====================================================
async function fetchAPI(endpoint) {
    try {
        const response = await fetch(`${API_BASE}${endpoint}`);
        if (!response.ok) throw new Error('API Error');
        return await response.json();
    } catch (error) {
        console.error(`Fetch error for ${endpoint}:`, error);
        return null;
    }
}

function formatCurrency(amount) {
    const num = parseFloat(amount) || 0;
    return new Intl.NumberFormat('tr-TR', {
        style: 'currency',
        currency: 'TRY',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(num);
}

function formatDate(dateStr) {
    if (!dateStr) return '-';
    return new Date(dateStr).toLocaleDateString('tr-TR');
}

function formatDateTime(dateStr) {
    if (!dateStr) return '-';
    return new Date(dateStr).toLocaleString('tr-TR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function getInitials(name) {
    if (!name) return '?';
    return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
}

function translateStatus(status) {
    const translations = {
        'Pending': 'Bekliyor',
        'Confirmed': 'Onaylandı',
        'Completed': 'Tamamlandı',
        'Cancelled': 'İptal',
        'No-Show': 'Gelmedi'
    };
    return translations[status] || status;
}

function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    
    const icons = {
        success: '✓',
        error: '✕',
        warning: '!',
        info: 'i'
    };
    
    toast.innerHTML = `
        <span class="toast-icon">${icons[type]}</span>
        <span class="toast-message">${message}</span>
    `;
    
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideIn 0.3s ease reverse';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Add Customer
async function addCustomer(event) {
    event.preventDefault();
    
    const customerData = {
        full_name: document.getElementById('newCustName').value,
        phone: document.getElementById('newCustPhone').value || null,
        email: document.getElementById('newCustEmail').value || null,
        vip_status: document.getElementById('newCustVip').checked
    };
    
    try {
        const response = await fetch(`${API_BASE}/customers`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(customerData)
        });
        
        if (response.ok) {
            // Bildirim ekle
            addNotification(
                'customer',
                'Yeni Müşteri',
                `${customerData.full_name} eklendi`,
                'customers'
            );
            
            closeModal('addCustomerModal');
            document.getElementById('addCustomerForm').reset();
            loadCustomers();
        } else {
            const error = await response.json();
            showToast('Hata: ' + (error.error || 'Müşteri eklenemedi'), 'error');
        }
    } catch (error) {
        console.error('Add customer error:', error);
        showToast('Bağlantı hatası! Backend çalışıyor mu?', 'error');
    }
}

// Delete Customer
async function deleteCustomer(customerId) {
    console.log('deleteCustomer called with ID:', customerId);
    
    if (!confirm('Bu müşteriyi silmek istediğinizden emin misiniz?')) {
        return;
    }
    
    try {
        console.log('Sending DELETE request to:', `${API_BASE}/customers/${customerId}`);
        const response = await fetch(`${API_BASE}/customers/${customerId}`, {
            method: 'DELETE'
        });
        
        console.log('Response status:', response.status);
        
        if (response.ok) {
            // Bildirim ekle
            addNotification(
                'alert',
                'Müşteri Silindi',
                `Müşteri #${customerId} silindi`,
                'customers'
            );
            loadCustomers();
        } else {
            const error = await response.json();
            console.error('Delete error response:', error);
            showToast('Hata: ' + (error.error || 'Müşteri silinemedi'), 'error');
        }
    } catch (error) {
        console.error('Delete customer error:', error);
        showToast('Bağlantı hatası!', 'error');
    }
}

// Initialize on load
window.addEventListener('load', () => {
    showPage('dashboard');
});
