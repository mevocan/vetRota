# Aban, Bunları Test Etmen Lazım

> Bu doküman, kod yazılmış ama **gerçek koşullarda doğrulanmamış** veya
> **bilerek "fake" tutulmuş** her şeyin merkezi listesidir. PHPUnit yeşil
> olması veya `curl` 200 dönmesi yeterli değildir — bu doküman
> "sahada/cihazda/tarayıcıda gerçekten denedin mi?" sorusunun cevabıdır.
>
> **Renk kodu:**
> - 🔴 **Kritik** — sahada/prod'da patlama riski yüksek; mutlaka test
> - 🟡 **Orta** — yazıldı, mantıken doğru ama kullanıcı UX'i belirsiz
> - 🟢 **Düşük risk** — sadece formalite testi
>
> Tarih: 2026-05-08 itibariyle. Yeni iş yapıldıkça güncellenmeli.

---

## 1. SMS Gönderimi — "Fake" (Bilerek)

### 🟡 1.1 LogSmsSender — gerçek SMS atmıyor

**Ne yapıldı:** `app/Sms/Drivers/LogSmsSender.php` içinde `Log::info(...)`
çağrısı var. SMS gövdesi `storage/logs/laravel.log`'a düşer; çiftçinin
telefonuna **hiçbir şey gitmiyor**.

**Neden böyle:** MVP'de gerçek SMS göndermek (a) ücretli, (b) test sırasında
çiftçileri spam'lar, (c) provider entegrasyonu sonradan eklenebilir.

**Eksik olan:**
- Gerçek bir SMS sağlayıcısı (NetGSM, İletimerkezi, Twilio vs.) entegre değil
- `config/sms.php`'de `drivers.netgsm` blok yorumda
- `SmsServiceProvider::register`'da sadece `'log'` case'i var
- `.env.example`'da `NETGSM_USERNAME` gibi bir alan yok

**Test/aktivasyon zamanı (M8 deploy öncesi):**
1. NetGSM hesabı al (Türkiye için), header bilgilerini öğren
2. `app/Sms/Drivers/NetGsmSmsSender.php` yaz (~50 satır, `implements SmsSender`)
3. `config/sms.php`'deki yorumlu blok aktifleştir
4. `SmsServiceProvider`'a `'netgsm' => new NetGsmSmsSender(...)` case'i ekle
5. `.env`'e `SMS_DRIVER=netgsm` + credentials
6. Tek bir test numarasına gerçek SMS at, `sms_messages.status=sent` ve
   gerçekten cep telefonu çaldı mı kontrol et
7. Idempotency test: aynı randevuyu iki kez observer ile dispatch et,
   ikinci SMS gitmediğinden emin ol (sms_messages lookup)

**Kontrol komutları:**
```bash
docker compose exec backend php artisan tinker --execute="
echo config('sms.default') . PHP_EOL;
echo get_class(app(\App\Sms\Contracts\SmsSender::class)) . PHP_EOL;
"
```

---

## 2. Mobile (Flutter) — Cihazda Test Edilmedi

### 🔴 2.1 M3.6/11 — Sync sahada (airplane mode) tam smoke

**Ne yapıldı:** Push/pull queue, conflict UI, retry hepsi yazıldı.
M3.6/1-10 cihazda smoke yapıldı (bir kez), ama **kalan 4 senaryo
edge-case'leri** sahada denenmedi:

1. Uçak modu açıkken 5 yeni hayvan + muayene oluştur, sonra netten gel
   → hepsi sync'e alındı mı, conflict yok mu?
2. İki cihaz aynı hayvanı offline güncellesin, sonra birlikte sync olsun
   → LWW kuralı (client kazanır) gerçekten çalışıyor mu?
3. Push sırasında network kop → retry queue dolu kalıyor mu, yeniden
   internet gelince tüketiyor mu?
4. Stok additive merge: iki cihaz aynı ilaca farklı hareketler yazsın,
   sonuç toplam doğru mu?

**Test cihazı:** Android telefon veya emulator + Docker backend.

### 🔴 2.2 M4.7 — Fotoğraflı muayene cihazda

**Ne yapıldı:** image_picker, lokal saklama, multipart upload, fotoğraf
galerisi hepsi yazıldı, `flutter analyze` temiz. Ama **kameradan
fotoğraf çekme + offline'da saklama + online olunca yükleme + galeride
görme** zinciri bir gerçek cihazda yapılmadı.

