# M9 İlerleme Takibi — Mobil-Web Tam Eşitlik

> **Amaç:** Mobil uygulamayı web panelinin tam fonksiyonel eşi yapmak.
> Ana panel (dashboard) + tüm modüllere offline-first erişim + çiftçi
> seçme bug'ının çözümü.
>
> **Tetikleyici:** Kullanıcı sahada her zaman internet olmadığını
> belirtti; web-only kalan modüller mobile alınmalı. Ayrıca yeni hayvan
> ekleme akışı serbest UUID input'u ile bozuktu — çiftçi picker yok.
>
> **Sonuç:** 10 alt-faz, 10 commit, tüm modüller dashboard'a bağlandı.

---

## Strateji: M9'u 10 alt-faza parçala

| Faz | Alt-özellik | Yer | Sync | Commit |
|---|---|---|---|---|
| M9.1 | Çiftçi picker + Çiftçiler CRUD | Mobil | Drift offline-first | `d580ca3` |
| M9.2 | Ana dashboard (grid + 3 stat) | Mobil | — | `0ea3047` |
| M9.3 | İlaç/stok CRUD + ledger | Mobil | Drift offline-first | `3e17a01` |
| M9.4 | Tam randevu modülü (3 tab) | Mobil | Drift offline-first | `5b4e0fc` |
| M9.5 | Muayene listesi + edit | Mobil | Drift offline-first | `30bf0e9` |
| M9.6 | Aşı planları (Drift v6) | Mobil | **Drift v6 + sync push/pull** | `3f9fabc` |
| M9.7 | Borç/ödeme ledger | Mobil | Drift offline-first | `82dc5d5` |
| M9.8 | Reçete listesi (online) | Mobil + backend | Online (sync-dışı) | `ea17bc8` |
| M9.9 | Hastalık haritası | Mobil | Online (sync-dışı) | `8146c95` |
| M9.10 | Ayarlar / profil / çıkış | Mobil | — | `c1ddc33` |

**Yan görev:** Marka logosu mobil + web entegrasyonu (`2d21e41`,
`348c177`) — `logo/` klasöründeki dosyalar `mobile/assets/branding/`
ve `web/public/branding/` altına kopyalandı, login + dashboard +
favicon yerine kullanılır oldu.

---

## Faz Detayları

### M9.1 — Çiftçi picker + Çiftçiler CRUD

**Sorun:** `animal_form_screen.dart`'ta "Çiftçi ID (UUID)" serbest text
input vardı. Sahada yeni hayvan eklenirken çiftçi seçilemiyordu.

**Çözüm:**
- `FarmersRepository`: `watchAll` / `searchByQuery` / `create` / `update`
  / `softDelete` (offline-first, `localSyncStatus=pending`)
- `FarmerFormScreen`: ad / soyad / telefon / e-posta / adres
- `FarmerPickerSheet`: bottom sheet — arama + liste + "Yeni çiftçi"
  butonu (sahada yeni çiftçi ekleme akışı içinde)
- `FarmersListScreen`: arama + FAB
- `AnimalFormScreen`: serbest UUID input yerine picker; `villageId`
  çiftçiden otomatik gelir; çiftçi seçilmeden kayıt engellenir

**Dosyalar:**
- `mobile/lib/data/farmers/farmers_repository.dart` (genişletildi)
- `mobile/lib/ui/farmers/farmer_form_screen.dart` (yeni)
- `mobile/lib/ui/farmers/farmer_picker_sheet.dart` (yeni)
- `mobile/lib/ui/farmers/farmers_list_screen.dart` (yeni)
- `mobile/lib/ui/animals/animal_form_screen.dart` (yeniden yazıldı)

---

### M9.2 — Ana dashboard

**Önceki durum:** Login sonrası direkt `AnimalsListScreen` açılıyordu.
AppBar'a tıkanmış 4 ikon (sync, çatışmalar, çıkış, bugünkü randevular)
ile karışık görünüyordu.

**Yeni durum:**
- `HomeScreen`: login sonrası gelinen ekran
- **Üst:** 3'lü özet şeridi — Bekleyen sync · Çatışmalar · Yaklaşan doğum
- **Grid:** 2 kolon × 5 satır = 10+ modül kartı
- **AppBar:** çatışma rozet + sync + çıkış ikonları
- **Pull-to-refresh** ile sync
- `AnimalsListScreen` AppBar sadeleşti — global ikonlar dashboard'a
  taşındı, sadece seçim modu actions kaldı

