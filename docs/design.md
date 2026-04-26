# VetRota — Tasarım Brifi

> **Amaç:** M2'ye girmeden önce ürünün görsel ve etkileşim tasarımı için
> ortak referansı oluşturmak. Bu doküman *brief*'tir — kararlar verildikçe
> aynı dosya hi-fi mockup'lar, component özellikleri ve ekran akışlarıyla
> zenginleşecek.
>
> **Kaynak:** `proje.md`, `data-model.md`, `plan.md`, `CLAUDE.md`.
> Çelişki olursa bu dosya değil onlar bağlayıcıdır; bu dosya o kararların
> görsel yansımasıdır.

---

## 1. Tasarım Süreci

| Aşama | Çıktı | Nerede |
|---|---|---|
| 1. Brief (bu doküman) | Kapsam, kısıtlar, persona, ekran listesi | Repo |
| 2. Mockup | HTML/CSS Artifacts (claude.ai) veya Figma | Dış araç |
| 3. Onay + ekleme | Mockup linkleri/snapshot bu dokümana | Repo |
| 4. Implementation | Nuxt UI v4 component'leri ile kodlama | M2'de |

Mockup'lar onaylandıktan sonra `docs/design/` altına PNG/HTML kopyaları
düşer; kararlar bu dokümanın "5. Onaylanan Kararlar" bölümüne işlenir.

---

## 2. Personalar ve Cihazlar

| Persona | Cihaz | Bağlam | Önceliği |
|---|---|---|---|
| Ahmet, gezici veteriner | Tablet/telefon (Android) | Köyde, çoğu zaman offline, eldiven/kirli el, dikey kullanım | Hız, büyük dokunma alanı, az tıklama |
| Klinik sahibi/sekreter | Masaüstü (web) | Klinik içi, internet var, klavye | Tablo + filtreleme, toplu işlem |
| Çiftçi | Telefon tarayıcısı (web) | SMS linkinden gelir, login yok | Tek bir hayvanı/raporu okumak |

---

## 3. Marka Kısıtları

Tasarım bu kararları **sorgulamaz**, uygular.

| | Değer |
|---|---|
| Ana renk | `#2E7D32` (orman yeşili) — `vetrota-green-600` |
| Koyu ana | `#1B5E20` — `vetrota-green-700` |
| Uyarı | `#FF9800` |
| Beyaz | `#FFFFFF` |
| Font | DM Sans (web ve mobil) |
| Web component lib | Nuxt UI v4 — sıfırdan div+class değil, önce UButton/UInput/UTable/UCard/UModal/UForm |
| Mobil component | Material 3, `ColorScheme.fromSeed(seedColor: vetrotaGreen)` |
| Ton | Sade, güvenilir, abartı yok. Emoji yok. "Siz" hitabı |
| Dil | Tüm UI metinleri Türkçe |

---

## 4. Tasarlanacak Ekranlar (M2 Kapsamı)

### 4.1 Web Paneli (Nuxt — klinik sahibi/sekreter)

**Layout:**
- Sol sidebar (sabit): logo + ana menü (Hayvanlar, Çiftçiler, Muayeneler, İlaçlar/Stok, Randevular, Raporlar)
- Üst bar: arama, kullanıcı menüsü
- Ana içerik: liste/detay/form

**Ekranlar:**
1. **Dashboard** — bugünkü randevular, düşük stok uyarıları, son muayeneler özeti
2. **Hayvan listesi** — filtre (köy, çiftçi, tür), tablo, satır → detaya
3. **Hayvan detayı** — kimlik kartı + sekmeler (Geçmiş muayeneler, Aşılar, Reçeteler, Fotoğraflar)
4. **Hayvan formu** — yeni/düzenle (tek kolon, validation, kaydet/iptal)
5. **Çiftçi listesi + detayı + formu** — aynı pattern
6. **Muayene listesi + detayı + formu** — aynı pattern; muayene formu hayvan seçimi + bulgular + tedavi
7. **İlaç/stok listesi** — düşük stok kırmızı ile, hareket geçmişi sekmesi
8. **Randevu listesi** — gün/hafta görünümü

### 4.2 Mobil (Flutter — gezici veteriner, **offline-first**)

