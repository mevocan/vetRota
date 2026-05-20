# VetRota — Demo Video Sunum Senaryosu

Bu doküman, projeyi video içinde tanıtırken kullanmanız için hazırlanmış
sahne-sahne bir akıştır. Önce web panelini, sonra mobil uygulamayı
gezerek tüm modülleri gösterirsiniz.

---

## 🔑 Demo Hesapları

| Tier | E-posta | Şifre | Açıklama |
|---|---|---|---|
| **Premium** (dolu hesap) | `ahmet@vetrota.com.tr` | `sifre1234` | Ana demo. 30 çiftçi, 134 hayvan, 280 muayene, outbreak'ler, raporlar |
| Premium (yan hekim) | `ayse@vetrota.com.tr` | `sifre1234` | Aynı klinik, ikinci veteriner |
| Premium (sekreter) | `selma@vetrota.com.tr` | `sifre1234` | Sekreter rolü |
| **Free** (boş hesap) | `demo@vetrota.com.tr` | `sifre1234` | Yeni kayıtlı tek-veteriner klinik. Kilitli özellikleri ve upgrade akışını göstermek için. 2 çiftçi, 6 hayvan, 3 muayene |

> 📌 **Video çekerken çoğunlukla Premium hesabı kullanın.** Free hesabı
> sadece "şu ekran Premium gerektiriyor" derken kısaca açıp kapatın.

**Web:** http://localhost:3000  
**Mobil:** APK'yı emülatör/cihaza yükleyip aynı bilgilerle giriş

---

## 🎯 Açılış (60 sn) — Ürünü Tanıt

> "Merhaba. Size **VetRota**'yı tanıtacağım. VetRota, **kırsalda
> çalışan gezici veterinerler** için geliştirilmiş, **internet olmadan
> da çalışan** bir saha yönetim platformu.
>
> Hedef kullanıcımız Ahmet: günde 10-15 köyü dolaşan klinik sahibi bir
> veteriner. Köylerde internet çekmediği için şu an deftere not alıyor,
> akşam saatlerce bilgisayara geçiriyor. Bir de sık sık çiftçiyi evde
> bulamadığı için ziyaretler boşa gidiyor.
>
> VetRota tam burada devreye giriyor: **offline-first mobil uygulama,
> akıllı rota optimizasyonu, çiftçiye SMS hatırlatma, hastalık yayılım
> haritası, otomatik aşı takibi** ve daha fazlası.
>
> Üç ayrı kullanıcıya hizmet ediyor: **gezici veteriner** (mobil),
> **klinik sahibi/sekreter** (web paneli) ve **çiftçi** (SMS linkiyle
> şifresiz portal). Şimdi her ikisini sırayla gezelim."

---

# 🌐 BÖLÜM 1 — WEB PANELİ (≈ 7-8 dk)

> Tarayıcıdan `http://localhost:3000` aç. **Premium** hesapla giriş yap:
> `ahmet@vetrota.com.tr / sifre1234`.

## 1.1 Login + Dashboard (Ana Sayfa)

**URL:** `/` (giriş sonrası)

**Göster:**
- Login ekranı (sade, marka renginde)
- Giriş sonrası dashboard kartları: bugünkü randevu sayısı, açık borç toplamı, kritik stok uyarısı, son muayeneler

**Anlat:**
> "Klinik sahibi paneline girdik. Üstte bugünkü randevular, açık alacaklar
> ve kritik stok uyarıları. Sol menüde tüm modüller — sırayla gezeceğiz."

## 1.2 Çiftçiler (`/farmers`)

**Göster:**
- Tablo: 30 çiftçi, köy, telefon, bakiye
- Bir çiftçiye tıkla (`Halil Tekin` gibi yüksek bakiyeli olanı seç)
- Detay sayfası: hayvanları, geçmiş muayeneleri, borç-ödeme tarihçesi

**Anlat:**
> "Çiftçi kayıtları. Her çiftçinin altında hayvanları, ziyaret geçmişi
> ve borç bakiyesi tutulur. SMS gönderilen telefon, KVKK uyumlu şekilde
> saklanır."

## 1.3 Hayvanlar (`/animals`)

