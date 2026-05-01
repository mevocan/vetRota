# M3 İlerleme Takibi

> **Amaç:** "Flutter offline muayene yazabiliyor ve sync oluyor" ⚡
> M3 projenin kritik yolu — geçilemezse gerisi anlamsız.
> Detay protokol: `docs/sync-api.md`. Conflict stratejileri: `docs/data-model.md` §7.

---

## M2 Devralınan Durum (2026-05-01)

M2 bilinçli olarak şunları M3'e bıraktı:
- `clinics` tablosu yok, `users.clinic_id` / `users.device_id` yok
- JWT'de `clinic_id` / `device_id` claim'i yok
- Mevcut 8 tabloda sync kolonları yok: `version`, `last_modified_at`, `origin_device_id`, `clinic_id`
- PostgreSQL `bump_sync_columns()` trigger'ı yok
- `sync_logs`, `sync_conflicts`, `medical_record_drugs` tabloları yok
- Flutter projesi henüz başlatılmadı (sadece `backend/` + `frontend/` var)

---

## Faz Özeti

| Faz | Kapsam | Durum |
|---|---|---|
| M3.1 | Şema upgrade: `clinics` + sync kolonları + trigger + sync tabloları | ⏳ Yazıldı |
| M3.2 | JWT'ye `device_id` + `clinic_id` claim, `EnsureDeviceMatchesJwt` middleware | ⏳ Yazıldı |
| M3.3 | `POST /sync/push` — Service + 8 processor + LWW + additive merge + idempotency | ⬜ Bekliyor |
| M3.4 | `GET /sync/pull` — cursor pagination + echo prevention + clinic scope | ⬜ Bekliyor |
| M3.5 | `GET /sync/status` + integration testler (sync-api.md §12 madde 6) | ⬜ Bekliyor |
| M3.6 | Flutter projesi: Drift şeması, push/pull queue, retry, conflict UI, airplane-mode demo | ⬜ Bekliyor |

**Durum sembolleri:** ✅ Tamam · ⏳ Yazıldı (test edilmedi) · ⚠️ Bloke · ⬜ Bekliyor

---

## M3.1 — Şema Upgrade

**Hedef:** Sync altyapısının veritabanı tarafı hazır, M2 endpoint'leri eskisi gibi yeşil.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Migration: `clinics` tablosu (id UUID, name, settings jsonb) | ⏳ | `2026_05_02_000001_create_clinics_table` — default demo klinik insert eder |
| 2 | Migration: `users` → `clinic_id`, `device_id`, `role` kolonları | ⏳ | `2026_05_02_000002` — backfill + NOT NULL + FK |
| 3 | Migration: mevcut 8 tabloya sync kolonları (`version`, `last_modified_at`, `origin_device_id`, `clinic_id`) | ⏳ | `2026_05_02_000003` — villages global, diğer 7 tabloya `clinic_id` NOT NULL + index |
| 4 | Migration: PostgreSQL `bump_sync_columns()` fonksiyonu + her sync tablosuna BEFORE UPDATE trigger | ⏳ | `2026_05_02_000007` — `medical_record_drugs` dahil 9 tabloda trigger |
| 5 | Migration: `sync_logs` tablosu | ⏳ | `2026_05_02_000004` |
| 6 | Migration: `sync_conflicts` tablosu | ⏳ | `2026_05_02_000005` — LWW audit trail |
| 7 | Migration: `medical_record_drugs` tablosu | ⏳ | `2026_05_02_000006` — soft delete + sync kolonları dahil |
| 8 | Eloquent: `Clinic` modeli + `BelongsToClinic` trait (creating hook ile auto-fill) | ⏳ | M2 controller'ları değişmedi; auto-fill auth'lu requestlerde tetikleniyor |
| 9 | Eloquent: `HasSyncColumns` trait | ⏳ | `version` int + `last_modified_at` datetime cast |
| 10 | Modeller güncellendi (Animal, Farmer, Village, Appointment, MedicalRecord, Drug, Stock, StockMovement, MedicalRecordDrug, User) | ⏳ | `clinic_id` fillable; User `getJWTCustomClaims` clinic_id+device_id+role döndürüyor |
| 11 | Seeder güncellendi: default klinik + her tenant kayda `clinic_id` | ⏳ | Idempotent korundu |
| 12 | **Test (Docker ile)** — `php artisan migrate:fresh --seed` + M2 curl 57/57 | ⬜ | Docker erişimi yok, kullanıcı çalıştıracak |

---

## M3.2 — Auth & Device Identity

**Hedef:** JWT içinde `device_id` + `clinic_id` taşınıyor, middleware doğruluyor.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Login request → `device_id` (UUID, body veya `X-Device-Id` header) | ⏳ | `AuthController::login` parametre `sometimes,uuid`; `claims(['device_id'=>..])->attempt()` ile JWT'ye gomuluyor |
| 2 | JWT custom claim'leri (`clinic_id`, `device_id`, `role`) | ⏳ | `User::getJWTCustomClaims()` (M3.1) + login akışından device_id |
| 3 | `AuthController::me` response → id/email/role/clinic_id/device_id | ⏳ | Payload'dan okunuyor |
| 4 | Middleware `EnsureDeviceMatchesJwt` | ⏳ | `device.match` alias, JWT yoksa veya header mismatch ise 403 |
| 5 | Middleware `bootstrap/app.php` alias'lendi | ⏳ | Sync rotalarında M3.3'te kullanılacak |
| 6 | `auth:api` global tenant scope (BelongsToClinic) | ⬜ | Şimdilik creating hook ile auto-fill, query scope M3.4'e ertelendi |
| 7 | **Test (Docker ile)** — login + me + device mismatch curl | ⬜ | Docker erişimi yok |