**Ana akış:**
1. **Giriş** (✅ M1'de yapıldı)
2. **Bugünün rotası** — köy bazlı gruplanmış randevu listesi (M5'te optimize edilecek, M2'de basit liste yeter)
3. **Köy detayı / hayvan listesi** — bu köydeki hayvanlar
4. **Hayvan detayı** — minimal kimlik + son muayene + "Yeni muayene" butonu
5. **Yeni muayene formu** — bulgu, tanı, ilaç verme. **Offline çalışır**, sync queue'ya düşer
6. **Senkronizasyon durumu** — header'da küçük bir indikatör + ayrı bir "bekleyen değişiklikler" sayfası

**Kritik UX kuralları:**
- Hiç loading spinner ile ağ bekleme — önce yerel veri, ağ sonradan
- Offline'da yazılan kayıtlar UI'da `Taslak #ABC123` gibi gösterilir, sync sonrası gerçek numara ile değişir
- Dokunma hedefleri minimum 48dp
- Her listede çekerek yenile değil, otomatik gri bar + son sync zamanı

### 4.3 Çiftçi Portalı (Web — SMS linkinden)

- Tek sayfa, login yok, sadece okuma
- URL: `vetrota.com.tr/farmer/[token]`
- Hayvanın: kimlik, son muayene özeti, aşı tarihleri, varsa reçete linki
- M6'da detaylanacak; M2'de yer ayrılması yeterli

---

## 5. Onaylanan Kararlar

> Format: tarih + karar + gerekçe + mockup referansı.

### 2026-04-26 — v1 baseline kabul edildi

**Mockup:** `docs/design/mockup-v1.html` (claude.ai Artifacts çıktısı, tek
dosya, web 5 ekran + mobil 4 ekran). Implementation sırasında bu dosya
**görsel referanstır**, kod ile birebir eşleşmeyen yerlerde mockup
güncellenir, koda özel "doğaçlama" yapılmaz.

**Web paneli kararları:**
- **Layout:** Sol sidebar (224px, beyaz arka plan, üstte logo + nav,
  altta kullanıcı kartı) + 52px topbar (sayfa başlığı + arama) + ana
  içerik (gri `#F4F6F8` arka plan)
- **Aktif menü vurgusu:** açık yeşil `#E8F5E9` zemin + `#2E7D32` yazı
- **Kartlar:** beyaz, `1px solid #E5E7EB`, 8px border-radius, 18px iç
  boşluk
- **Tablo:** sticky thead, gri arka plan, 11px uppercase başlıklar;
  düşük stok satırları sarı (`#FFFDE7`), kritik kırmızı (`#FFF1F2`)
- **Buton:** `btn-primary` ana renk dolgu / `btn-ghost` beyaz + gri
  border; hepsi 6px radius, DM Sans 500
- **Form:** tek kolon, 16px arası, label üstte 12.5px, error inline
  altta 11.5px kırmızı; iki kolon gerekirse `form-row` grid
- **Filtre paneli:** liste sayfalarında 192px sol panel (sidebar'ın
  yanında), checkbox grupları
- **Boş durum:** ortada küçük ikon + 1 satır açıklama + ana aksiyon
  butonu
- **Sayfalama:** sağ alt, 28px kare butonlar, aktif sayfa ana renk
- **Hayvan kimlik kartı:** büyük monospace küpe no + alt satırda meta
  bilgiler (cinsiyet, yaş, çiftçi, köy)

**Mobil kararları:**
- **Üst:** AppBar başlığı + sağda **sync indikatörü** (yeşil nokta =
  Senkron, sarı = "N taslak")
- **Hero alanı:** ana renk dolgu blok, beyaz büyük metin (örn. "12
  hayvan · 4 köy")
- **Köy/hayvan kartı:** beyaz, ikon + isim + alt satır + sayı; 16px
  iç boşluk
- **Bottom nav:** 4 sekme (Rota / Hayvanlar / Randevular / Profil),
  aktif sekme ana renk
- **Yeni muayene:** sticky FAB en altta tam genişlik, 56dp yükseklik,
  ana renk
- **Taslak rozeti:** offline kayıtlar `#TASLAK-ABC123` formatında,
  sarı arka plan + koyu turuncu yazı
- **Senkron sayfası:** kaç değişiklik bekliyor, son sync zamanı,
  "Şimdi senkronla" butonu (offline'da disabled görsel)

**İmplementation eşleşmesi (Nuxt UI v4):**
- Sidebar → `UDashboardSidebar`
- Topbar → `UDashboardNavbar`
- Tablolar → `UTable` (filtreleme + sayfalama prop'ları)
- Formlar → `UForm` + `UFormField` + `UInput`/`USelect`/`UTextarea`
- Kartlar → `UCard`
- Butonlar → `UButton color="primary"` / `UButton variant="ghost"`
- Boş durum → `UCard` içinde özel layout (Nuxt UI'da hazır
  `EmptyState` component'i yoksa kompoze edilir)

---

## 6. Kapsam Dışı

Tasarım brifinde **ele alınmayacak** konular:

- M3+ ekranları (fotoğraf, rota optimizasyonu, sürü işlemi, hastalık haritası, analitik panel) — kendi milestone'larında tasarlanır
- Karanlık tema (sonra)
- Çoklu dil (sadece Türkçe)
- İllüstrasyon/karakter tasarımı (yok, sade ikon)
- Özel font yükleme stratejisi (DM Sans Google Fonts üzerinden, optimize sonra)

---

## 7. Deliverable Beklentisi

Her ekran için:
- **Layout** — ana bölgeler ve hiyerarşi
- **Boş durum** (empty state)
- **Yükleme durumu** (web için skeleton, mobilde kullanılmaz — offline-first kuralı)
- **Hata durumu**
- **Form için validation görünümü** (inline veya alert)

Format tercihi sırasıyla:
1. claude.ai Artifacts → tek HTML dosyası, tüm ekranlar yan yana, gerçek `#2E7D32` + DM Sans ile
2. Figma frame
3. Çizim/elle braslama (en azından akışı netleştirmek için yeterli)