**Test akışı:**
1. Emulator/cihaz: uçak modu aç
2. Hayvan seç → muayene formu → "Fotoğraf çek" → 2-3 fotoğraf
3. Kaydet → Drift'te `medical_record_photos.upload_status=pending` görmeli
4. Hayvan detayında galeri thumbnail'leri görünmeli (file:// üzerinden)
5. Uçak modu kapat → Sync butonu
6. `storage/app/photos/{clinic}/{animal}/{uuid}.jpg` dosya backend'de var
7. `medical_record_photos.upload_status=uploaded`, `server_storage_path` dolu
8. Galeri'de fotoğraf hâlâ görünüyor (artık `file://` veya backend URL fark etmez)

### 🔴 2.3 M5.9 — Bugünün randevuları + harita + optimize + rapor

**Ne yapıldı:** `AppointmentsTodayScreen` (liste/harita toggle),
`route_optimizer.dart` (nearest-neighbor + Haversine + unit test),
optimize butonu, randevu detay sheet, "Tamamla + muayene", PDF rapor
indirme — hepsi yazıldı, `flutter analyze` temiz.

**`M5SmokeSeeder` hazır** (5 köy lat/lng + 5 randevu bugüne).

**Test akışı:**
1. Backend'de `php artisan db:seed --class=M5SmokeSeeder`
2. Flutter'da Sync butonuna bas → 5 randevu çekilmeli
3. AppBar'da takvim ikonu (📅) → "Bugünün randevuları" sayfası
4. **Liste** sekmesinde 5 randevu (saat sıralı), her birinde 📍 ikonu olmalı
   (lat/lng var)
5. **Harita** sekmesinde OSM tile + 5 yeşil pin görünmeli
6. FAB **"Rotayı optimize et"** → numaralı pin (1-2-3-4-5) + yeşil polyline
7. Bir randevuya tap → bottom sheet → **"Tamamla + muayene"** → MR formu
   açılmalı, animal pre-fill olmalı
8. Tamamlandıktan sonra liste'de o randevu üstü çizili + gri görünmeli
9. AppBar'da PDF ikonu (📄) → backend'den ~1.5MB PDF iner, `open_filex`
   ile dosya görüntüleyici açılmalı

**Bilinen risk:** "Optimize başlangıç noktası" şu an MVP'de **ilk randevunun
konumu** alınıyor (manuel pin / mevcut konum / klinik seçeneği yok).
Sonradan eklenmesi gereken UX kararı.

### 🟢 2.4 Mobile'da `vaccine_schedules` Drift tablosu yok — bilinçli erteleme

**Durum (2026-05-11):** Aktif bug yok. Mobil `/sync/pull` çağrısında
`tables` parametresine kendi curated listesini gönderiyor
(`mobile/lib/data/sync/sync_repository.dart:69`, `_tables`); bu listede
`vaccine_schedules` yok, dolayısıyla backend bu tabloyu mobile'a hiç
döndürmüyor. 500 riski yok.

**Karar:** Mobile'da aşı planı görüntüleme/yönetimi **M7+'a ertelendi**.
MVP'de aşı planı web panelden (`/animals/[id]/vaccinations`) yönetilir,
zamanlayıcı SMS'i çiftçiye gider. Veterinerin sahada plan oluşturması
gerektiği gün gelirse Drift tablosu + mapper + ekran eklenir (~1-2 saat).

---

## 3. Web (Nuxt) — Tarayıcıda Test Edilmedi

### 🔴 3.1 Çiftçi portal sayfası `/farmer/[token]`

**Ne yapıldı:** `web/app/pages/farmer/[token].vue`,
`definePageMeta({ layout: false })`, public middleware, 410 ekranı,
hayvan kart listesi, son muayene, yaklaşan aşı.

Backend endpoint `curl` ile test edildi (200 + tam JSON, 410 enum-safe).
**Ama Nuxt SSR olarak gerçek tarayıcıda açılmadı.**

