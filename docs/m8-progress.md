# M8 İlerleme Takibi

> **Amaç:** "Analitik paneli + Deploy"
> Bağımlılık: Tüm önceki milestone'lar.
> Klinik sahibi için 3 panel + Hetzner Docker deploy.

---

## Strateji: M8'i 4 alt-faza parçala

| Faz | Alt-özellik | Yer | Risk |
|---|---|---|---|
| M8.1 | Backend analytics endpoint'leri (3 panel) | Backend | düşük |
| M8.2 | Veteriner performansı paneli | Web | düşük |
| M8.3 | İlaç tüketim analitiği paneli | Web | düşük |
| M8.4 | Klinik kazancı paneli | Web | düşük |
| M8.5 | Deploy (Hetzner Docker Compose) | DevOps | orta |

Her faz biter biter bu dosya güncellenir + atomik commit/push.

---

## Faz Detayları

### M8.1 — Backend analytics endpoint'leri

**Amaç:** Üç farklı endpoint, hepsi `from`/`to` tarih filtreli, clinic_id auth user'dan.

**Endpoint'ler:**
- `GET /api/v1/analytics/vet-performance?from=&to=`
  - Her veteriner için: muayene sayısı, toplam km (routes.total_distance_km), toplam gelir (medical_records.service_fee + payments.amount değil — sadece MR fee).
- `GET /api/v1/analytics/drug-consumption?from=&to=`
  - Her ilaç için: toplam kullanım miktarı (medical_record_drugs.quantity), kalan stok (stocks.current_quantity), tahmini bitiş günü.
- `GET /api/v1/analytics/revenue?from=&to=&groupBy=day|week|month`
  - Zaman serisi: aralıkta gün/hafta/ay bazında MR service_fee toplamı + payments toplamı.

**Adımlar:**
1. **M8.1.1** `AnalyticsController` + 3 service class.
2. **M8.1.2** Route'lar.

**Durum:** ✅ M8.1 kod tamam
- ✅ `VetPerformanceService`, `DrugConsumptionService`, `RevenueService`.
- ✅ `AnalyticsController` (vetPerformance, drugConsumption, revenue).
- ✅ Route'lar: `/api/v1/analytics/{vet-performance,drug-consumption,revenue}`.

---

### M8.2 — Veteriner performansı paneli

**Web sayfa:** `/analytics/vets`
- Tarih filtresi (default son 30 gün).
- UTable: vet adı · muayene sayısı · km · ortalama hayvan/gün · toplam gelir.
- Top 3 vet için UBadge highlight.

**Durum:** ✅ M8.2 kod tamam — `/analytics/vets` sayfası, 3 stat kart, sıralı tablo + ilk 3 vet rozetli + pay bar.

---

### M8.3 — İlaç tüketim analitiği paneli

**Web sayfa:** `/analytics/drugs`
- Tarih filtresi.
- UTable: ilaç adı · toplam kullanım · kalan stok · tahmini bitiş günü.
- Düşük stok için renkli UBadge (kırmızı=≤7 gün, sarı=≤14 gün).

**Durum:** ✅ M8.3 kod tamam — `/analytics/drugs` sayfası, stat kartlar + düşük stok rozetleri + pay bar.

---

### M8.4 — Klinik kazancı paneli

**Web sayfa:** `/analytics/revenue`
- Tarih filtresi + groupBy (gün/hafta/ay).
- Stat kartlar: toplam tahsil edilen, toplam fatura edilen, açık alacak.
- Basit bar chart (CSS based, leaflet/chart.js olmadan iskelet).

**Durum:** ✅ M8.4 kod tamam — `/analytics/revenue` sayfası, 3 stat kart (fatura/tahsil/açık alacak) + günlük/haftalık/aylık zaman serisi CSS bar chart (mavi=fatura, yeşil=tahsil).

---

### M8.5 — Deploy (Hetzner Docker Compose)

**Hazırlıklar:**
- `docker-compose.prod.yml` (postgres + backend + web, nginx-proxy + SSL).
- Backend Dockerfile (multi-stage, php-fpm + composer prod install).
- Web Dockerfile (Nuxt build + node alpine).
- `.env.prod.example` (DB, JWT_SECRET, SMS_PORTAL_BASE_URL).
- Hetzner cloud-init veya manuel deploy notes (`docs/deploy.md`).
- Backup stratejisi: pg_dump cron.

**Durum:** ⏳ Bekliyor — kullanıcı onayı bekliyor (Hetzner hesap detayları + domain)

---

## Genel Notlar

- Analytics endpoint'leri sadece klinik sahibi (role=owner) erişebilir mi? MVP'de tüm auth'lu kullanıcılar erişebilir; role-based kısıtlama M8 sonrası.
- Chart kütüphanesi şimdilik **yok** — UNumber/UBadge + CSS bar yeterli (CLAUDE.md: dependency için sor).

---

**Doküman Sonu.**
