# M6 İlerleme Takibi

> **Amaç:** "SMS portalı + Çiftçi portal sayfası + Aşı hatırlatma"
> Bağımlılık: M2 (sync'ten bağımsız — server-side özellikler).
> Detay: `docs/data-model.md` §5.7 (SMS), §5 vaccine_schedules / vaccination_reminders, çiftçi portal akışı.

---

## M5 Devralınan Durum (2026-05-08)

- M5.1–M5.8 ✅ kod (backend + mobile + flutter analyze temiz)
- M5.9 cihaz smoke testi bekliyor (kullanıcı zamanı olunca yapacak)
- `M5SmokeSeeder` hazır (5 köy lat/lng + 5 randevu bugüne)

---

## Karar: SMS sağlayıcı — Driver pattern (log + production)

MVP'de **`LogSmsSender`** kullanılır (Laravel logger'a yazar, gerçek SMS gitmez).
Production'da `NetGsmSmsSender` veya benzeri eklenir. Seçim
`config/sms.php` + `.env` `SMS_DRIVER=log|netgsm` ile yapılır.

Gerekçe: MVP'de gerçek SMS göndermek (a) ücretli, (b) test sırasında
çiftçileri spam'lar, (c) provider integration'ı sonradan eklenebilir.

---

## Karar: Queue driver — `database`

Laravel queue için `database` driver. Redis sonra (M8 deploy zamanı).
`jobs` ve `failed_jobs` tabloları Laravel default migration'ları zaten kurar.

---

## Karar: Token — 32 char random, SHA-256 hash + prefix

