// --- server.js (ULTIMATE V4) ---
import express from 'express';
import mysql from 'mysql2/promise';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';

// --- Global Değişkenler ve Önbellek ---
let marketCache = { rates: null, commodities: null };
let lastMarketFetch = 0;
const CACHE_DURATION = 3600000; // 1 saat

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// --- Veritabanı Yapılandırması ---
const dbConfig = {
    host: 'localhost',
    user: 'user',        // MySQL kullanıcı adınız
    password: 'pasword', // MySQL şifreniz
    database: 'coal',    // Veritabanı adınız
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    connectTimeout: 10000
};

let pool;
try {
    pool = mysql.createPool(dbConfig);
    console.log("MySQL bağlantı havuzu başarıyla oluşturuldu.");
    
    pool.getConnection()
       .then(connection => {
            console.log("İlk veritabanı bağlantısı başarılı!");
            connection.release();
        })
       .catch(err => {
            console.error("!!! Veritabanına ilk bağlantı denemesi BAŞARISIZ:", err.message);
            console.error("!!! Lütfen dbConfig ayarlarını (host, user, password, database) ve MySQL sunucusunun çalıştığını kontrol edin.");
        });

} catch (err) {
    console.error("!!! KRİTİK HATA: MySQL bağlantı havuzu oluşturulamadı:", err);
    process.exit(1);
}

// --- Express Uygulamasının Başlatılması ---
const app = express();
const port = 3000;
app.use(cors());
app.use(express.static(path.join(__dirname, 'public'))); 
app.use(express.json());


// --- HATA YAKALAMA YARDIMCISI ---
const handleSqlError = (res, err, action) => {
    console.error(`!!! SQL HATA (${action}):`, err);
    if (err.code === 'ER_NO_REFERENCED_ROW_2' || err.code === 'ER_ROW_IS_REFERENCED_2') {
        return res.status(400).json({ message: `Hata: İlişkili veri bulunamadı veya kullanılıyor. (Foreign Key Kısıtlaması). Detay: ${err.message}` });
    }
    if (err.code === 'ER_DUP_ENTRY') {
        return res.status(400).json({ message: `Hata: Bu kayıt zaten mevcut (tekrarlanan veri). Detay: ${err.message}` });
    }
    return res.status(500).json({ message: `Sunucu hatası (${action}).`, error: err.message });
};

// --- TEMEL API ENDPOINT'LERİ ---

