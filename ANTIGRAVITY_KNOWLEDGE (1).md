# ANTIGRAVITY KNOWLEDGE — Fortune 500 SaaS Aort Dilimi

**Son kontrol tarihi:** 16 Ekim 2026  
**Amaç:** Antigravity'nin ödev gereksinimlerini eksiksiz ve kanıtlanabilir şekilde yerine getirmesine yardımcı olan proje bilgi tabanı. Bu belge araştırmanın son sonucu değil, araştırmayı doğru yürütme rehberidir. Her kaynak açılıp iddia bazında doğrulanmalıdır.

## 1. Ödevin başarı tanımı

Ödevin puanlaması ikili ve serttir:
- **0 puan riski:** Canlı URL yok; ana akış uçtan uca çalışmıyor; sunumda var denilen özellik çalışmıyor; test sonucu uydurulmuş; orijinal marka adı/logo uygulamada.
- **85 puan için:** Fortune 500 kanıtı ve kaynaklı Faz 1/Faz 2 README'de; canlı aort dilimi; GitHub Actions yeşil ve README rozeti; `travel_to` ile zaman kuralı testleri; durum geçişi testleri; proje özelinde `AGENT.md`; README'de “Yapamadıklarım”.
- **100+ için:** Yukarıdakilerin tamamı ve gerçek kullanıcı yorumlarından çıkarılan bir acının çalışan uygulamada çözülmesi.

Kod miktarı tek başına başarı değildir. En önemli kanıtlar: çalışan canlı URL, gerçek test sonucu, kaynakların iddiaları desteklemesi ve yorumdan ürüne izlenebilir bağlantı.

## 2. Araştırma standardı

Her araştırma iddiası için şu alanlar kaydedilmeli:
- İddia ve sayı
- Ölçüm birimi ve dönem
- Kaynağın başlığı/kurumu
- Yayın veya son güncelleme tarihi
- Erişim tarihi
- Doğrudan URL
- Kaynağın iddiayı tam olarak nasıl desteklediği
- Sınırlamalar/örneklem

**Önemli kavramsal ayrımlar**
- Fortune 500, ABD'de faaliyet gösteren ve uygun finansal bildirimleri yapan şirketleri **gelire göre** sıralar; piyasa değerine göre sıralamaz.
- Market capitalization / market value, enterprise value ve revenue farklı ölçülerdir. “Değerleme” kullanılırsa hangisinin kastedildiği tanımlanmalı.
- Şirket çalışan sayıları dönem ve konsolidasyon kapsamı açısından farklılık gösterebilir.
- Bir sektör raporundaki ortalama, tek bir Fortune 500 şirketinin doğrulanmış SaaS harcaması değildir.
- SaaS uygulama sayısı ile lisans sayısı aynı şey değildir.
- Kapalı kaynak ticari bir SaaS'ın gerçek LOC sayısı çoğunlukla kamuya açık değildir. “300.000 satır” doğrulanmış gerçek gibi yazılamaz; ancak yöntemli tahmin olarak belirsizlikleriyle sunulabilir.
- 2026'da yayımlanmış rapor, 2025 mali yılı verisi kullanıyor olabilir. Yayın yılı ile veri dönemini ayrı belirt.

## 3. Araştırma başlangıç kaynakları

Aşağıdaki bağlantılar 16 Ekim 2026 araştırması için başlangıç noktalarıdır. Sayfalar açılmalı; her sayının gerçekten hangi kapsamı temsil ettiği kontrol edilmelidir.

