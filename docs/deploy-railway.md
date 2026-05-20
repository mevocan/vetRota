# Railway Deploy Rehberi

Adım adım Railway üzerinde VetRota'yı yayına alma. Tahmini süre **45-70 dk**.

Sonuçta üç URL'e sahip olacaksınız:
- **Backend API:** `https://vetrota-backend.up.railway.app`
- **Web panel:** `https://vetrota-web.up.railway.app`
- **APK:** mobil cihazda Railway backend URL'ine bakacak şekilde build

---

## 0. Ön Hazırlık (5 dk)

1. https://railway.app açın, GitHub ile giriş yapın
2. **New Project** → **Deploy from GitHub repo** → `vetRota` reposunu seçin
3. Bu rehberi takip edin — her servis için ayrı bir Railway "Service" oluşturacağız

> ℹ️ Railway free trial $5 kredi verir, sonra Hobby plan ~$5/ay. Demo için yeter.

---

## 1. PostgreSQL Servisini Ekle (5 dk)

1. Project ekranında **+ New** → **Database** → **Add PostgreSQL**
2. Birkaç saniyede hazır olur
3. **Variables** sekmesinde şu env'ler oluşur (referans için):
   ```
   PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE, DATABASE_URL
   ```
4. PG18 değil PG16/17 gelebilir — sorun değil, projemiz uyumlu.

---

## 2. Backend Servisini Ekle (15 dk)

### 2.1 Servisi oluştur

1. **+ New** → **GitHub Repo** → aynı repo (`vetRota`)
2. Servis adını: **`vetrota-backend`**
3. **Settings** sekmesi:
   - **Root Directory:** `backend`
   - **Dockerfile Path:** `Dockerfile.prod` (özel prod Dockerfile kullanır)
   - **Build Command:** boş bırak (Dockerfile hallediyor)
   - **Start Command:** boş bırak

### 2.2 Environment Variables (Variables sekmesi)

Şunları **tek tek** ekleyin (en önemlisi yıldızlı olanlar):

```
APP_NAME=VetRota
APP_ENV=production
APP_KEY=                       # ⭐ aşağıda üreteceğiz
APP_DEBUG=false
APP_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
APP_TIMEZONE=Europe/Istanbul

LOG_CHANNEL=stderr
LOG_LEVEL=info

DB_CONNECTION=pgsql
DB_HOST=${{Postgres.PGHOST}}           # ⭐ Postgres servisine referans
DB_PORT=${{Postgres.PGPORT}}
DB_DATABASE=${{Postgres.PGDATABASE}}
DB_USERNAME=${{Postgres.PGUSER}}
DB_PASSWORD=${{Postgres.PGPASSWORD}}

SESSION_DRIVER=database
CACHE_STORE=database
QUEUE_CONNECTION=database

# JWT (vardı zaten)
JWT_SECRET=                    # ⭐ aşağıda üreteceğiz

# Sync için origin device id (server tarafi)
APP_SERVER_DEVICE_ID=railway-prod

# ⭐ İLK DEPLOY için: migrate:fresh + seed çalıştır
# İlk başarılı deploy'dan sonra bu satırı SİL (yoksa her deploy DB'yi sıfırlar!)
SEED_ON_BOOT=1
```

### 2.3 APP_KEY ve JWT_SECRET üret

Lokalde terminal aç:

```bash
# APP_KEY
docker compose exec -T backend php artisan key:generate --show
# Çıktıyı (base64:xxxx) APP_KEY env değerine yapıştır

# JWT_SECRET
docker compose exec -T backend php -r "echo base64_encode(random_bytes(64));"
# Çıktıyı JWT_SECRET env değerine yapıştır
```

### 2.4 Public domain aç

1. **Settings** → **Networking** → **Generate Domain**
2. Üretilen URL'i bir yere not edin: `vetrota-backend-XXXX.up.railway.app`

### 2.5 İlk deploy

1. **Deployments** sekmesinde otomatik build başlamış olmalı
2. Logları izleyin — Composer install + migrate:fresh + seed çalışacak
3. ~3-5 dk sonra ✅ olunca: tarayıcıdan `https://vetrota-backend-XXXX.up.railway.app` aç
4. Laravel hoş geldin sayfası veya 404 görmeli (route yok ama uygulama ayakta)
5. API test: `https://vetrota-backend-XXXX.up.railway.app/api/v1/health` (varsa) veya bir endpoint

### 2.6 ⚠️ SEED_ON_BOOT'u SİL!

İlk deploy başarılı olunca:
- **Variables** → `SEED_ON_BOOT` satırını sil
- Yoksa **her deploy DB'yi sıfırlar.**

---

## 3. Web Servisini Ekle (15 dk)

### 3.1 Servisi oluştur

