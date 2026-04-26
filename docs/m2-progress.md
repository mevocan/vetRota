# M2 İlerleme Takibi

> **Amaç:** "Çekirdek veri modeli API'den dönüyor". Vertical slice yaklaşımı:
> önce Hayvan ucundan uca, sonra çiftçi/muayene/ilaç/randevu aynı pattern'le.

---

## Vertical Slice 1 — Hayvan (Animal)

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Migration: villages, farmers, animals | ⏳ Yazıldı | UUID PK, soft delete; clinic_id ve sync kolonları (last_modified_at, origin_device_id, version) **kapsam dışı**, M3'te eklenecek |
| 2 | Modeller: Village, Farmer, Animal | ⏳ Yazıldı | HasUuids + SoftDeletes + ilişkiler |
| 3 | Form Request: Store/UpdateAnimalRequest | ⏳ Yazıldı | Türkçe hata mesajları |
| 4 | Controller: AnimalController + FarmerController + VillageController | ⏳ Yazıldı | Hayvan tam CRUD; çiftçi/köy read-only (dropdown için) |
| 5 | Route: `apiResource('animals')` + `GET /farmers` + `GET /villages` | ⏳ Yazıldı | Hepsi `auth:api` middleware ile JWT korumalı |
| 6 | Seeder güncelleme | ⏳ Yazıldı | 4 köy + 5 çiftçi + 2 hayvan idempotent seed |
| 7 | Nuxt: auth store localStorage persistence | ⏳ Yazıldı | `vetrota.token`; `auth.client.ts` plugin ile hydrate |
| 8 | Nuxt: global auth middleware | ⏳ Yazıldı | `/login` dışı her sayfa korumalı |
| 9 | Nuxt: `useApi()` + `useApiFetch()` composable | ⏳ Yazıldı | JWT otomatik header, 401'de logout |
| 10 | Nuxt: dashboard layout (sidebar + topbar) | ⏳ Yazıldı | `mockup-v1.html`'e göre; menu: Panel/Hayvanlar/Çiftçiler/Muayeneler/İlaç/Randevular |
| 11 | Nuxt: `pages/index.vue` (panel) | ⏳ Yazıldı | 4 stat card + son hayvan listesi |
| 12 | Nuxt: `pages/animals/index.vue` (liste) | ⏳ Yazıldı | Arama + tür filtresi + sayfalama + boş durum |
| 13 | Nuxt: `pages/animals/[id].vue` (detay) | ⏳ Yazıldı | Kimlik kartı + sahibi/köy kartları + sil butonu |
| 14 | Nuxt: `pages/animals/new.vue` + `pages/animals/[id]/edit.vue` | ⏳ Yazıldı | Ortak `AnimalForm.vue` component |
| 15 | **Test (canlı)** | ⬜ Bekliyor | Backend container restart edilince + migration çalıştırınca test edilecek |

**Durum sembolleri:** ✅ Tamam · ⏳ Yazıldı (test edilmedi) · ⚠️ Bloke · ⬜ Bekliyor

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
