# CLAUDE.md

Bu dosya, VetRota repository'sinde çalışan Claude Code (ve diğer Claude
agent'ları) için kalıcı context sağlar. Her oturumda otomatik okunur.

---

## 1. Ürün Özeti

**VetRota**, kırsalda çalışan gezici veterinerler için geliştirilen
**offline-first** bir saha yönetim platformudur. Ana persona (Ahmet, 38)
günde 10-15 köyü dolaşan bir klinik sahibidir; köylerde internet çekmediği
için telefonunu/tabletini internetsiz kullanmak zorundadır.

Platform üç kullanıcıya hizmet eder:
1. **Gezici veteriner** (ana kullanıcı) — mobil, offline-first
2. **Klinik sahibi / sekreter** — web paneli
3. **Çiftçi** — SMS linkiyle şifresiz portal sayfası (`/farmer/[token]`)

---

## 2. Teknik Stack (Değişmez Kararlar)

Bu kararlar önceden verilmiştir; Claude Code bunları **sorgulamaz**, alternatif
önermez, olduğu gibi uygular.

| Katman | Teknoloji |
|---|---|
| Backend dil | PHP 8.4 |
| Backend framework | Laravel 13 |
| Veritabanı | PostgreSQL 18 |
| Web frontend | Nuxt 4 + TypeScript |
| CSS | Tailwind CSS |
| State management | Pinia |
| Mobil | Flutter 3.41 (Dart 3.11) |
| Yerel DB (mobil) | Drift (SQLite tabanlı) |
| API stili | RESTful |
| Auth | JWT (refresh token rotation) |
| DevOps | Docker + Docker Compose |
| Repo hosting | GitHub |
| Production hosting | Hetzner |

**Kod konvansiyonları:**
- Laravel 13 "slim skeleton" konvansiyonları (Laravel 11'de tanıtılan yapı
  devam ediyor): `bootstrap/app.php` ile middleware register,
  `routes/api.php` manuel registration ile. Laravel 13 PHP 8.3+ gerektirir
  ama PHP 8.4'ün property hooks, asymmetric visibility gibi özelliklerini
  kullanabiliriz.
- Nuxt 4 yeni dizin yapısı: uygulama kodu `app/` altında (pages, layouts,
  components, composables, middleware), server kodu `server/` altında,
  paylaşılan kod `shared/` altında. Tek `tsconfig.json` root'ta.
- PHP: strict types, constructor property promotion, enum kullanımı, PHP 8.4
  property hooks ve asymmetric visibility (uygun yerlerde)
- TypeScript: strict mode, type inference tercih et, gereksiz type
  annotation koyma
- Flutter: Dart 3.11, sound null safety, dot shorthand syntax (`.center`
  gibi), `riverpod` veya `bloc` yerine **state management tercihimi M3'e
  kadar ertele** — Claude Code önerir, kullanıcı karar verir

---

## 3. Temel Mimari Prensip: Offline-First

**En kritik prensip bu.** Kod yazarken Claude Code her zaman şunu sormalı:
"Bu kod veterinerin internet olmadığı ahırda çalışır mı?"

**Kurallar:**

- Hiçbir Flutter ekranı "loading spinner" ile ağ beklemez; önce Drift'ten
  okur, ağ sonradan gelir (background sync).
- ID'ler **her zaman client'ta UUID v4** olarak üretilir — auto-increment
  yok.
- Yazma işlemleri **her zaman önce Drift'e**, sonra sync queue'ya düşer.
- Server-assigned değerler (örn. `prescription_number`, `invoice_number`)
  offline'da UI'da "Taslak #<kısa-UUID>" olarak gösterilir; sync sonrası
  gerçek numara ile değiştirilir.
- Türetilmiş alanlar (örn. `stocks.current_quantity`) offline'da client
  tarafından kendi ledger'ından hesaplanır; sync sonrası server değeri ile
  overwrite edilir.