`farmer_portal_tokens.token_hash` SHA-256, `token_prefix` ilk 8 karakter
(debug log'larda görünür). Ham token sadece SMS gönderiminde view'a
girer; DB'de saklanmaz.

URL formatı: `https://vetrota.com.tr/farmer/{raw_token}`. MVP'de
`vetrota.test` veya `localhost:3000` test alanı.

---

## Karar: Aşı hatırlatma — günlük scheduler

`php artisan vaccinations:scan` komutu Laravel scheduler'da günlük 08:00'de
çalışır. `vaccine_schedules.next_due_date <= today + remind_days_before`
olan aktif planlar için `vaccination_reminders` satırı oluşturur ve
SMS queue'ya `vaccination_reminder` tipiyle iter.

---

## Faz Özeti

| Faz | Kapsam | Durum |
|---|---|---|
| M6.1 | Backend: SMS altyapısı — driver interface + `LogSmsSender` + `sms_messages` migration + Model + queue config | ✅ Docker'da test edildi |
| M6.2 | Backend: `farmer_portal_tokens` migration + `FarmerPortalToken` model + `TokenService` (issue/verify/expire) | ✅ Docker'da test edildi |
| M6.3 | Backend: `SendSmsJob` (queue job) + SMS template renderer + retry policy | ✅ Docker'da test edildi |
| M6.4 | Backend: Randevu oluşunca SMS hatırlatma (Observer/Event → SendSmsJob dispatch) | ✅ Tinker'dan Appointment::create → 1 SMS + 1 token + 1 job → queue:work → status=sent |
| M6.5 | Backend: `vaccine_schedules` + `vaccination_reminders` migration + Eloquent + observer | ✅ Migration koştu, modeller çalışıyor (M6SmokeSeeder ile schedule oluştu) |
| M6.6 | Backend: Aşı planı CRUD endpoint + `vaccinations:scan` scheduler command | ✅ `vaccinations:scan` çalıştı: 1 hatırlatma + SMS sent (vaccination_reminders.status=sms_sent) |
| M6.7 | Backend: Çiftçi portal endpoint | ✅ `curl /farmer-portal/{raw}` 200 + JSON (clinic+farmer+animals+son muayene+upcoming_vacc); geçersiz token → 410 |
| M6.8 | Web: Nuxt `/farmer/[token]` SSR sayfası | ⏳ Yazıldı; backend endpoint yeşil, Nuxt SSR ayrı test edilecek |
| M6.9 | Web: Klinik panelinde "Aşı planları" sayfası (CRUD) | ⏳ Backend CRUD endpoint hazır; Nuxt sayfa SSR test edilecek |
| M6.10 | Smoke: end-to-end SMS akışı | ✅ M5SmokeSeeder + tinker appointment + M6SmokeSeeder + vaccinations:scan + queue:work hepsi yeşil. PHPUnit feature 10/10 yeşil (regresyon yok). M5 PDF rapor: 1.6MB PDF (HTTP 200, application/pdf) |

**Durum sembolleri:** ✅ Tamam · ⏳ Yazıldı (test edilmedi) · 🟡 Kısmi · ⚠️ Bloke · ⬜ Bekliyor

---

## M6.1 — SMS altyapısı

**Hedef:** Driver pattern + log driver + sms_messages tablosu hazır,
job henüz yok.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `config/sms.php` + `.env` `SMS_DRIVER=log` ekle | ⬜ | |
| 2 | `App\Sms\Contracts\SmsSender` interface (`send(SmsPayload): SmsResult`) | ⬜ | |
| 3 | `App\Sms\Drivers\LogSmsSender` — Laravel logger'a yazar, kayıt UUID döner | ⬜ | |
| 4 | `App\Providers\SmsServiceProvider` — config'ten driver seç, container'a bind | ⬜ | |
| 5 | Migration `sms_messages` (data-model.md §5.7'deki şema) | ⬜ | |
| 6 | Eloquent `SmsMessage` model | ⬜ | |
| 7 | Queue config: `QUEUE_CONNECTION=database`, `php artisan queue:table` migration | ⬜ | |
| 8 | Test (Docker): unit test — LogSmsSender çağrılınca logger.info ile metin görünüyor | ⬜ | |

---

## M6.2 — Çiftçi portal token'ları

**Hedef:** Token üretimi + doğrulama servis sınıfı.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Migration `farmer_portal_tokens` (data-model.md §5.7) | ⬜ | |
| 2 | Eloquent `FarmerPortalToken` model + scope kontrolü (enum) | ⬜ | |
| 3 | `App\Services\FarmerPortal\TokenService::issue(farmer, scope, ttl)` — random 32 char + sha256 + DB satırı + raw token döner | ⬜ | Raw token sadece return value'da |
| 4 | `TokenService::verify(rawToken)` — hash'e göre arar, expires_at + revoked_at kontrolü | ⬜ | |
| 5 | `TokenService::recordAccess(token, ip, userAgent)` — last_accessed_at + access_count++ | ⬜ | IP hash SHA-256 |
| 6 | Test (Docker): issue → verify ✅, expired → fail, revoked → fail | ⬜ | |

---

## M6.3 — SMS gönderim job'u

**Hedef:** Queue üzerinden SMS gönderiliyor, sms_messages'a status yazılır.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `App\Jobs\SendSmsJob` — handle() içinde SmsSender'ı resolve eder, sms_messages.status'u günceller | ⬜ | tries=3, backoff=[60,300,900] |
| 2 | `App\Sms\TemplateRenderer` — basit blade-style `{{ var }}` substitution; portal link template'i için yardımcı | ⬜ | |
| 3 | `SmsService::send(farmerId, triggerType, body, ?triggerRef)` — sms_messages satırı oluşturur, SendSmsJob dispatch eder | ⬜ | |
| 4 | Test (Docker): job senkron çalıştırıldığında log driver tetiklenir, sms_messages.status = 'sent' | ⬜ | |

---

## M6.4 — Randevu SMS hatırlatma

**Hedef:** Yeni randevu oluşunca çiftçiye SMS gider (planned/confirmed durumunda).

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `AppointmentObserver::created` — eğer farmer.sms_notifications_enabled ise SmsService.send çağır | ⬜ | trigger_type=appointment_reminder, sms_reminder_sent_at güncellenir |
| 2 | Template: "Sayın {ad}, {tarih saat} randevunuz onaylandı. Detay: {portal_link}" — link short-lived `appointment` scope token | ⬜ | |
| 3 | sms_notifications_enabled = false ise sessizce skip (loglama yine yap) | ⬜ | |
| 4 | Test (Docker): factory ile appointment oluştur → log'da SMS satırı + sms_messages.status=sent | ⬜ | |

---

## M6.5 — Aşı planı tabloları

**Hedef:** Aşı planı + hatırlatma kayıtları DB'de.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Migration `vaccine_schedules` (data-model.md) | ⬜ | |
| 2 | Migration `vaccination_reminders` | ⬜ | |
| 3 | Eloquent `VaccineSchedule` + `VaccinationReminder` modelleri | ⬜ | |
| 4 | `AnimalObserver` — status='deceased' olduğunda ilgili schedules.is_active=false | ⬜ | |
| 5 | Sync trigger'ları (vaccine_schedules sync edilir, reminders server-only) | ⬜ | SyncPullService listesine vaccine_schedules ekle |
| 6 | Test (Docker): migrate + factory + observer cascade | ⬜ | |

---

## M6.6 — Aşı tarayıcı + CRUD

**Hedef:** Klinik veteriner aşı planı tanımlayabiliyor; günlük scheduler hatırlatma üretiyor.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `App\Console\Commands\VaccinationsScan` — bugünden +remind_days_before tarihine düşen schedule'lar için reminders satırı + SmsService.send | ⬜ | Idempotent: aynı (schedule_id, due_date) için çift satır yazma |
| 2 | `app/Console/Kernel.php` — `vaccinations:scan` daily 08:00 Europe/Istanbul | ⬜ | |
| 3 | API endpoint `GET/POST/PUT/DELETE /api/v1/vaccine-schedules` (auth:api, clinic-scoped) | ⬜ | |
| 4 | Test (Docker): planı oluştur, due_date today+5 → komut çalıştır → reminder + sms_messages satırı | ⬜ | |

---

## M6.7 — Çiftçi portal endpoint'i

**Hedef:** Token ile şifresiz, çiftçinin verisi dönüyor.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `GET /api/v1/farmer-portal/{token}` (auth'suz, public route) | ⬜ | |
| 2 | `FarmerPortalController::show` — TokenService.verify, recordAccess, farmer'ın hayvan + son 5 muayene + yaklaşan aşılar JSON | ⬜ | |
| 3 | Hata durumları: 404 (token bulunamadı), 410 (expired/revoked) | ⬜ | |
| 4 | Test (Docker): geçerli token → 200 + payload, expired → 410 | ⬜ | |

---

## M6.8 — Nuxt çiftçi portal sayfası

**Hedef:** SMS'teki link tarayıcıda açılınca düzgün portal sayfası görünüyor.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `web/app/pages/farmer/[token].vue` — useFetch ile backend endpoint'i çağır | ⬜ | SSR aktif, public sayfa |
| 2 | Layout: klinik adı + çiftçi adı + hayvan listesi (UCard) + son muayeneler (UTable) + yaklaşan aşılar | ⬜ | Nuxt UI v4 component'leri |
| 3 | 410/404 hata sayfası — "Bu link süresi geçmiş, klinik ile iletişime geçin" | ⬜ | |
| 4 | Test (manuel): backend'de token üret → tarayıcıda aç → veriler görünür | ⬜ | |

---

## M6.9 — Klinik panelinde aşı planları

**Hedef:** Veteriner web panelinden hayvan-bazlı aşı planı tanımlayabiliyor.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `web/app/pages/animals/[id]/vaccinations.vue` — hayvan detayında "Aşı planları" sekmesi | ⬜ | |
| 2 | UTable: aşı adı, interval, sonraki tarih, aktif | ⬜ | |
| 3 | UModal + UForm: yeni plan / düzenleme | ⬜ | |
| 4 | UButton: "Devre dışı bırak" (soft delete değil, is_active=false) | ⬜ | |

---

## M6.10 — Smoke test

| # | Adım | Durum |
|---|---|---|
| 1 | Backend'de seed: 1 ahşap aşı planı (interval 365 gün, due 5 gün sonra) | ⬜ |
| 2 | `php artisan vaccinations:scan` → log'da SMS satırı + sms_messages.status=sent | ⬜ |
| 3 | Token tarayıcıda aç → Nuxt sayfası açılıyor, çiftçinin hayvan listesi görünüyor | ⬜ |
| 4 | Web panelde aşı planı oluştur → SMS log'u kontrol | ⬜ |

---

**Doküman Sonu.**
