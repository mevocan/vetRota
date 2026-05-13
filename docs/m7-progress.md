# M7 İlerleme Takibi

> **Amaç:** "Hastalık haritası + Sürü işlemi + QR + Gebelik + Reçete + Borç"
> Bağımlılık: M3 (sync) + M6 (SMS portal).
> Detay: `docs/data-model.md` §5 (animals, medical_records), §5.6 (prescriptions),
> §5.7 (sms), `docs/proje.md` özellik listesi.

---

## M6 Devralınan Durum (2026-05-11)

- M6.1–M6.10 ✅ tüm SMS altyapısı çalışıyor (LogSmsSender + queue:database).
- `aban-bunlari-test-etmen-lazim.md`: 2.2 / 2.3 / 3.1 / 3.2 yeşil; 2.1 kullanıcıda.
- Sync push artık defansif (vet_id, unit, service_fee, foto echo prevention fix).

---

## Strateji: M7'yi 6 alt-fasta parçala

Tek seansta hepsi yapılmaz. Sıra **küçük & izole** → **yüksek değerli** → **bulanık**:

| Faz | Alt-özellik | Ölçek | Yer | Risk |
|---|---|---|---|---|
| M7.1 | Gebelik takibi | küçük | Backend + Mobil | düşük |
| M7.2 | QR etiket PDF | küçük | Backend | düşük |
| M7.3 | Borç/ödeme | orta | Backend + Web + Mobil | düşük |
| M7.4 | Reçete PDF + SMS | orta | Backend + Mobil | düşük |
| M7.5 | Sürü işlemi (toplu) | orta | Mobil | orta |
| M7.6 | Hastalık haritası | büyük | Web | yüksek |

Her faz biter bitmez bu dokümanda **bittiği işaretlenir + bir sonraki başlığa geçilir**. Faz arası commit zorunlu (atomik check-point).

---

## Faz Detayları

### M7.1 — Gebelik takibi

**Amaç:** Veteriner sığır/koyunda gebelik tespit eder, beklenen doğum tarihi otomatik hesaplanır, yaklaşan doğumlar listesinde görünür.

**Veri:** `animals.is_pregnant` (var), yeni alanlar:
- `pregnancy_started_at` (DATE, nullable)
- `expected_birth_date` (DATE, nullable, generated veya manuel)
- Tür bazında gebelik süresi: cattle=283, sheep=150, goat=150, horse=340 gün.

**Adımlar:**
1. **M7.1.1** Backend migration: animals tablosuna `pregnancy_started_at`, `expected_birth_date`, `pregnancy_notes`.
2. **M7.1.2** Backend Animal modelinde fillable + casts; `markPregnant(date)` servisi tahmini doğum hesaplar.
3. **M7.1.3** Mobil Drift schema upgrade (v3→v4): aynı 3 kolon. sync_mappers'a ekle.
4. **M7.1.4** Mobil hayvan formuna "Gebelik" toggle + tarih seçici.
5. **M7.1.5** Mobil hayvanlar listesinde gebe hayvanlar için 🤰 rozet; "Yaklaşan doğumlar" alt-listesi (30 gün içinde).
6. **M7.1.6** Web hayvan detayında gebelik kartı.

**Bitti kriteri:** Bir sığır gebe işaretlenir, 283 gün sonrası otomatik gelir, listede rozet görünür.