app.get('/', (req, res) => {
    console.log('[API /] index.html sunuluyor...');
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.get('/api/market-data', async (req, res) => {
    console.log('[API /api/market-data] Piyasa verisi istendi...');
    const now = Date.now();
    if (now - lastMarketFetch < CACHE_DURATION && marketCache.rates) {
        console.log('[API /api/market-data] Veriler önbellekten sunuluyor.');
        return res.json(marketCache);
    }
    console.log('[API /api/market-data] Önbellek süresi doldu veya boş, yeni veriler çekiliyor...');
    try {
        const ratesResponse = await fetch('https://api.frankfurter.app/latest?from=USD&to=EUR,AUD');
        if (!ratesResponse.ok) throw new Error(`Döviz kuru API hatası (${ratesResponse.status})`);
        const ratesData = await ratesResponse.json();

        // Simüle edilmiş maden fiyatları
        const commoditiesData = {
             gold: { name: 'Altın (XAU)', price: 1985.50 + (Math.random() - 0.5) * 20, unit: 'oz' },
             iron_ore: { name: 'Demir Cevheri (Fe %62)', price: 118.25 + (Math.random() - 0.5) * 5, unit: 't' },
             coal: { name: 'Kömür (Newcastle)', price: 124.50 + (Math.random() - 0.5) * 8, unit: 't' },
             bauxite: { name: 'Boksit', price: 58.70 + (Math.random() - 0.5) * 2, unit: 't' }
        };

        marketCache = { rates: ratesData, commodities: commoditiesData };
        lastMarketFetch = now;
        res.json(marketCache);
    } catch (err) {
        console.error('!!! [API /api/market-data] HATA:', err);
        res.status(500).json(marketCache.rates ? marketCache : { rates: null, commodities: null });
    }
});


app.get('/api/full-data', async (req, res) => {
    console.log('[API /api/full-data] İstek alındı.');
    let connection;
    const startTime = Date.now(); 

    try {
        connection = await pool.getConnection();
        console.log('[API /api/full-data] Veritabanı bağlantısı alındı.');

        const queryMap = {
            companyInfo: 'SELECT * FROM company_info',
            cities: 'SELECT * FROM cities',
            minerals: 'SELECT * FROM minerals',
            roles: 'SELECT * FROM roles',
            miningSites: `SELECT s.*, c.name AS city_name, m.name AS mineral_name, m.unit AS mineral_unit, c.latitude, c.longitude FROM mining_sites s LEFT JOIN cities c ON s.city_id=c.id LEFT JOIN minerals m ON s.primary_mineral_id=m.id`,
            employees: `SELECT e.*, r.name AS role_name, d.name AS department_name, s.name AS site_name FROM employees e LEFT JOIN roles r ON e.role_id=r.id LEFT JOIN departments d ON e.department_id=d.id LEFT JOIN mining_sites s ON e.site_id=s.id ORDER BY e.last_name, e.first_name`,
            productionLogs: `SELECT pl.*, s.name AS site_name, m.name AS mineral_name, m.unit AS mineral_unit FROM production_logs pl LEFT JOIN mining_sites s ON pl.site_id=s.id LEFT JOIN minerals m ON pl.mineral_id=m.id ORDER BY pl.log_datetime DESC`,
            operationalRisks: `SELECT o.*, s.name AS site_name, e.first_name AS reporter_first_name, e.last_name AS reporter_last_name FROM operational_risks o LEFT JOIN mining_sites s ON o.site_id=s.id LEFT JOIN employees e ON o.reported_by=e.id ORDER BY o.created_at DESC`,
            equipment: `SELECT eq.*, s.name AS site_name FROM equipment eq LEFT JOIN mining_sites s ON eq.site_id=s.id`,
            shipmentLogs: `SELECT sh.*, s.name AS site_name, org_port.name AS origin_port_name, dest_port.name AS destination_port_name, sup.name AS carrier_name, u.abbreviation AS unit_abbreviation FROM shipment_logs sh LEFT JOIN mining_sites s ON sh.site_id=s.id LEFT JOIN ports org_port ON sh.origin_port_id=org_port.id LEFT JOIN ports dest_port ON sh.destination_port_id=dest_port.id LEFT JOIN suppliers sup ON sh.carrier_id=sup.id LEFT JOIN units u ON sh.unit_id=u.id ORDER BY sh.shipment_date DESC`,
            cityAnalysis: 'SELECT ca.*, c.name AS city_name FROM city_analysis_data ca JOIN cities c ON ca.city_id = c.id',
            potentialReserves: `SELECT p.*, c.name AS city_name, m.name AS mineral_name, u.abbreviation AS unit_abbreviation FROM potential_city_reserves p LEFT JOIN cities c ON p.city_id=c.id LEFT JOIN minerals m ON p.mineral_id=m.id LEFT JOIN units u ON p.unit_id=u.id`,
            ports: 'SELECT p.*, c.name AS city_name FROM ports p LEFT JOIN cities c ON p.city_id=c.id',
            departments: 'SELECT * FROM departments',
            currencies: 'SELECT * FROM currencies',
            units: 'SELECT * FROM units',
            suppliers: 'SELECT * FROM suppliers',
            trainingRecords: 'SELECT tr.*, e.first_name, e.last_name FROM training_records tr LEFT JOIN employees e ON tr.employee_id=e.id',
            maintenanceLogs: 'SELECT ml.*, eq.equipment_name, s.name AS site_name, e.first_name AS performer_first_name, e.last_name AS performer_last_name, sup.name AS vendor_name FROM maintenance_logs ml LEFT JOIN equipment eq ON ml.equipment_id=eq.id LEFT JOIN mining_sites s ON ml.site_id=s.id LEFT JOIN employees e ON ml.performed_by=e.id LEFT JOIN suppliers sup ON ml.vendor_id=sup.id ORDER BY ml.maintenance_date DESC',
            safetyIncidents: 'SELECT si.*, s.name AS site_name, e.first_name AS reporter_first_name, e.last_name AS reporter_last_name FROM safety_incidents si LEFT JOIN mining_sites s ON si.site_id=s.id LEFT JOIN employees e ON si.reported_by=e.id ORDER BY si.incident_datetime DESC',
            environmentalIncidents: 'SELECT ei.*, s.name AS site_name FROM environmental_incidents ei LEFT JOIN mining_sites s ON ei.site_id=s.id ORDER BY ei.date DESC'
        };

        const queryPromises = Object.entries(queryMap).map(([key, sql]) => {
            console.log(`[API /api/full-data] Sorgu hazırlanıyor: ${key}`); 
            return connection.execute(sql)
               .then(result => {
                    console.log(`[API /api/full-data] Sorgu BAŞARILI: ${key}`); 
                    return result; 
                })
               .catch(err => {
                    console.error(`!!! [API /api/full-data] SQL Sorgu HATASI (${key}):`, err); 
                    throw err; 
                });
        });

        const results = await Promise.all(queryPromises);
        console.log('[API /api/full-data] Tüm SQL sorguları başarıyla tamamlandı.');

        const responseData = {};
        Object.keys(queryMap).forEach((key, index) => {
            responseData[key] = results[index][0]; // Sadece [rows] kısmını al
        });
        
        const duration = Date.now() - startTime; 
        console.log(`[API /api/full-data] Yanıt gönderiliyor... (Süre: ${duration}ms)`);

        // === ÖNBELLEK ENGELLEME DÜZELTMESİ ===
        res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
        // ========================================

        res.json(responseData);

    } catch (err) {
        console.error('!!! [API /api/full-data] GENEL HATA OLUŞTU!!!:', err.message);
        res.status(500).json({ message: 'Veritabanı verileri alınırken bir hata oluştu.', error: err.message });
    } finally {
        if (connection) {
            try {
                await connection.release();
                console.log('[API /api/full-data] Veritabanı bağlantısı iade edildi.');
            } catch (releaseError) {
                console.error("!!! Bağlantı iade edilirken hata:", releaseError);
            }
        }
    }
});


// =========================================================
// === CRUD ENDPOINT'LERİ (Risk, Ekipman, Sevkiyat) ===
// =========================================================

// --- Operasyonel Riskler CRUD ---
app.post('/api/risks', async (req, res) => {
    const { site_id, severity, category, risk_description, mitigation_plan, reported_by } = req.body;
    const sql = `INSERT INTO operational_risks 
                 (site_id, severity, category, risk_description, mitigation_plan, reported_by, status, created_at) 
                 VALUES (?,?,?,?,?,?, 'Aktif', NOW())`;
    try {
        const [result] = await pool.execute(sql, [site_id, severity, category, risk_description, mitigation_plan, reported_by]);
        res.status(201).json({ message: 'Risk başarıyla eklendi.', id: result.insertId });
    } catch (err) { handleSqlError(res, err, 'Yeni risk ekleme'); }
});

app.patch('/api/risks/:id/status', async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;
    const sql = `UPDATE operational_risks SET status =? WHERE id =?`;
    try {
        const [result] = await pool.execute(sql, [status, id]);
        if (result.affectedRows === 0) return res.status(404).json({ message: 'Güncellenecek risk bulunamadı.' });
        res.json({ message: 'Risk durumu başarıyla güncellendi.' });
    } catch (err) { handleSqlError(res, err, 'Risk durum güncelleme'); }
});

app.delete('/api/risks/:id', async (req, res) => {
    const { id } = req.params;
    const sql = `DELETE FROM operational_risks WHERE id =?`;
    try {
        const [result] = await pool.execute(sql, [id]);
        if (result.affectedRows === 0) return res.status(404).json({ message: 'Silinecek risk bulunamadı.' });
        res.status(200).json({ message: 'Risk başarıyla silindi.' });
    } catch (err) { handleSqlError(res, err, 'Risk silme'); }
});

// --- Ekipman CRUD ---
app.post('/api/equipment', async (req, res) => {
    const { site_id, equipment_code, equipment_name, type, manufacturer, model, purchase_date, purchase_value, service_interval_days, last_service_date, next_service_date, status, location_detail } = req.body;
    const sql = `INSERT INTO equipment 
                 (site_id, equipment_code, equipment_name, type, manufacturer, model, purchase_date, purchase_value, service_interval_days, last_service_date, next_service_date, status, location_detail) 
                 VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`;
    try {
        const [result] = await pool.execute(sql, [ site_id, equipment_code, equipment_name, type, manufacturer, model, purchase_date, purchase_value, service_interval_days, last_service_date, next_service_date, status, location_detail ]);
        res.status(201).json({ message: 'Ekipman başarıyla eklendi.', id: result.insertId });
    } catch (err) { handleSqlError(res, err, 'Yeni ekipman ekleme'); }
});

app.put('/api/equipment/:id', async (req, res) => {
    const { id } = req.params;
    const { site_id, equipment_code, equipment_name, type, manufacturer, model, purchase_date, purchase_value, service_interval_days, last_service_date, next_service_date, status, location_detail } = req.body;
    const sql = `UPDATE equipment SET 
                 site_id =?, equipment_code =?, equipment_name =?, type =?, 
                 manufacturer =?, model =?, purchase_date =?, purchase_value =?, 
                 service_interval_days =?, last_service_date =?, next_service_date =?, 
                 status =?, location_detail =?
                 WHERE id =?`;
    try {
        const [result] = await pool.execute(sql, [ site_id, equipment_code, equipment_name, type, manufacturer, model, purchase_date, purchase_value, service_interval_days, last_service_date, next_service_date, status, location_detail, id ]);
        if (result.affectedRows === 0) return res.status(404).json({ message: 'Güncellenecek ekipman bulunamadı.' });
        res.json({ message: 'Ekipman başarıyla güncellendi.' });
    } catch (err) { handleSqlError(res, err, 'Ekipman güncelleme'); }
});

app.delete('/api/equipment/:id', async (req, res) => {
    const { id } = req.params;
    const sql = `DELETE FROM equipment WHERE id =?`;
    try {
        const [result] = await pool.execute(sql, [id]);
        if (result.affectedRows === 0) return res.status(404).json({ message: 'Silinecek ekipman bulunamadı.' });
        res.json({ message: 'Ekipman başarıyla silindi.' });
    } catch (err) { handleSqlError(res, err, 'Ekipman silme'); }
});

// --- Sevkiyat Logları CRUD ---
app.post('/api/shipments', async (req, res) => {
    const { site_id, origin_port_id, destination_port_id, carrier_id, shipment_date, quantity, unit_id, status, cost, etd, eta, container_number, invoice_id } = req.body;
    const sql = `INSERT INTO shipment_logs 
                 (site_id, origin_port_id, destination_port_id, carrier_id, shipment_date, quantity, unit_id, status, cost, etd, eta, container_number, invoice_id) 
                 VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`;
    try {
        const [result] = await pool.execute(sql, [ site_id, origin_port_id, destination_port_id, carrier_id, shipment_date, quantity, unit_id, status, cost, etd, eta, container_number, invoice_id ]);
        res.status(201).json({ message: 'Sevkiyat başarıyla eklendi.', id: result.insertId });
    } catch (err) { handleSqlError(res, err, 'Yeni sevkiyat ekleme'); }
});

app.put('/api/shipments/:id', async (req, res) => {
    const { id } = req.params;
    const { site_id, origin_port_id, destination_port_id, carrier_id, shipment_date, quantity, unit_id, status, cost, etd, eta, container_number, invoice_id } = req.body;
    const sql = `UPDATE shipment_logs SET 
                 site_id =?, origin_port_id =?, destination_port_id =?, carrier_id =?, 
                 shipment_date =?, quantity =?, unit_id =?, status =?, cost =?, 
                 etd =?, eta =?, container_number =?, invoice_id =?
                 WHERE id =?`;
    try {
        const [result] = await pool.execute(sql, [ site_id, origin_port_id, destination_port_id, carrier_id, shipment_date, quantity, unit_id, status, cost, etd, eta, container_number, invoice_id, id ]);
        if (result.affectedRows === 0) return res.status(404).json({ message: 'Güncellenecek sevkiyat bulunamadı.' });
        res.json({ message: 'Sevkiyat başarıyla güncellendi.' });
    } catch (err) { handleSqlError(res, err, 'Sevkiyat güncelleme'); }
});

app.patch('/api/shipments/:id/status', async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;
    const sql = `UPDATE shipment_logs SET status =? WHERE id =?`;
    try {
        const [result] = await pool.execute(sql, [status, id]);
        if (result.affectedRows === 0) return res.status(404).json({ message: 'Güncellenecek sevkiyat bulunamadı.' });
        res.json({ message: 'Sevkiyat durumu başarıyla güncellendi.' });
    } catch (err) { handleSqlError(res, err, 'Sevkiyat durum güncelleme'); }
});