**Test akışı:**
1. `docker compose up -d web` (Nuxt container'ı ayağa kalksın)
2. Backend'de geçerli token üret:
   ```bash
   docker compose exec backend php artisan tinker --execute="
   \$f = \App\Models\Farmer::first();
   echo app(\App\Services\FarmerPortal\TokenService::class)->issue(\$f, 'general')['raw'];
   "
   ```
3. Tarayıcıda `http://localhost:3000/farmer/{raw}` aç
4. Görmen gereken:
   - Klinik adı + bölge başlık
   - "Sayın {ad} {soyad}" satırı
   - Yaklaşan aşılar varsa turuncu kart
   - Hayvan kartları (UCard'lar) — her birinde son 5 muayene
   - Sayfa altında "Bu sayfa SMS ile gönderilen özel bağlantı..." dipnotu
5. **Geçersiz token testi:** `http://localhost:3000/farmer/InvalidXXXXX` →
   "Bu link süresi geçmiş" ekranı, 410 mesajı

**Bilinen risk:** SSR'de `useFetch` error handling'i Nuxt sürümüne göre
`error.value.statusCode` veya `error.value.status` olabilir; 410 algılaması
çalışmazsa kart "Bir hata oluştu" gösterir, "süresi geçmiş" göstermez.
İlk gerçek testte bu davranışı kontrol et.

### 🔴 3.2 Aşı planları sayfası `/animals/[id]/vaccinations`

**Ne yapıldı:** Liste (UCard), yeni plan formu (USelect + UInput date),
"Devre dışı bırak" aksiyonu. Backend CRUD endpoint hazır.

**Tarayıcıda hiç açılmadı.**

**Test akışı:**
1. Login → bir hayvan detayına gir
2. URL'i manuel `vaccinations` ekle: `/animals/{id}/vaccinations`
   *(Şu an `[id].vue`'da bu sayfaya link yok — ya ekle ya da URL elle yaz)*
3. **"Yeni plan"** → form açılır, USelect'te sadece `is_vaccine=true`
   ilaçlar listelenmeli
4. Tarih seç, kaydet → toast "Aşı planı eklendi" → liste yenilenmeli
5. Plan kartında "Sonraki: ..., her N günde bir, M gün önce hatırlatma"
6. 🗑️ ikonu → confirm dialog → DELETE → "Devre dışı" rozetli görünmeli

**Eksik:** `animals/[id].vue` detay sayfasında bu alt-sayfaya **link/sekme yok**.
URL'i bilmek gerekiyor. Sonradan tab/section eklenebilir.

### 🟡 3.3 Auth middleware public path mantığı

**Ne yapıldı:** `auth.global.ts`'ye `/farmer/` prefix'i eklendi:
```ts
const PUBLIC_PREFIXES = ['/farmer/']
```

**Test:**
1. Çıkış yap (auth state temiz)
2. `/farmer/{token}` açıl → login'e yönlendirmemeli
3. `/animals` açıl → login'e yönlendirmeli (regression)

---

## 4. Aşı Hatırlatma Scheduler — Ortam Bağımlı

### 🟡 4.1 `vaccinations:scan` günlük cron

**Ne yapıldı:** `routes/console.php`'de:
```php
Schedule::command('vaccinations:scan')
    ->dailyAt('08:00')->timezone('Europe/Istanbul')
    ->onOneServer()->withoutOverlapping();
```

**Eksik olan (prod):**
1. **Sistem cron** kurulu değil — Hetzner deploy zamanı `crontab -e`'ye
   şunu eklemen lazım:
   ```
   * * * * * cd /path/to/backend && php artisan schedule:run >> /dev/null 2>&1
   ```
   Bu satır olmadan Laravel scheduler hiç çalışmaz.
2. **Queue worker** sürekli çalışmıyor — şu an `queue:work --once` ile
   manuel tüketiyoruz. Prod'da systemd unit veya supervisor:
   ```
   php artisan queue:work --tries=3 --timeout=60
   ```
3. **Timezone:** Sunucu UTC ise `Europe/Istanbul`'a göre 08:00 yerel,
   doğru çalışıyor — ama prod'da bir kez sabah 08:00'i bekleyip log'da
   `VaccinationsScan` satırını görmen lazım.

**Test (lokal):**
```bash
# Manuel tetikle (cron yok)
docker compose exec backend php artisan vaccinations:scan
docker compose exec backend php artisan queue:work --once
```

**Test (prod yaklaştığında):**
- 08:00'a 5 dk kala bir test schedule oluştur, gerçekten çalıştı mı bak
- `--dry-run` flag'i ile sadece raporla, SMS atma

---

## 5. Açık Tasarım Kararları

### 🟡 5.1 AnimalObserver — deceased cascade

**data-model.md'de:** "animals.status='deceased' olunca ilgili tüm
vaccine_schedules.is_active=false yapılır."

**Ne eksik:** `AnimalObserver` yazılmadı. Bir hayvan ölü işaretlenirse
aşı planları aktif kalmaya devam ediyor → boşuna SMS gider.

**M7'ye ertelendi.**

### 🟡 5.2 Çiftçi portal'a giriş kapısı yok

Çiftçi sadece SMS link'i ile gelebilir. **"Linkim yandı/bulamıyorum"**
durumu için kapıdan giriş yok (telefon doğrulama vb.). MVP'de SMS
stratejisi bu — kullanıcı kabul etmiş gibi gözüküyor ama sahada şikayet
gelebilir.

### 🟡 5.3 SMS opt-out mekanizması

`farmers.sms_notifications_enabled` alanı var, observer kontrol ediyor.
**Ama:** çiftçi "STOP" SMS atınca otomatik off olmuyor. Veteriner manuel
toggle'lamak zorunda. KVKK ve KKB şikayetlerine karşı **sahada** bu
gerekli olabilir, sonradan eklenmeli.

### 🟡 5.4 Token URL'i — production base URL

`.env` `SMS_PORTAL_BASE_URL=http://localhost:3000` şu an. Prod'a
geçerken `https://vetrota.com.tr` olmalı, **yoksa SMS link'leri kırık**.

---

## 6. Çift Çalışma Ortamı — WSL ↔ Windows

**Mevcut kurulum:**
- WSL `~/projects/vetrota` → backend tarafı (Docker burada çalışır)
- Windows `C:\Users\mc.dag\projects\vetrota` → Flutter tarafı (Android Studio/build burada çalışır)
- İki ayrı git clone, aynı remote (`mevocan/vetRota`)

**Risk:** İki yerde aynı dosyayı düzenlersen merge conflict çıkar. Şu an
dosya bazında ayrılma var (backend WSL'de, mobile Windows'ta) ama
özellikle `docs/` her iki tarafta dokunulabilir.

**Disiplin:**
- Backend/web → WSL'de düzenle, commit, push
- Mobile (Flutter) → Windows'ta düzenle, commit, push
- Doküman değişikliği → bittiği yerde push et, diğer tarafta `git pull`
- Her oturuma başlarken **iki tarafta da `git pull origin main`** çek

---

## 7. Hızlı Doğrulama Komutları

### Backend (Docker)
```bash
# Ayağa kaldır
docker compose up -d postgres backend

# Tüm migration + seed
docker compose exec backend php artisan migrate:fresh --seed
docker compose exec backend php artisan db:seed --class=M5SmokeSeeder
docker compose exec backend php artisan db:seed --class=M6SmokeSeeder

# SMS akışı (full)
docker compose exec backend php artisan tinker --execute="
\$f = \App\Models\Farmer::where('phone','5559990001')->first();
\$a = \App\Models\Animal::where('farmer_id', \$f->id)->first();
\App\Models\Appointment::create([
  'clinic_id' => \$f->clinic_id, 'farmer_id' => \$f->id,
  'animal_id' => \$a?->id, 'vet_id' => 1, 'village_id' => \$f->village_id,
  'scheduled_at' => now()->addDay(),
  'estimated_duration_minutes' => 30, 'appointment_type' => 'follow_up',
  'reason' => 'test', 'status' => 'planned',
]);
"
docker compose exec backend php artisan queue:work --once
docker compose exec backend grep "SMS gonderildi" storage/logs/laravel.log

# Aşı tarayıcı
docker compose exec backend php artisan vaccinations:scan
docker compose exec backend php artisan queue:work --once

# Test suite
docker compose exec backend php artisan test
```

### Web (Nuxt)
```bash
docker compose up -d web
# veya lokal: cd web && npm run dev

# Tarayıcıda:
# http://localhost:3000/login
# http://localhost:3000/animals/{id}/vaccinations
# http://localhost:3000/farmer/{raw_token}
```

### Mobile (Flutter)
```bash
# Windows tarafında:
cd C:\Users\mc.dag\projects\vetrota\mobile
flutter pub get
flutter analyze    # temiz olmalı
flutter test       # route_optimizer_test.dart geçmeli
flutter run        # cihaz/emulator
```

---

## 8. Bu Doküman Ne Zaman Silinir

Her başlığın yanındaki risk işareti 🟢'ye dönüştüğünde **veya** o iş
başka bir milestone'a taşındığında bu satırı sil. Her oturum başında
hızlıca üzerinden geç — "bugün gerçekten test ettiklerim hangileri?"

**Dokümanın kendisi de bir TODO** — silmek hedeftir.

---

**Doküman Sonu.**
