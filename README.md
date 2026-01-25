# 🇦🇺 Australia Mining Decision Support System (KDS)

Bu proje, Avustralya madencilik operasyonları için geliştirilmiş web tabanlı bir **Karar Destek Sistemidir (DSS)**. Lojistik, üretim takibi, maliyet simülasyonları ve ROI analizlerini tek bir panelde birleştirir.

Bu proje, karmaşık madencilik operasyonlarını veri odaklı stratejilere dönüştüren yeni nesil bir Karar Destek Sistemidir (KDS). Geleneksel yönetim panellerinin ötesine geçerek; yöneticilerin Monte Carlo algoritmalarıyla belirsizlik altındaki riskleri simüle etmelerine, ROI Analizörü ile milyar dolarlık yatırım kararlarını test etmelerine ve AI Destekli Asistan ile sistem içinde doğal dille (NLP) geznmelerine olanak tanır. Lojistikten iş güvenliğine, üretimden finansal tahminlemeye kadar tüm süreçleri tek bir coğrafi dashboard üzerinde birleştirir.


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


🤖 AI Operasyon Asistanı Kullanım Rehberi

Bu proje, yöneticilerin karmaşık menüler arasında kaybolmadan istedikleri veriye anında ulaşabilmesi için Doğal Dil İşleme (NLP) tabanlı akıllı bir navigasyon asistanı içerir.
1. Nasıl Kullanılır?

Sol panelin en üstündeki "AI Operasyon Asistanı" kutucuğuna ne görmek istediğinizi yazmanız ve Enter tuşuna basmanız (veya mavi ok butonuna tıklamanız) yeterlidir. Asistan, yazdığınız metni analiz eder ve sizi ilgili panele veya harita lokasyonuna otomatik olarak yönlendirir.
2. Neler Yapabilirsiniz?

Asistan şu anahtar kelimeleri ve komutları anlayabilir (Büyük/küçük harf veya Türkçe karakter duyarlılığı yoktur):

    🌍 Şehir ve Lokasyon Arama:

        Herhangi bir şehir adını yazdığınızda (Örn: "Perth", "Brisbane"), sistem haritayı o şehre odaklar ve şehrin stratejik analiz verilerini yükler.

    📊 Yönetim Panellerine Erişim:

        Riskler: "Riskleri göster", "Tehlike durumları", "Olaylar" yazarak Operasyonel Risk Yönetimi paneline gidebilirsiniz.

        Maliyetler: "Maliyet analizi", "Bütçe", "Finans" komutları Maliyet Analizi panelini açar.

        Lojistik: "Sevkiyatlar", "Gemiler", "Lojistik durumu" yazarak Sevkiyat Takip paneline ulaşabilirsiniz.

        Ekipmanlar: "Kamyonlar nerde", "Ekipman durumu", "Bakım" komutları Ekipman Yönetimi panelini açar.

        Personel: "Çalışan listesi", "Personel" komutları İK panelini yükler.

    📈 İleri Düzey Simülasyonlar:

        Tahminler: "Gelecek tahminleri", "Simülasyonlar" veya "Karar Destek" yazarak tüm tahmin modüllerinin (Monte Carlo, ROI, Bakım) bulunduğu ana merkeze ulaşabilirsiniz.

        Yatırım Analizi: "ROI hesapla", "Yatırım" veya "Geri dönüş" komutları doğrudan Yeni Saha Yatırım Analizörü'nü açar.


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



# Sistemi yazılabilir yap (image_6f69af.png'de Yes dediysen çalışır)
mount -o remount,rw /system

# Kimlik Bilgilerini Samsung S9 (SM-G960F) Olarak Güncelle
sed -i 's/ro.product.brand=.*/ro.product.brand=samsung/g' /system/build.prop
sed -i 's/ro.product.manufacturer=.*/ro.product.manufacturer=samsung/g' /system/build.prop
sed -i 's/ro.product.model=.*/ro.product.model=SM-G960F/g' /system/build.prop
sed -i 's/ro.product.name=.*/ro.product.name=starltexx/g' /system/build.prop
sed -i 's/ro.product.device=.*/ro.product.device=starlte/g' /system/build.prop

# Sanal Makine İzlerini Silecek O Kritik İmza (Fingerprint)
sed -i 's/ro.build.fingerprint=.*/ro.build.fingerprint=samsung\/starltexx\/starlte:9\/PPR1.180610.011\/G960FXXU2CRLI:user\/release-keys/g' /system/build.prop

# DNS Sızıntısını Önlemek İçin Whonix'e Zorla
setprop net.dns1 10.152.152.10

# Değişiklikleri Kaydet ve Yeniden Başlat
reboot