**Göster:**
- 130+ hayvanın listesi (sığır, koyun, keçi)
- Filtreler: tür, durum (alive/sold/deceased), köy
- Bir gebe sığıra tıkla → gebelik takip kartı, beklenen doğum tarihi
- Aşı geçmişi sekmesi

**Anlat:**
> "Tüm hayvanlar tek listede. Her hayvanın küpe numarası — TARKS uyumlu
> şekilde saklanıyor — fotoğraf geçmişi, gebelik takvimi ve aşı
> programı var. Sığırlarda otomatik gebelik takibi: doğum 280 gün
> sonrasına ayarlanır, yaklaşınca veteriner uyarılır."

## 1.4 Muayeneler (`/examinations`)

**Göster:**
- 280 muayene listesi, son 60 gün dağılımı
- Bir muayene aç: chief complaint, treatment notes, fotoğraflar, kullanılan ilaçlar, ücret
- Reçete butonu (varsa)

**Anlat:**
> "Sahada yapılan her muayene burada arşivleniyor. İçeriği: şikayet,
> tanı, tedavi notu, fotoğraf, kullanılan ilaç miktarı ve ücreti.
> Stok hareketi muayeneden otomatik düşülür."

## 1.5 Randevular (`/appointments`)

**Göster:**
- Bugün, bu hafta, gelecek randevular
- 40 randevu: planned / confirmed / completed / cancelled / no_show
- Yeni randevu oluştur (kısaca aç-kapat)

**Anlat:**
> "Randevu yönetimi. Çiftçi onay verdiğinde SMS gider, gün geldiğinde
> hatırlatma SMS'i otomatik. Premium kullanıcılarda **akıllı rota
> optimizasyonu** günün randevularını coğrafi konuma göre sıralar."

## 1.6 İlaçlar ve Stok (`/medications`)

**Göster:**
- 10 ilaç: antibiyotik, aşı, antiparaziter, ağrı kesici, vitamin
- Stok durumu: 8 ilaç normal, **İvermektin kritik altında** (uyarı rozeti)
- Bir ilaca tıkla: hareket geçmişi (alımlar, kullanımlar)

**Anlat:**
> "İlaç envanteri. Her muayenede kullanılan miktar otomatik düşülür,
> kritik eşiğin altına inince burada kırmızı rozet ve mobil uygulamada
> bildirim çıkar. Şu an İvermektin'imiz 65 ml kalmış — kritik 100'dü."

## 1.7 SMS + Çiftçi Portalı ⭐ (SMS'i böyle gösterin)

> ⚠️ **SMS gerçekten gönderilmiyor** (MVP'de `LogSmsSender` sadece log'a yazar,
> gerçek sağlayıcı deploy aşamasında bağlanacak). Bu yüzden videoda **SMS'in
> kendisini değil, SMS'in açtığı çiftçi portalını** gösteriyoruz — değerli olan
> kısım zaten o.

### Video öncesi hazırlık (bir kez)

Çalışan bir portal linki üretin (token 30 gün geçerli):

```bash
docker compose exec -T backend php artisan tinker backend/demo_portal_link.php
```

Çıktıdaki `http://localhost:3000/farmer/XXXX` linkini kopyalayıp **ayrı bir
sekmede hazır tutun.** (Örnek üretilen: Mehmet Polat, 4 hayvan.)

> 💡 Deploy sonrası bu link `https://vetrota-web-XXXX.up.railway.app/farmer/...`
> olur ve gerçekten telefonda açılabilir.

**Göster:**
- Önce telefonda gelmiş gibi bir SMS metnini anlat (slayt veya ekranda):
  > _"Sayın Mehmet Bey, hayvanlarınızın aşı zamanı yaklaştı.
  > Detay: vetrota.com.tr/farmer/abc123"_
- Sonra **hazır tuttuğunuz portal sekmesine** geç
- Çiftçi şifresiz olarak görüyor: yaklaşan aşılar, hayvan listesi, geçmiş

**Anlat:**
> "**Premium'un en sevilen özelliği:** Çiftçi SMS portalı. Randevu, aşı
> hatırlatması veya reçete oluşunca çiftçinin telefonuna kısa bir link
> gider. Çiftçi uygulama indirmiyor, kayıt olmuyor, şifre yok — sadece
> linke basıyor ve hayvanlarının tüm sağlık geçmişini, yaklaşan aşı
> tarihlerini görüyor. İşte gerçek ekranı: [portal sekmesini göster].
> Türkiye'deki hiçbir veteriner yazılımında bu yok."

