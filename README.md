# 🇦🇺 Australia Mining Decision Support System (KDS)

Bu proje, Avustralya madencilik operasyonları için geliştirilmiş web tabanlı bir **Karar Destek Sistemidir (DSS)**. Lojistik, üretim takibi, maliyet simülasyonları ve ROI analizlerini tek bir panelde birleştirir.

![Status](https://img.shields.io/badge/Status-Completed-success)
![License](https://img.shields.io/badge/License-MIT-blue)

## 🚀 Özellikler

Bu sistem, yöneticilerin veriye dayalı stratejik kararlar almasını sağlar:

* **🗺️ İnteraktif Harita:** Leaflet.js ile Avustralya'daki maden sahaları, limanlar ve şehirlerin coğrafi analizi.
* **📊 Monte Carlo Simülasyonu:** Operasyonel maliyetlerin risk senaryolarına (iyimser/kötümser) göre tahmini.
* **💰 ROI Analizörü:** Yeni maden sahaları için "Go / No-Go" yatırım geri dönüş analizi.
* **🚛 Lojistik Takibi:** Sevkiyatların durumu, liman kapasiteleri ve tedarik zinciri yönetimi.
* **📈 Üretim Projeksiyonları:** Geçmiş verilere dayanarak gelecek üretim tahminleri.
* **⚠️ Risk Yönetimi:** İş güvenliği ve çevresel olayların takibi ve raporlanması.

## 🛠️ Teknolojiler

* **Frontend:** HTML5, Tailwind CSS, Chart.js (Veri Görselleştirme), Leaflet.js (Harita)
* **Backend:** Node.js, Express.js
* **Veritabanı:** MySQL
* **Veri Analizi:** İstatistiksel Simülasyon Algoritmaları (Backend tarafında)

## ⚙️ Kurulum

Projeyi yerel makinenizde çalıştırmak için:

1.  Repoyu klonlayın:
    ```bash
    git clone [https://github.com/KULLANICI_ADIN/australia-mining-dss.git](https://github.com/KULLANICI_ADIN/australia-mining-dss.git)
    ```

2.  Bağımlılıkları yükleyin:
    ```bash
    npm install
    ```

3.  Veritabanını Kurun:
    * MySQL'de `coal` adında bir veritabanı oluşturun.
    * `database/coal.sql` dosyasını içe aktarın (Import).

4.  `.env` dosyasını oluşturun:
    * Ana dizinde `.env` dosyası oluşturun ve veritabanı bilgilerinizi girin:
    ```env
    DB_HOST=localhost
    DB_USER=root
    DB_PASSWORD=sifreniz
    DB_NAME=coal
    ```

5.  Uygulamayı başlatın:
    ```bash
    node server.js
    ```
    Tarayıcıda `http://localhost:3000` adresine gidin.

## 📷 Ekran Görüntüleri

<img width="1362" height="624" alt="Screenshot From 2025-12-16 13-42-59" src="https://github.com/user-attachments/assets/9881f7c8-2734-429b-9371-3e6a95a69529" />
<img width="1366" height="768" alt="Screenshot From 2025-12-16 13-47-59" src="https://github.com/user-attachments/assets/c13e1c21-638b-4e8c-942b-1773df9324f3" />
<img width="533" height="414" alt="Screenshot From 2025-12-16 22-34-50" src="https://github.com/user-attachments/assets/970467c0-d614-4139-b2a2-e668337fa95e" />
<img width="534" height="447" alt="Screenshot From 2025-12-16 22-36-58" src="https://github.com/user-attachments/assets/39af06b1-e15d-4f60-8b00-5f9018e06ed2" />
<img width="534" height="487" alt="Screenshot From 2025-12-16 22-38-54" src="https://github.com/user-attachments/assets/1f27d4bf-0611-46dd-95d6-6a6eb21e2aee" />


---
**Lisans:** Bu proje MIT Lisansı ile lisanslanmıştır. Eğitim amaçlı geliştirilmiştir.
