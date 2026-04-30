# M2 İlerleme Takibi

> **Amaç:** "Çekirdek veri modeli API'den dönüyor". Vertical slice yaklaşımı:
> önce Hayvan ucundan uca, sonra çiftçi/muayene/ilaç/randevu aynı pattern'le.

---

## Vertical Slice 1 — Hayvan (Animal)

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Migration: villages, farmers, animals | ✅ Tamam | UUID PK, soft delete; clinic_id ve sync kolonları (last_modified_at, origin_device_id, version) **kapsam dışı**, M3'te eklenecek |
| 2 | Modeller: Village, Farmer, Animal | ✅ Tamam | HasUuids + SoftDeletes + ilişkiler |
| 3 | Form Request: Store/UpdateAnimalRequest | ✅ Tamam | Türkçe hata mesajları |
| 4 | Controller: AnimalController + FarmerController + VillageController | ✅ Tamam | Hayvan tam CRUD; çiftçi/köy read-only (dropdown için) |
| 5 | Route: `apiResource('animals')` + `GET /farmers` + `GET /villages` | ✅ Tamam | Hepsi `auth:api` middleware ile JWT korumalı |
| 6 | Seeder güncelleme | ✅ Tamam | 4 köy + 5 çiftçi + 2 hayvan idempotent seed |
| 7 | Nuxt: auth store localStorage persistence | ✅ Tamam | `vetrota.token`; `auth.client.ts` plugin ile hydrate |
| 8 | Nuxt: global auth middleware | ✅ Tamam | `/login` dışı her sayfa korumalı |
| 9 | Nuxt: `useApi()` + `useApiFetch()` composable | ✅ Tamam | JWT otomatik header, 401'de logout |
| 10 | Nuxt: dashboard layout (sidebar + topbar) | ✅ Tamam | `mockup-v1.html`'e göre; menu: Panel/Hayvanlar/Çiftçiler/Muayeneler/İlaç/Randevular |
| 11 | Nuxt: `pages/index.vue` (panel) | ✅ Tamam | 4 stat card + son hayvan listesi |
| 12 | Nuxt: `pages/animals/index.vue` (liste) | ✅ Tamam | Arama + tür filtresi + sayfalama + boş durum |
| 13 | Nuxt: `pages/animals/[id].vue` (detay) | ✅ Tamam | Kimlik kartı + sahibi/köy kartları + sil butonu |
| 14 | Nuxt: `pages/animals/new.vue` + `pages/animals/[id]/edit.vue` | ✅ Tamam | Ortak `AnimalForm.vue` component |
| 15 | **Test (canlı)** | ✅ Tamam | 2026-04-30: 11/11 backend curl senaryosu yeşil (login, 401, list, show, store, validation 422 + Türkçe mesaj, update, soft delete, 404). Frontend SSR 200; tarayıcı UX testi kullanıcıda. |

**Durum sembolleri:** ✅ Tamam · ⏳ Yazıldı (test edilmedi) · ⚠️ Bloke · ⬜ Bekliyor

---

## Vertical Slice 2 — Çiftçi (Farmer) tam CRUD