**Durum:** ✅ M7.1 kod tamamlandı (cihaz testi bekliyor)
- ✅ M7.1.1 Migration (`2026_05_11_000001_add_pregnancy_fields_to_animals`) — pregnancy_started_at, expected_birth_date, pregnancy_notes. Docker'da apply edildi.
- ✅ M7.1.2 Animal model fillable + casts + `App\Services\Animals\PregnancyService` (gestationDaysFor + calculateBirthDate + markPregnant/markNotPregnant). AnimalProcessor sync fillable güncellendi.
- ✅ M7.1.3 Mobil Drift v3→v4 + sync_mappers (pregnancy_started_at, expected_birth_date, pregnancy_notes 3 alani; addColumn migration).
- ✅ M7.1.4 Mobil form gebelik — `pregnancy_card.dart` `PregnancyCard` widget + bottom sheet (`_PregnancyEditSheet`). Tespit tarihi seçici + otomatik beklenen doğum tarihi (PregnancyHelper). AnimalsRepository.setPregnancy.
- ✅ M7.1.5 Liste rozeti (pregnant_woman ikonu hayvan satırında) + AppBar'da "Yaklaşan dogumlar" badge'li butonu + `upcoming_births_screen.dart`.
- ✅ M7.1.6 Web hayvan detayında `Gebelik` UCard (sadece female): beklenen dogum, tespit tarihi, not. Read-only — gebelik bilgisi mobilden eklenir.

**Cihaz testi (Windows):**
1. Git pull + flutter run.
2. Bir disi sigir/koyun detayina gir → "Gebe isaretle" → tarih sec → otomatik beklenen dogum tarihi gozukmeli (sigir +283, koyun +150 gun).
3. Sync → listede 🤰 ikonu cikmali.
4. AppBar'da "Yaklasan dogumlar" badge'i (30 gun icinde olanlar varsa).
5. Web'de hayvan detayinda Gebelik kartinda ayni bilgi.

---

### M7.2 — QR etiket PDF

**Amaç:** Her hayvan için QR kodlu PDF etiket — küpe numarası + temel bilgiler. Veteriner çiftçiye verir, çiftçi telefonla okuturken portal sayfasına gider.

**Adımlar:**
1. **M7.2.1** Backend `endroid/qr-code` paketi (composer).
2. **M7.2.2** Endpoint `GET /api/v1/animals/{id}/qr.pdf` — Blade view + dompdf.
3. **M7.2.3** Web hayvan detayında "QR PDF indir" butonu.
4. **M7.2.4** Mobil hayvan detayında "QR PDF indir" + `open_filex`.
5. **M7.2.5** QR içeriği: `https://vetrota.com.tr/animal/{ear_tag}` (placeholder URL — public hayvan sayfası sonra).

**Bitti kriteri:** Boncuk'un QR PDF'i tarayıcıdan/mobilden indirilir, QR okutulunca placeholder URL açılır.

**Durum:** ✅ M7.2 kod tamam (cihaz/tarayıcı testi bekliyor)
- ✅ M7.2.1 `endroid/qr-code` ^6.1 composer'a eklendi.
- ✅ M7.2.2 `AnimalQrController` + `reports.animal_qr` blade (A6, DejaVu Sans, QR base64 inline). Route: `GET /api/v1/animals/{animal}/qr.pdf`.
- ✅ M7.2.3 Web hayvan detayında "QR PDF" butonu (Bearer auth ile fetch, blob → indir).
- ✅ M7.2.4 Mobil hayvan detayı AppBar'da QR ikonu + `ReportsRepository.fetchAnimalQrPdf` + `open_filex`.
- ✅ M7.2.5 QR içeriği: `{SMS_PORTAL_BASE_URL}/animal/{ear_tag}` (placeholder).

**Cihaz/tarayıcı testi:**
- Web: `/animals/{id}` → QR PDF butonu → dosya iner, açınca QR + küpe + ad gözükmeli.
- Mobil: hayvan detay → AppBar'daki QR ikonu → PDF iner ve `open_filex` ile açılır.

---

### M7.3 — Borç/ödeme

**Amaç:** Her muayenede `service_fee` çiftçinin balance'ından düşer; ödeme alındıkça eklenir. Veteriner gün sonu kim ne kadar borçlu görür.

**Veri:** `farmers.balance` zaten var (negatif = borç). Yeni tablo:
- `payments` (id, farmer_id, amount, paid_at, method, notes, clinic_id, vet_id, sync columns).