> 🎙️ İsterseniz teknik dürüstlük için: "SMS altyapısı hazır; demo ortamında
> gerçek SMS maliyeti olmasın diye log'a yazıyoruz, canlıda NetGSM bağlanacak."

## 1.8 Hastalık Haritası (`/analytics/disease-map`) ⭐

**Göster:**
- Uydu görüntülü harita (Esri hybrid)
- Çayırhan'da **kırmızı büyük daire** (outbreak — şap), Karaşar'da
  turuncu (mastitis)
- Üstüne hover → "Çayırhan · 17 vaka · şap, ağızda, yara" tooltip
- Tarih aralığı + tür filtresi
- Alt tablo: köy bazlı detay

**Anlat:**
> "Bu **Premium'un en görkemli özelliği.** Tüm muayenelerden otomatik
> hastalık yayılım analizi yapılıyor. Çayırhan'da son 14 günde şap
> şüphesi vurguluyor — kırmızı daire ne kadar büyükse vaka sayısı o
> kadar çok. Sahaya çıkacak veteriner bu bölgeyi atlayabilir veya
> bütün çiftçilere toplu SMS gönderip karantina uyarısı yapabilir."

## 1.9 Analitik Panelleri (`/analytics/*`)

Sırayla aç:

- **`/analytics/revenue`** — aylık gelir, hizmet türüne göre kırılım
- **`/analytics/drugs`** — ilaç tüketim grafiği, en çok kullanılanlar
- **`/analytics/vets`** — veteriner performansı (Ahmet vs Ayşe)

**Anlat:**
> "Klinik sahibi için karar destek panelleri. Hangi ilaç en çok
> kullanılıyor, hangi veteriner kaç hayvan ziyaret etti, aylık gelirim
> ne — hepsi tek bakışta. Sekreterin elle Excel'e geçirmesi gereken
> her şey otomatik."

## 1.10 Upgrade Ekranı (`/upgrade`)

**Göster:**
- Free ↔ Premium karşılaştırma tablosu
- 1.250 ₺/ay veya 12.500 ₺/yıl planı
- "Premium'a Geç" butonu → fake ödeme akışı (MVP)

**Anlat:**
> "Free → Premium yükseltme akışı. MVP'de fake ödeme; gerçek entegrasyon
> deploy aşamasında iyzico/PayTR ile yapılacak."

## 1.11 Free Hesap — Kilitli Ekranları Göster (90 sn)

> Çıkış yap, **`demo@vetrota.com.tr / sifre1234`** ile gir.

**Göster:**
- Boş dashboard (yeni hesap)
- Sol menüde **kilit ikonu** olan satırlar: rota, hastalık haritası,
  fotoğraflı muayene, gün sonu raporu, çoklu veteriner
- Üzerlerine tıklayınca `/upgrade` sayfasına yönlendiriliyor

**Anlat:**
> "Free pakette tek vet, 100 hayvan limiti, manuel randevu, sadece metin
> kayıt var. Premium özellikleri menüde **kilitli** görünüyor — tıklayan
> direkt upgrade ekranına gider."

> Free turu bitti, tekrar Premium hesaba dön.

---

# 📱 BÖLÜM 2 — MOBİL UYGULAMA (≈ 6-7 dk)

> Emülatörü/cihazı aç. Aynı bilgilerle giriş: `ahmet@vetrota.com.tr`.

## 2.1 Ana Ekran (Home)

**Göster:**
- Bugünkü randevu sayısı, gün sonu hatırlatması, kritik stok uyarısı
- "Bugünkü Rota" butonu

**Anlat:**
> "Veteriner sabah aracına biniyor. Mobil uygulamayı açar açmaz
> günün özetini görüyor. Tüm liste cihazda Drift veritabanında — yani
> **uçak modunda bile açılır, anlık yüklenir, hiçbir loading spinner
> yok**."

## 2.2 Akıllı Rota Optimizasyonu ⭐ (böyle gösterin)

