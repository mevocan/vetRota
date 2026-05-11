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

**Durum:** ⏳ Bekliyor

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

**Durum:** ⏳ Bekliyor

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

**Durum:** ⏳ Bekliyor

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

**Durum:** ⏳ Bekliyor

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