**Adımlar:**
1. **M7.3.1** Backend migration: `payments` tablosu.
2. **M7.3.2** Backend Payment model + observer (insert sonrası farmer.balance += amount).
3. **M7.3.3** Backend medical_record observer: insert sonrası farmer.balance -= service_fee. M6/M5'te bu trigger yoktu — yeni borç MR'la birlikte oluşacak.
4. **M7.3.4** Backend REST endpoints: GET /payments, POST /payments, GET /farmers/{id}/ledger.
5. **M7.3.5** Sync: `payments` tablosu push/pull listesinde.
6. **M7.3.6** Mobil Drift Payments tablosu + mapper + repo.
7. **M7.3.7** Mobil çiftçi detayında ödeme alma butonu + ledger sekmesi.
8. **M7.3.8** Web çiftçi detayında bakiye + ledger + ödeme kaydet.

**Bitti kriteri:** Boncuk muayene → fee 200 TL → Mehmet balance -200. Mobil "Ödeme al 100" → balance -100. Web'de ledger görünür.

**Durum:** ✅ M7.3 kod tamamlandı (cihaz/tarayıcı testi bekliyor)
- ✅ M7.3.1 Migration `2026_05_11_000002_create_payments_table` (ledger + sync kolonları + last_modified_at trigger).
- ✅ M7.3.2 Payment model + PaymentObserver (created/updated/deleted/restored hep `farmers.balance += delta`).
- ✅ M7.3.3 MedicalRecordBalanceObserver: MR oluşunca `farmers.balance -= service_fee`. AppServiceProvider'da register edildi.
- ✅ M7.3.4 PaymentController (index + store) + route'lar.
- ✅ M7.3.5 PaymentProcessor sync push'a kayıtlı, SyncPullService tables listesine eklendi.
- ✅ M7.3.6 Mobil Drift Payments tablosu (schema v5), mapper, PaymentsRepository (offline create + watchByFarmer).
- ✅ M7.3.7 Mobil: `FarmerBalanceCard` hayvan detayında çiftçi bakiyesi + "Ödeme al" bottom sheet (tutar + yöntem + not).
- ✅ M7.3.8 Web: `/farmers/[id]`'de "Ödeme al" toggle formu + Ödeme geçmişi tablosu. Bakiye negatifse kırmızı.

**Test akışı:**
1. Boncuk için 100 TL ücretli muayene oluştur (mobilden veya web).
2. Sync → Mehmet'in bakiyesi -100 TL gözükmeli (web çiftçi detayı).
3. Web "Ödeme al" → 50 TL nakit → bakiye -50 TL.
4. Mobil hayvan detayında FarmerBalanceCard "Borç: 50.00 TL" yazmalı.
5. Mobilden "Ödeme al" 30 TL → sync sonrası bakiye -20 TL.

---

### M7.4 — Reçete PDF + SMS link

**Amaç:** Muayene sonrası veteriner reçete PDF üretir; SMS ile çiftçiye link gider.

**Veri:** Yeni tablo `prescriptions` (var ya da yeni — kontrol et).

**Adımlar:**
1. **M7.4.1** Backend migration `prescriptions` (yoksa).
2. **M7.4.2** Backend service: medical_record'tan reçete üret (drugs + dosage).
3. **M7.4.3** Backend PDF endpoint + Blade view (DejaVu Sans, vet imza placeholder).
4. **M7.4.4** Reçete oluşturulduğunda otomatik SMS observer → "Reçeteniz: {url}".
5. **M7.4.5** Mobil muayene formunda "Reçete oluştur ve gönder" butonu.

**Bitti kriteri:** Muayene + 2 ilaç → reçete oluştur → SMS log'a düşer → URL ile PDF açılır.

**Durum:** ✅ M7.4 kod tamamlandı (migration + cihaz/tarayıcı testi bekliyor)
- ✅ M7.4.1 Migration `2026_05_13_000001_create_prescriptions_table` — id, clinic_id, medical_record_id, farmer_id, animal_id, vet_id, prescription_number (unique), notes, portal_token_id, sms_sent_at, soft delete.
- ✅ M7.4.2 `App\Services\Prescriptions\PrescriptionService::createFromMedicalRecord($mr, $notes)` — RX-YYMMDD-XXXX numara üretir, ilaç listesi medical_record_drugs üzerinden okunur.
- ✅ M7.4.3 `PrescriptionController` (store + pdf + publicPdf), Blade view `reports.prescription` (DejaVu Sans, A4, brand renk, vet imza placeholder). Routes:
  - `POST /api/v1/prescriptions` (auth)
  - `GET /api/v1/prescriptions/{prescription}/pdf` (auth)
  - `GET /api/v1/prescriptions/public/{token}/pdf` (public, scope=prescription token doğrulanır)
