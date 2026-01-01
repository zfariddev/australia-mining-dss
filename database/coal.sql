DROP DATABASE IF EXISTS coal;
CREATE DATABASE coal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE coal;

-- =========================================
-- MASTER / REFERANS TABLOLARI
-- =========================================
SET FOREIGN_KEY_CHECKS=0;


CREATE TABLE suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type ENUM('Carrier', 'Vendor', 'General') DEFAULT 'General',
    contact_person VARCHAR(100),
    contact_email VARCHAR(100)
);

CREATE TABLE company_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    abn VARCHAR(50),
    headquarters_city_id INT,
    country VARCHAR(100) DEFAULT 'Australia',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE cities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Australia',
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    timezone VARCHAR(50),
    population BIGINT
);

CREATE TABLE ports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    city_id INT,
    country VARCHAR(100) DEFAULT 'Australia',
    berth_capacity INT,
    container_handling INT,
    FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE TABLE minerals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    unit VARCHAR(20) DEFAULT 'ton',
    typical_grade_unit VARCHAR(50)
);

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT
);

CREATE TABLE currencies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10),
    name VARCHAR(50),
    symbol VARCHAR(5)
);

CREATE TABLE units (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    abbreviation VARCHAR(10)
);
CREATE TABLE mining_sites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    city_id INT,
    company_id INT,
    primary_mineral_id INT,
    status ENUM('Aktif','Bakımda','Pasif') DEFAULT 'Aktif',
    established_date DATE,
    permitted_capacity_tons_per_day BIGINT,
    FOREIGN KEY (city_id) REFERENCES cities(id),
    FOREIGN KEY (company_id) REFERENCES company_info(id),
    FOREIGN KEY (primary_mineral_id) REFERENCES minerals(id)
);

CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    role_id INT,
    department_id INT,
    hire_date DATE,
    employment_type ENUM('Full-Time','Part-Time','Contractor'),
    salary DECIMAL(15,2),
    manager_id INT,
    site_id INT,
    certifications JSON,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (site_id) REFERENCES mining_sites(id)
);

CREATE TABLE production_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT,
    mineral_id INT,
    supervisor_id INT,
    log_datetime DATETIME,
    produced_amount DECIMAL(15,2),
    shift ENUM('Sabah','Öğle','Gece'),
    fuel_consumed DECIMAL(10,2),
    operating_hours DECIMAL(5,2),
    efficiency_pct DECIMAL(5,2),
    notes TEXT,
    FOREIGN KEY (site_id) REFERENCES mining_sites(id),
    FOREIGN KEY (mineral_id) REFERENCES minerals(id),
    FOREIGN KEY (supervisor_id) REFERENCES employees(id)
);

CREATE TABLE shipment_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT,
    origin_port_id INT,
    destination_port_id INT,
    carrier_id INT,
    shipment_date DATE,
    etd DATE,
    eta DATE,
    quantity DECIMAL(15,2),
    unit_id INT,
    status ENUM('Yüklendi','Yolda','Teslim Edildi','Gecikti'),
    container_number VARCHAR(50),
    invoice_id VARCHAR(50),
    cost DECIMAL(15,2),
    FOREIGN KEY (site_id) REFERENCES mining_sites(id),
    FOREIGN KEY (origin_port_id) REFERENCES ports(id),
    FOREIGN KEY (destination_port_id) REFERENCES ports(id),
    FOREIGN KEY (carrier_id) REFERENCES suppliers(id),
    FOREIGN KEY (unit_id) REFERENCES units(id)
);

CREATE TABLE operational_risks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT,
    risk_description TEXT NOT NULL,
    category VARCHAR(100),
    severity ENUM('Düşük','Orta','Yüksek','Kritik'),
    mitigation_plan TEXT,
    reported_by INT,
    status ENUM('Aktif','İzleniyor','Çözüldü') DEFAULT 'Aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (site_id) REFERENCES mining_sites(id),
    FOREIGN KEY (reported_by) REFERENCES employees(id)
);


CREATE TABLE equipment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT,
    equipment_code VARCHAR(50) UNIQUE,
    equipment_name VARCHAR(255),
    type VARCHAR(100),
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    purchase_date DATE,
    purchase_value DECIMAL(15,2),
    service_interval_days INT,
    last_service_date DATE,
    next_service_date DATE,
    status ENUM('Çalışıyor','Bakımda','Arızalı'),
    location_detail TEXT,
    FOREIGN KEY (site_id) REFERENCES mining_sites(id)
);

CREATE TABLE maintenance_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    equipment_id INT,
    site_id INT,
    maintenance_date DATE,
    maintenance_type ENUM('Planned','Unplanned'),
    description TEXT,
    performed_by INT,
    vendor_id INT,
    cost DECIMAL(15,2),
    downtime_minutes INT,
    next_due_date DATE,
    FOREIGN KEY (equipment_id) REFERENCES equipment(id),
    FOREIGN KEY (site_id) REFERENCES mining_sites(id)
);


CREATE TABLE training_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    training_name VARCHAR(255),
    completion_date DATE,
    expiry_date DATE,
    certificate_no VARCHAR(50),
    provider VARCHAR(100),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);


CREATE TABLE potential_city_reserves (
    id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT NOT NULL,
    mineral_id INT NOT NULL,
    estimated_amount DECIMAL(15,2),
    unit_id INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (city_id) REFERENCES cities(id),
    FOREIGN KEY (mineral_id) REFERENCES minerals(id),
    FOREIGN KEY (unit_id) REFERENCES units(id)
);


CREATE TABLE safety_incidents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT,
    reported_by INT,
    incident_datetime DATETIME,
    description TEXT,
    severity ENUM('Düşük','Orta','Yüksek','Kritik'),
    status ENUM('Aktif','Çözüldü'),
    injured_count INT,
    lost_time_hours DECIMAL(5,2),
    root_cause TEXT,
    corrective_action TEXT,
    cost_estimate DECIMAL(15,2),
    FOREIGN KEY (site_id) REFERENCES mining_sites(id),
    FOREIGN KEY (reported_by) REFERENCES employees(id)
);