| Konu | Kaynak | URL |
|---|---|---|
| 2026 Fortune 500 listesi | Fortune | https://fortune.com/ranking/fortune500/ |
| 2026 Fortune 500 Explorer | Fortune | https://fortune.com/ranking/fortune500/2026/explore/ |
| 2026 Fortune 500 istihdam, gelir, piyasa değeri bağlamı | Fortune | https://fortune.com/2026/06/19/fortune-500-employment-profits-revenue-hiring-jobs-ai/ |
| SaaS harcaması ve portföy büyüklüğü | Zylo 2026 SaaS Management Index | https://zylo.com/2026-saas-management-index |
| SaaS istatistikleri, 2026 güncellemesi | Zylo | https://zylo.com/blog/saas-statistics |
| Zendesk ürün kullanıcı yorumları | G2 | https://www.g2.com/products/zendesk-for-customer-service/reviews |
| Zendesk 2026 G2 yorumlarının tematik analizi | G2 Learn | https://learn.g2.com/zendesk-review |
| Zendesk'in Box müşteri hikâyesi | Zendesk | https://www.zendesk.nl/customer/box/ |
| Rails resmi rehberi | Ruby on Rails | https://guides.rubyonrails.org/ |
| Rails API | Ruby on Rails | https://api.rubyonrails.org/ |
| Render Rails deployment rehberi | Render | https://render.com/docs/deploy-rails |
| Ruby projeleri için GitHub Actions | GitHub Docs | https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-ruby |

### İlk bakışta raporlanan 2026 SaaS benchmark'ı
Zylo'nun 2026 SaaS Management Index sayfası kuruluş başına yıllık ortalama SaaS harcamasını **55,7 milyon ABD doları**, medyanını **20,6 milyon dolar** ve ortalama portföyü **305 uygulama** olarak bildiriyor. Bunlar Zylo'nun veri kümesinin benchmark'larıdır; her Fortune 500 şirketine uygulanabilecek kesin şirket verileri değildir. README'ye yazmadan önce raporun kapsamını, örneklemini ve metrik tanımlarını doğrula.

Fortune'un 2026 sayfası Fortune 500 şirketlerinin toplamda yaklaşık **21 trilyon dolar gelir**, **2,1 trilyon dolar kâr** ve **30,5 milyon çalışan** bildirdiğini söylüyor. Bu toplulaştırılmış veriler minimum/maksimum şirket piyasa değerini veya minimum/maksimum çalışan sayısını tek başına vermez. Uç değerler liste/Explorer ve şirket bildirimleri üzerinden ayrı hesaplanmalı.

## 4. SaaS seçimi ve kanıt kalitesi

Başlangıç adayı Zendesk benzeri destek talebi yönetimi ürünüdür. Bu bir nihai seçim değil; gerçek Fortune 500 müşteri/ödeme kanıtı ve kullanıcı acısı doğrulanarak kesinleştirilmeli.

Kanıt seviyeleri:
1. **Güçlü ödeme kanıtı:** Şirketin veya tedarikçinin ücretli sözleşme/abonelik/ödeme ilişkisini açıkça belirten güvenilir kaynak.
2. **Kullanım/müşteri kanıtı:** Resmi müşteri hikâyesi, vaka çalışması veya şirket açıklaması ürünün kullanıldığını kanıtlar ama ücretli planı açıkça söylemeyebilir.
3. **Zayıf kanıt:** Logo duvarı, pazarlama iddiası veya kaynağı belirsiz liste. Tek başına yeterli sayılmamalı.

Örneğin Zendesk'in Box müşteri hikâyesi Zendesk'in Box müşteri hizmetlerinde kullanıldığını destekler. Ancak sayfada açıkça ücretli abonelik veya ödeme belirtilmiyorsa bunu doğrudan “ödeme kanıtı” olarak abartma; README'de kanıtın sınırını belirt ve daha güçlü kanıt ara.

## 5. Kullanıcı acısı araştırma yöntemi

G2/Capterra'daki gerçek yorumları doğrudan aç:
1. Yorumun tam sayfası ve yorum tarihi.
2. Kullanıcının rolü/şirket büyüklüğü gibi sayfada mevcut bağlam (gereksiz kişisel veri kopyalama yok).
3. Kullanıcının tam olarak hangi problemi söylediği.
4. Sorunun uygulama kapsamına girip girmediği.
5. Üründe bu sorunu çözen görünür özellik.
6. Özelliğin davranışını kanıtlayan otomatik test ve canlı demo adımı.

G2 Zendesk sayfasında 2026 tarihli örnek yorumlar arasında, çok markalı kurulumlarda otomasyon tetikleyicilerinin markalar arasında tutarlı tutulmasının zor olması ve yanıtsız forum gönderilerinin destek talebine otomatik yükseltilememesi gibi konular görünmektedir. Bunlar yalnızca **aday hipotezlerdir**; gerçek yorumun URL'si, tarihi ve bağlamı kontrol edilmeden README'de nihai acı olarak kullanılmamalıdır.