> Slice 1 ile aynı pattern. Backend: `FarmerController` read-only'den
> `apiResource`'a yükseltilir + Form Request'ler eklenir. Frontend: hayvan
> sayfalarının ikizi.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Form Request: Store/UpdateFarmerRequest | ✅ Tamam | `phone` unique kuralı (update'te kendisi hariç + soft-delete'leri hariç), Türkçe mesajlar |
| 2 | Controller: FarmerController'a show/store/update/destroy | ✅ Tamam | `with('village')` + `withCount('animals')` + show'da son 50 hayvan |
| 3 | Route: `apiResource('farmers')` | ✅ Tamam | Eski sade `GET /farmers` kaldırıldı |
| 4 | Migration: farmers.phone partial unique (deleted_at IS NULL) | ✅ Tamam | Smoke test sırasında "soft-deleted phone yeniden kullanılamıyor 500 atıyor" sorunu fark edildi, partial index ile düzeltildi |
| 5 | Nuxt: `pages/farmers/index.vue` | ✅ Tamam | Arama (ad/soyad/telefon) + sayfalama + boş durum + hayvan sayısı + bakiye TL formatı |
| 6 | Nuxt: `pages/farmers/[id].vue` | ✅ Tamam | Kimlik kartı + iletişim + köy/adres kartları + bu çiftçinin hayvanları listesi (ilk 50) |
| 7 | Nuxt: `pages/farmers/new.vue` + `[id]/edit.vue` | ✅ Tamam | Ortak `FarmerForm.vue` |
| 8 | **Test (canlı, backend)** | ✅ Tamam | 2026-04-30: 11/11 curl senaryosu yeşil — list+animals_count, validation 422 + Türkçe mesajlar, duplicate phone 422, valid POST 201, show + animals, partial PUT, kendi telefonu OK, başkasının telefonu 422, soft delete 204, soft-deleted phone yeni kayıtla yeniden kullanılabiliyor |
| 9 | **Test (canlı, frontend)** | ⬜ Bekliyor | 4 sayfa SSR 200; tarayıcı UX testi kullanıcıda |

---

## Vertical Slice 3 — Muayene (MedicalRecord) tam CRUD

> Hayvan tablosunu ana modelin etrafında bir saha ziyareti kayıtlarına
> bağlar. M2 kapsamında **clinic_id, diagnosis_id, appointment_id,
> invoice_id, sync kolonları (last_modified_at/origin_device_id/version)
> yok** — bunlar M2.5/M3/M4/M7'de ALTER TABLE ile eklenecek. `vet_id`
> users tablosu bigint olduğu için `foreignId` (M3 UUID geçişinde uyumlu
> hâle getirilecek).

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Migration: `medical_records` (sade kapsam) | ✅ Tamam | UUID PK + animal_id (UUID) + vet_id (bigint) + village_id; vital değerler, takip, hizmet ücreti, soft delete |
| 2 | Model: `MedicalRecord` + `Animal::medicalRecords()` | ✅ Tamam | belongsTo animal/vet/village + hasMany Animal'da |
| 3 | Form Request: Store/UpdateMedicalRecordRequest | ✅ Tamam | Türkçe mesajlar; `temperature_celsius` 30–50, `follow_up_date` STORE'da `required_if:follow_up_needed,true` |
| 4 | Controller: `MedicalRecordController` (CRUD + filtreler) | ✅ Tamam | animal_id/vet_id/visit_type/from/to/follow_up_due filtreleri; `vet_id` otomatik = giriş yapan kullanıcı; `village_id` boşsa hayvanın köyünden alınır |
| 5 | Route: `apiResource('medical-records')` | ✅ Tamam | URL'de tire (Türkçe `/muayeneler` yerine REST konvansiyonu) |
| 6 | Seeder: 2 muayene | ✅ Tamam | Sarıkız → gebelik kontrolü + takip; TR-06-014 → aşı |
| 7 | Nuxt: `pages/examinations/index.vue` | ✅ Tamam | Tür filtresi + "sadece takip gerekenler" + sayfalama; ziyaret rozeti renkli (acil = kırmızı, gebelik = sarı) |
| 8 | Nuxt: `pages/examinations/[id].vue` | ✅ Tamam | Vital kart şeritleri (sıcaklık/ağırlık/nabız/solunum) + şikayet/semptom/tanı/tedavi/öneri kartları + ücret + takip |
| 9 | Nuxt: `pages/examinations/new.vue` + `[id]/edit.vue` | ✅ Tamam | Ortak `ExaminationForm.vue`; `?animal_id=...` query'si geldiğinde hayvan kilitli açılır |
| 10 | Nuxt: hayvan detayında "Son muayeneler" bölümü | ✅ Tamam | `/animals/[id]` altına son 10 muayene tablosu + "Yeni muayene" CTA (animal_id preset) |
| 11 | **Test (canlı, backend)** | ✅ Tamam | 2026-04-30: 10/10 curl senaryosu yeşil — list+ilişkiler, animal_id filter, validation 422 (3 alan), geçersiz visit_type + sıcaklık out-of-range 422, valid POST 201 (vet_id otomatik, village_id otomatik), show, PUT partial, follow_up_date STORE'da `required_if`, DELETE 204, 404 |
| 12 | **Test (canlı, frontend)** | ⬜ Bekliyor | 4 sayfa SSR 200 + hayvan detay 200; tarayıcı UX testi kullanıcıda |