1. **+ New** → **GitHub Repo** → aynı repo
2. Servis adı: **`vetrota-web`**
3. **Settings**:
   - **Root Directory:** `web`
   - **Dockerfile Path:** `Dockerfile.prod`

### 3.2 Environment Variables

```
NODE_ENV=production
NUXT_PUBLIC_API_BASE=https://vetrota-backend-XXXX.up.railway.app/api/v1
NUXT_API_BASE_SERVER=https://vetrota-backend-XXXX.up.railway.app/api/v1
```

> ⚠️ `vetrota-backend-XXXX.up.railway.app`'i adım 2.4'te aldığınız gerçek URL ile değiştirin.

### 3.3 Domain ve deploy

1. **Settings → Networking → Generate Domain** → not edin
2. Deploy bitince tarayıcıdan açın: `https://vetrota-web-XXXX.up.railway.app`
3. Login: `ahmet@vetrota.com.tr / sifre1234`
4. Hastalık haritası, hayvan listesi vb. çalışmalı

### 3.4 CORS sorunu çıkarsa

Browser console'da `CORS blocked` görürseniz, backend'in `bootstrap/app.php`'sinde
HandleCors middleware'e izin verilen origin eklemek gerekir. Genelde Laravel 11+
default CORS config'i `*` allow eder; problem yoksa atla.

---

## 4. APK Build (10 dk)

Mobil uygulamayı Railway backend URL'sine bakacak şekilde APK'la.

### 4.1 Lokalde Flutter SDK kontrolü

```powershell
flutter --version
flutter doctor
```

### 4.2 Release APK build

```powershell
cd mobile
flutter clean
flutter pub get
flutter build apk --release `
  --dart-define=API_BASE_URL=https://vetrota-backend-XXXX.up.railway.app
```

Çıktı: `mobile/build/app/outputs/flutter-apk/app-release.apk`

### 4.3 APK'yı paylaş

- **WhatsApp / e-posta** ile hocaya gönderin
- veya **Google Drive** linki
- veya hocanın telefonuna USB ile yükleyin
- Hoca telefonundan kuruyor: ayarlar → "bilinmeyen kaynaklara izin ver" → APK'ya tıklayıp install

### 4.4 APK içinde giriş

Hoca demo hesaplarıyla giriş yapabilir:

| Tier | E-posta | Şifre |
|---|---|---|
| Premium (dolu) | `ahmet@vetrota.com.tr` | `sifre1234` |
| Premium (yardımcı) | `ayse@vetrota.com.tr` | `sifre1234` |
| Free (boş) | `demo@vetrota.com.tr` | `sifre1234` |

---

## 5. Doğrulama Listesi

Her şey çalışıyor mu kontrol:

- [ ] `https://vetrota-backend-XXXX.up.railway.app` ayakta
- [ ] `https://vetrota-web-XXXX.up.railway.app` açılıyor
- [ ] Web'de login çalışıyor
- [ ] Web'de hastalık haritası uydu görüntüsü ile geliyor
- [ ] APK telefonda kuruluyor
- [ ] Mobil app login çalışıyor
- [ ] Mobil app hayvan listesi yükleniyor
- [ ] Mobil app **uçak modunda da açılıyor** (offline-first kanıt!)

---

## 6. Sorun Giderme

### Backend 502 / Application failed to respond
- Logları aç (Deployments → en son deploy → Logs)
- Genelde: APP_KEY eksik, DB env'leri yanlış bağlanmış, migrate hata vermiş
- DB ref'lerinin `${{Postgres.PGHOST}}` doğru yazıldığından emin ol

### Web "fetch failed" / "Network error"
- `NUXT_PUBLIC_API_BASE` doğru mu? `/api/v1` ekli mi?
- Backend URL'i tarayıcıdan açılıyor mu?

### Mobil "Connection refused"
- APK build sırasında `--dart-define=API_BASE_URL=` doğru URL'i aldı mı?
- `flutter clean` yapıp yeniden build et

### Her deploy'da veriler siliniyor
- `SEED_ON_BOOT=1` env'i hâlâ duruyor → **sil**

### Postgres bağlantı limiti
- Railway free tier 5 connection sınırı
- Backend bir scale instance ile yetinsin

---

## 7. Üretim İçin Kalan İşler (Bu Demo Sonrası)

- [ ] **Fotoğraf storage**: Cloudflare R2 entegrasyonu (ephemeral disk yerine)
- [ ] **Gerçek SMS sağlayıcı**: NetGSM/İletimerkezi (şu an LogSmsSender)
- [ ] **Custom domain**: vetrota.com.tr DNS A/CNAME kaydı
- [ ] **pg_dump backup cron**: Railway addon veya external script
- [ ] **Sentry / log monitoring**
- [ ] **HTTPS redirect** + HSTS

---

**Hocaya hazır demo:** web URL + APK + demo hesap bilgileri.  
İyi şanslar! 🚀