**Karar:** Grid kart düzeni seçildi (bottom nav / drawer yerine).
Sahada parmakla rahat erişim için.

**Dosyalar:**
- `mobile/lib/ui/home/home_screen.dart` (yeni)
- `mobile/lib/main.dart` (SessionGate → HomeScreen)
- `mobile/lib/ui/animals/animals_list_screen.dart` (AppBar sadeleştirildi)

---

### M9.3 — İlaç/stok CRUD

**Yeni:**
- `DrugsRepository`: watchAll / searchByQuery / watchAllWithStock
  (drug + stock client-side join) / create / update / softDelete /
  `addStockMovement`
- `addStockMovement`: **additive ledger** (CLAUDE.md §3 — silinmez).
  4 tip: `purchase` (giriş) / `usage` (çıkış) / `adjustment` / `waste`.
  Offline'da `stocks.current_quantity` yerel olarak güncellenir,
  sync sonrası server kanonu olur.
- `MedicationsListScreen`: arama + stok miktarı + kritik kırmızı rozet
- `MedicationFormScreen`: 8 drug_type × 6 unit + ambalaj + aşı toggle
- `StockMovementFormScreen`: alış/kullanım/ayarlama/zayi; alışsa
  tedarikçi + SKT + birim fiyat opsiyonel
- `MedicationDetailScreen`: ilaç kart + stok kart (kritik kırmızı) +
  hareket ledger'ı (in/out ikonlu)

**MVP kısıtı:** Drift `Drugs` tablosu backend'in tam supersetine
sahip değil — `barcode`, `default_price`, `vaccine_duration_days`,
`requires_prescription`, `critical_threshold` mobile sync edilmez.
Gerekirse migration ile eklenir.

**Dosyalar:**
- `mobile/lib/data/drugs/drugs_repository.dart` (yeni)
- `mobile/lib/ui/medications/*.dart` (4 yeni dosya)

---

### M9.4 — Tam randevu modülü

**Önceki durum:** Sadece "Bugün" ekranı vardı (harita+rota+optimize).
İleri tarihli randevu kurma, randevu listesi yoktu.

**Yeni:**
- `AppointmentsRepository`: watchUpcoming / watchPast / watchById /
  _watchRange ortak join + create / update / softDelete / setStatus
- `AnimalsRepository.watchByFarmer` + `animalsByFarmerProvider`
  (randevu / muayene formu için animal picker)
- `AppointmentsListScreen`: 3 tab (Bugün / Yaklaşan / Geçmiş), tarihe
  göre grupli; AppBar'da harita ikonu eski "today" ekranına geçer
- `AppointmentFormScreen`: çiftçi picker + hayvan picker (çiftçiye
  göre filtreli) + tarih+saat + durum + sebep
- `AppointmentDetailScreen`: kart + durum chip + hızlı aksiyonlar
  (Tamamlandı/Başla/İptal) + düzenle/sil + "Muayene başlat"

**MVP kısıtı:** Drift schema `appointment_type` ve
`estimated_duration_minutes` içermiyor — backend support eder, mobile
göstermiyor.

**Dosyalar:**
- `mobile/lib/data/appointments/appointments_repository.dart` (genişletildi)
- `mobile/lib/data/animals/animals_repository.dart` (watchByFarmer eklendi)
- `mobile/lib/ui/appointments/*.dart` (3 yeni dosya)

---

### M9.5 — Muayene listesi + edit + detay

**Önceki durum:** Yeni muayene formu vardı (hayvan detayından
açılıyordu) ama global muayene listesi, detay ve edit yoktu.

**Yeni:**
- `MedicalRecordsRepository`: watchAllWithMeta (animal+farmer join) +
  watchById + watchDrugsForRecord (drug katalogundan ad+birim join) +
  `updateBasic` (sadece metin+vital alanlar) + softDelete
- `MedicalRecordWithMeta` + `MedicalRecordDrugDetail` DTO'lar
- `MedicalRecordsListScreen`: arama (hayvan/çiftçi/şikayet) + servis
  bedeli rozet + tarih + çiftçi
- `MedicalRecordDetailScreen`: 5 kart bölümü — header (tarih+tip+ücret),
  notlar (şikayet/belirti/tanı/tedavi/öneri), vitals (sıcaklık/ağırlık/
  nabız/solunum), ilaçlar, follow-up
- `MedicalRecordEditScreen`: metin+vital düzenleme

**MVP kısıtı:** İlaç listesi edit'i yapılmıyor — stok ledger
karmaşıklığı (negatif hareket + yeni hareket) için ayrı bir akış
gerekir.