- ✅ M7.4.4 `PrescriptionObserver` — created sonrası TokenService ile prescription-scope portal token üretir, SmsService ile "Receteniz hazir: {portal_base_url}/prescription/{token}" SMS gönderir. AppServiceProvider'da register.
- ✅ M7.4.5 Mobil: `ReportsRepository.createPrescription` + `fetchPrescriptionPdf`. Hayvan detayında her MR satırının trailing'inde `receipt_long` ikonu (sadece localSyncStatus=synced ise aktif) → not dialog'u → POST + PDF indir + open_filex. Çevrimiçi zorunlu.

**Test akışı:**
1. Migration: `docker compose up -d && docker exec vetrota-backend php artisan migrate`.
2. Mobilden bir muayene oluştur (en az 1 ilaç, çiftçinin telefon numarası olsun).
3. Sync → MR yeşil olunca hayvan detayında "Reçete" ikonu aktifleşmeli.
4. İkona tıkla → not gir → "Olustur ve gonder" → PDF indir, açıl.
5. Backend: `sms_messages` tablosunda trigger_type='prescription' satırı; LogSmsSender driver ise `storage/logs/laravel.log`'da SMS gövdesi.
6. SMS'teki URL'i tarayıcıda aç → `/api/v1/prescriptions/public/{token}/pdf` PDF döndürmeli.

---

### M7.5 — Sürü işlemi (toplu)

**Amaç:** Veteriner aynı çiftçinin 50 koyununa tek tıkla aynı aşı/işlemi uygular.

**Adımlar:**
1. **M7.5.1** Mobil hayvanlar listesinde multi-select mode (long-press → checkbox).
2. **M7.5.2** Seçim sonrası action bar: "Toplu aşı", "Toplu muayene".
3. **M7.5.3** Toplu aşı bottom sheet: drug seç + miktar → her hayvana ayrı MR oluştur, stoktan toplam düşür.
4. **M7.5.4** Filtre: aynı çiftçi / aynı tür kısıtı.
5. **M7.5.5** Progress: 50 hayvan üzerinde işlem batch göstergesi.

**Bitti kriteri:** Mehmet'in 5 hayvanı seçilir → toplu aşı → 5 MR + 5 stok hareketi oluşur.

**Durum:** ⏳ Bekliyor

---

### M7.6 — Hastalık haritası

**Amaç:** Klinik sahibi web'de köy bazlı semptom yoğunluğunu görür (örn. "şap son 30 günde Karaçam'da 12 vaka").

**Adımlar:**
1. **M7.6.1** Backend: `chief_complaint` veya `symptoms` üzerinde basit kategori (öncelik: enum yok, free text). MVP: sadece sayım.
2. **M7.6.2** Endpoint `GET /api/v1/analytics/disease-map?from=&to=` → village bazlı MR sayısı + en sık 3 keyword.
3. **M7.6.3** Web Nuxt'ta harita sayfası: Leaflet + village marker + radius=count.
4. **M7.6.4** Filtre: tarih aralığı + tür.

**Bitti kriteri:** Son 30 gün yoğunluk haritası tıklanabilir köy marker'ları ile açılır.

**Durum:** ⏳ Bekliyor

---

## Genel Notlar

- Her faz biter biter bu dosya güncellenir + commit.
- Atomik check-point: faz commit'i tek tek atılır, faz adı commit başlığında.
- Migration geri döndürme YOK; yeni migration ile düzeltilir.
- Mobil schema versiyonu her gerektiren faz için artırılır (v3 şu an → v4 M7.1 sonrası).

---

**Doküman Sonu.**