app.delete('/api/shipments/:id', async (req, res) => {
    const { id } = req.params;
    const sql = `DELETE FROM shipment_logs WHERE id =?`;
    try {
        const [result] = await pool.execute(sql, [id]);
        if (result.affectedRows === 0) return res.status(404).json({ message: 'Silinecek sevkiyat bulunamadı.' });
        res.json({ message: 'Sevkiyat başarıyla silindi.' });
    } catch (err) { handleSqlError(res, err, 'Sevkiyat silme'); }
});

// =========================================================
// === STRATEJİK ANALİZ VE PROJEKSİYON ENDPOINT'LERİ ===
// =========================================================

// --- Şehir Stratejik Analiz CRUD ---
app.post('/api/analysis/:city_id', async (req, res) => {
    const { city_id } = req.params;
    const { economic_indicator, infrastructure_score, skilled_labor_availability_pct, risk_level, notes } = req.body;
    const sql = `INSERT INTO city_analysis_data 
                 (city_id, economic_indicator, infrastructure_score, skilled_labor_availability_pct, risk_level, notes, last_updated) 
                 VALUES (?,?,?,?,?,?, NOW())`;
    try {
        const [result] = await pool.execute(sql, [ city_id, economic_indicator || null, infrastructure_score || null, skilled_labor_availability_pct || null, risk_level || 'Orta', notes || null ]);
        if (result.affectedRows === 0) return res.status(400).json({ message: 'Analiz kaydı oluşturulamadı.' });
        // Yeni oluşturulan (ve JOIN'lu) kaydı geri döndür
        const [newRecordRows] = await pool.execute( 'SELECT ca.*, c.name AS city_name FROM city_analysis_data ca JOIN cities c ON ca.city_id = c.id WHERE ca.city_id =?', [city_id] );
        if (newRecordRows.length === 0) return res.status(404).json({ message: 'Kayıt oluşturuldu ancak bulunamadı.'});
        res.status(201).json(newRecordRows[0]);
    } catch (err) { handleSqlError(res, err, 'Yeni şehir analizi ekleme'); }
});