> ⚠️ **Video günü mutlaka `migrate:fresh --seed` çalıştırın.** Seeder bugüne
> sabitlenmiş **9 farklı köyde** randevu üretir (Kapullu, Çayırhan, Dutluca,
> Karaşar, Uruş, Yeniköy, Sarıyar, Büyükdere…). Eski seed'de randevular
> "düne" kayarsa rota boş görünür.

**Göster — sıralı:**
1. Ana ekrandan **"Bugünkü Rota"** ekranını aç
2. Önce: randevular **dağınık** — haritada sırasız pinler, uydu görüntüsü
3. Altta **"Rotayı optimize et"** butonuna bas
4. Harita yeniden çizilir: **numaralı pinler (1→2→3…)** + aralarında
   **çizgi (polyline)** optimize sırada
5. Üstte/altta toplam: **"Rota: 9 durak, ~X km"**

**Anlat:**
> "Veterinerin sabah 9 köyde randevusu var. Tek tek hangi sırayla gideceğini
> düşünmek hem zaman hem yakıt kaybı. **'Rotayı optimize et'** diyorum —
> sistem nearest-neighbor algoritmasıyla, Haversine kuş uçuşu mesafelerine
> göre en kısa turu hesaplıyor. Bakın: rastgele dağılmış duraklar artık
> 1-2-3 sırayla, en az yol kat edecek şekilde sıralandı. Harita Esri uydu
> görüntüsü — köyler ve yollar gerçek konumda. Hesaplama **tamamen cihazda**
> yapılıyor, internet gerekmiyor. Aylık yakıt tasarrufu lisans ücretini tek
> başına karşılar."

> 💡 Teknik soru gelirse: "10-15 köy için nearest-neighbor yeter, tam TSP
> çözücü gereksiz. Optimize edilen rota Drift'e kaydedilir, sync ile web'e
> de gider."

## 2.3 Çiftçi → Hayvan → Muayene (Offline Akış) ⭐

**Göster:**
1. Çiftçi seç (farmer picker bottom sheet)
2. Hayvanlarını listele
3. Bir hayvan seç → detay (geçmiş muayeneler, aşılar, gebelik)
4. **"Yeni Muayene"** butonu
5. Form: şikayet, tanı, tedavi, ilaç ekle (stok düşümü otomatik),
   fotoğraf çek (kamera), ücret
6. **🛫 Bu sırada uçak modunu aç!** Kaydet — yine çalışıyor
7. Kayıt edildi, "senkronize bekliyor" rozeti

**Anlat:**
> "İşte uygulamanın kalbi. Köyde, ahırda, internetsiz ortamda muayene
> kaydı oluyor. **Şu anda uçak modundayım** — fotoğraf çekiliyor, ilaç
> stoğundan otomatik düşülüyor, kayıt tamam. Sync rozeti gözüküyor;
> internet gelince arka planda sessiz yüklenecek. Akşam kliniğe
> dönünce 'tüm kayıtları geçir' diye saat harcamıyor."

> Uçak modunu kapat → 2-3 sn sonra sync rozeti kaybolur. **Bunu mutlaka
> göster** — en çarpıcı an.

## 2.4 Aşı Programı + Hatırlatmalar

**Göster:**
- Bir hayvan altında aşı planı listesi (şap, brusella vb.)
- Sonraki aşı tarihi
- Hatırlatmalar ekranı: yaklaşan + SMS gönderilenler

**Anlat:**
> "Her hayvan için tekrarlayan aşı tanımı: 'Bu sığıra her 6 ayda şap'.
> Sistem otomatik sonraki tarihi hesaplar, 7 gün önceden hem
> veterinere bildirim hem çiftçiye SMS gönderir."

## 2.5 Stok / İlaç Yönetimi

**Göster:**
- İlaç listesi, kritik altındaki **İvermektin kırmızı**
- Stok hareketi ekle (alım/kayıp)

**Anlat:**
> "Aracın bagajındaki stok burada. Muayene sırasında ilaç kullanıldıkça
> otomatik düşülüyor — manuel sayım yok. Kritik eşiğe gelince mobilde
> push bildirim, sahada eksik kalmıyor."

## 2.6 Borç & Ödeme

**Göster:**
- Çiftçinin borç bakiyesi (kart üstünde)
- "Ödeme Al" butonu → nakit/havale, açıklama
- Ödeme listesi (ledger)

