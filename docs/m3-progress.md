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
| M3.5 | `GET /sync/status` + integration testler (sync-api.md §12 madde 6) | ✅ Test edildi |
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
| 2 | PHPUnit feature test: basit push | ✅ | `tests/Feature/Sync/SyncFlowTest.php` |
| 3 | PHPUnit feature test: update push (version eşleşen) | ✅ | |
| 4 | PHPUnit feature test: LWW conflict (client_won) | ✅ | sync_conflicts kaydı + version+1 dogrulanir |
| 5 | PHPUnit feature test: delete vs update çakışması | ✅ | server_won_deleted; soft-delete korunur |
| 6 | PHPUnit feature test: echo prevention | ✅ | deviceA pull'da kendi yazdigini almaz; deviceB gorur |
| 7 | PHPUnit feature test: idempotent retry | ✅ | ayni client_sync_id duplicate yaratmaz, version=1 kalir |
| 8 | PHPUnit feature test: cursor pagination | ✅ | 5 kayit, limit=2, en az 3 sayfa |
| 9 | PHPUnit feature test: ledger delete reddi | ✅ | stock_movements delete → `ledger_immutable` |

**Test altyapisi notu:** `vetrota_testing` veritabani ayri kullanilir
(`docker compose exec backend createdb` yerine ilk kurulumda
`docker compose exec postgres psql -U vetrota -d vetrota -c "CREATE DATABASE vetrota_testing;"`).
`backend/.env.testing` ile DB ayarlari tutulur; container'da
`DB_DATABASE=vetrota` env'i Dotenv-immutable tarafindan
ezilemediginden `tests/TestCase.php` setUp icinde `putenv` ile zorla
override yapilir. `RefreshDatabase` her test once tabloyu wipe eder.

---

## M3.6 — Flutter Client