---

## M3.3 — POST /sync/push

**Hedef:** Client batch'i transaction içinde işleyen push endpoint'i çalışıyor.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Enum: `SyncOperation`, `ConflictStrategy`, `SyncResult` | ⬜ | sync-api.md §11.4 |
| 2 | `SyncIdempotencyCache` (Redis/file cache 24h) | ⬜ | sync-api.md §11.7 |
| 3 | `SyncPushRequest` form request | ⬜ | Tablo bazında kural seti |
| 4 | `AbstractTableProcessor` | ⬜ | upsert/delete + LWW + version bump (saveQuietly) |
| 5 | Concrete processors (8 adet) | ⬜ | Village, Farmer, Animal, Appointment, MedicalRecord, MedicalRecordDrug, Stock, StockMovement |
| 6 | `StockMovementProcessor` AdditiveMerge override | ⬜ | upsert=INSERT, delete=REJECTED |
| 7 | `SyncPushService` orchestrator | ⬜ | DB::transaction + sync_logs |
| 8 | `SyncPushController` + route | ⬜ | `/api/v1/sync/push` |
| 9 | Curl test: yeni hayvan + muayene push | ⬜ | M2 verisinden bağımsız |
| 10 | Curl test: idempotent retry (aynı `client_sync_id`) | ⬜ | Cache hit |
| 11 | Curl test: LWW conflict (version mismatch) | ⬜ | sync_conflicts log |

---

## M3.4 — GET /sync/pull

**Hedef:** Cursor pagination ile delta pull, echo prevention çalışıyor.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `SyncCursor` helper (base64 encode/decode) | ⬜ | sync-api.md §11.12 |
| 2 | `SyncPullService` | ⬜ | clinic scope + `origin_device_id != device` |
| 3 | `SyncPullController` + route | ⬜ | `/api/v1/sync/pull` |
| 4 | Curl test: ilk sync (`since=1970-01-01`) | ⬜ | Tüm veri döner |
| 5 | Curl test: delta pull (`since=<last_sync>`) | ⬜ | Sadece yeniler |
| 6 | Curl test: echo prevention | ⬜ | Cihaz kendi yazdığını geri almıyor |
| 7 | Curl test: cursor pagination 500+ kayıt | ⬜ | `has_more=true` → ikinci sayfa |
| 8 | Curl test: clinic scope ihlali | ⬜ | Başka klinik verisi sızmıyor |

---

## M3.5 — Status & Integration Testler

**Hedef:** sync-api.md §12 madde 6'daki 8 senaryo otomatik test ile yeşil.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `SyncStatusController` + route | ⬜ | last_pushed_at, last_pulled_at, pending_conflicts |
| 2 | PHPUnit feature test: basit push | ⬜ | Yeni kayıtlar |
| 3 | PHPUnit feature test: update push (version eşleşen) | ⬜ | |
| 4 | PHPUnit feature test: LWW conflict (client_won) | ⬜ | |
| 5 | PHPUnit feature test: delete vs update çakışması | ⬜ | server_won_deleted |
| 6 | PHPUnit feature test: echo prevention | ⬜ | |
| 7 | PHPUnit feature test: idempotent retry | ⬜ | |
| 8 | PHPUnit feature test: cursor pagination | ⬜ | |
| 9 | PHPUnit feature test: ledger delete reddi | ⬜ | stock_movements |

---

## M3.6 — Flutter Client

**Hedef:** Veteriner airplane-mode'da hayvan ekleyebiliyor, internet gelince sync oluyor.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Flutter projesi başlat (`flutter create mobile`) | ⬜ | Dart 3.11, sound null safety |
| 2 | State management seçimi (riverpod / bloc / provider) | ⬜ | CLAUDE.md: M3'te karar verilecek |
| 3 | Drift kurulumu + şema (sync_status, version kolonu dahil) | ⬜ | 8 tablo + UUID PK |
| 4 | Dio HTTP client + JWT interceptor + retry | ⬜ | Exponential backoff |
| 5 | Login ekranı + JWT storage (flutter_secure_storage) | ⬜ | device_id `Uuid().v4()` ilk açılışta |
| 6 | Hayvan listesi + ekleme formu (sadece Drift'ten) | ⬜ | Loading spinner YOK |
| 7 | Muayene formu + stok düşüm (additive ledger) | ⬜ | client UUID üretir |
| 8 | Push queue manager (`sync_status='pending'` → batch) | ⬜ | |
| 9 | Pull queue manager (cursor + delta) | ⬜ | |
| 10 | Conflict UI (badge + bildirim) | ⬜ | sync_conflicts göster |
| 11 | Airplane-mode demo testi | ⬜ | Manuel: uçağa al, kayıt gir, indir, sync gör |

---

**Doküman Sonu.**
