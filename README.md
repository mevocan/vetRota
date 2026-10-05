# VetRota

Kırsalda çalışan gezici veterinerler için **offline-first** bir saha yönetim platformu: randevu, hayvan ve muayene kayıtları, ilaç stoğu, rota sıralama ve çiftçi portalı. Köyde internet olmasa da çalışır, bağlantı gelince sunucuyla senkronize olur.

> Slogan: *"Sahada Kesintisiz Teşhis, Akıllı Rota."*
> Tanıtım sitesi: [vetrota.com.tr](https://vetrota.com.tr)

Tek kişi geliştirdim: ürün tanımı, veri modeli, backend, web paneli, mobil uygulama, UI/UX ve marka kimliği.

## Problem

Gezici bir veteriner günde 10-15 köyü dolaşır. Ahırlarda ve dağ köylerinde internet çekmez; hangi hayvana ne verdiğini deftere yazar, akşam kliniğe dönünce bilgisayara geçirir. Bulut tabanlı klinik yazılımları bu ortamda çalışmaz. Çiftçiyi evde bulamamak da sık yaşanan bir zaman kaybı.

## Üç kullanıcı, üç yüzey

| Kullanıcı | Yüzey | Teknoloji |
|---|---|---|
| Gezici veteriner | Mobil uygulama, internetsiz çalışır | Flutter + Drift (SQLite) |
| Klinik sahibi / sekreter | Web paneli: kayıtlar, analitik, raporlar | Nuxt 4 + Nuxt UI + Pinia |
| Çiftçi | SMS ile gelen linkten şifresiz portal (`/farmer/[token]`) | Nuxt, token tabanlı |

Hepsi tek bir REST API'ye bağlı: Laravel 13 (PHP 8.4) + PostgreSQL 18, JWT ile kimlik doğrulama, Docker Compose ile ayağa kalkar.

```
Flutter (Drift ↔ Sync Manager) ──HTTPS/JWT──▶ Laravel API ──▶ PostgreSQL
                                                  ▲
                              Nuxt web paneli + çiftçi portalı
```

## Verdiğim mimari kararlar

**Offline-first, sunucu ikinci planda.** Mobilde hiçbir ekran ağı beklemez; önce yerel veritabanından okur, yazma önce Drift'e gider, sonra senkron kuyruğuna düşer. Bu yüzden ID'ler client'ta UUID/ULID üretilir (auto-increment yok), sunucu tarafında atanan değerler (reçete numarası gibi) çevrimdışıyken "Taslak" olarak gösterilir.

**Senkronizasyon protokolü ayrı tasarlandı** ([docs/sync-api.md](docs/sync-api.md)):
- `push` ve `pull` ayrı endpoint'ler: saha ağı zayıf olduğu için iki ayrı, yeniden denenebilir adım.
- Pull, cursor tabanlı delta (`last_modified_at` + `id`); saat farkı sorunu olmasın diye zaman damgasını istemci değil veritabanı trigger'ı yazar.
- Push tek transaction: hepsi ya da hiçbiri. Aynı istek tekrar gelirse sonuç değişmez (idempotency).
- Çakışmada **client kazanır (last-write-wins)**: saha verisi kanondur, veterinerin yazdığı kaybolmamalı. Her çözüm `sync_conflicts` tablosuna denetim kaydı olarak yazılır.
- Stok ve ödeme gibi **ledger tabloları hiç silinmez ve ezilmez**; iki cihazın hareketleri toplanır, silme isteği ters hareket olarak eklenir.
- `origin_device_id` ile cihaz kendi yazdığını pull'da geri almaz.
- Tablolar foreign key sırasıyla işlenir; çok kiracılı yapı `clinic_id` ile ayrılır.

**Rota optimizasyonu: bilerek basit.** Günün randevuları *nearest-neighbor* (açgözlü en yakın komşu) ile, Haversine kuş uçuşu mesafesiyle sıralanır ([route_optimizer.dart](mobile/lib/util/route_optimizer.dart)). 10-15 durak için O(N²) yeterli; tam TSP çözücü ya da harita servisi API'si eklemek bu ölçekte karmaşıklık ve maliyet olurdu. Hesap cihazda yapıldığı için rota da internetsiz çalışır. Yol ağını hesaba katmaz, bu bilinen bir sınırdır.

**Gerçek bir sunucuya bağımlı olan şeyler açıkça ayrıldı.** SMS ve PDF üretimi gibi internet gerektiren özellikler çevrimdışı davranışı belirtilerek tasarlandı.

## Özellikler

- Hayvan kaydı (kulak küpesi ile hızlı arama), sürü bazlı toplu işlem, gebelik takibi
- Muayene kaydı, çevrimdışı fotoğraf çekme ve aynı hayvanın fotoğraflarını kronolojik karşılaştırma
- İlaç/stok: muayene ile atomik stok düşümü, stok ledger'ı
- Randevu takvimi ve günlük rota (harita üzerinde sıralı duraklar, toplam km)
- Aşı planı şablonları ve yaklaşan aşıları tarayan zamanlanmış görev
- Çiftçi portalı (SMS linki), borç/ödeme takibi, dijital reçete PDF'i, hayvan QR etiketi
- Hastalık yayılım haritası, günlük PDF raporu
- Klinik analitiği: veteriner performansı, ilaç tüketimi, kazanç
- Free / Premium paket ayrımı (rota, çiftçi portalı, harita gibi özellikler Premium'da kilitli)

## Proje yapısı

```
backend/   Laravel 13 API (sync servisleri, SMS kuyruğu, PDF, analitik)
web/       Nuxt 4 klinik paneli ve çiftçi portalı
mobile/    Flutter uygulaması (Drift, sync manager, harita)
docs/      Tasarım kararları: veri modeli (32 tablo), sync protokolü, milestone planı
logo/      Marka varlıkları
```

Geliştirme dokümanları `docs/` altında; kararların kaynağı oradadır ([plan.md](docs/plan.md), [data-model.md](docs/data-model.md), [sync-api.md](docs/sync-api.md)).

## Çalıştırma

```bash
cp .env.example .env
docker compose up -d                       # Laravel + PostgreSQL + Nuxt
docker compose exec backend php artisan migrate --seed
```

Mobil için `mobile/` altında:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # Android emülatörü için
```

Seeder demo klinik, çiftçi, hayvan ve muayene verisi üretir.

## Durum ve bilinen sınırlar

Dürüst bir tablo, çünkü bu bir portföy projesi ve üretimde kullanılan bir sistem değil:

- **SMS gerçek değil.** `LogSmsSender` mesajı log'a yazar; telefona SMS gitmez. Sürücü arayüzü hazır, gerçek bir sağlayıcı bağlanmadı.
- **Sync testleri.** Backend tarafında sync akışı için entegrasyon testleri var; mobil uçtan uca akış emülatör/cihazda denendi (randevu pull, muayene ve fotoğraf push). **İki cihazın aynı kaydı çevrimdışı değiştirdiği çakışma senaryosu henüz cihazda doğrulanmadı.**
- **Rota** yol ağını değil kuş uçuşu mesafeyi kullanır.
- Web'deki hastalık haritası şimdilik basit bir görselleştirme; mobil tarafta `flutter_map` kullanılıyor.
- Production deploy rehberi (`docs/deploy-railway.md`) hazır; kalıcı bir canlı ortam bu repoda tutulmuyor.