---

## Vertical Slice 4 — İlaç & Stok (Drug + Stock + StockMovement)

> Üç tablo: `drugs` (katalog), `stocks` (cumulative cache), `stock_movements`
> (ledger — `deleted_at` YOK, asla silinmez). Her ilaç oluşturulduğunda
> otomatik 1 stok kaydı açılır. Hareket eklenince `StockMovementObserver`
> `stocks.current_quantity`'i atomik olarak günceller (lockForUpdate),
> `last_purchased_at` ve `earliest_expiry_at` türetilmiş alanlarını
> tazeler.
>
> M2 kapsam dışı: clinic_id (M2.5/M3), owner_user_id (çoklu vet — M3+),
> sync kolonları (M3), `medical_record_drugs` ara tablosu (M2.5'te muayene
> ile bağlamak için), `medical_record_photos` (M5+).

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Migration: `drugs` (partial unique name) | ✅ Tamam | Soft-delete'lere izin veren `WHERE deleted_at IS NULL` index |
| 2 | Migration: `stocks` | ✅ Tamam | drug_id unique → her ilaç için tek kayıt |
| 3 | Migration: `stock_movements` (ledger, deleted_at YOK) | ✅ Tamam | `chk_movement_type` constraint; `related_movement_id` self-FK PG aynı CREATE'te sorun çıkardığı için sadece UUID kolonu, FK M3'te ALTER ile eklenecek |
| 4 | Modeller: Drug, Stock, StockMovement (+ ilişkiler) | ✅ Tamam | StockMovement'ta `SoftDeletes` YOK |
| 5 | `StockMovementObserver` + `AppServiceProvider::boot()` | ✅ Tamam | DB transaction + `lockForUpdate` ile race-safe; `earliest_expiry_at` sadece pozitif quantity'de güncellenir |
| 6 | Form Request: Store/UpdateDrugRequest, StoreStockMovementRequest | ✅ Tamam | Türkçe mesajlar; `quantity != 0` kuralı; `name` partial unique |
| 7 | DrugController CRUD + filtreler | ✅ Tamam | search (name/etken/üretici/barkod), drug_type, is_vaccine, **low_stock_only** (`whereColumn current_quantity <= critical_threshold`); store yeni ilaç + stock kaydı tek atomik işlem; destroy soft delete + stok soft delete |
| 8 | StockMovementController (index + store) | ✅ Tamam | drug_id/movement_type/from/to filtreleri; store stock_id'yi otomatik bulur, performed_by = giriş yapan kullanıcı |
| 9 | Route: apiResource('drugs') + GET/POST stock-movements | ✅ Tamam | |
| 10 | Seeder: 3 ilaç + 3 alım hareketi | ✅ Tamam | Amoksisilin LA (1000ml), Şap Aşısı (500doz), İvermektin (80ml — bilerek kritik test); seeder `WithoutModelEvents` kullandığı için stock cache manuel güncellenir |
| 11 | Frontend: `pages/medications/index.vue` | ✅ Tamam | Arama + tür filtresi + **"sadece kritik stok"** + kritik satırlar amber arka plan |
| 12 | Frontend: `pages/medications/[id].vue` | ✅ Tamam | 4 stok kartı (mevcut/eşik/SKT/son alım) + inline "Yeni hareket" formu (toggle ile açılır) + son 50 hareket geçmişi tablosu (giriş yeşil, çıkış kırmızı) |
| 13 | Frontend: `new/edit` + `DrugForm.vue` + `StockMovementForm.vue` | ✅ Tamam | Drug form: drug_type=vaccine seçince is_vaccine otomatik açılır. Movement form: kullanım/fire seçince işaret otomatik negatif olur, kullanıcı pozitif girer |
| 14 | **Test (canlı, backend)** | ✅ Tamam | 2026-04-30: 13/13 curl senaryosu yeşil — list + ilişkiler, low_stock_only filter, duplicate name 422, valid POST 201 + otomatik stock, alım observer +200, kullanım observer -50 → toplam 150 doğru, quantity=0 reddedildi, hareket geçmişi 2, PUT, DELETE soft delete + 404 |
| 15 | **Test (canlı, frontend)** | ⬜ Bekliyor | 4 sayfa SSR 200; tarayıcı UX testi kullanıcıda |