CREATE TABLE environmental_incidents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT,
    date DATE,
    type VARCHAR(50),
    volume DECIMAL(15,2),
    contamination_level VARCHAR(50),
    remediation_status ENUM('Pending','Completed'),
    regulatory_reported BOOLEAN,
    fine_amount DECIMAL(15,2),
    FOREIGN KEY (site_id) REFERENCES mining_sites(id)
);


CREATE TABLE IF NOT EXISTS city_analysis_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT UNIQUE NOT NULL,
    economic_indicator DECIMAL(15,2),
    infrastructure_score DECIMAL(5,2),
    skilled_labor_availability_pct DECIMAL(5,2),
    risk_level ENUM('Düşük','Orta','Yüksek') DEFAULT 'Orta',
    notes TEXT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (city_id) REFERENCES cities(id)
);



USE coal;

-- ***** BÜYÜK SEED SCRIPT START *****
SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;

-- BAĞIMSIZ TABLOLAR (İlk önce bunları ekliyoruz)

-- Para Birimleri (Manuel ID'ler kaldırıldı)
INSERT INTO currencies (code, name, symbol) VALUES
('AUD', 'Australian Dollar', '$'),
('USD', 'US Dollar', '$');

-- Birimler (Manuel ID'ler kaldırıldı)
INSERT INTO units (name, abbreviation) VALUES
('Tonne', 't'),
('Kilogram', 'kg'),
('Ounce', 'oz'),
('Litre', 'L');

-- Mineraller (Manuel ID'ler kaldırıldı)
INSERT INTO minerals (name, unit, typical_grade_unit) VALUES
('Iron Ore', 't', 'Fe %'),
('Gold', 'oz', 'g/t'),
('Bauxite', 't', 'Al2O3 %'),
('Coal', 't', 'CV (kcal/kg)');

-- Roller (Manuel ID'ler kaldırıldı)
INSERT INTO roles (name, description) VALUES
('Site Manager', 'Tüm saha operasyonlarını yönetir'),
('Geologist', 'Mineral yataklarını analiz eder'),
('Heavy Equipment Operator', 'Kamyon, ekskavatör vb. operatörü'),
('Safety Officer', 'İş güvenliği ve uyumluluğu sağlar'),
('Logistics Coordinator', 'Sevkiyat ve envanteri yönetir');

-- Departmanlar (Manuel ID'ler kaldırıldı)
INSERT INTO departments (name, description) VALUES
('Operations', 'Üretim ve çıkarma işlemleri'),
('Geology & Exploration', 'Yeni yatakların bulunması'),
('Health & Safety (HSE)', 'Sağlık, Güvenlik ve Çevre'),
('Logistics', 'Sevkiyat ve tedarik zinciri'),
('Maintenance', 'Ekipman bakım ve onarımı');

-- Şehirler (Manuel ID'ler kaldırıldı)
INSERT INTO cities (name, state, country, latitude, longitude, timezone, population) VALUES
('Perth', 'WA', 'Australia', -31.9523, 115.8613, 'AWST', 2100000),
('Port Hedland', 'WA', 'Australia', -20.3111, 118.6011, 'AWST', 15000),
('Kalgoorlie', 'WA', 'Australia', -30.7485, 121.4655, 'AWST', 30000),
('Brisbane', 'QLD', 'Australia', -27.4698, 153.0251, 'AEST', 2500000),
('Weipa', 'QLD', 'Australia', -12.6158, 141.8703, 'AEST', 4000),
('Sydney', 'NSW', 'Australia', -33.8688, 151.2093, 'AEST', 5312000),
('Melbourne', 'VIC', 'Australia', -37.8136, 144.9631, 'AEST', 5096000),
('Adelaide', 'SA', 'Australia', -34.9285, 138.6007, 'ACST', 1376000),
('Canberra', 'ACT', 'Australia', -35.2809, 149.1300, 'AEST', 467000),
('Hobart', 'TAS', 'Australia', -42.8821, 147.3272, 'AEST', 251000),
('Darwin', 'NT', 'Australia', -12.4634, 130.8456, 'ACST', 148000),
('Gold Coast', 'QLD', 'Australia', -28.0167, 153.4000, 'AEST', 710000),
('Newcastle', 'NSW', 'Australia', -32.9283, 151.7817, 'AEST', 498000),
('Cairns', 'QLD', 'Australia', -16.9186, 145.7781, 'AEST', 155000),
('Geelong', 'VIC', 'Australia', -38.1499, 144.3617, 'AEST', 282000),
('Townsville', 'QLD', 'Australia', -19.2590, 146.8169, 'AEST', 183000),
('Wollongong', 'NSW', 'Australia', -34.4278, 150.8931, 'AEST', 312000),
('Alice Springs', 'NT', 'Australia', -23.6980, 133.8807, 'ACST', 28000),
('Broome', 'WA', 'Australia', -17.9613, 122.2359, 'AWST', 14000),
('Mount Isa', 'QLD', 'Australia', -20.7250, 139.4917, 'AEST', 21000),
('Toowoomba', 'QLD', 'Australia', -27.5606, 151.9520, 'AEST', 140000),
('Mackay', 'QLD', 'Australia', -21.1411, 149.1850, 'AEST', 80000),
('Rockhampton', 'QLD', 'Australia', -23.3750, 150.5111, 'AEST', 79000),
('Bundaberg', 'QLD', 'Australia', -24.8661, 152.3486, 'AEST', 71000),
('Hervey Bay', 'QLD', 'Australia', -25.2950, 152.8436, 'AEST', 55000),
('Gladstone', 'QLD', 'Australia', -23.8483, 151.2580, 'AEST', 63000),
('Central Coast (Gosford)', 'NSW', 'Australia', -33.4267, 151.3417, 'AEST', 346000),
('Tweed Heads', 'NSW', 'Australia', -28.1746, 153.5385, 'AEST', 64000),
('Coffs Harbour', 'NSW', 'Australia', -30.2963, 153.1135, 'AEST', 72000),
('Port Macquarie', 'NSW', 'Australia', -31.4333, 152.9167, 'AEST', 48000),
('Orange', 'NSW', 'Australia', -33.2833, 149.1000, 'AEST', 41000),
('Dubbo', 'NSW', 'Australia', -32.2569, 148.6011, 'AEST', 40000),
('Tamworth', 'NSW', 'Australia', -31.0928, 150.9322, 'AEST', 43000),
('Wagga Wagga', 'NSW', 'Australia', -35.1083, 147.3594, 'AEST', 57000),
('Bathurst', 'NSW', 'Australia', -33.4200, 149.5769, 'AEST', 37000),
('Broken Hill', 'NSW', 'Australia', -31.9567, 141.4678, 'ACST', 17500), 
('Ballarat', 'VIC', 'Australia', -37.5622, 143.8503, 'AEST', 113000),
('Bendigo', 'VIC', 'Australia', -36.7570, 144.2794, 'AEST', 103000),
('Shepparton', 'VIC', 'Australia', -36.3769, 145.4025, 'AEST', 52000),
('Mildura', 'VIC', 'Australia', -34.1848, 142.1583, 'AEST', 52000),
('Warrnambool', 'VIC', 'Australia', -38.3833, 142.4833, 'AEST', 35000),
('Traralgon', 'VIC', 'Australia', -38.1950, 146.5400, 'AEST', 28000),
('Bunbury', 'WA', 'Australia', -33.3256, 115.6394, 'AWST', 75000),
('Geraldton', 'WA', 'Australia', -28.7744, 114.6089, 'AWST', 39000),
('Albany', 'WA', 'Australia', -35.0228, 117.8814, 'AWST', 34000),
('Karratha', 'WA', 'Australia', -20.7358, 116.8464, 'AWST', 17000),
('Busselton', 'WA', 'Australia', -33.6475, 115.3461, 'AWST', 40000),
('Mount Gambier', 'SA', 'Australia', -37.8294, 140.7797, 'ACST', 30000),
('Whyalla', 'SA', 'Australia', -33.0333, 137.5833, 'ACST', 21000),
('Port Augusta', 'SA', 'Australia', -32.4925, 137.7667, 'ACST', 14000),
('Port Pirie', 'SA', 'Australia', -33.1878, 138.0167, 'ACST', 14000),
('Port Lincoln', 'SA', 'Australia', -34.7333, 135.8667, 'ACST', 14500),
('Launceston', 'TAS', 'Australia', -41.4333, 147.1417, 'AEST', 87000),
('Devonport', 'TAS', 'Australia', -41.1786, 146.3639, 'AEST', 26000),
('Katherine', 'NT', 'Australia', -14.4650, 132.2636, 'ACST', 10000);

-- Tedarikçiler / Taşıyıcılar (Manuel ID'ler kaldırıldı)
INSERT INTO suppliers (name, type, contact_person, contact_email) VALUES
('Toll Group', 'Carrier', 'Jane Smith', 'jane.smith@tollgroup.com'),
('Qube Logistics', 'Carrier', 'Bill Hanks', 'bill.hanks@qube.com.au'),
('Caterpillar Services', 'Vendor', 'Mike Ross', 'mike.ross@catservices.com'),
('Sandvik Mining', 'Vendor', 'Sarah Chen', 'sarah.chen@sandvik.com');

-- BAĞIMLI TABLOLAR (Tier 1)

-- Şirket Bilgileri (Manuel ID'ler kaldırıldı)
-- DİKKAT: Diğer tablolardaki company_id'ler buna göre ayarlanmalı
INSERT INTO company_info (name, abn, headquarters_city_id, country) VALUES
('Rio Tinto', '12345678901', 1, 'Australia'), -- ID = 1 olacak
('BHP Group', '23456789012', 4, 'Australia'), -- ID = 2 olacak
('Fortescue Metals', '34567890123', 1, 'Australia'); -- ID = 3 olacak

-- Limanlar (Manuel ID'ler kaldırıldı)
INSERT INTO ports (name, city_id, country, berth_capacity, container_handling) VALUES
('Port Hedland', 2, 'Australia', 12, 50000000), -- ID = 1
('Port of Dampier', 2, 'Australia', 10, 30000000), -- ID = 2
('Port of Brisbane', 4, 'Australia', 8, 10000000), -- ID = 3
('Port of Weipa', 5, 'Australia', 5, 15000000); -- ID = 4

-- ŞEHİR ANALİZ VERİLERİ (TÜM 55 ŞEHİR İÇİN)
-- city_id'ler şehirlerin AUTO_INCREMENT ID'lerine (1-55) karşılık gelmelidir.
INSERT INTO city_analysis_data 
(city_id, economic_indicator, infrastructure_score, skilled_labor_availability_pct, risk_level, notes) 
VALUES
(1, 150000000.00, 95.5, 88.0, 'Düşük', 'Perth: Güçlü ekonomi, yüksek vasıflı iş gücü ve gelişmiş altyapı.'),
(2, 75000000.00, 88.0, 72.5, 'Orta', 'Port Hedland: Kritik liman altyapısı. İş gücü maliyeti yüksek, risk orta seviyede.'),
(3, 45000000.00, 65.0, 91.0, 'Orta', 'Kalgoorlie: Madencilik konusunda yüksek vasıflı iş gücü, ancak altyapı (lojistik) kısıtlı.'),
(4, 200000000.00, 92.0, 90.0, 'Düşük', 'Brisbane: Büyük eyalet başkenti, güçlü lojistik ve iş gücü piyasası.'),
(5, 30000000.00, 55.0, 60.0, 'Orta', 'Weipa: Uzak boksit madeni ve limanı. Lojistik zorluklar, vasıflı iş gücü madencilik odaklı.'),
(6, 350000000.00, 98.0, 95.0, 'Düşük', 'Sydney: Avustralya''nın en büyük ekonomisi. Mükemmel altyapı, yüksek maliyetler.'),
(7, 320000000.00, 96.0, 94.0, 'Düşük', 'Melbourne: Büyük sanayi ve liman kenti. Güçlü yetenek havuzu.'),
(8, 100000000.00, 85.0, 85.0, 'Düşük', 'Adelaide: Güney Avustralya merkezi. Savunma ve sanayi altyapısı mevcut.'),
(9, 60000000.00, 90.0, 92.0, 'Düşük', 'Canberra: Başkent. Sanayi zayıf, ancak yüksek eğitimli iş gücü ve stabilite.'),
(10, 40000000.00, 75.0, 80.0, 'Düşük', 'Hobart: Tazmanya merkezi. Lojistik kısıtlı (ada), ancak stabil.'),
(11, 50000000.00, 68.0, 70.0, 'Orta', 'Darwin: Asya''ya açılan kapı. Stratejik liman, ancak uzak ve hava koşulları riskli.'),
(12, 70000000.00, 88.0, 75.0, 'Düşük', 'Gold Coast: Turizm odaklı, sanayi yok. İyi altyapı, ancak iş gücü hizmet odaklı.'),
(13, 90000000.00, 90.0, 88.0, 'Düşük', 'Newcastle: Dünyanın en büyük kömür limanı. Güçlü sanayi ve altyapı.'),
(14, 45000000.00, 70.0, 78.0, 'Orta', 'Cairns: Uzak kuzey QLD merkezi. Turizm odaklı. Siklon riski.'),
(15, 65000000.00, 85.0, 85.0, 'Düşük', 'Geelong: Melbourne yakını sanayi ve liman kenti. Güçlü altyapı.'),
(16, 55000000.00, 78.0, 80.0, 'Orta', 'Townsville: Kuzey QLD askeri ve sanayi merkezi. Liman mevcut, hava koşulları riskli.'),
(17, 70000000.00, 87.0, 86.0, 'Düşük', 'Wollongong: Sydney yakını sanayi (çelik) ve liman kenti.'),
(18, 15000000.00, 35.0, 50.0, 'Yüksek', 'Alice Springs: Çok uzak. Lojistik maliyetleri aşırı yüksek. Sadece turizm.'),
(19, 20000000.00, 40.0, 45.0, 'Yüksek', 'Broome: Uzak batı WA. Turizm ve inci. Lojistik çok zorlu.'),
(20, 35000000.00, 50.0, 70.0, 'Yüksek', 'Mount Isa: Uzak QLD maden kenti. Altyapı sadece madenciliğe yönelik. Lojistik zorlu.'),
(21, 80000000.00, 80.0, 75.0, 'Düşük', 'Toowoomba: Güçlü tarım ve lojistik merkezi. İyi kara yolu bağlantıları.'),
(22, 60000000.00, 85.0, 80.0, 'Orta', 'Mackay: Bowen Havzası kömür ihracat kapısı (Hay Point/Dalrymple Bay). Madencilik iş gücü mevcut.'),
(23, 70000000.00, 75.0, 70.0, 'Düşük', 'Rockhampton: Madencilik ve tarım (özellikle sığır) için bölgesel hizmet merkezi.'),
(24, 40000000.00, 70.0, 65.0, 'Düşük', 'Bundaberg: Tarım odaklı ekonomi (şeker kamışı). Liman kapasitesi sınırlı.'),
(25, 30000000.00, 65.0, 60.0, 'Düşük', 'Hervey Bay: Turizm ve hizmet sektörü ağırlıklı. Sanayi altyapısı zayıf.'),
(26, 90000000.00, 92.0, 85.0, 'Orta', 'Gladstone: Avustralya''nın en önemli sanayi ve LNG/kömür/boksit limanlarından biri. Mükemmel altyapı.'),
(27, 110000000.00, 88.0, 85.0, 'Düşük', 'Central Coast (Gosford): Sydney''e yakın, güçlü banliyö ekonomisi ve iş gücü havuzu.'),
(28, 45000000.00, 85.0, 70.0, 'Düşük', 'Tweed Heads: Gold Coast ile entegre. Turizm ve hizmet odaklı.'),
(29, 40000000.00, 75.0, 65.0, 'Düşük', 'Coffs Harbour: Turizm ve tarım. Orta ölçekli bölgesel merkez.'),
(30, 35000000.00, 70.0, 60.0, 'Düşük', 'Port Macquarie: Hizmet ve turizm odaklı, büyüyen emekli nüfusu.'),
(31, 50000000.00, 70.0, 75.0, 'Orta', 'Orange: Önemli altın madenciliği (Newcrest''in Cadia madeni yakın) ve tarım bölgesi.'),
(32, 45000000.00, 75.0, 70.0, 'Düşük', 'Dubbo: NSW için iç lojistik ve tarım merkezi. Önemli bir kavşak noktası.'),
(33, 40000000.00, 70.0, 65.0, 'Düşük', 'Tamworth: Tarım merkezi, bölgesel hizmetler.'),
(34, 60000000.00, 80.0, 75.0, 'Düşük', 'Wagga Wagga: Önemli bölgesel merkez, savunma (ordu/hava üssü) ve tarım.'),
(35, 38000000.00, 70.0, 70.0, 'Düşük', 'Bathurst: Eğitim ve tarım. Bölgesel merkez.'),
(36, 25000000.00, 45.0, 60.0, 'Yüksek', 'Broken Hill: Tarihi maden kenti (BHP''nin doğuşu), çok uzak, lojistik zorlu.'),
(37, 70000000.00, 85.0, 80.0, 'Düşük', 'Ballarat: Melbourne''e yakın, tarihi (altın) ve büyüyen bölgesel merkez. İyi iş gücü.'),
(38, 68000000.00, 82.0, 78.0, 'Düşük', 'Bendigo: Güçlü bölgesel merkez, Ballarat''a benzer yapıda.'),
(39, 45000000.00, 70.0, 65.0, 'Düşük', 'Shepparton: Tarım ve gıda işleme endüstrisi merkezi.'),
(40, 40000000.00, 65.0, 60.0, 'Orta', 'Mildura: Uzak tarım bölgesi (özellikle üzüm/şarap). Lojistik orta zorlukta.'),
(41, 35000000.00, 70.0, 65.0, 'Düşük', 'Warrnambool: Kıyısal merkez, tarım ve turizm (Great Ocean Road bitişi).'),
(42, 55000000.00, 75.0, 80.0, 'Orta', 'Traralgon (Latrobe Valley): Enerji üretim merkezi (linyit). Ekonomik geçiş süreci riski.'),
(43, 65000000.00, 88.0, 80.0, 'Düşük', 'Bunbury: Perth''in güneyindeki ana liman. Alümina, mineral ve tarım ihracatı.'),
(44, 50000000.00, 80.0, 75.0, 'Orta', 'Geraldton: Orta-Batı bölgesel limanı. Tahıl ve demir cevheri ihracatı.'),
(45, 40000000.00, 75.0, 70.0, 'Düşük', 'Albany: Güney kıyısı limanı. Tarım ve turizm.'),
(46, 100000000.00, 90.0, 85.0, 'Yüksek', 'Karratha: Pilbara''nın kalbi. Demir cevheri (Dampier) ve LNG merkezi. Yüksek maliyet, siklon riski.'),
(47, 30000000.00, 70.0, 60.0, 'Düşük', 'Busselton: Turizm ve şarapçılık (Margaret River bölgesi). Sanayi yok.'),
(48, 35000000.00, 70.0, 65.0, 'Düşük', 'Mount Gambier: Ormancılık ve tarım. VIC sınırına yakın.'),
(49, 40000000.00, 75.0, 70.0, 'Orta', 'Whyalla: Çelik fabrikası (GFG Alliance) merkezi. Endüstriyel dönüşüm riski.'),
(50, 30000000.00, 70.0, 65.0, 'Orta', 'Port Augusta: Lojistik kavşağı, yenilenebilir enerjiye geçiş (eski kömür santrali sahası).'),
(51, 38000000.00, 72.0, 70.0, 'Yüksek', 'Port Pirie: Önemli metal izabe tesisi (kurşun). Çevresel riskler.'),
(52, 35000000.00, 70.0, 65.0, 'Düşük', 'Port Lincoln: Balıkçılık (ton balığı) ve tarım limanı.'),
(53, 38000000.00, 72.0, 75.0, 'Düşük', 'Launceston: Tazmanya''nın kuzey merkezi. Bölgesel hizmetler.'),
(54, 30000000.00, 78.0, 70.0, 'Düşük', 'Devonport: Tazmanya''nın ana lojistik limanı (Melbourne bağlantısı).'),
(55, 10000000.00, 40.0, 50.0, 'Yüksek', 'Katherine: Uzak bölgesel kasaba. Savunma, tarım. Lojistik çok zorlu.');
    

-- city_id, mineral_id, unit_id'ler AUTO_INCREMENT ID'lerine karşılık gelmelidir.
-- city_id 1-55, mineral_id 1-4, unit_id 1-4
INSERT INTO potential_city_reserves (city_id, mineral_id, estimated_amount, unit_id)
VALUES
(1, 1, 5000000, 1),  -- Perth (WA): Iron Ore, 5M tons
(2, 4, 2000000, 1),  -- Port Hedland (WA): Coal, 2M tons
(3, 2, 150000, 3),   -- Kalgoorlie (WA): Gold, 150k oz
(4, 4, 25000000, 1), -- Brisbane (QLD): Coal, 25M tons
(5, 3, 50000000, 1), -- Weipa (QLD): Bauxite, 50M tons (Büyük Boksit yatağı)
(8, 1, 8000000, 1),  -- Adelaide (SA): Iron Ore, 8M tons
(11, 3, 5000000, 1), -- Darwin (NT): Bauxite, 5M tons
(13, 4, 40000000, 1), -- Newcastle (NSW): Coal, 40M tons (Büyük Kömür limanı)
(16, 2, 40000, 3),   -- Townsville (QLD): Gold, 40k oz
(18, 2, 25000, 3),   -- Alice Springs (NT): Gold, 25k oz
(19, 1, 15000000, 1), -- Broome (WA): Iron Ore, 15M tons
(20, 2, 75000, 3),  -- Mount Isa (QLD): Gold, 75k oz
(21, 4, 12000000, 1), -- Toowoomba (QLD) (Surat Havzası): Kömür, 12M ton
(22, 4, 80000000, 1), -- Mackay (QLD) (Bowen Havzası): Kömür, 80M ton
(23, 4, 15000000, 1), -- Rockhampton (QLD): Kömür, 15M ton
(26, 3, 30000000, 1), -- Gladstone (QLD): Boksit, 30M ton
(26, 4, 20000000, 1), -- Gladstone (QLD): Kömür, 20M ton (Aynı şehirde ikinci mineral)
(31, 2, 250000, 3),  -- Orange (NSW) (Cadia): Altın, 250k oz
(32, 2, 30000, 3),   -- Dubbo (NSW): Altın, 30k oz
(35, 2, 20000, 3),   -- Bathurst (NSW): Altın, 20k oz
(36, 2, 60000, 3),   -- Broken Hill (NSW): Altın (Gümüş/Kurşun/Çinko için proxy), 60k oz
(37, 2, 100000, 3),  -- Ballarat (VIC): Altın, 100k oz
(38, 2, 90000, 3),   -- Bendigo (VIC): Altın, 90k oz
(42, 4, 150000000, 1),-- Traralgon (VIC) (Latrobe Valley): Kömür (Linyit), 150M ton
(43, 3, 10000000, 1), -- Bunbury (WA): Boksit (Alümina rafinerileri yakını), 10M ton
(44, 1, 18000000, 1), -- Geraldton (WA): Demir Cevheri, 18M ton
(46, 1, 200000000, 1),-- Karratha (WA) (Pilbara): Demir Cevheri, 200M ton
(49, 1, 40000000, 1), -- Whyalla (SA): Demir Cevheri, 40M ton
(50, 1, 15000000, 1), -- Port Augusta (SA): Demir Cevheri, 15M ton
(51, 2, 25000, 3),   -- Port Pirie (SA): Altın (Proxy), 25k oz
(53, 2, 15000, 3),   -- Launceston (TAS): Altın, 15k oz
(55, 2, 35000, 3);   -- Katherine (NT): Altın, 35k oz

-- Maden Sahaları (Manuel ID'ler kaldırıldı)
-- city_id, company_id, primary_mineral_id'ler AUTO_INCREMENT ID'lerine karşılık gelmelidir.
INSERT INTO mining_sites (name, city_id, company_id, primary_mineral_id, status, established_date, permitted_capacity_tons_per_day) VALUES
('Mount Whaleback', 2, 2, 1, 'Aktif', '1968-01-01', 150000), -- ID = 1
('Super Pit', 3, 1, 2, 'Aktif', '1989-01-01', 50000), -- ID = 2
('Weipa Bauxite Mine', 5, 1, 3, 'Bakımda', '1963-01-01', 75000); -- ID = 3

-- BAĞIMLI TABLOLAR (Tier 2)

-- Çalışanlar (Manuel ID'ler kaldırıldı)
-- role_id, department_id, site_id'ler AUTO_INCREMENT ID'lerine karşılık gelmelidir.
INSERT INTO employees (first_name, last_name, email, phone, role_id, department_id, hire_date, employment_type, salary, manager_id, site_id, certifications, is_active) VALUES
('John', 'Doe', 'john.doe@bhp.com', '0411223344', 1, 1, '2010-05-15', 'Full-Time', 250000.00, NULL, 1, '{"PMP": "123", "MineSafetyCert": "MSC-001"}', TRUE), -- ID = 1
('Jane', 'Smith', 'jane.smith@riotinto.com', '0422334455', 1, 1, '2012-07-20', 'Full-Time', 240000.00, NULL, 2, '{"PMP": "456"}', TRUE), -- ID = 2
('Mike', 'Johnson', 'mike.j@bhp.com', '0433445566', 3, 1, '2018-02-10', 'Full-Time', 120000.00, 1, 1, '{"HR_License": "789", "OperatorCert": "OPC-111"}', TRUE), -- ID = 3
('Emily', 'Davis', 'emily.d@riotinto.com', '0444556677', 2, 2, '2020-11-01', 'Full-Time', 110000.00, 2, 2, '{"GeoCert": "ABC"}', TRUE), -- ID = 4
('Chris', 'Lee', 'chris.l@bhp.com', '0455667788', 4, 3, '2019-06-05', 'Full-Time', 95000.00, 1, 1, '{"SafetyCert": "DEF", "FirstAid": "FA-222"}', TRUE), -- ID = 5
('Sarah', 'Wilson', 'sarah.w@riotinto.com', '0466778899', 5, 4, '2021-01-20', 'Part-Time', 75000.00, 2, 2, '{"LogisticsMgmt": "LGM-333"}', TRUE); -- ID = 6

-- Ekipmanlar (Manuel ID'ler kaldırıldı)
INSERT INTO equipment (site_id, equipment_code, equipment_name, type, manufacturer, model, purchase_date, purchase_value, service_interval_days, last_service_date, next_service_date, status, location_detail) VALUES
(1, 'TRK-101', 'Haul Truck 101', 'Truck', 'Caterpillar', '797F', '2020-01-15', 3500000.00, 90, '2025-09-01', '2025-12-01', 'Çalışıyor', 'Pit A, Ramp 2'), -- ID = 1
(1, 'EXC-201', 'Excavator 201', 'Excavator', 'Komatsu', 'PC8000', '2019-05-20', 7000000.00, 120, '2025-08-15', '2025-12-15', 'Çalışıyor', 'Pit B, Face 1'), -- ID = 2
(2, 'DRL-301', 'Drill Rig 301', 'Drill', 'Sandvik', 'DR580', '2021-03-10', 1500000.00, 60, '2025-10-01', '2025-12-01', 'Bakımda', 'West Face Processing Area'), -- ID = 3
(3, 'BLD-401', 'Bulldozer 401', 'Dozer', 'Caterpillar', 'D11', '2018-07-30', 2200000.00, 90, '2025-09-15', '2025-12-15', 'Arızalı', 'Stockpile East'); -- ID = 4

-- Çevresel Olaylar (Manuel ID'ler kaldırıldı)
INSERT INTO environmental_incidents (site_id, date, type, volume, contamination_level, remediation_status, regulatory_reported, fine_amount) VALUES
(1, '2025-08-01', 'Diesel Spill', 500.00, 'Low', 'Completed', TRUE, 10000.00),
(3, '2025-07-20', 'Tailing Dam Leakage', 1200.00, 'Medium', 'Pending', TRUE, 150000.00);


-- BAĞIMLI TABLOLAR (Tier 3 - En çok bağımlılığı olanlar)

-- ================================================
-- GEÇMİŞ VERİ BÖLÜMÜ - PROJEKSİYONLAR İÇİN GEREKLİ
-- ================================================

-- Üretim Kayıtları (Tümü TEK BİR SORGUDA BİRLEŞTİRİLDİ VE ID SÜTUNU KALDIRILDI)
-- site_id 1-3, mineral_id 1-3, supervisor_id 1-6 arası olmalı
INSERT INTO production_logs (site_id, mineral_id, supervisor_id, log_datetime, produced_amount, shift, fuel_consumed, operating_hours, efficiency_pct, notes) VALUES
-- Orijinal 4 kayıt
(1, 1, 1, '2025-10-21 08:00:00', 5000.00, 'Sabah', 1200.50, 8.0, 95.5, 'Normal operations, grade 62% Fe'),
(2, 2, 2, '2025-10-21 14:00:00', 150.75, 'Öğle', 400.20, 7.5, 92.0, 'Grade slightly lower (2.1 g/t)'),
(1, 1, 1, '2025-10-21 16:00:00', 4800.00, 'Öğle', 1150.00, 8.0, 94.0, 'Shift change notes, crusher feed normal'),
(3, 3, 2, '2025-10-20 09:00:00', 3000.00, 'Sabah', 850.00, 8.0, 90.0, 'Site currently in maintenance, partial production test'),
-- Site 1 Geçmiş Verileri
(1, 1, 1, '2024-11-15 08:00:00', 4500.00, 'Sabah', 1100.00, 8.0, 92.0, 'Geçmiş veri'),
(1, 1, 1, '2024-12-15 08:00:00', 4700.00, 'Sabah', 1150.00, 8.0, 93.0, 'Geçmiş veri'),
(1, 1, 1, '2025-01-15 08:00:00', 4600.00, 'Sabah', 1120.00, 8.0, 92.5, 'Geçmiş veri'),
(1, 1, 1, '2025-02-15 08:00:00', 4300.00, 'Sabah', 1050.00, 8.0, 90.0, 'Yağışlar nedeniyle verimlilik düştü'),
(1, 1, 1, '2025-03-15 08:00:00', 4800.00, 'Sabah', 1180.00, 8.0, 94.0, 'Geçmiş veri'),
(1, 1, 1, '2025-04-15 08:00:00', 5100.00, 'Sabah', 1250.00, 8.0, 96.0, 'Yüksek tenörlü cevher'),
(1, 1, 1, '2025-05-15 08:00:00', 5200.00, 'Sabah', 1280.00, 8.0, 97.0, 'Geçmiş veri'),
(1, 1, 1, '2025-06-15 08:00:00', 5050.00, 'Sabah', 1240.00, 8.0, 95.0, 'Geçmiş veri'),
(1, 1, 1, '2025-07-15 08:00:00', 4900.00, 'Sabah', 1200.00, 8.0, 94.5, 'Geçmiş veri'),
(1, 1, 1, '2025-08-15 08:00:00', 4950.00, 'Sabah', 1210.00, 8.0, 95.0, 'Geçmiş veri'),
(1, 1, 1, '2025-09-15 08:00:00', 5150.00, 'Sabah', 1260.00, 8.0, 96.5, 'Geçmiş veri'),
-- Site 2 Geçmiş Verileri
(2, 2, 2, '2025-01-20 14:00:00', 140.50, 'Öğle', 380.00, 7.5, 90.0, 'Geçmiş veri'),
(2, 2, 2, '2025-02-20 14:00:00', 135.00, 'Öğle', 370.00, 7.5, 88.0, 'Geçmiş veri'),
(2, 2, 2, '2025-03-20 14:00:00', 145.20, 'Öğle', 390.00, 7.5, 91.0, 'Geçmiş veri'),
(2, 2, 2, '2025-04-20 14:00:00', 155.00, 'Öğle', 410.00, 7.5, 93.0, 'İyi tenör'),
(2, 2, 2, '2025-05-20 14:00:00', 152.10, 'Öğle', 405.00, 7.5, 92.5, 'Geçmiş veri'),
(2, 2, 2, '2025-06-20 14:00:00', 148.00, 'Öğle', 395.00, 7.5, 91.5, 'Geçmiş veri'),
(2, 2, 2, '2025-07-20 14:00:00', 160.00, 'Öğle', 420.00, 7.5, 95.0, 'Çok yüksek tenör (3.0 g/t)'),
(2, 2, 2, '2025-08-20 14:00:00', 153.00, 'Öğle', 400.00, 7.5, 92.0, 'Geçmiş veri'),
(2, 2, 2, '2025-09-20 14:00:00', 151.00, 'Öğle', 398.00, 7.5, 91.8, 'Geçmiş veri');

-- Operasyonel Riskler (Manuel ID'ler kaldırıldı)
INSERT INTO operational_risks 
(site_id, risk_description, category, severity, mitigation_plan, reported_by, status) 
VALUES
(
    1, 
    'Aşırı yağış nedeniyle maden çukurunda su baskını riski.', 
    'Çevresel', 
    'Yüksek', 
    'Ek drenaj pompaları devreye alınacak, hava durumu 7/24 izlenecek.', 
    1, 
    'Aktif'
),
(
    2, 
    'Ana ekskavatör (EXC-201) hidrolik sisteminde tekrarlayan arıza.', 
    'Ekipman', 
    'Orta', 
    'Detaylı kök neden analizi yapılacak. Kritik yedek parçalar stokta tutulacak.', 
    2, 
    'İzleniyor'
),
(
    1, 
    'Kritik yedek parça tedarik zincirinde gecikme riski.', 
    'Lojistik/Tedarik', 
    'Orta', 
    'Alternatif yerel tedarikçiler araştırılıyor.', 
    5, 
    'Aktif'
),
(
    3, 
    'Liman tesislerinde planlanmamış bakım nedeniyle sevkiyat gecikmesi.', 
    'Lojistik', 
    'Düşük', 
    'Bakım tamamlandı, operasyonlar normale döndü.', 
    1, 
    'Çözüldü'
);


-- Sevkiyat Kayıtları (TÜMÜ BİRLEŞTİRİLDİ VE ID'LER KALDIRILDI)
-- site_id 1-3, port_id 1-4, carrier_id 1-4, unit_id 1-4 olmalı
INSERT INTO shipment_logs (site_id, origin_port_id, destination_port_id, carrier_id, shipment_date, etd, eta, quantity, unit_id, status, container_number, invoice_id, cost) VALUES
-- Orijinal 3 kayıt
(1, 1, 3, 1, '2025-10-15', '2025-10-16', '2025-11-05', 120000.00, 1, 'Yolda', 'BULK-VSSL-A01', 'INV-9876', 1500000.00),
(2, 2, 1, 2, '2025-10-18', '2025-10-20', '2025-11-10', 5000.00, 3, 'Yüklendi', 'CON-67890', 'INV-9877', 75000.00),
(3, 4, 3, 1, '2025-10-22', '2025-10-23', '2025-11-15', 80000.00, 1, 'Yüklendi', 'BULK-VSSL-B02', 'INV-9878', 1100000.00),
-- Site 1 Geçmiş Verileri
(1, 1, 3, 1, '2024-11-20', '2024-11-21', '2024-12-10', 110000.00, 1, 'Teslim Edildi', 'BULK-VSSL-C01', 'INV-9001', 1400000.00),
(1, 1, 3, 1, '2024-12-20', '2024-12-21', '2025-01-10', 115000.00, 1, 'Teslim Edildi', 'BULK-VSSL-C02', 'INV-9002', 1450000.00),
(1, 1, 3, 1, '2025-01-20', '2025-01-21', '2025-02-10', 112000.00, 1, 'Teslim Edildi', 'BULK-VSSL-C03', 'INV-9003', 1420000.00),
(1, 1, 3, 1, '2025-02-20', '2025-02-21', '2025-03-10', 105000.00, 1, 'Teslim Edildi', 'BULK-VSSL-C04', 'INV-9004', 1350000.00),
(1, 1, 3, 1, '2025-03-20', '2025-03-21', '2025-04-10', 118000.00, 1, 'Teslim Edildi', 'BULK-VSSL-C05', 'INV-9005', 1480000.00),
(1, 1, 3, 1, '2025-04-20', '2025-04-21', '2025-05-10', 125000.00, 1, 'Teslim Edildi', 'BULK-VSSL-C06', 'INV-9006', 1550000.00),
(1, 1, 3, 1, '2025-05-20', '2025-05-21', '2025-06-10', 128000.00, 1, 'Teslim Edildi', 'BULK-VSSL-C07', 'INV-9007', 1580000.00),
(1, 1, 3, 1, '2025-06-20', '2025-06-21', '2025-07-10', 126000.00, 1, 'Teslim Edildi', 'BULK-VSSL-C08', 'INV-9008', 1560000.00),
(1, 1, 3, 1, '2025-07-20', '2025-07-21', '2025-08-10', 120000.00, 1, 'Teslim Edildi', 'BULK-VSSL-C09', 'INV-9009', 1500000.00),
(1, 1, 3, 1, '2025-08-20', '2025-08-21', '2025-09-10', 122000.00, 1, 'Teslim Edildi', 'BULK-VSSL-C10', 'INV-9010', 1520000.00),
(1, 1, 3, 1, '2025-09-20', '2025-09-21', '2025-10-10', 124000.00, 1, 'Teslim Edildi', 'BULK-VSSL-C11', 'INV-9011', 1540000.00);


-- Bakım Kayıtları (TÜMÜ BİRLEŞTİRİLDİ VE ID'LER KALDIRILDI)
-- equipment_id 1-4, site_id 1-3, performed_by 1-6, vendor_id 1-4 olmalı
INSERT INTO maintenance_logs (equipment_id, site_id, maintenance_date, maintenance_type, description, performed_by, vendor_id, cost, downtime_minutes, next_due_date) VALUES
-- Orijinal 3 kayıt
(3, 2, '2025-10-01', 'Planned', '60-day planned service for drill rig', 4, 4, 25000.00, 1440, '2025-12-01'),
(1, 1, '2025-10-20', 'Unplanned', 'Haul truck hydraulic line burst', 3, 3, 8500.00, 480, NULL),
(4, 3, '2025-10-22', 'Unplanned', 'Dozer engine failure investigation', 1, 3, 12000.00, 2880, NULL),
-- Ekipman 1 Geçmiş Verileri
(1, 1, '2024-12-01', 'Planned', '90-day service', 3, 3, 15000.00, 720, '2025-03-01'),
(1, 1, '2025-03-01', 'Planned', '90-day service', 3, 3, 15500.00, 750, '2025-06-01'),
(1, 1, '2025-04-10', 'Unplanned', 'Tire replacement (x2)', 3, 3, 22000.00, 360, NULL),
(1, 1, '2025-06-01', 'Planned', '90-day service', 3, 3, 16000.00, 720, '2025-09-01'),
(1, 1, '2025-09-01', 'Planned', '90-day service (Orijinal verideki)', 3, 3, 16500.00, 730, '2025-12-01'),
-- Ekipman 2 Geçmiş Verileri
(2, 1, '2024-12-15', 'Planned', '120-day service', 3, 3, 35000.00, 1440, '2025-04-15'),
(2, 1, '2025-04-15', 'Planned', '120-day service', 3, 3, 36000.00, 1440, '2025-08-15'),
(2, 1, '2025-07-05', 'Unplanned', 'Hydraulic leak (minor)', 3, 3, 7500.00, 300, NULL),
(2, 1, '2025-08-15', 'Planned', '120-day service (Orijinal verideki)', 3, 3, 37000.00, 1440, '2025-12-15');


-- Eğitim Kayıtları (Manuel ID'ler kaldırıldı)
INSERT INTO training_records (employee_id, training_name, completion_date, expiry_date, certificate_no, provider) VALUES
(3, 'Haul Truck Operation Cert (CAT 797F)', '2024-01-15', '2026-01-15', 'CAT-987', 'Caterpillar'),
(5, 'Occupational First Aid Level 2', '2025-03-01', '2028-03-01', 'STJ-123', 'St John Ambulance'),
(1, 'Mine Safety Management (G2)', '2023-11-10', '2026-11-10', 'WA-MSM-001', 'WA Mining Board'),
(4, 'Advanced Geological Modelling', '2024-05-20', NULL, 'GEO-MOD-456', 'UniWA');

-- İş Güvenliği Olayları (Manuel ID'ler kaldırıldı)
INSERT INTO safety_incidents (site_id, reported_by, incident_datetime, description, severity, status, injured_count, lost_time_hours, root_cause, corrective_action, cost_estimate) VALUES
(1, 5, '2025-09-15 10:30:00', 'Minor slip and fall near processing plant.', 'Düşük', 'Çözüldü', 1, 4.0, 'Wet floor, no signage', 'Install non-slip mats and mandatory signage', 500.00),
(2, 2, '2025-10-01 14:00:00', 'Vehicle collision (low speed) between two haul trucks.', 'Orta', 'Aktif', 0, 8.0, 'Driver fatigue, blind spot', 'Review shift schedules, install proximity sensors', 22000.00);

-- ---------------------
-- 5) FINALIZE: commit and re-enable FK checks
-- ---------------------
COMMIT;
SET FOREIGN_KEY_CHECKS = 1;

-- ***** BÜYÜK SEED SCRIPT END *****
}