app.patch('/api/analysis/:city_id', async (req, res) => {
    const { city_id } = req.params;
    const { economic_indicator, infrastructure_score, skilled_labor_availability_pct, risk_level, notes } = req.body;
    const sql = `UPDATE city_analysis_data SET 
                 economic_indicator =?, infrastructure_score =?, skilled_labor_availability_pct =?, 
                 risk_level =?, notes =?, last_updated = NOW()
                 WHERE city_id =?`;
    try {
        const [result] = await pool.execute(sql, [ economic_indicator || null, infrastructure_score || null, skilled_labor_availability_pct || null, risk_level || 'Orta', notes || null, city_id ]);
        if (result.affectedRows === 0) return res.status(404).json({ message: 'Güncellenecek analiz kaydı bulunamadı. Lütfen önce kayıt ekleyin.' });
        // Güncellenmiş (ve JOIN'lu) kaydı geri döndür
        const [updatedRecordRows] = await pool.execute( 'SELECT ca.*, c.name AS city_name FROM city_analysis_data ca JOIN cities c ON ca.city_id = c.id WHERE ca.city_id =?', [city_id] );
        if (updatedRecordRows.length === 0) return res.status(404).json({ message: 'Analiz kaydı güncellendi ancak bulunamadı.'});
        res.status(200).json(updatedRecordRows[0]);
    } catch (err) { handleSqlError(res, err, 'Şehir analizi güncelleme'); }
});

