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
| M3.1 | Şema upgrade: `clinics` + sync kolonları + trigger + sync tabloları | ✅ Test edildi |
| M3.2 | JWT'ye `device_id` + `clinic_id` claim, `EnsureDeviceMatchesJwt` middleware | ✅ Test edildi |
| M3.3 | `POST /sync/push` — Service + 8 processor + LWW + additive merge + idempotency | ✅ Test edildi |
| M3.4 | `GET /sync/pull` — cursor pagination + echo prevention + clinic scope | ✅ Test edildi |
| M3.5 | `GET /sync/status` + integration testler (sync-api.md §12 madde 6) | ⏳ Status ✅, PHPUnit testleri bekliyor |
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
| 12 | **Test (Docker ile)** — `php artisan migrate:fresh --seed` + M2 curl 57/57 | ✅ | 2026-05-01 smoke; trigger BEFORE UPDATE eksigi tespit edildi → migration `..._000008` ile INSERT'e de baglandi |

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
| 7 | **Test (Docker ile)** — login + me + device mismatch curl | ✅ | 2026-05-01: login JWT clinic_id+device_id+role icerir, /me dogru, device mismatch 403. Bug: middleware'de yanlis JWT facade namespace'i (Tymon -> PHPOpenSourceSaver) duzeltildi. |

---

## M3.3 — POST /sync/push

**Hedef:** Client batch'i transaction içinde işleyen push endpoint'i çalışıyor.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Enum: `SyncOperation`, `ConflictStrategy`, `SyncResult` | ⏳ | `app/Enums/Sync/` |
| 2 | `SyncIdempotencyCache` (Laravel Cache, 24h TTL) | ⏳ | `app/Support/Sync/SyncIdempotencyCache.php` |
| 3 | `SyncCursor` helper (M3.4 için hazır) | ⏳ | base64+json |
| 4 | `SyncLog` + `SyncConflict` Eloquent modelleri | ⏳ | UUID PK |
| 5 | `SyncPushRequest` form request | ⏳ | 9 tablo için kural seti (drugs dahil) |
| 6 | `AbstractTableProcessor` | ⏳ | upsert/delete + LWW + insert version=1 + DB trigger update'te version++ |
| 7 | Concrete processors (9 adet) | ⏳ | Village, Farmer, Animal, Appointment, MedicalRecord, MedicalRecordDrug, Drug, Stock, StockMovement |
| 8 | `StockMovementProcessor` AdditiveMerge override + performed_by auto-fill | ⏳ | resolveAdditive parent'ten gelir; insertNew override |
| 9 | `SyncPushService` orchestrator | ⏳ | DB::transaction + sync_logs |
| 10 | `SyncPushController` + route `/api/v1/sync/push` | ⏳ | `device.match` middleware ile korunuyor |
| 11 | **Test (Docker ile)** — yeni hayvan + muayene push, idempotent retry, LWW conflict | ✅ | 2026-05-01: animal+MR push accepted, idempotent retry duplicate yaratmiyor. Bug: insertNew Model::create fillable filtresi client UUID + version=1'i dusuruyordu (HasUuids yeni v7 ureterek offline-first kontratini kiriyordu) → forceFill+save ile duzeltildi. |

---

## M3.4 — GET /sync/pull

**Hedef:** Cursor pagination ile delta pull, echo prevention çalışıyor.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `SyncCursor` helper (base64 encode/decode) | ⏳ | M3.3'te hazırlandı |
| 2 | `SyncPullService` | ⏳ | clinic scope + echo prevention + cursor + sync_logs |
| 3 | `SyncPullController` + route `/api/v1/sync/pull` | ⏳ | `device.match` middleware altında |
| 4 | **Test (Docker ile)** — ilk sync, delta, echo prevention, cursor 500+, clinic scope | ✅ | 2026-05-01: device1 kendi yazdigini almiyor, device2 device1'in animal'ini goruyor. Cursor 500+ ve LWW conflict henuz dataset ile dogrulanmadi (PHPUnit'te kapsanir). |

---

## M3.5 — Status & Integration Testler

**Hedef:** sync-api.md §12 madde 6'daki 8 senaryo otomatik test ile yeşil.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `SyncStatusController` + route | ✅ | 2026-05-01 Docker'da test edildi; last_pushed_at + last_pulled_at + pending_conflicts + server_time donuyor |
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