- Bir özellik internet gerektiriyorsa (örn. SMS gönderimi, PDF üretimi)
  bunu **açıkça belirt**, offline davranışını veya fallback'i tasarla.

**Senkronizasyon felsefesi:**
- Conflict resolution stratejisi **Last-Write-Wins, client kazanır**.
  Veteriner saha kaynağıdır; onun yazdığı kanondur.
- Ledger tabloları (`stock_movements`, `payments`) **hiç silinmez**;
  additive merge ile birleştirilir. Silme istendiğinde ters hareket eklenir.
- Echo prevention: `origin_device_id` sayesinde cihaz kendi yazdığı kaydı
  pull'da geri almaz.

Detay: `docs/sync-api.md`.

---

## 4. Referans Dokümanlar

Claude Code bu dokümanlara **her yeni özellik öncesi** bakmalıdır. Çelişki
durumunda doküman önce, kod sonra — önce dokümanı güncelle, sonra kod yaz.

| Dosya | İçerik | Ne zaman oku |
|---|---|---|
| `docs/proje.md` | Ürün tanımı, paketleme, marka kimliği | Yeni özellik tasarlarken |
| `docs/plan.md` | Milestone'lar, bağımlılık grafiği, kritik yol | Hangi milestone'dayız? Sıradaki ne? |
| `docs/data-model.md` | PostgreSQL şeması, 32 tablo, conflict stratejileri | DB ile ilgili her şey |
| `docs/sync-api.md` | M3 sync protokolü, Laravel iskeleti | Offline/sync ile ilgili her şey |
| `CLAUDE.md` | Bu dosya, genel tutum ve kısıtlar | Her oturum başı |

**Önemli:** `docs/` altındaki dosyalar **tasarım kararlarının kaynağıdır**.
Claude Code bu dosyaları kullanıcının onayı olmadan değiştirmez; sadece okur.
Kod yazdıkça ortaya çıkan yeni kararlar olursa, kullanıcıya "bunu dokümana
ekleyeyim mi?" diye sorar.

---

## 5. Marka ve Lokalizasyon

