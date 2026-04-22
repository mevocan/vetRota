# VetRota — Yol Haritası

> **Kısıt:** Tek kişi geliştirici, kapsam sabit (tüm free + premium özellikler)

---

## 1. Bağımlılık Grafiği ve Kritik Yol

### Katmanlar

**Temel Altyapı (her şeyin altında)**
- Docker Compose ortamı (Laravel + PostgreSQL + Nuxt)
- Laravel projesi + JWT auth iskeleti
- PostgreSQL şeması v0 (users, clinics, vets, animals, farmers,
  appointments, medical_records, drugs, stocks)
- Flutter projesi + Drift yerel DB + auth ekranı
- Nuxt projesi + Tailwind + Pinia + login

**Çekirdek Domain (veri modeli)**
- Hayvan CRUD (kulak küpesi dahil)
- Çiftçi CRUD
- Muayene kaydı (metin)
- İlaç/stok kataloğu
- Randevu CRUD

**Offline-First Çekirdeği (kritik yol ⚡)**
- Flutter tarafında Drift şemaları (server şemasının aynısı +
  `sync_status`, `local_id`, `updated_at_local`)
- Sync Manager: push kuyruğu + pull + conflict resolution
  (last-write-wins + özel kurallar)
- Laravel tarafında `/sync` endpoint'leri (delta pull, batch push)
- Çakışma çözüm stratejisi (stok için additive, muayene için
  last-write-wins, fotoğraf için ayrı upload kanalı)

**Özellik Katmanı**
- Fotoğraflı muayene (çevrimdışı çek → senkronda yükle)
- Stok düşümü (muayene ile atomik)
- Rota optimizasyonu (randevu + GPS)
- Hastalık yayılım haritası (muayene + lokasyon verisi)
- SMS portalı + token bazlı çiftçi sayfası
- Aşı hatırlatma motoru + tekrarlayan şablonlar
- Gebelik takibi
- Sürü bazlı toplu işlem
- QR etiket üretimi
- Reçete PDF
- Borç/ödeme takibi
- Gün sonu PDF raporu
- Klinik analitik paneli + veteriner performansı + ilaç tüketim analitiği

### Kritik Yol ⚡

```
Docker + Laravel + PostgreSQL şeması
        ↓
JWT auth (web + mobil)
        ↓
Hayvan/Çiftçi/Muayene REST endpoint'leri
        ↓
Flutter Drift yerel şema + CRUD
        ↓
SYNC MANAGER (push/pull/conflict) ⚡ EN RİSKLİ NOKTA
        ↓
Offline muayene + stok düşümü
        ↓
Geri kalan her şey buradan dallanır
```

**Sync Manager kritik yolun kalbidir.** Doğru kurulmazsa üstüne inşa
edilecek her özellik (muayene, stok, fotoğraf, rota, rapor) bozuk olur.
Buradaki hata sonraki tüm işleri çöpe atar.

**Bağımlılık özeti:**
`Sync → Muayene → Stok → Fotoğraf → Rapor/Analitik`

- SMS portalı ve hastalık haritası sync'ten bağımsız paralel gidebilir
  (sunucu tarafında çalışırlar).
- Rota optimizasyonu randevu + GPS'e bağlı.
- Aşı hatırlatma motoru randevu + zamanlayıcıya bağlı.

---

## 2. Milestone Listesi

### M1 — "Docker ayağa kalktı, login çalışıyor"
- **Bağımlılık:** Yok
- **Tamamlandı kriteri:** `docker compose up` ile Laravel + PostgreSQL +
  Nuxt çalışıyor; bir veteriner web panelinden login olabiliyor; JWT
  dönüyor; Flutter'da da aynı JWT ile login çalışıyor.

### M2 — "Çekirdek veri modeli API'den dönüyor"
- **Bağımlılık:** M1
- **Tamamlandı kriteri:** Hayvan, çiftçi, muayene (metin), ilaç/stok,
  randevu için CRUD REST endpoint'leri çalışıyor. Nuxt panelde liste +
  detay + form var.

### M3 — "Flutter offline muayene yazabiliyor ve sync oluyor" ⚡
- **Bağımlılık:** M2
- **Tamamlandı kriteri:** Flutter uçağa alınır (airplane mode), yeni
  hayvan ekler, muayene yazar, stoktan ilaç düşer. İnternete bağlanır,
  tüm veri sunucuya gider; aynı hayvan başka bir cihazda değiştirildiyse
  çakışma kuralı çalışır (muayene için last-write-wins, stok için
  additive). Push kuyruğu, delta pull, retry logic var.
- **Not:** Bu milestone geçilemezse projenin geri kalanı anlamsız.
  Burayı bitirmeden ilerleme.

### M4 — "Fotoğraflı muayene + kronolojik karşılaştırma"
- **Bağımlılık:** M3
- **Tamamlandı kriteri:** Flutter'da kameradan fotoğraf çekilir, yerelde
  saklanır, internete gelince sunucuya yüklenir. Hayvan detayında aynı
  hayvanın geçmiş fotoğrafları kronolojik yan yana gösterilir.

### M5 — "Randevu + Rota optimizasyonu + Gün sonu raporu"
- **Bağımlılık:** M3
- **Tamamlandı kriteri:** Veteriner günlük randevularını Flutter'da
  görür; "Rotayı optimize et" butonu ile randevular mesafeye göre
  sıralanır (nearest-neighbor). Harita üzerinde sırayla gösterilir.
  Gün sonu sync'te PDF raporu üretilir (muayene sayısı, mesafe, ilaç,
  gelir).

### M6 — "SMS portalı + Çiftçi portal sayfası + Aşı hatırlatma"
- **Bağımlılık:** M2 (sync'ten bağımsız)
- **Tamamlandı kriteri:** Randevu onayları ve aşı hatırlatmaları için
  Laravel Queue job SMS gönderir. SMS'teki
  `vetrota.com.tr/farmer/[token]` linki Nuxt'ta şifresiz portal sayfası
  açar; çiftçi kendi hayvanlarının geçmişini görür. Tekrarlayan aşı
  şablonu tanımlanabilir, zamanlayıcı yaklaşan aşıları tespit edip SMS
  gönderir.

### M7 — "Hastalık haritası + Sürü işlemi + QR + Gebelik + Reçete + Borç"
- **Bağımlılık:** M3, M6
- **Tamamlandı kriteri:** Dokümandaki geri kalan tüm özellikler çalışır
  iskelet seviyesinde: hastalık haritası Nuxt'ta köy bazlı yoğunluk
  gösterir; sürü bazlı toplu işlem Flutter'da çoklu seçim + tek aksiyon;
  her hayvan için QR etiket PDF'i; gebelik tarihi + tahmini doğum
  bildirimi; dijital reçete PDF'i çiftçiye SMS linkiyle gider; çiftçi
  borç/ödeme kaydı.

### M8 — "Analitik paneli + Deploy"
- **Bağımlılık:** Tüm önceki milestone'lar
- **Tamamlandı kriteri:** Nuxt'ta klinik sahibi için 3 panel: veteriner
  performansı, ilaç tüketim analitiği, genel klinik kazancı. Hetzner'a
  Docker Compose ile deploy.

---

## 3. İlk Adım

**M1 — Docker Compose ve Laravel + PostgreSQL + Nuxt iskeleti.**