**Ürün farklılaştırması için olası özellikler (yorum doğrulamasından sonra birini seç):**
- Otomasyon kurallarında çok markalı kapsam kontrolü, eksik marka kuralı uyarısı ve kural tutarlılığı testi.
- Belirli süre boyunca yanıtsız kalan soru için SLA tabanlı hatırlatma ve tek tıkla ticket'a dönüştürme.
- Aynı müşteriden gelen benzer/tekrarlı talepler için olası yinelenen ticket uyarısı.

Sadece UI'da bir buton göstermek çözüm değildir. Kural veritabanında uygulanmalı ve regresyon testi olmalıdır.

## 6. Aort dilimi: minimum iş akışı

Önerilen özgün ürün adı: **Pasla**. Kullanılmadan önce repo içinde isim çakışması kontrolü yap. Bu isim için marka/alan adı müsaitliği iddiasında bulunma.

Minimum tam akış:
1. Müşteri bir destek talebi açar.
2. Talep `new` durumunda kaydedilir; oluşturulma zamanı ve SLA hedef zamanı belirlenir.
3. Destek personeli talebi listede görür, atar ve `open` durumuna geçirir.
4. Personel yanıt/yorum ekler; olay geçmişi korunur.
5. Talep izin verilen durum geçişleriyle `pending` ve `solved` durumlarına ilerler.
6. SLA hedefi geçilirse gecikme durumu tutarlı biçimde hesaplanır ve kullanıcıya gösterilir.
7. Gerçek kullanıcı yorumundan seçilen acı noktası için farklılaştırıcı özellik çalışır.
8. Canlı ortamda akışın her adımı doğrulanır.

### Örnek durum makinesi
`new -> open -> pending -> solved`

İş kuralı tek yerde uygulanmalı. Yasak geçişler açıkça reddedilmeli. Yeniden açma gereksinimi varsa ayrıca tanımlanmalı ve test edilmelidir. Durum akışının tam olarak bu şekilde olması bir ürün kararıdır; gerekirse daha uygun geçişler belgelenebilir.

### Örnek zaman kuralı
İlk yanıt SLA hedefi: örneğin 4 iş saati veya 24 saat. Bu yalnızca örnek bir ürün kararıdır; gerçek müşteri sözleşmesi gibi sunulmamalı. Takvim saati mi iş saati mi olduğu açıkça yazılmalı. `travel_to` ile hedef öncesi, hedef anı ve hedef sonrası test edilmeli. Hafta sonu sayılmayacaksa bu kural ayrıca uygulanmalı ve test edilmelidir.

## 7. Mimari ve kalite

- Ruby on Rails 8+
- PostgreSQL
- Rails server-rendered HTML/Hotwire veya proje için gerekli olduğu kanıtlanırsa API + frontend; en küçük çalışan kapsam tercih edilir.
- Modeller ve ilişkiler: User/Agent, Ticket, Comment/Reply, StatusEvent ve gerekiyorsa AutomationRule.
- Yetkilendirme ve kimlik doğrulama gerçek olmalı; yalnızca ön yüzde rol saklamak güvenlik değildir.
- Durum geçişleri bir model/service nesnesinde merkezi olmalı.
- SLA hedefi/ihlal hesabı ayrı test edilebilir servis/policy'de olmalı.
- Kullanıcı girdileri doğrulanmalı; CSRF, yetkilendirme, güvenli secret yönetimi ve üretim hata sayfaları ele alınmalı.
- Migration ve seed'ler yeni kurulumda çalışmalı.
- Özgün marka, logo ve tasarım kullanılmalı; uygulama içinde Zendesk adı/logo/markası olmamalı.
- Demo verileri açıkça demo olarak tanımlanmalı; gerçek müşteri verisi izlenimi yaratılmamalı.

## 8. Test ve CI gereksinimleri