**Dosyalar:**
- `mobile/lib/data/medical_records/medical_records_repository.dart` (genişletildi)
- `mobile/lib/ui/medical_records/*.dart` (3 yeni dosya)

---

### M9.6 — Aşı planları (Drift v6 + sync)

**Önceki durum:** Test doc 2.4'te belgelendiği üzere mobile'da
`vaccine_schedules` Drift tablosu yoktu. M7+'a ertelenmişti. Web'de
zaten vardı (`/animals/[id]/vaccinations`).

**Yeni — Drift migration v6:**
- `VaccineSchedules` tablosu: animal_id, drug_id, interval_days,
  first_due_date, next_due_date, last_administered_at,
  remind_days_before, is_active, notes (+ SyncColumns)
- `schemaVersion` 5 → 6, `onUpgrade` adımı

**Sync entegrasyonu:**
- `sync_mappers`: `vaccineScheduleToData` + `vaccineScheduleFromServer`
- `sync_repository`: `_tables` listesine eklendi, push
  (`_pendingVaccineSchedules`), success/failed handler'lar, pull case,
  `pendingCountProvider` sayım sütununa eklendi

**Repository + UI:**
- `VaccineSchedulesRepository`: watchAllWithMeta (animal+drug join),
  watchByAnimal, create, **markAdministered** (next_due += interval),
  setActive (devre dışı), softDelete
- `VaccineScheduleWithMeta`: `daysToNext` / `isDueSoon` / `isOverdue`
- `vaccineDrugsProvider`: sadece `is_vaccine=true` ilaçlar (picker filtre)
- `VaccineSchedulesListScreen`: aciliyet renk kodlu (kırmızı=geçmiş,
  turuncu=yaklaştı) + PopupMenu (Yapıldı / Devre dışı / Sil)
- `VaccineScheduleFormScreen`: çiftçi picker + hayvan picker + aşı
  picker + ilk yapılacak tarih + tekrar aralığı + hatırlatma aralığı

**Önemli:** Codegen sonrası `flutter pub run build_runner build
--delete-conflicting-outputs` çalıştırılmalı.

**Dosyalar:**
- `mobile/lib/data/db/app_database.dart` (tablo + migration)
- `mobile/lib/data/sync/sync_mappers.dart` (vaccine mapper)
- `mobile/lib/data/sync/sync_repository.dart` (6 yer)
- `mobile/lib/data/vaccinations/vaccine_schedules_repository.dart` (yeni)
- `mobile/lib/ui/vaccinations/*.dart` (2 yeni dosya)

---

### M9.7 — Borç/ödeme ledger

**Yeni:**
- `PaymentsRepository`: `watchAllWithMeta` (farmer join) + `reverse`
  (negatif tutarlı ters hareket — ledger silinmez)
- `PaymentWithMeta` DTO + `paymentsAllProvider`
- `PaymentsListScreen`: arama (çiftçi/not) + üst kart toplam + liste
  (yeşil/kırmızı rozet pozitif/negatif tutar)
- `PaymentFormScreen`: çiftçi picker (initial verilirse kilitli) +
  tutar (negatif izinli — iptal için) + yöntem + tarih+saat + not

**Not:** Farmer detay sayfasındaki mevcut `FarmerBalanceCard`
korundu — buradan ödeme ekrana hızlı link sonraki iyileştirme.

**Dosyalar:**
- `mobile/lib/data/payments/payments_repository.dart` (genişletildi)
- `mobile/lib/ui/payments/*.dart` (2 yeni dosya)

---

### M9.8 — Reçete listesi (online + backend index)

**Önceki durum:** Reçete tasarım gereği **sync-dışı** (prescription
migration yorumu: "Sync disi — sadece online iken POST edilir").
Mobile'da sadece `_createPrescription` butonu vardı (medical record
detay), liste/PDF indirme yoktu.

**Backend:**
- `PrescriptionController::index` — sayfalı, `q=ara`,
  farmer/animal/vet ilişkileri preload, klinik filtreli
- `routes/api.php`: `GET /prescriptions` eklendi

**Mobile (online-only):**
- `PrescriptionsRepository`: `fetchAll(query)` + `downloadPdf`
- `PrescriptionListItem` + `Farmer`/`Animal` DTO'lar
- `prescriptionsListProvider` (`FutureProvider.family<query>`)
- `PrescriptionsListScreen`: arama (submit ile) + refresh + üst uyarı
  "online listelenir" + PDF indir + `open_filex` ile aç + error halinde
  "Tekrar dene" CTA