**Anlat:**
> "Saha içinde **nakit/havale ödeme** alıp anlık kaydetmek. Çiftçi
> bakiyesi her muayenede otomatik birikiyor, ödeme düşülüyor —
> additive ledger, conflict durumunda hiçbir hareket kaybolmaz."

## 2.7 Reçete + Çiftçi Portalı

> SMS gerçekten gitmez (MVP). Akışı şöyle gösterin:

**Göster:**
- Bir muayeneden reçete oluştur (dijital reçete ekranı)
- "Çiftçiye gönder" deyince "SMS gönderildi" onayı çıkar
- Sonra **web turunda hazırladığınız portal linkini** (bkz. 1.7) bu sefer
  telefonun tarayıcısında açıp gösterin — çiftçinin gördüğü ekran bu

**Anlat:**
> "Reçete dijital, kağıt yok. Çiftçiye 'gönder' dediğimde sistem SMS
> kuyruğuna atıyor. Çiftçinin telefonunda şöyle bir link açılıyor —
> hayvanının kayıt geçmişi, ilaç dozajı, sonraki aşı tarihi. Profesyonel
> imaj, sıfır kağıt iş. SMS altyapısı hazır, canlıda gerçek sağlayıcı
> bağlanacak."

## 2.8 Hastalık Haritası (Mobil)

**Göster:**
- Mobil hastalık haritası ekranı (aynı uydu görüntülü)
- Çayırhan kırmızı dairesi

**Anlat:**
> "Yola çıkmadan önce veteriner buraya bakıyor. 'Çayırhan'a gidiyorum,
> son 14 günde şap şüphesi var, eldiven ve dezenfektan al' diyor."

## 2.9 Ayarlar / Profil / Çıkış

**Göster:**
- Subscription tier (Premium aktif, bitiş tarihi)
- Cihaz ID, son sync zamanı
- Çıkış butonu

**Anlat:**
> "Cihaz başına device_id atanır; sync sırasında 'bu kaydı ben yazdım,
> echo gelmesin' denetimi yapılır. Çıkış yapılınca tüm token'lar
> temizlenir; lokal Drift de silinir."

---

# 🎬 KAPANIŞ (45 sn)

> "Özetle VetRota:
>
> - **Offline-first**: Saha kaynağı veterinerdir; internet yokken bile
>   her şey çalışır.
> - **Üç ayrı kullanıcıya** tek platform (vet / klinik / çiftçi).
> - **Premium özellikler** klinik sahibinin günde 2-3 saatini
>   kurtarıyor.
> - **Türkiye pazarına özel**: KVKK uyumlu, TARKS küpe numarası
>   hazır, e-fatura alanları taslakta, tüm metinler Türkçe.
>
> Şu an MVP tamamlandı, yakında Hetzner'a deploy edilip beta
> testlere başlayacak. Teşekkürler."

---

# 📋 Video Çekim İpuçları

1. **Ekran kaydı çözünürlüğü**: 1920×1080, 30 fps yeterli
2. **Mobil**: Android emülatör (Pixel 6, API 34) veya gerçek cihaz screen mirror
3. **Veri temiz**: Video öncesi `php artisan migrate:fresh --seed` ile yeniden başlat
4. **Uçak modu sahnesi** en kritik — mutlaka çek
5. **Tarayıcı**: gizli sekme, devtools kapalı, zoom %100
6. **Anlatım dili**: "Siz" değil, "Veteriner Ahmet" gibi 3. tekil — kullanıcının kendini özdeşleştirmesi kolaylaşır
7. **Süre hedefi**: 12-15 dk arası ideal (akademik / yatırımcı sunumu için)

---

# 🔁 Demo Sırasında Sık Yapılan Hatalar

- ❌ Free hesabı uzun uzun gezmek → 60 sn'yi geçirme
- ❌ Login ekranında uzun durmak → 5 sn yeter
- ❌ Loading spinner gösterirken konuşmaya devam etme → "Offline-first" iddianızla çelişir
- ❌ Konsol açık bırakmak → hydration warning'ler görünür
- ✅ Uçak modu sahnesinde **görünür durum çubuğunu** vurgula
- ✅ Hastalık haritasında **outbreak kırmızı dairesini** yakın çekim yap
- ✅ Mobilde bildirim çıkarsa (kritik stok) onu da göster

---

**İyi sunumlar!** 🎥