// --- ÜRETİM PROJEKSİYONU (Sizin hatanızın kaynağı) ---
app.post('/api/projection', async (req, res) => {
    const { site_id, period, efficiency_change_pct, extra_shifts } = req.body;
    console.log(`[API /api/projection] İstek alındı:`, req.body);
    if (!site_id) return res.status(400).json({ message: 'Eksik parametre: site_id' });

    let connection;
    try {
        connection = await pool.getConnection();
        
        // 1. ADIM: Geçmiş Veri Kontrolü
        const historyCheckSql = `
            SELECT 
                MIN(log_datetime) AS min_date, 
                MAX(log_datetime) AS max_date,
                COUNT(id) AS log_count,
                SUM(produced_amount) AS total_production
            FROM production_logs 
            WHERE site_id = ?
        `;
        
        const [historyRows] = await connection.execute(historyCheckSql, [site_id]);
        const history = historyRows[0];

        if (!history || !history.min_date || history.log_count < 2) {
            return res.status(400).json({ message: 'Projeksiyon için yeterli geçmiş veri (en az 2 kayıt) bulunamadı.' });
        }

        const minDate = new Date(history.min_date);
        const maxDate = new Date(history.max_date);
        const diffTime = Math.abs(maxDate.getTime() - minDate.getTime());
        const diffMonths = diffTime / (1000 * 60 * 60 * 24 * 30.4375); 

        console.log(`[API /api/projection] Veri aralığı: ${diffMonths.toFixed(2)} ay.`);

        // === HATA KONTROLÜ (Frontend'in yaptığı mantık) ===
        if (diffMonths < 3) {
            console.warn(`[API /api/projection] HATA: Veri aralığı 3 aydan az.`);
            return res.status(400).json({ message: `Hata: Projeksiyon için yeterli geçmiş veri (en az 3 ay) bulunamadı. (Bulunan: ${diffMonths.toFixed(1)} ay)` });
        }

        // 2. ADIM: Basit Projeksiyon Hesaplaması
        const avgProductionPerMonth = history.total_production / diffMonths;
        const efficiencyMultiplier = 1 + ( (Number(efficiency_change_pct) || 0) / 100 );
        const shiftMultiplier = 1 + ( (Number(extra_shifts) || 0) * 0.20 ); // %20'lik basit etki varsayımı
        const projectedMonthlyProduction = avgProductionPerMonth * efficiencyMultiplier * shiftMultiplier;
        
        console.log(`[API /api/projection] Hesaplama: (Ort: ${avgProductionPerMonth.toFixed(2)}) * (Verimlilik: ${efficiencyMultiplier}) * (Vardiya: ${shiftMultiplier}) = ${projectedMonthlyProduction.toFixed(2)}`);

        // 3. ADIM: Gelecek Veri Serisi Oluştur
        const projectionResult = [];
        let currentDate = new Date(); 
        const monthsToProject = 12; // 'period' değişkeni yerine şimdilik 12 ay
        
        for (let i = 0; i < monthsToProject; i++) {
            currentDate.setMonth(currentDate.getMonth() + 1);
            projectionResult.push({
                date: `${currentDate.toLocaleString('tr-TR', { month: 'long' })} ${currentDate.getFullYear()}`,
                projected_amount: projectedMonthlyProduction
            });
        }
        res.status(200).json(projectionResult);

    } catch (err) {
        handleSqlError(res, err, 'Projeksiyon çalıştırma');
    } finally {
        if (connection) await connection.release();
    }
});


// --- Sunucuyu Başlat ---
app.listen(port, () => {
    console.log(`================================================================`);
    console.log(`Ultimate Aussie Mining KDS FULL API (V4) çalışıyor`);
    console.log(`Ana Uygulama: http://localhost:${port}/`);
    console.log(`(Bu adresin çalışması için 'index.html' dosyasının 'server.js' ile aynı klasörde olması gerekir)`);
    console.log(`================================================================`);
});