**Dosyalar:**
- `backend/app/Http/Controllers/Api/V1/Prescriptions/PrescriptionController.php`
- `backend/routes/api.php`
- `mobile/lib/data/prescriptions/prescriptions_repository.dart` (yeni)
- `mobile/lib/ui/prescriptions/prescriptions_list_screen.dart` (yeni)

---

### M9.9 — Hastalık haritası (online flutter_map)

**Önceki durum:** Backend M7.6'da hazırdı, web'de kullanılıyordu
(`/analytics/disease-map`). Mobile'da yoktu.

**Yeni:**
- `DiseaseMapRepository`: `/analytics/disease-map` çekimi, köy bazlı
  agregat (case_count + top_keywords). `DiseaseVillage` +
  `DiseaseMapQuery` DTO'lar. `FutureProvider.family<query>` cache.
- `DiseaseMapScreen`:
  - **Tarih aralığı** filtresi (default son 30 gün)
  - **Üst özet kart:** toplam olgu + köy sayısı
  - **Harita/Liste toggle** (AppBar)
  - **Harita:** OSM tile + `CircleLayer` (yarıçapı + rengi case_count
    ile orantılı — yeşil/turuncu/kırmızı) + Marker etiketi (köy adı
    + olgu sayısı)
  - **Liste:** olgu sayısı rozet + ilk 3 anahtar kelime

**Online by design.** Backend M7.6.2 endpoint'ini kullanır.

**Dosyalar:**
- `mobile/lib/data/disease_map/disease_map_repository.dart` (yeni)
- `mobile/lib/ui/disease_map/disease_map_screen.dart` (yeni)

---

### M9.10 — Ayarlar / profil / çıkış

**Yeni:** `SettingsScreen` — sahada gerekli bilgileri tek ekranda gör:

- Kullanıcı e-postası (secure storage'dan)
- Klinik ID
- Cihaz ID
- Bekleyen sync sayısı
- Çözümlenmemiş çakışmalar
- Son sync zamanı
- Hakkında (versiyon)
- Çıkış (bekleyen kayıt varsa uyarı ile onay)

`_comingSoon` helper kaldırıldı — artık dashboard'da disabled kart yok.

**Dosyalar:**
- `mobile/lib/ui/settings/settings_screen.dart` (yeni)
- `mobile/lib/ui/home/home_screen.dart` (Ayarlar kartı aktif)

---

## Marka logosu entegrasyonu (yan görev)

**`logo/` klasöründeki dosyalar:**
- `logo.png` — VetRota wordmark (pin+stetoskop + yazı, yeşil)
- `logo2.png` — Sadece pin+stetoskop ikonu (kare, app icon için ideal)
- `favicon.png` — Tarayıcı sekme ikonu

**Mobil:**
- Dosyalar `mobile/assets/branding/` altına kopyalandı
- `pubspec.yaml`: assets + `flutter_launcher_icons` dev dep + config
- `LoginScreen`: AppBar kalktı, banner olarak `logo.png` (height 80)
- `HomeScreen` AppBar: `logo2.png` (height 28) + "VetRota" yazı
- Launcher icon üretmek için: `dart run flutter_launcher_icons`

**Web:**
- `web/public/branding/` altına kopyalandı
- `nuxt.config.ts`: favicon `/branding/favicon.png` + title
- `default.vue` layout: sidebar üstündeki `lucide-leaf` + text yerine
  `logo.png` (h-9), `NuxtLink` ile `/`'a bağlandı
- `login.vue`: text "VetRota" başlık yerine `logo.png` (h-16) + alt yazı

**Çiftçi portal (`/farmer/[token]`):** Klinik adını + stetoskop ikonu
gösterdiği için VetRota logosu eklenmedi — sayfa altında metin marka
mevcut.

---

## Bekleyen iş

- **Saha testi** — yeni 10 modülün her birini cihazda denemek
  (`docs/aban-bunlari-test-etmen-lazim.md` bölümünde takip)
- **`CLAUDE.md` §7 Mevcut Durum** — "M9 tamam" olarak güncellendi
- **`docs/plan.md`** — M9 zaten yol haritası dışıydı (kullanıcı
  ortaya çıkardı), gerekirse eklenebilir
- **MVP kısıtları** (her fazda not edildi):
  - Drift `Drugs` schema backend'in supersetine sahip değil
  - Drift `Appointments` `appointment_type` içermiyor
  - Muayene edit'inde ilaç listesi değişmez
  - Reçete + hastalık haritası online (sync-dışı)

---

**Doküman Sonu.**
