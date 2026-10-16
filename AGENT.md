# AGENT.md — Buzul Geliştirici ve Ajan Kuralları Sözleşmesi

> **Proje:** Buzul (Kurumsal Bulut Veri Ambarı Kredi ve Kota Yönetim Platformu)  
> **Teknoloji:** Ruby on Rails 8.1.4, Ruby 3.4.7, SQLite3 / PostgreSQL  
> **Son Güncelleme:** 16 Ekim 2026

Bu belge, Buzul projesinde çalışacak yapay zeka ajanları (Coding Agents) ve yazılım mühendisleri için bağlayıcı mimari, kodlama, test, güvenlik ve doğrulama kurallarını belirler. Jenerik kurallar yerine bu deponun gerçek dosya yapısı ve teknik gereksinimlerine göre hazırlanmıştır.

---

## 1. Temel Mimari Prensipler

1. **Katmanlı Servis Ayrımı (Clean Service Architecture):**
   - İş kuralları, kota hesaplamaları ve durum geçişleri asla Controller sınıfları içine gömülmemelidir.
   - Durum geçişleri için `Warehouses::StatusTransitionService` kullanılmalıdır.
   - Kota hesaplamaları ve eşik kontrolleri için `Finops::QuotaCalculatorService` kullanılmalıdır.
   - SLA zaman aşımı ve koruyucu askıya alma işlemleri için `Finops::AutoGovernorEngine` kullanılmalıdır.

2. **Durum Makinesi Bütünlüğü:**
   - Ambar durumları yalnızca `active`, `warning`, `throttled`, `suspended` olabilir.
   - İzin verilen geçişler `Warehouse::TRANSITIONS` sabiti ile sıkı bir şekilde sınırlandırılmıştır. İzin verilmeyen bir geçiş denendiğinde sessizce geçilmemeli, hata fırlatılmalı veya reddedilmelidir.

3. **Denetim İzi (Audit Logging):**
   - Her durum değişikliğinde mutlaka bir `StatusEvent` kaydı oluşturulmalıdır (`from_status`, `to_status`, `reason`, `triggered_by_id`, `created_at`).

4. **Özgün Marka Kimliği:**
   - İlham kaynağı Snowflake olsa dahi, uygulama arayüzünde, HTML şablonlarında, CSS sınıflarında veya görsel varlıklarda Snowflake adı veya logosu kesinlikle yer alamaz. Proje adı her zaman **Buzul**'dur.

5. **CLI ve Arka Plan Görevleri:**
   - 15 dakikalık SLA süresi dolan ambarları arka planda tarayıp güvenli biçimde askıya almak için `lib/tasks/finops.rake` (`bin/rails finops:auto_govern`) komutu kullanılmalıdır. Bu görev `Finops::AutoGovernorEngine.run!` üzerinden idempotent çalışır.

---

## 2. Kodlama ve Stil Standartları

1. **Ruby on Rails 8 Standartları:**
   - Rails 8 sözdizimi ve modern Ruby 3.4 özellikleri (örneğin tek satırlık metod tanımları `def usage_pct = ...`) tercih edilir.
   - Kimlik doğrulama için Rails'in yerleşik `has_secure_password` mekanizması kullanılır.
   - Varlık yönetimi için Propshaft ve importmap standartlarına uyulur.

2. **Model Doğrulamaları (Validations):**
   - Her modelde veri bütünlüğünü garanti eden doğrulayıcılar bulunmalıdır.
   - `Department#cost_center_code`: `/\ACP-\d{3,6}\z/` formatında olmalı (örn: `CP-001`).
   - `Warehouse#credit_quota`: Sıfırdan büyük pozitif bir sayı olmalıdır.
   - `Warehouse#warning_threshold_pct`: 1 ile 99 arasında bir tam sayı olmalıdır (varsayılan: 80).

3. **RuboCop ve Statik Analiz:**
   - Kod değişiklikleri sonrası `bin/rubocop` çalıştırılmalı ve stil ihlalleri temizlenmelidir.
   - Güvenlik açıkları için `bin/brakeman` analizinde sıfır yüksek seviyeli uyarı hedeflenir.

---

## 3. Test ve Doğrulama Kuralları

1. **Zaman Makinesi Test Zorunluluğu (`travel_to`):**
   - 15 dakikalık SLA kuralları test edilirken kesinlikle `sleep` veya rastgele gecikmeler kullanılamaz.
   - `ActiveSupport::Testing::TimeHelpers` altındaki `travel_to` kullanılmalıdır:
     - 14. dakika testi: Ambarın halen `throttled` kaldığı ve askıya alınmadığı doğrulanmalıdır.
     - 16. dakika testi: Ambarın otomatik olarak `suspended` durumuna geçtiği doğrulanmalıdır.

2. **Gerçek Test Koşumu:**
   - Testler yazıldıktan sonra mutlaka yerel veya CI ortamında gerçekten çalıştırılmalıdır. Çıktı alınmadan "testler başarılı" raporu verilemez.
   - Komut: `bin/rails test`

---

## 4. Windows ve Ortam Kuralları

1. **Non-ASCII Dosya Yolu Uyarısı:**
   - Projenin `OneDrive\Masaüstü` gibi Türkçe karakterli dizinlerde bulunması durumunda, Ruby'nin MinGW UCRT derlemesi `config/boot.rb` yüklemesinde `LoadError` verebilir.
   - Bu sorun `config/boot.rb` içerisinde bootsnap'in güvenli koşullandırılmasıyla yönetilmektedir. Geliştirme ortamında en kararlı deneyim için projenin `C:\buzul` gibi temiz bir ASCII dizinde çalıştırılması tavsiye edilir.

2. **PowerShell ve Karakter Kodlaması:**
   - Dosya yazma veya betik çalıştırma işlemlerinde PowerShell boru (`|`) operatörlerinin kaçışına dikkat edilmeli, dosyalar her zaman UTF-8 kodlamasıyla kaydedilmelidir.

---

## 5. Güvenlik ve Gizlilik Kuralları

1. **Sırların ve Parolaların Korunması:**
   - `master.key`, API tokenları veya veritabanı şifreleri asla kaynak koda veya commit geçmişine yazılmamalıdır.
   - Üretim ortamında `RAILS_MASTER_KEY` veya çevre değişkenleri (`ENV`) kullanılmalıdır.

2. **Sentetik Veri İlkesi:**
   - Hiçbir geliştirme veya test aşamasında gerçek şirket verileri, gerçek kredi kartı bilgileri veya gerçek Snowflake kimlik bilgileri kullanılmaz. Tüm telemetri sentetik olarak türetilir.