- Model/validasyon testleri
- Durum makinesi izinli ve yasak geçiş testleri
- Rol/yetki testleri
- SLA testleri: `travel_to` ile önce, tam sınır, sonra
- Kullanıcı acısı çözümüne yönelik regresyon testi
- Kritik HTTP/controller/system testleri
- Yeni clone'da kurulum, migration, seed ve test komutları
- GitHub Actions içinde gerçek test çalıştırma
- Gerçek yeşil CI run URL'si
- README badge'i doğru repo ve workflow'a bağlı olmalı

Bir workflow dosyasının var olması, CI'ın başarılı olduğu anlamına gelmez. CI çalıştırılmadıysa veya başarısızsa “yeşil” diye bildirme.

## 9. LOC, maliyet ve süre tahmini

Kapalı kaynak ürün için kesin LOC genellikle doğrulanamaz. README'de:
- Tahmin kapsamı: frontend, backend, testler, konfigürasyon, vendor/dependency kodu dahil mi?
- Yöntem: kamuya açık kaynak kodu/benzer projeler veya varsayımları açıklanmış fonksiyonel bileşen tahmini.
- Tahmin aralığı ve belirsizlik.
- “Bu, sağlayıcının yayımladığı gerçek LOC değildir” açıklaması.
- Coding-agent süresi: ilk çalışan sürüm ve tam kurumsal ürün birbirinden ayrılmalı.
- Önceden tahmin edilen maliyet ile gerçekten harcanan para ayrı yazılmalı.
- Gerçek ücret/tokens bilgisi yoksa “ölçülmedi” yazılmalı. Abonelik ücretinin tamamını bu projeye harcanan token maliyeti gibi göstermemeli; abonelik ile kullanım başına maliyeti ayırmalı.

## 10. Deployment ve teslim

Render yalnızca daha önce kullanılmamışsa ve hesaba erişim mümkünse kullanılmalı. Canlıya alma kanıtları:
- Gerçek public URL
- Production DB bağlantısı
- Production secrets ve environment variables
- Migration sonucu
- Health check
- Gerçek tarayıcı/HTTP smoke testleri
- Ticket oluşturma, atama, yanıt, durum ve SLA akışı
- Kullanıcı acısı özelliği
- GitHub Actions başarılı çalıştırma URL'si

Erişim engeli varsa deploy yapılmış gibi davranma. Kullanıcının tamamlaması gereken net adımı ve mevcut durumu bildir.

## 11. README teslim kontrol listesi

- [ ] Ürün adı, açıklama, ekran görüntüsü varsa gerçek uygulamadan
- [ ] Canlı URL
- [ ] Doğrulanmış GitHub Actions badge
- [ ] İlham alınan SaaS ve kullanım/ödeme kanıtının sınırları
- [ ] Fortune 500 2026 araştırması: değerleme/market value aralığı, çalışan aralığı, yöntem ve kaynaklar
- [ ] SaaS uygulama sayısı ve yıllık harcama benchmark'ı, örneklem ve dönem
- [ ] LOC tahmin yöntemi ve belirsizlik
- [ ] Agent maliyeti/süresi: tahmin ile ölçülen gerçek ayrı
- [ ] Kullanıcı yorumu, kaynak URL'si, tarih/bağlam ve çözülen acı
- [ ] Mimari ve kurulum
- [ ] Test komutları ve gerçek sonuçlar
- [ ] `AGENT.md`
- [ ] “Yapamadıklarım”
- [ ] Kaynakça: başlık, kurum, yayın tarihi, erişim tarihi, URL, desteklediği iddia

## 12. Sunum için kanıtlı 5 dakika

1. **30 sn:** Hangi SaaS, ana iş akışı ve şirketlerin neden kullandığı/ödediği (kanıt düzeyini doğru söyle).
2. **2 dk:** Canlı URL'de talep oluşturma → atama → yanıt → durum geçişi → çözüm.
3. **1 dk:** SLA zaman kuralı ve durum geçişi kodunu aç; ilgili dosya/satırları göster.
4. **1 dk:** Gerçek kullanıcı yorumundaki acı ve çalışan çözüm; kanıt yoksa dürüstçe “Yapamadıklarım”.
5. **30 sn:** Kural değişikliğinin hangi dosya/servis/testlere dokunacağını göster.

Son prensip: **Kanıtlanmamış özellik yok; kaynaklandırılmamış rakam yok; test edilmemiş başarı iddiası yok.**