---

## Vertical Slice 5 — Randevular (Appointments)

> M2'nin son slice'ı. Status state machine basit: planned → confirmed →
> in_progress → completed (veya cancelled / no_show). Detay sayfasında
> hızlı durum geçiş butonları ve "tamamlandı"sa otomatik "muayene
> oluştur" CTA'sı var.
>
> M2 kapsam dışı: source/source_reference_id (M5: aşı takvimi/follow-up
> tetikleyicileri), sms_reminder_sent_at + confirmed_by_farmer_at (M6:
> SMS akışları), completed_medical_record_id (M2.5'te muayene ile
> bidirectional bağlama), sync kolonları (M3).

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Migration: `appointments` | ✅ Tamam | UUID PK + farmer_id + animal_id (nullable, sürü bazlı için) + vet_id (bigint) + village_id; `chk_appt_type` ve `chk_appt_status` PG check constraint'leri |
| 2 | Model: `Appointment` + ilişkiler | ✅ Tamam | belongsTo farmer/animal/vet/village |
| 3 | Form Request: Store/UpdateAppointmentRequest | ✅ Tamam | Türkçe mesajlar; süre 5–480 dk; status 6 değerli enum |
| 4 | Controller: `AppointmentController` | ✅ Tamam | farmer_id/animal_id/status/type/from/to filtreleri + sort asc/desc; `vet_id` otomatik = giriş yapan kullanıcı; `village_id` boşsa hayvan→çiftçi zincirinden türetilir; status değişince `status_changed_at` otomatik güncellenir |
| 5 | Route: `apiResource('appointments')` | ✅ Tamam | |
| 6 | Seeder: 4 randevu | ✅ Tamam | Yarın gebelik takip, +2 gün aşı confirmed, +3 gün sürü ziyareti, dün tamamlanmış rutin (test çeşitliliği için) |
| 7 | Frontend: `pages/appointments/index.vue` | ✅ Tamam | **Gün gün gruplanmış** liste (tarih başlığı + altında kartlar); status/type filtreleri + "bugünden itibaren" varsayılan açık |
| 8 | Frontend: `pages/appointments/[id].vue` | ✅ Tamam | Tarih + tür/durum rozetleri + **hızlı durum geçiş butonları** (state machine'e göre dinamik: planned'dan 4, confirmed'dan 4 vs) + farmer/animal/village/vet kartları + tamamlandıysa "muayene oluştur" CTA |
| 9 | Frontend: `new.vue` + `[id]/edit.vue` + `AppointmentForm.vue` | ✅ Tamam | Hayvan dropdown çiftçi seçimine göre filtrelenir; çiftçi değişince hayvan reset; `?farmer_id=&animal_id=` query desteği; edit formunda durum alanı görünür |
| 10 | **Test (canlı, backend)** | ✅ Tamam | 2026-05-01: 11/11 curl senaryosu yeşil — list + ilişkiler, status filter, validation 422 (3 alan), geçersiz type 422, valid POST 201 (vet_id + village_id otomatik), show, status değişikliği `status_changed_at` güncellendi, geçersiz status 422, süre<5dk 422 (Türkçe mesaj eklendi), DELETE soft delete + 404, tarih aralığı filtresi |
| 11 | **Test (canlı, frontend)** | ⬜ Bekliyor | 4 sayfa SSR 200; sidebar artık tüm linklere kayıtlı (No-match uyarısı sıfır); tarayıcı UX testi kullanıcıda |

---

## M2 Genel Durumu

Tüm 5 slice ✅ kod düzeyinde tamam. Geriye sadece **kullanıcı tarafında
tarayıcı UX testi** kaldı:

| Slice | Backend test | Frontend SSR | Tarayıcı testi |
|---|---|---|---|
| 1 — Hayvan | 11/11 ✅ | ✅ | ✅ kullanıcı doğruladı |
| 2 — Çiftçi | 11/11 ✅ | ✅ | ✅ "ekleme çalışıyor" |
| 3 — Muayene | 10/10 ✅ | ✅ | ⬜ |
| 4 — İlaç & Stok | 13/13 ✅ | ✅ | ⬜ |
| 5 — Randevu | 11/11 ✅ | ✅ | ⬜ |

Sıradaki: tarayıcı testleri tamamlandığında M2 kapatılır, **M3 — Sync
Protokolü** başlar (offline-first kalbi).

---

## Test Kontrol Listesi (sonra yapılacak)

Backend:
- [ ] `php artisan migrate` hatasız çalışıyor (3 yeni migration)
- [ ] `php artisan db:seed` 4 köy + 5 çiftçi + 2 hayvan ekliyor
- [ ] `GET /api/v1/animals` JWT ile 200 döner, paginated payload geliyor
- [ ] `POST /api/v1/animals` valid payload ile 201, eksik `farmer_id` ile 422 + Türkçe mesaj
- [ ] `GET /api/v1/animals/{id}` farmer + village ilişkilerini load ediyor
- [ ] `PUT /api/v1/animals/{id}` partial update
- [ ] `DELETE /api/v1/animals/{id}` soft delete (deleted_at dolar, kayıt silinmez)
- [ ] `GET /api/v1/farmers` + `GET /api/v1/villages` dropdown verisi dönüyor
- [ ] JWT'siz istek 401 döner

Frontend:
- [ ] `/login`'dan giriş sonrası `/`'a yönlendirilir
- [ ] Refresh sonrası login durumu korunur (localStorage hydrate)
- [ ] Sidebar'da aktif menü vurgulu, route değişimi çalışıyor
- [ ] `/animals` listede sayfalama, arama, filtre çalışıyor
- [ ] `/animals/new` formu validation + başarılı kayıt sonrası detaya yönlendirme
- [ ] `/animals/[id]` detayda doğru bilgiler + edit linkı + silme onayı
- [ ] `/animals/[id]/edit` mevcut değerlerle dolu, güncelleme çalışıyor
- [ ] 401 alınca otomatik `/login`'a yönlendirir
- [ ] Çıkış yap → token silinir → `/login`

---

## Açık Notlar

- **Backend container şu an kapalı.** Kullanıcının paralel `teknik-dizel` projesi 8000 portunu tutuyor olabilir. Test için ya o proje kapatılıp `vetrota-backend` ayağa kaldırılacak ya da WSL'de farklı portla `php artisan serve` çalıştırılacak; o zaman Nuxt'ın `NUXT_PUBLIC_API_BASE`'i de değişir.
- **`config/cors.php`** Laravel'in default'u `api/*` paths için `*` origin allow ediyor; localhost:3000 → localhost:8000 çalışmalı. Sorun çıkarsa `allowed_origins` daraltılır.
- **CSRF muafiyeti:** Stateless API (JWT) için CSRF gerekmez; `routes/api.php` zaten Laravel 11+ slim skeleton'da CSRF dışında. Doğrula.
- **Sync kolonları yok.** M3'te `last_modified_at`, `origin_device_id`, `version` eklenecek; o noktada migration **silinmez**, ALTER TABLE migration eklenir.
- **Çoklu klinik (`clinic_id`) yok.** M2.5 veya M3'te tek klinikten çoklu kliniğe geçiş ALTER TABLE + auth scope ile.
- **Vertical slice 2** (Çiftçi tam CRUD UI) bu pattern'le çoğaltılacak; ardından muayene, ilaç/stok, randevu.

---

## Sonraki Oturum İçin Hızlı Başlangıç

1. Backend'i ayağa kaldır (kullanıcının kararına göre container veya WSL native).
2. `php artisan migrate && php artisan db:seed`.
3. `npm run dev` (web/) — `localhost:3000`.
4. Yukarıdaki test kontrol listesini sırayla geç.
5. Hatalar düzeltildikten sonra Vertical Slice 2 (Çiftçi) için aynı pattern.