**Hedef:** Veteriner airplane-mode'da hayvan ekleyebiliyor, internet gelince sync oluyor.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Flutter projesi başlat (`flutter create mobile`) | ✅ | Flutter 3.41.9 / Dart 3.11.5 |
| 2 | State management seçimi (riverpod / bloc / provider) | ✅ | `flutter_riverpod` seçildi |
| 3 | Drift kurulumu + şema (sync_status, version kolonu dahil) | ✅ | 9 tablo (drugs MR dahil) + sync_meta + sync_conflicts; `SyncColumns` mixin; build_runner üretildi |
| 4 | Dio HTTP client + JWT interceptor + retry | ✅ | `_AuthInterceptor` Bearer + X-Device-Id otomatik; 401'de session temizlenir; retry M3.6/8'de queue manager'a |
| 5 | Login ekranı + JWT storage (flutter_secure_storage) | ✅ | `_SessionGate` boot'ta kontrol; `AuthRepository.login` + `/me` ile clinic_id; cihaz UUID ilk açılışta üretilir |
| 6 | Hayvan listesi + ekleme formu (sadece Drift'ten) | ✅ | `AnimalsListScreen` Drift stream'e bağlı; `AnimalFormScreen` UUID v4 üretir, `localSyncStatus=pending` |
| 7 | Muayene formu + stok düşüm (additive ledger) | ✅ | `MedicalRecordsRepository.create` tek transaction'da: `medical_records` + `medical_record_drugs` + `stock_movements (usage, -qty)` + `stocks.current_quantity` cache update; ilaç kataloğu boşsa form bilgi mesajı gösterir |
| 8 | Push queue manager (`sync_status='pending'` → batch) | ✅ | `SyncRepository.push()` 9 tabloda pending kayıtları toplar; ULID `client_sync_id`; `accepted/conflicts/rejected` bucket'larına göre `localSyncStatus` + `version` günceller; `sync_conflicts` tablosuna log düşer |
| 9 | Pull queue manager (cursor + delta) | ✅ | `SyncRepository.pull()` cursor loop (max 50 sayfa); `last_synced_at` + `pull_cursor` `sync_meta`'da; `insertOnConflictUpdate` ile upsert; `deleted_at != null` → `deletedLocal=true` |
| 10 | Conflict UI (badge + bildirim) | ✅ | AppBar'da bekleyen sayısı + çatışma rozeti; `ConflictsScreen` `sync_conflicts` listesi gösterir |
| 11 | Airplane-mode demo testi | 🟡 | Senaryo 1 (smoke) ✅ 2026-05-03 emulator'da geçti — login + hayvan ekle + sync. Senaryo 2-5 (airplane-mode, echo, LWW, idempotent retry) sahada test bekliyor. Bug düzeltildi: AuthRepository token'ı `/me` çağrısından önce storage'a yazıyor (yoksa interceptor Bearer ekleyemiyordu, 401 dönüyordu) |

---

## M3.6/11 — Manuel Test Rehberi

> **Amaç:** Veterinerin sahada offline çalıştığını ve internet gelince
> sync olduğunu **bizzat görmek**. Otomatik test değildir; sürüm
> kapanışı öncesi bir kez elle yapılır.

### Ön koşullar

| Bileşen | Kurulum |
|---|---|
| Backend | `docker compose up` — Laravel + Postgres ayakta, `/api/v1/auth/login` 200 dönüyor olmalı |
| Cihaz A | Android emulator (API 30+) veya fiziksel Android cihaz |
| Cihaz B | İkinci emulator (LWW conflict testi için) — opsiyonel ama önerilir |
| Hesap | `ahmet@vetrota.com.tr` / `sifre1234` (seeder'dan) |
| Çiftçi UUID | Backend'de seed edilmiş bir farmer.id — `docker compose exec postgres psql -U vetrota -d vetrota -c "SELECT id, first_name FROM farmers LIMIT 3;"` |

**Cihaz A başlat:**
```bash
cd mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # Android emulator
# Fiziksel cihaz için: --dart-define=API_BASE_URL=http://<lan-ip>:8000
```

---

### Senaryo 1 — Online happy path (smoke)

| # | Adım | Beklenen |
|---|---|---|
| 1 | Login ekranında "Giris yap" | `AnimalsListScreen` açılır, liste boş, AppBar'da sync ikonu görünür |
| 2 | "Yeni hayvan" → Çiftçi UUID + tür gir → Kaydet | Liste anında satırı gösterir; sağda **turuncu cloud_upload** ikonu (pending) |
| 3 | AppBar sync butonuna bas | Snackbar: `Sync: 1 kabul · 0 catisma · 0 reddedildi · N cekildi` |
| 4 | Liste satırı | Sağda **yeşil cloud_done** (synced) |
| 5 | Backend doğrulama | `psql ... "SELECT id, name, version, origin_device_id FROM animals ORDER BY created_at DESC LIMIT 1;"` → version=1, origin_device_id = cihaz UUID'si |

---

### Senaryo 2 — Airplane-mode write (offline-first kanıtı)

| # | Adım | Beklenen |
|---|---|---|
| 1 | Cihaz A: Ayarlar → **Uçak modu açık** | Kablosuz/veri kapalı |
| 2 | "Yeni hayvan" → kaydet | Form **loading spinner ile ağ beklemez**, snackbar "kaydedildi (sync bekliyor)" |
| 3 | Listeye 3 hayvan daha ekle | Hepsi turuncu pending; AppBar sync ikonunda badge: **4** |
| 4 | Bir hayvana gir → "Yeni muayene" → kaydet (ilaç yok) | Detayda muayene satırı turuncu nokta, geri dön → AppBar badge: **5** (MR de pending) |
| 5 | AppBar sync butonuna bas (hâlâ uçak modunda) | Snackbar: `Sync hatasi: ...` (ConnectionError); satırlar **hâlâ turuncu, kayıp yok** |
| 6 | **Uçak modunu kapat** | Bağlantı geri gelir |
| 7 | Sync butonuna tekrar bas | Snackbar: `Sync: 5 kabul ...` — tüm satırlar yeşile döner, badge sıfırlanır |
| 8 | Backend kontrol | `SELECT COUNT(*) FROM animals WHERE origin_device_id = '<deviceA>';` = 4; `medical_records` 1 satır eklenmiş |

✅ **Kritik gözlem:** 2-7 arası adımlarda hiçbir UI bloklanmadı, hiçbir kayıt kaybolmadı.

---

### Senaryo 3 — Echo prevention (kendi yazdığını geri almama)

| # | Adım | Beklenen |
|---|---|---|
| 1 | Senaryo 2 sonrası Cihaz A'da sync butonu (artık pending=0) | Snackbar: `Sync: 0 kabul · 0 catisma · 0 reddedildi · 0 cekildi` |
| 2 | Backend log: `docker compose logs backend \| grep sync_log` | `pull` çağrısı gelmiş ama Cihaz A kendi yazdıklarını geri çekmemiş |

---

### Senaryo 4 — LWW conflict (iki cihaz, opsiyonel)

> Cihaz B'yi farklı bir emulator olarak başlat. **Login ederken farklı device_id otomatik üretilir** (ilk açılışta secure storage'a yazılır).

| # | Cihaz | Adım | Beklenen |
|---|---|---|---|
| 1 | A | "Yeni hayvan" → kaydet → sync | Sync sonrası version=1 |
| 2 | B | Sync butonuna bas | A'nın yazdığı hayvan listede yeşil görünür |
| 3 | A | Aynı hayvanı düzenle (M3'te edit ekranı yok — `psql` ile elle: `UPDATE animals SET notes='A guncel', version=2, last_modified_at=NOW(), origin_device_id='<deviceA>' WHERE id='<uuid>';`) | — |
| 4 | B | Aynı hayvanı düzenle ama **A'nın değişikliğinden haberi yok** (`expected_version=1`) → sync | Snackbar: `... 1 catisma ...`; AppBar'da uyarı rozeti belirir |
| 5 | B | Uyarı rozetine bas → ConflictsScreen | Satır: `animals · <id>… · Cozum: server_won · sunucu v2` |

✅ **Kritik gözlem:** B'nin yazımı reddedilmedi, server_won olarak işaretlendi; B sonraki pull'da A'nın değerini alır (LWW).

---

### Senaryo 5 — Idempotent retry (network flap simülasyonu)

| # | Adım | Beklenen |
|---|---|---|
| 1 | Cihaz A: 2 hayvan ekle (pending) | Badge: 2 |
| 2 | Backend'i durdur: `docker compose stop backend` | — |
| 3 | Sync butonuna bas | `Sync hatasi: ...` |
| 4 | Backend başlat: `docker compose start backend` | — |
| 5 | Sync butonuna bas | `Sync: 2 kabul ...` — duplicate kayıt **yaratılmaz** (`client_sync_id` ULID idempotency cache) |
| 6 | Backend doğrulama | `SELECT COUNT(*) FROM animals WHERE id IN ('<uuid1>','<uuid2>');` = 2 (3 değil) |

---

### Tamamlanma kriteri

Tüm 5 senaryo geçtiğinde:
- M3.6/11 → ✅
- M3 milestone'u **kapanır**
- `docs/plan.md`'deki bir sonraki milestone'a geçilir

---

**Doküman Sonu.**