**Dil:**
- Tüm kullanıcı metinleri **Türkçe** (hata mesajları, form label'ları, SMS
  template'leri, e-postalar).
- Kod yorumları **Türkçe** tercih edilir ama İngilizce de kabul.
- Commit mesajları **Türkçe**, imperative mood ("Hayvan modeli eklendi"
  değil "Hayvan modeli ekle" şeklinde).
- Değişken/fonksiyon isimleri **İngilizce** (`animal`, `medicalRecord`).
- Veritabanı kolon isimleri **İngilizce**, snake_case.

**Renkler:**
- Ana: `#2E7D32` (orman yeşili)
- Koyu ana: `#1B5E20`
- Uyarı: `#FF9800`
- Beyaz: `#FFFFFF`

**Font:** DM Sans (web ve mobil).

**Ton:** Güvenilir, sade, sahada işe yarayan. Emoji kullanma. Abartılı
pazarlama dili yok. UX metninde çiftçi ve veteriner **"siz"** diye hitap
edilir, **"sen" değil**.

**Pazar:** Türkiye. Regülasyonlar geçerli:
- **KVKK** (Kişisel Verileri Koruma Kanunu)
- **E-fatura** (alanlar `invoices` tablosunda hazır, M8 sonrası entegrasyon)
- **TARKS** (Tarım Kayıt Sistemi — `animals.national_id` alanı ayrıldı)

---

## 6. Claude Code İçin Kurallar

### 6.1 Kod kalitesi

- **MVP düzeyi yeterli.** Production-ready olma zorunluluğu yok. Kullanıcı
  iteratif çalışıyor; "önce çalışan, sonra güzel" mantığı.
- Aşırı soyutlama yapma (örn. 3 sınıf kullanılacakken "Abstract Factory
  pattern" kurma). Laravel/Nuxt/Flutter framework konvansiyonları yeter.
- Yorum yaz, ama "ne" yaptığını değil "neden" yaptığını. Karmaşık
  iş mantığında neden o yolun seçildiğini açıkla.
- Kendi başına **test yazma kararı alma.** Test istenmedikçe yazma; istenirse
  PHPUnit (Laravel) / Vitest (Nuxt) / `flutter_test` kullan.

### 6.2 Karar verme

- Kararsız olduğun konularda kullanıcıya **2-3 seçenek** sun ve
  artılar/eksileri karşılaştır. Tek bir yol dayatma.
- "Production için X yapmalıyız" gibi cümlelerden kaçın — MVP evresindeyiz.
- Kullanıcının `docs/` altındaki dokümanlarla çelişen bir istek verdiğini
  fark edersen, kodu yazmadan önce çelişkiyi kullanıcıya bildir.

### 6.3 Kapsam dışı konular

Aşağıdaki konular MVP'de **yoktur**. Kullanıcı sorarsa "MVP kapsamı dışı,
sonraya bırakıldı" de.

- Çoklu dil desteği (sadece Türkçe)
- Instagram, Sahibinden gibi 3. parti entegrasyonlar
- WhatsApp Business API (SMS yeterli)
- GIB e-fatura entegrasyonu (alanlar hazır, bağlantı sonra)
- Bakanlığa salgın bildirimi (alan var, API bağlantısı sonra)
- PostGIS / coğrafi sorgular (lat/lng var, şimdilik basit Haversine yeter)
- Push notification (FCM/APNS — token alanı var, M8+)
- Real-time (WebSocket, Pusher vb.) — offline-first ile çelişir, yok

### 6.4 Git ve dosya değişiklikleri

- **Commit atma** — kullanıcı ne zaman commit istiyorsa o zaman at.
- **`docs/` altındaki dosyaları değiştirme.** Değişiklik öner, kullanıcı onaylarsa at.
- `.env` dosyasını asla git'e ekleme; `.env.example` tut.
- Migration dosyalarını **geri döndürme** — yeni migration ile düzelt.
- Secret, token, API key hardcode etme. `.env` + `config/*.php` kullan.

### 6.5 Dependency yönetimi

- Composer paketi eklerken kullanıcıya sor (özellikle ana dependency).
- Ufak utility paketler (`ramsey/uuid` gibi Laravel zaten içinde olanlar)
  için sormaya gerek yok.
- Flutter package'ları için de aynı kural: major dependency (`drift`,
  `dio`, `riverpod`) → sor; küçük utility → at.
- Npm için aynı.

### 6.6 Dosya oluşturma

- Gereksiz README, CHANGELOG, CONTRIBUTING gibi dosyalar **yaratma**.
  Kullanıcı isterse yazarsın.
- Boilerplate dosyaları (Laravel/Nuxt/Flutter'ın otomatik ürettikleri)
  olduğu gibi kullan, gereksiz yere özelleştirme.

---

## 7. Mevcut Durum

**Aktif milestone:** M1 başlamadan önce (planlama fazı bitti)

**Sıradaki iş:** `docs/plan.md` bölüm "M1 — Docker ayağa kalktı, login
çalışıyor".

M1 tamamlandı kriteri:
- `docker compose up` ile Laravel 13 + PostgreSQL 18 + Nuxt 4 çalışıyor
- Veteriner web panelinden login olabiliyor
- JWT dönüyor
- Flutter'da da aynı JWT ile login çalışıyor

Geri kalan milestone'lar için `docs/plan.md`'ye bak.

---

## 8. İletişim Tercihleri

- Cevaplar **Türkçe** olsun.
- Uzun cevap istenmedikçe kısa tut. Gereksiz preamble/özet/tekrar yok.
- Kod bloklarında dil tag'i koy (` ```php`, ` ```dart`, ` ```typescript`).
- Dosya yolları backtick içinde (`app/Services/Sync/SyncPushService.php`).
- Tablo formatını uzun listeler için tercih et — göze hızlı gelir.
- "Mükemmel soru!", "Harika!" gibi yağcılık yok. Düz, sade, saygılı ton.

---

**Doküman Sonu.**
