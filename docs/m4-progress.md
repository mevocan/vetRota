# M4 İlerleme Takibi

> **Amaç:** "Fotoğraflı muayene + kronolojik karşılaştırma"
> Detay tablo: `docs/data-model.md` `medical_record_photos`.
> Sync ayrı kanal: `docs/sync-api.md` §6 `POST /sync/photos`.

---

## M3 Devralınan Durum (2026-05-03)

- M3.1–M3.5 ✅ test edildi
- M3.6/1–10 ✅ flutter analyze temiz, login + hayvan + muayene + sync + conflict UI çalışıyor
- M3.6/11 🟡 smoke ✅, sahada kalan 4 senaryo bekliyor
- `medical_record_photos` tablosu data-model.md'de var ama henüz migration yazılmadı

---

## Faz Özeti

| Faz | Kapsam | Durum |
|---|---|---|
| M4.1 | Backend: `medical_record_photos` migration + Eloquent + sync kolonları + trigger | ✅ Migration koştu, M3 testleri (8/8) regresyonsuz |
| M4.2 | Backend: `POST /sync/photos` multipart endpoint + storage (`storage/app/photos/<clinic_id>/`) | ✅ Idempotent (client UUID), tenant kontrolü, pull metadata'ya dahil |
| M4.3 | Flutter: `image_picker` entegrasyonu + Drift `medical_record_photos` tablosu | ✅ Schema v1→v2 migration, `LocalUploadStatus` enum, iOS Info.plist key'leri |
| M4.4 | Flutter: muayene formuna "Fotoğraf çek/seç" + offline lokal saklama | ✅ Kamera + galeri, thumbnail strip, çoklu foto, app docs/photos/ altında saklama |
| M4.5 | Flutter: photo upload queue (sync repository genişletmesi, multipart Dio) | ✅ `uploadPendingPhotos()` her foto ayrı POST, başarı→uploaded, hata→failed retryable |
| M4.6 | Flutter: hayvan detayında kronolojik fotoğraf galerisi (yatay liste, tap → büyük görünüm) | ✅ `PhotoStripForAnimal`, file:// thumbnail, fullscreen `InteractiveViewer`, sync rozet |
| M4.7 | Smoke test (Docker + emulator): foto çek → offline kaydet → online ol → galeri | ⬜ Cihazda elle test bekliyor |

**Durum sembolleri:** ✅ Tamam · ⏳ Yazıldı (test edilmedi) · 🟡 Kısmi · ⚠️ Bloke · ⬜ Bekliyor

---

## M4.1 — Backend: medical_record_photos şeması

**Hedef:** Tablo + sync kolonları + trigger hazır, M3 endpoint'leri yeşil.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Migration `medical_record_photos` (id UUID, medical_record_id FK, animal_id FK denormalize, storage_path, original_filename, mime_type, size_bytes, taken_at, sync kolonları) | ⬜ | data-model.md §4.3 referans |
| 2 | `BEFORE INSERT/UPDATE` trigger (bump_sync_columns) | ⬜ | M3.1'deki fonksiyon zaten var, sadece tabloya bağla |
| 3 | Eloquent `MedicalRecordPhoto` modeli + `HasSyncColumns` + `BelongsToClinic` | ⬜ | |
| 4 | Test (Docker): `migrate:fresh --seed` + M2/M3 curl 57/57 + yeni tablo SELECT | ⬜ | |

---

## M4.2 — Backend: POST /sync/photos

**Hedef:** Multipart upload endpoint'i + storage_path üretimi + idempotency.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `SyncPhotoRequest` (medical_record_id UUID, photo file, taken_at ISO, optional caption) | ⬜ | `device.match` middleware altında |
| 2 | `SyncPhotoController::upload` — file `storage/app/photos/<clinic_id>/<animal_id>/<uuid>.jpg`'e kaydet, `medical_record_photos` kaydı oluştur | ⬜ | |
| 3 | Idempotency: client `client_photo_id` (UUID) gönderir; aynı ID 2. kez gelirse mevcut kaydı dön | ⬜ | |
| 4 | Response: `{ id, storage_path, version, last_modified_at }` | ⬜ | |
| 5 | Pull: photo metadata `/sync/pull`'a dahil edilir (binary değil, sadece path/url) | ⬜ | M3.4 service genişlet |
| 6 | Test (Docker): curl multipart + retry + listele | ⬜ | |

---

## M4.3 — Flutter: image_picker + Drift tablosu

**Hedef:** Cihazdan fotoğraf alınabiliyor + lokal şema hazır.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `image_picker` package + Android `AndroidManifest.xml` izinleri (CAMERA, READ_MEDIA_IMAGES) + iOS `Info.plist` keys | ⬜ | |
| 2 | Drift `MedicalRecordPhotos` tablosu (id, medical_record_id, animal_id, local_path, server_storage_path nullable, mime_type, size_bytes, taken_at, upload_status enum, sync kolonları) | ⬜ | M3.6/3 paterni |
| 3 | `build_runner` üret | ⬜ | |
| 4 | `PhotosRepository` — `addLocalPhoto(File, mr_id, animal_id)` lokal `path_provider` `getApplicationDocumentsDirectory()/photos/` altında saklar, Drift'e satır yazar | ⬜ | |

---

## M4.4 — Muayene formunda fotoğraf çek

**Hedef:** Form'da "Fotoğraf ekle" butonu, çekilen foto thumbnail listesi.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Form'a "Fotoğraf çek/seç" butonu (kamera + galeri seçimi) | ⬜ | |
| 2 | Çekilen foto thumbnail grid'de göster, sil butonu | ⬜ | |
| 3 | Form submit'te muayene + fotoğraflar tek transaction'da kaydedilir | ⬜ | MedicalRecordsRepository.create genişlet, photos parametresi ekle |
| 4 | Offline-first: foto cihazda kalır, upload_status=pending | ⬜ | |

---

## M4.5 — Photo upload queue

**Hedef:** Sync sırasında fotoğraflar da yüklenir.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `SyncRepository.uploadPendingPhotos()` — pending fotoğrafları teker teker `POST /sync/photos`'a gönderir (multipart) | ⬜ | |
| 2 | Başarıda `upload_status=uploaded`, `server_storage_path` doldurulur | ⬜ | |
| 3 | Hata durumunda `upload_status=failed`, lastError | ⬜ | |
| 4 | `sync()` orchestrator akışı: push → photos → pull | ⬜ | |
| 5 | Pending count provider'a fotoğrafları dahil et | ⬜ | |

---

## M4.6 — Hayvan detayında foto galerisi

**Hedef:** Hayvan detayında kronolojik foto şeridi.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `PhotosRepository.watchByAnimal(animal_id)` stream — `taken_at` DESC | ⬜ | |
| 2 | `AnimalDetailScreen` üst kısma yatay foto şeridi (thumbnail + tarih) | ⬜ | |
| 3 | Tap → tam ekran görünüm (`InteractiveViewer` zoom) + tarih + bağlı muayene linki | ⬜ | |
| 4 | Local path varsa file://, sadece server path varsa indir cache (M4.5 sonrası) | ⬜ | |

---

## M4.7 — Smoke test

| # | Adım | Durum |
|---|---|---|
| 1 | Hayvan detayında "Yeni muayene" → fotoğraf çek (kamera) → kaydet | ⬜ |
| 2 | Liste/detayda thumbnail görünüyor (offline) | ⬜ |
| 3 | Sync butonu → backend `storage/app/photos/...` altında dosya | ⬜ |
| 4 | Diğer cihazda pull → foto metadata gelir, indirme tetiklenir | ⬜ |

---

**Doküman Sonu.**
