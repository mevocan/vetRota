# VetRota — Sync API Tasarımı

> **Sürüm:** 1.0
> **Tarih:** 19 Nisan 2026
> **Hedef Milestone:** M3 — "Flutter offline muayene yazabiliyor ve sync oluyor" ⚡
> **Bağlantılı Dokümanlar:** `plan.md`, `data-model.md`, `proje.md`

Bu doküman VetRota'nın çevrimdışı Flutter uygulaması ile Laravel sunucusu
arasındaki senkronizasyon protokolünü tanımlar. M3'ün kritik yol
belgesidir; üstüne inşa edilecek her özellik (muayene, stok, fotoğraf,
rota, rapor) bu protokole bağlıdır.

---

## İçindekiler

1. [Temel Mimari Kararlar](#1-temel-mimari-kararlar)
2. [Tablo İşleme Sırası](#2-tablo-işleme-sırası)
3. [Endpoint Envanteri](#3-endpoint-envanteri)
4. [POST `/sync/push`](#4-post-syncpush)
5. [GET `/sync/pull`](#5-get-syncpull)
6. [POST `/sync/photos`](#6-post-syncphotos)
7. [GET `/sync/status`](#7-get-syncstatus)
8. [Conflict Resolution Detayı](#8-conflict-resolution-detayı)
9. [Idempotency](#9-idempotency)
10. [Hata Kodları](#10-hata-kodları)
11. [Laravel İskeleti](#11-laravel-i̇skeleti)
12. [Açık TODO'lar](#12-açık-todolar)

---

## 1. Temel Mimari Kararlar

| Karar | Seçim | Gerekçe |
|---|---|---|
| Push/Pull mimarisi | **Ayrı endpoint'ler** (`POST /sync/push` + `GET /sync/pull`) | Saha ağı flaky; iki ayrı retry edilebilir adım, doğal progress UX |
| Pull delta stratejisi | **Cursor-based** (`last_modified_at` + `id` tiebreaker) | Stateless, sunucu state tutmaz, clock skew sorunu yok (trigger yazar) |
| Payload formatı | **Tablo bazında gruplu** | Her tabloya özel validation/conflict handler; batch upsert performansı |
| Push transaction | **Tek transaction — hepsi veya hiçbiri** | Tutarlılık garantisi; partial success yönetimi MVP için aşırı |
| LWW stratejisi | **Client her zaman haklı** | Veteriner saha kaynağıdır; çiftçi hekim "yazdığım kayboldu" hissini yaşamamalı |
| Echo prevention | `origin_device_id` kolonu | Kaydı gönderen cihaza geri dönmesin |

---

## 2. Tablo İşleme Sırası

FK dependency order — push ve pull'da **tümü bu sırada** işlenir:

```
1.  villages          (bağımsız master)
2.  diagnoses         (global master, genelde sadece pull)
3.  drugs             (clinic-scoped master)
4.  farmers           (animals'tan önce)
5.  animals           (farmers + villages'a bağlı)
6.  appointments      (farmers + animals + users'a bağlı)
7.  medical_records   (animals + vets + appointments'a bağlı)
8.  medical_record_drugs
9.  stocks
10. stock_movements   (medical_records'a referans verebilir)
11. vaccine_schedules
12. vaccination_reminders
13. pregnancies
14. routes
15. route_stops
```

**Delete sırası:** Yukarıdakinin tam tersi (yapraktan köke).

**M3 kapsamı:** İlk 10 tablo. Geri kalanı M5–M7'de aynı altyapıya eklenir.

---

## 3. Endpoint Envanteri

Tümü `Authorization: Bearer <jwt>` ister. JWT payload'ında `user_id`,
`clinic_id`, `device_id` bulunur.

| Method | Path | Amaç |
|---|---|---|
| `POST` | `/api/v1/sync/push` | Client'taki bekleyen değişiklikleri server'a gönder |
| `GET`  | `/api/v1/sync/pull` | Son sync'ten sonra değişen kayıtları çek |
| `POST` | `/api/v1/sync/photos` | Muayene fotoğraflarını ayrı kanalda yükle (M4) |
| `GET`  | `/api/v1/sync/status` | Bu cihaz için özet: son sync zamanı, bekleyen conflict sayısı |

---

## 4. POST `/sync/push`

### 4.1 Request

```json
{
  "client_sync_id": "01HXXX...",
  "device_id": "uuid",
  "client_time": "2026-04-19T10:12:34.567Z",
  "batch": {
    "villages":            [...],
    "farmers":             [...],
    "animals":             [...],
    "appointments":        [...],
    "medical_records":     [...],
    "medical_record_drugs":[...],
    "stocks":              [...],
    "stock_movements":     [...]
  }
}
```

| Alan | Tip | Açıklama |
|---|---|---|
| `client_sync_id` | ULID (26 char) | Idempotency anahtarı; 24 saat cache'te tutulur |
| `device_id` | UUID | JWT'dekiyle eşleşmeli (yoksa 403) |
| `client_time` | ISO8601 | Telemetri + clock skew tespiti |
| `batch` | object | Tablo bazında kayıt listeleri |

### 4.2 Kayıt Formatı

```json
{
  "op": "upsert",
  "id": "uuid-client-generated",
  "expected_version": 3,
  "data": {
    "farmer_id": "...",
    "ear_tag": "TR12345",
    "...": "..."
  },
  "client_last_modified_at": "2026-04-19T09:05:00Z"
}
```

| Alan | Açıklama |
|---|---|
| `op` | `"upsert"` veya `"delete"`. UUID client'ta üretildiği için create/update ayrımı yok |
| `id` | Client tarafından üretilmiş UUID |
| `expected_version` | Bu kayıt client'a son çekildiğinde hangi version'daydı. Yeni kayıtta `0` |
| `data` | Upsert'te zorunlu, delete'te yok |
| `client_last_modified_at` | Audit için; karşılaştırmada kullanılmaz (version yeter) |

### 4.3 İşleme Mantığı (Pseudo)

```
BEGIN TRANSACTION;

for table in [villages, farmers, animals, ..., stock_movements]:
    for record in batch[table]:
        server_row = SELECT ... WHERE id = record.id FOR UPDATE;

        if not server_row and record.op == 'upsert':
            INSERT with origin_device_id, version=1

        elif not server_row and record.op == 'delete':
            skip  // idempotent no-op

        elif server_row and record.op == 'delete':
            handle_delete(server_row, record)  // ledger tabloları RED

        elif server_row.version == record.expected_version:
            UPDATE  // trigger version bump yapar

        elif server_row.version > record.expected_version:
            resolve_conflict(table, server_row, record)

COMMIT;
```

### 4.4 Response

```json
{
  "client_sync_id": "01HXXX...",
  "server_time": "2026-04-19T10:12:35.123Z",
  "results": {
    "accepted": [
      { "table": "animals", "id": "uuid1", "new_version": 2 }
    ],
    "conflicts": [
      {
        "table": "medical_records",
        "id": "uuid3",
        "strategy": "last_write_wins",
        "resolution": "client_won",
        "server_version": 5
      }
    ],
    "rejected": [
      {
        "table": "animals",
        "id": "uuid4",
        "reason": "fk_violation",
        "detail": "farmer_id not found"
      }
    ]
  },
  "server_assigned": {
    "prescriptions": [
      { "id": "uuid", "prescription_number": "2026-0042" }
    ]
  }
}
```

| Bucket | Client davranışı |
|---|---|
| `accepted` | `sync_status='synced'` yap, version'u güncelle |
| `conflicts` | `sync_status='synced'` yap, conflict log'u UI'da göster |
| `rejected` | `sync_status='error'`, kullanıcıya "manuel düzeltme gerek" uyarısı |

### 4.5 Transaction Atomikliği

**Tek transaction — hepsi veya hiçbiri.** Bir kayıtta bile runtime hatası
varsa her şey rollback. `rejected` bucket'ı validation hatasıdır,
transaction'ı bozmaz — kayıt atlanır ama diğerleri commit'lenir.

Runtime hata (DB bağlantısı kopar, trigger patlar) → 500, client aynı
`client_sync_id` ile retry eder.

---

## 5. GET `/sync/pull`

### 5.1 Query Parametreleri

```
GET /api/v1/sync/pull
  ?since=2026-04-19T09:00:00.000Z
  &tables=animals,farmers,medical_records
  &limit=500
  &cursor=<opaque_base64>
```

| Parametre | Zorunlu | Açıklama |
|---|---|---|
| `since` | ✓ | Client'taki en son `last_modified_at`. İlk sync'te `1970-01-01T00:00:00Z` |
| `tables` | | Comma-separated; yoksa tüm tablolar |
| `limit` | | Sayfa boyutu, default 500, max 1000 |
| `cursor` | | Önceki response'dan gelen `next_cursor` |

### 5.2 Server Filtresi

Her tablo için:

```sql
SELECT *
FROM <table>
WHERE clinic_id = :auth_clinic_id              -- global tablolarda yok
  AND last_modified_at > :since
  AND (origin_device_id IS NULL
       OR origin_device_id != :auth_device_id) -- echo prevention
ORDER BY last_modified_at ASC, id ASC
LIMIT :limit
```

**Silinmiş kayıtlar pull'a dahil edilir** (`deleted_at IS NOT NULL`
filtre yok). Client bunları yerel DB'de soft-delete eder.

**Global tablolar** (`villages`, `diagnoses`) — `clinic_id` filtresi yok.

### 5.3 Response

```json
{
  "server_time": "2026-04-19T10:12:36.000Z",
  "has_more": true,
  "next_cursor": "eyJ0YWJsZSI6ImFuaW1hbHMiLC4uLn0=",
  "next_since": "2026-04-19T09:00:00.000Z",
  "data": {
    "villages": [...],
    "farmers": [...],
    "animals": [...]
  }
}
```

`has_more=true` → client cursor ile tekrar çağırır, `since`'i **aynı tutar**.
`has_more=false` → client `last_synced_at = next_since` yapar.

### 5.4 Keyset Pagination Nüansı

Aynı `last_modified_at`'e sahip çok sayıda kayıt olabilir. Cursor hem
timestamp hem id tutar:

```json
{
  "table": "animals",
  "last_modified_at": "2026-04-19T09:05:00.000Z",
  "id": "uuid-last-seen"
}
```

Sorgu:

```sql
WHERE (last_modified_at > :cursor_ts)
   OR (last_modified_at = :cursor_ts AND id > :cursor_id)
```

---

## 6. POST `/sync/photos`

Fotoğraflar JSON batch'e sığmaz, ayrı multipart kanal.

### 6.1 Akış

```
FAZ 1 — Sahada (offline)
  Kamera → /app-docs/photos/<photo_uuid>.jpg
  Drift'e medical_record_photos kaydı (upload_status='pending')

FAZ 2 — Sync (metadata önce)
  POST /sync/push ile medical_record_photos metadata'sı gider
  Server kaydı oluşur, storage_path NULL

FAZ 3 — Photo upload (binary ikinci kanal)
  Push başarılı olduktan sonra pending fotolar tek tek yüklenir
  Server storage_path'i doldurur, upload_status='uploaded'
```

**Kritik kural:** Foto upload asla metadata'dan önce gitmez.

### 6.2 Request

```
POST /api/v1/sync/photos
Content-Type: multipart/form-data
Authorization: Bearer <jwt>

Form fields:
  photo_id           : uuid   (medical_record_photos.id)
  medical_record_id  : uuid
  client_sha256      : hex    (integrity + idempotency)
  file               : binary (image/jpeg, max 5MB)
```

**Neden her istek tek foto?**
- Batch'te 7. foto patlarsa hepsi başa döner.
- Progress UX ("4/12 yükleniyor") tek-tek akışta doğal.
- Multipart parse daha basit.

### 6.3 Server İşleme

```
1. photo_id ile metadata bul (yoksa 404 — önce push atmalı)
2. medical_record_id eşleşmesi kontrol et (yoksa 422)
3. Clinic scope kontrol et (yoksa 403)
4. upload_status='uploaded' ise same response dön (idempotent)
5. SHA-256 hash doğrula (yoksa 422 — transferde bozulma)
6. Dosyayı disk'e yaz: clinics/<clinic_id>/photos/YYYY/MM/<photo_id>.jpg
7. storage_path doldur, upload_status='uploaded'
8. GenerateThumbnailJob queue'ya at
9. Response dön
```

### 6.4 Response

```json
{
  "photo_id": "uuid",
  "storage_path": "clinics/abc/photos/2026/04/uuid.jpg",
  "thumbnail_path": "clinics/abc/photos/2026/04/uuid_thumb.jpg",
  "already_uploaded": false
}
```

### 6.5 Kısıtlar

| Kısıt | Değer | Neden |
|---|---|---|
| Max dosya boyutu | 5 MB | Saha 3G/EDGE için kabul edilebilir süre |
| Format | JPEG only | HEIC/PNG conversion MVP'de yok |
| Client sıkıştırma | Longest edge 1920px, quality 85 | Flutter otomatik yapar |
| Muayene başına max foto | 10 | App validation (data-model.md) |
| Thumbnail | 400x400 square | Server-side job üretir |

### 6.6 Idempotency & Retry

- `upload_status='pending'` fotolar tek tek yüklenir.
- 5xx/timeout → exponential backoff, max 3 deneme.
- Server idempotent: zaten uploaded ise `already_uploaded=true` döner.
- 3 başarısız → client `upload_status='failed'`, UI'da "tekrar dene" butonu.

### 6.7 Storage Backend

MVP: Laravel local disk (`storage/app/photos`). Config flag ile S3'e
geçilebilir. `.env` → `SYNC_PHOTO_DISK=local|s3`.

---

## 7. GET `/sync/status`

Debug + settings ekranı için hızlı özet.

### Response

```json
{
  "device_id": "uuid",
  "last_pushed_at": "2026-04-19T09:55:00Z",
  "last_pulled_at": "2026-04-19T09:55:03Z",
  "pending_conflicts": 2,
  "server_time": "2026-04-19T10:12:40Z"
}
```

---

## 8. Conflict Resolution Detayı

`data-model.md` bölüm 7'deki strateji tablosunu implementation seviyesine
indirir.

### 8.1 Version-Based Detection

```
Client push:  expected_version=3
Server row:   version=4 (başka cihaz güncellemiş)
              → ÇAKIŞMA → strateji uygulanır
```

`client_last_modified_at` sadece audit için saklanır; karşılaştırmada
**version** kullanılır (daha deterministik, clock skew etkisiz).

### 8.2 Last-Write-Wins (LWW) — Çoğu Tablo

**Felsefe: Client her zaman haklı.**

Veteriner saha kaynağıdır. Çakışma olursa client'ın yazdığı kazanır.

```
Conflict detected → sync_conflicts tablosuna log (audit için)
                 → client verisi server'a yazılır (update)
                 → response: strategy="last_write_wins", resolution="client_won"
                 → client: sync_status='synced' (conflict bilgisi UI notification)
```

**Uygulanan tablolar:** `animals`, `farmers`, `medical_records`,
`appointments`, `drugs`, `vaccine_schedules`, `pregnancies`, `routes`,
`route_stops`, `medical_record_drugs`, `medical_record_photos` (metadata).

### 8.3 Additive Merge — Ledger Tabloları

**Uygulanan tablolar:** `stock_movements`, `payments`.

```
op='upsert' → her zaman INSERT (client farklı id üretir, çakışma imkansız)
op='delete' → REJECTED (ledger asla silinmez)
```

**Silme yerine ters hareket:**
- `stock_movements`: `movement_type='return'`, `quantity=-original`
- `payments`: `is_voided=true` (update, silme değil)

### 8.4 Türetilmiş Alanlar — Server Otoritesi

Client push'unda bu alanlar **yok sayılır**:

| Tablo | Türetilmiş Alan | Hesaplanma |
|---|---|---|
| `stocks` | `current_quantity` | `stock_movements` toplamı (Observer) |
| `invoices` | `paid_amount`, `balance` | `payments` toplamı (Observer) |
| `farmers` | `balance` | `invoices` + `payments` (Observer) |
| `animals` | `is_pregnant` | Aktif `pregnancies` (Observer) |
| `animals` | `last_vaccination_at` | Son vaccine tipi `medical_record` |

Client offline UI için kendi yerel hesaplamasını yapar; sync sonrası
server değeri ile overwrite edilir.

### 8.5 Server-Authoritative Tablolar

`outbreak_alerts`, `daily_reports` — server detect eder, client salt
okuyucu.

```
Client upsert → REJECTED (reason: 'server_authoritative')
Client delete → REJECTED
```

### 8.6 Delete vs Update Çakışması

**Delete her zaman kazanır.**

```
Client: update (expected_version=3)
Server: deleted_at IS NOT NULL, version=4

→ Response: conflict, resolution="server_won_deleted"
→ Client: yerel DB'de soft-delete uygulanır
```

### 8.7 FK Hayaletleri

Soft-deleted kayıtlara referans:

- `INSERT` → kabul edilir (FK constraint `deleted_at` bilmez).
- UI layer'da `deleted_at IS NULL` filtresi yeterli.
- Teorik absürtlükler (silinmiş farmer'a yeni animal) MVP'de tolere edilir.

---

## 9. Idempotency

### Request-Level

- `client_sync_id` (ULID, request başına unique).
- Server bu id'yi Redis/cache'te 24 saat tutar.
- Aynı id ile 2. istek → **aynı response**, DB'ye dokunmaz.

### Record-Level

UUID primary key sayesinde otomatik:

- Aynı `id` ile gelen 2. `upsert` → mevcut kayıtla version karşılaştırması.
- Aynı data geldiyse no-op (version artmaz).
- Aynı `id` ile gelen `delete` → zaten silinmiş ise no-op.

### Photo Upload

- `upload_status='uploaded'` ise same response, disk'e dokunmaz.
- `client_sha256` hash doğrulaması transferde bozulma olup olmadığını
  tespit eder.

---

## 10. Hata Kodları

| Kod | Anlamı | Client Davranışı |
|---|---|---|
| `200 OK` | Başarılı (conflict'ler response içinde) | Normal akış |
| `400 Bad Request` | Payload şeması bozuk | Log + crash report, bug |
| `401 Unauthorized` | JWT yok/geçersiz | Login ekranına yönlendir |
| `403 Forbidden` | device_id mismatch, clinic scope ihlali | Logout + re-login |
| `409 Conflict` | **Kullanılmıyor** (conflict'ler 200'de) | — |
| `413 Payload Too Large` | Batch > 10 MB | Batch'i chunk'la (örn. 100'er kayıt) |
| `422 Unprocessable` | Validation hatası | Log + kullanıcıya bildirim |
| `429 Too Many Requests` | Rate limit | Exponential backoff |
| `500 Internal Server Error` | Sunucu hatası | Retry (idempotency sayesinde güvenli) |
| `503 Service Unavailable` | DB down, bakım | Retry after header'a uy |

---

## 11. Laravel İskeleti

### 11.1 Dosya Yapısı

```
app/
├── Http/
│   ├── Controllers/Api/V1/Sync/
│   │   ├── SyncPushController.php
│   │   ├── SyncPullController.php
│   │   ├── SyncPhotoController.php
│   │   └── SyncStatusController.php
│   ├── Requests/Sync/
│   │   ├── SyncPushRequest.php
│   │   └── SyncPhotoUploadRequest.php
│   └── Middleware/
│       └── EnsureDeviceMatchesJwt.php
├── Services/Sync/
│   ├── SyncPushService.php
│   ├── SyncPullService.php
│   ├── ConflictResolver.php
│   ├── TableProcessors/
│   │   ├── AbstractTableProcessor.php
│   │   ├── VillageProcessor.php
│   │   ├── FarmerProcessor.php
│   │   ├── AnimalProcessor.php
│   │   ├── AppointmentProcessor.php
│   │   ├── MedicalRecordProcessor.php
│   │   ├── MedicalRecordDrugProcessor.php
│   │   ├── StockProcessor.php
│   │   └── StockMovementProcessor.php
│   └── Contracts/
│       └── TableProcessorInterface.php
├── Enums/Sync/
│   ├── SyncOperation.php      (upsert, delete)
│   ├── ConflictStrategy.php   (last_write_wins, additive_merge, ...)
│   └── SyncResult.php         (accepted, conflict, rejected)
└── Support/Sync/
    ├── SyncCursor.php
    └── SyncIdempotencyCache.php
```

### 11.2 Routes — `routes/api.php`

```php
<?php

use App\Http\Controllers\Api\V1\Sync\SyncPhotoController;
use App\Http\Controllers\Api\V1\Sync\SyncPullController;
use App\Http\Controllers\Api\V1\Sync\SyncPushController;
use App\Http\Controllers\Api\V1\Sync\SyncStatusController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')
    ->middleware(['auth:api', 'device.match'])
    ->group(function () {
        Route::prefix('sync')->group(function () {
            Route::post('push', SyncPushController::class)->name('sync.push');
            Route::get('pull', SyncPullController::class)->name('sync.pull');
            Route::post('photos', SyncPhotoController::class)->name('sync.photos');
            Route::get('status', SyncStatusController::class)->name('sync.status');
        });
    });
```

### 11.3 Middleware — `EnsureDeviceMatchesJwt`

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureDeviceMatchesJwt
{
    public function handle(Request $request, Closure $next): Response
    {
        $jwtDeviceId = auth()->payload()->get('device_id');
        $headerDeviceId = $request->header('X-Device-Id')
            ?? $request->input('device_id');

        if ($jwtDeviceId && $headerDeviceId && $jwtDeviceId !== $headerDeviceId) {
            return response()->json([
                'error' => 'device_mismatch',
                'message' => 'Device ID in request does not match JWT.',
            ], 403);
        }

        $request->attributes->set('device_id', $jwtDeviceId);
        return $next($request);
    }
}
```

### 11.4 Enum — `ConflictStrategy`

```php
<?php

namespace App\Enums\Sync;

enum ConflictStrategy: string
{
    case LastWriteWins = 'last_write_wins';
    case AdditiveMerge = 'additive_merge';
    case ServerAuthoritative = 'server_authoritative';
    case Manual = 'manual';

    /** Tablo → Strateji eşleşmesi */
    public static function forTable(string $table): self
    {
        return match ($table) {
            'stock_movements', 'payments' => self::AdditiveMerge,
            'outbreak_alerts', 'daily_reports' => self::ServerAuthoritative,
            default => self::LastWriteWins,
        };
    }
}
```

### 11.5 Form Request — `SyncPushRequest`

```php
<?php

namespace App\Http\Requests\Sync;

use Illuminate\Foundation\Http\FormRequest;

class SyncPushRequest extends FormRequest
{
    /** FK dependency order */
    public const TABLES = [
        'villages',
        'farmers',
        'animals',
        'appointments',
        'medical_records',
        'medical_record_drugs',
        'stocks',
        'stock_movements',
    ];

    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        $rules = [
            'client_sync_id' => ['required', 'string', 'size:26'], // ULID
            'device_id'      => ['required', 'uuid'],
            'client_time'    => ['required', 'date'],
            'batch'          => ['required', 'array'],
        ];

        foreach (self::TABLES as $table) {
            $rules["batch.{$table}"]                            = ['sometimes', 'array'];
            $rules["batch.{$table}.*.op"]                       = ['required', 'in:upsert,delete'];
            $rules["batch.{$table}.*.id"]                       = ['required', 'uuid'];
            $rules["batch.{$table}.*.expected_version"]         = ['required', 'integer', 'min:0'];
            $rules["batch.{$table}.*.client_last_modified_at"]  = ['required', 'date'];
            $rules["batch.{$table}.*.data"]                     = ['required_if:batch.*.*.op,upsert', 'array'];
        }

        return $rules;
    }
}
```

### 11.6 Push Controller

```php
<?php

namespace App\Http\Controllers\Api\V1\Sync;

use App\Http\Controllers\Controller;
use App\Http\Requests\Sync\SyncPushRequest;
use App\Services\Sync\SyncPushService;
use App\Support\Sync\SyncIdempotencyCache;
use Illuminate\Http\JsonResponse;

class SyncPushController extends Controller
{
    public function __construct(
        private SyncPushService $pushService,
        private SyncIdempotencyCache $idempotency,
    ) {}

    public function __invoke(SyncPushRequest $request): JsonResponse
    {
        $syncId = $request->input('client_sync_id');

        if ($cached = $this->idempotency->get($syncId)) {
            return response()->json($cached);
        }

        $response = $this->pushService->execute(
            user: auth()->user(),
            deviceId: $request->attributes->get('device_id'),
            clientSyncId: $syncId,
            batch: $request->input('batch'),
        );

        $this->idempotency->put($syncId, $response, ttl: 86400);
        return response()->json($response);
    }
}
```

### 11.7 Idempotency Cache

```php
<?php

namespace App\Support\Sync;

use Illuminate\Support\Facades\Cache;

class SyncIdempotencyCache
{
    private const PREFIX = 'sync:idempotency:';

    public function get(string $syncId): ?array
    {
        return Cache::get(self::PREFIX . $syncId);
    }

    public function put(string $syncId, array $response, int $ttl = 86400): void
    {
        Cache::put(self::PREFIX . $syncId, $response, $ttl);
    }
}
```

### 11.8 Push Service — Orkestrator

```php
<?php

namespace App\Services\Sync;

use App\Enums\Sync\SyncResult;
use App\Models\SyncLog;
use App\Services\Sync\Contracts\TableProcessorInterface;
use App\Services\Sync\TableProcessors\AnimalProcessor;
use App\Services\Sync\TableProcessors\AppointmentProcessor;
use App\Services\Sync\TableProcessors\FarmerProcessor;
use App\Services\Sync\TableProcessors\MedicalRecordDrugProcessor;
use App\Services\Sync\TableProcessors\MedicalRecordProcessor;
use App\Services\Sync\TableProcessors\StockMovementProcessor;
use App\Services\Sync\TableProcessors\StockProcessor;
use App\Services\Sync\TableProcessors\VillageProcessor;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class SyncPushService
{
    /** FK dependency order — değiştirme */
    private array $processors = [
        'villages'             => VillageProcessor::class,
        'farmers'              => FarmerProcessor::class,
        'animals'              => AnimalProcessor::class,
        'appointments'         => AppointmentProcessor::class,
        'medical_records'      => MedicalRecordProcessor::class,
        'medical_record_drugs' => MedicalRecordDrugProcessor::class,
        'stocks'               => StockProcessor::class,
        'stock_movements'      => StockMovementProcessor::class,
    ];

    public function execute($user, string $deviceId, string $clientSyncId, array $batch): array
    {
        $results = ['accepted' => [], 'conflicts' => [], 'rejected' => []];

        $syncLog = SyncLog::create([
            'device_id' => $deviceId,
            'direction' => 'push',
            'started_at' => now(),
            'status' => 'in_progress',
        ]);

        try {
            DB::transaction(function () use ($batch, $user, $deviceId, &$results) {
                foreach ($this->processors as $table => $processorClass) {
                    $records = $batch[$table] ?? [];
                    if (empty($records)) continue;

                    /** @var TableProcessorInterface $processor */
                    $processor = app($processorClass);
                    $processor->setContext($user, $deviceId);

                    foreach ($records as $record) {
                        $result = $processor->process($record);

                        match ($result['status']) {
                            SyncResult::Accepted->value => $results['accepted'][] = [
                                'table' => $table,
                                'id' => $record['id'],
                                'new_version' => $result['version'] ?? null,
                            ],
                            SyncResult::Conflict->value => $results['conflicts'][] = [
                                'table' => $table,
                                'id' => $record['id'],
                                ...$result['conflict'],
                            ],
                            SyncResult::Rejected->value => $results['rejected'][] = [
                                'table' => $table,
                                'id' => $record['id'],
                                'reason' => $result['reason'],
                                'detail' => $result['detail'] ?? null,
                            ],
                        };
                    }
                }
            });

            $syncLog->update([
                'completed_at' => now(),
                'pushed_count' => count($results['accepted']),
                'conflict_count' => count($results['conflicts']),
                'status' => 'success',
                'metadata' => ['rejected_count' => count($results['rejected'])],
            ]);

        } catch (\Throwable $e) {
            Log::error('Sync push failed', [
                'device_id' => $deviceId,
                'sync_id' => $clientSyncId,
                'error' => $e->getMessage(),
            ]);

            $syncLog->update([
                'completed_at' => now(),
                'status' => 'failed',
                'error_message' => $e->getMessage(),
            ]);

            throw $e;
        }

        return [
            'client_sync_id' => $clientSyncId,
            'server_time' => now()->toIso8601String(),
            'results' => $results,
        ];
    }
}
```

### 11.9 Processor Interface + Abstract

```php
<?php

namespace App\Services\Sync\Contracts;

interface TableProcessorInterface
{
    public function setContext($user, string $deviceId): void;
    public function process(array $record): array;
}
```

```php
<?php

namespace App\Services\Sync\TableProcessors;

use App\Enums\Sync\ConflictStrategy;
use App\Enums\Sync\SyncResult;
use App\Models\SyncConflict;
use App\Services\Sync\Contracts\TableProcessorInterface;
use Illuminate\Database\Eloquent\Model;

abstract class AbstractTableProcessor implements TableProcessorInterface
{
    protected $user;
    protected string $deviceId;

    abstract protected function tableName(): string;
    abstract protected function modelClass(): string;
    abstract protected function fillable(): array;

    protected function validateData(array $data): ?string
    {
        return null;
    }

    public function setContext($user, string $deviceId): void
    {
        $this->user = $user;
        $this->deviceId = $deviceId;
    }

    public function process(array $record): array
    {
        $modelClass = $this->modelClass();
        $server = $modelClass::withTrashed()
            ->where('id', $record['id'])
            ->lockForUpdate()
            ->first();

        return match ($record['op']) {
            'upsert' => $this->handleUpsert($record, $server),
            'delete' => $this->handleDelete($record, $server),
        };
    }

    private function handleUpsert(array $record, ?Model $server): array
    {
        $data = $record['data'];

        if ($error = $this->validateData($data)) {
            return [
                'status' => SyncResult::Rejected->value,
                'reason' => 'validation',
                'detail' => $error,
            ];
        }

        if (!$server) {
            return $this->insertNew($record);
        }

        if ($server->trashed()) {
            return [
                'status' => SyncResult::Conflict->value,
                'conflict' => [
                    'strategy' => ConflictStrategy::LastWriteWins->value,
                    'resolution' => 'server_won_deleted',
                    'server_version' => $server->version,
                    'server_data' => $server->toArray(),
                ],
            ];
        }

        if ($server->version == $record['expected_version']) {
            return $this->applyUpdate($server, $record);
        }

        return $this->resolveConflict($server, $record);
    }

    private function insertNew(array $record): array
    {
        $modelClass = $this->modelClass();
        $data = array_intersect_key($record['data'], array_flip($this->fillable()));
        $data['id'] = $record['id'];
        $data['origin_device_id'] = $this->deviceId;
        $data['version'] = 1;

        $model = $modelClass::create($data);

        return [
            'status' => SyncResult::Accepted->value,
            'version' => $model->version,
        ];
    }

    private function applyUpdate(Model $server, array $record): array
    {
        $data = array_intersect_key($record['data'], array_flip($this->fillable()));
        $server->fill($data);
        $server->origin_device_id = $this->deviceId;
        $server->save(); // trigger version++

        return [
            'status' => SyncResult::Accepted->value,
            'version' => $server->fresh()->version,
        ];
    }

    private function resolveConflict(Model $server, array $record): array
    {
        $strategy = ConflictStrategy::forTable($this->tableName());

        return match ($strategy) {
            ConflictStrategy::LastWriteWins => $this->resolveLWW($server, $record),
            ConflictStrategy::AdditiveMerge => $this->resolveAdditive($server, $record),
            ConflictStrategy::ServerAuthoritative => $this->resolveServerWins($server, $record),
            ConflictStrategy::Manual => $this->flagManual($server, $record),
        };
    }

    /** Client her zaman haklı */
    private function resolveLWW(Model $server, array $record): array
    {
        SyncConflict::create([
            'device_id' => $this->deviceId,
            'table_name' => $this->tableName(),
            'record_id' => $record['id'],
            'local_version' => $record['expected_version'],
            'server_version' => $server->version,
            'local_payload' => $record['data'],
            'server_payload' => $server->toArray(),
            'resolution_strategy' => ConflictStrategy::LastWriteWins->value,
            'resolution' => 'resolved_local',
            'resolved_at' => now(),
        ]);

        $this->applyUpdate($server, $record);

        return [
            'status' => SyncResult::Conflict->value,
            'conflict' => [
                'strategy' => ConflictStrategy::LastWriteWins->value,
                'resolution' => 'client_won',
                'server_version' => $server->fresh()->version,
            ],
        ];
    }

    protected function resolveAdditive(Model $server, array $record): array
    {
        return [
            'status' => SyncResult::Rejected->value,
            'reason' => 'additive_no_update',
            'detail' => 'Ledger tables do not accept updates.',
        ];
    }

    protected function resolveServerWins(Model $server, array $record): array
    {
        return [
            'status' => SyncResult::Conflict->value,
            'conflict' => [
                'strategy' => ConflictStrategy::ServerAuthoritative->value,
                'resolution' => 'server_won',
                'server_version' => $server->version,
                'server_data' => $server->toArray(),
            ],
        ];
    }

    private function flagManual(Model $server, array $record): array
    {
        SyncConflict::create([
            'device_id' => $this->deviceId,
            'table_name' => $this->tableName(),
            'record_id' => $record['id'],
            'local_version' => $record['expected_version'],
            'server_version' => $server->version,
            'local_payload' => $record['data'],
            'server_payload' => $server->toArray(),
            'resolution_strategy' => ConflictStrategy::Manual->value,
            'resolution' => 'pending',
        ]);

        return [
            'status' => SyncResult::Conflict->value,
            'conflict' => [
                'strategy' => ConflictStrategy::Manual->value,
                'resolution' => 'pending_manual',
                'server_version' => $server->version,
            ],
        ];
    }

    private function handleDelete(array $record, ?Model $server): array
    {
        if (!$server) {
            return ['status' => SyncResult::Accepted->value]; // idempotent
        }

        if (in_array($this->tableName(), ['stock_movements', 'payments'])) {
            return [
                'status' => SyncResult::Rejected->value,
                'reason' => 'ledger_immutable',
                'detail' => 'Ledger records cannot be deleted.',
            ];
        }

        $server->origin_device_id = $this->deviceId;
        $server->delete(); // soft delete
        return ['status' => SyncResult::Accepted->value];
    }
}
```

### 11.10 Somut Processor — `AnimalProcessor`

```php
<?php

namespace App\Services\Sync\TableProcessors;

use App\Models\Animal;
use App\Models\Farmer;

class AnimalProcessor extends AbstractTableProcessor
{
    protected function tableName(): string { return 'animals'; }
    protected function modelClass(): string { return Animal::class; }

    protected function fillable(): array
    {
        return [
            'farmer_id', 'village_id', 'ear_tag', 'name', 'national_id',
            'species', 'breed', 'birth_date', 'gender', 'weight_kg',
            'color', 'is_pregnant', 'last_vaccination_at', 'status',
            'status_changed_at', 'status_notes',
        ];
    }

    protected function validateData(array $data): ?string
    {
        $farmer = Farmer::find($data['farmer_id'] ?? null);
        if (!$farmer) {
            return 'farmer_id not found';
        }

        if ($farmer->clinic_id !== $this->user->clinic_id) {
            return 'farmer belongs to different clinic';
        }

        $validSpecies = ['cattle', 'sheep', 'goat', 'poultry', 'other'];
        if (isset($data['species']) && !in_array($data['species'], $validSpecies)) {
            return 'invalid species';
        }

        return null;
    }
}
```

### 11.11 Pull Controller + Service

```php
<?php

namespace App\Http\Controllers\Api\V1\Sync;

use App\Http\Controllers\Controller;
use App\Services\Sync\SyncPullService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SyncPullController extends Controller
{
    public function __construct(private SyncPullService $pullService) {}

    public function __invoke(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'since'  => ['required', 'date'],
            'tables' => ['sometimes', 'string'],
            'limit'  => ['sometimes', 'integer', 'min:1', 'max:1000'],
            'cursor' => ['sometimes', 'string'],
        ]);

        $response = $this->pullService->execute(
            user: auth()->user(),
            deviceId: $request->attributes->get('device_id'),
            since: $validated['since'],
            tables: isset($validated['tables'])
                ? explode(',', $validated['tables'])
                : null,
            limit: $validated['limit'] ?? 500,
            cursor: $validated['cursor'] ?? null,
        );

        return response()->json($response);
    }
}
```

```php
<?php

namespace App\Services\Sync;

use App\Support\Sync\SyncCursor;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class SyncPullService
{
    private array $tables = [
        'villages', 'diagnoses', 'drugs', 'farmers', 'animals',
        'appointments', 'medical_records', 'medical_record_drugs',
        'stocks', 'stock_movements',
    ];

    public function execute(
        $user,
        string $deviceId,
        string $since,
        ?array $tables,
        int $limit,
        ?string $cursor
    ): array {
        $tablesToPull = $tables ?? $this->tables;
        $sinceCarbon = Carbon::parse($since);
        $cursorData = $cursor ? SyncCursor::decode($cursor) : null;

        $data = [];
        $hasMore = false;
        $nextCursor = null;

        foreach ($tablesToPull as $table) {
            $query = DB::table($table)
                ->where('last_modified_at', '>', $sinceCarbon)
                ->where(fn($q) => $q->whereNull('origin_device_id')
                                    ->orWhere('origin_device_id', '!=', $deviceId))
                ->orderBy('last_modified_at')
                ->orderBy('id');

            $this->applyClinicScope($query, $table, $user);

            if ($cursorData && $cursorData['table'] === $table) {
                $query->where(function ($q) use ($cursorData) {
                    $q->where('last_modified_at', '>', $cursorData['last_modified_at'])
                      ->orWhere(function ($q2) use ($cursorData) {
                          $q2->where('last_modified_at', '=', $cursorData['last_modified_at'])
                             ->where('id', '>', $cursorData['id']);
                      });
                });
            }

            $rows = $query->limit($limit + 1)->get();

            if ($rows->count() > $limit) {
                $hasMore = true;
                $rows = $rows->take($limit);
                $last = $rows->last();
                $nextCursor = SyncCursor::encode([
                    'table' => $table,
                    'last_modified_at' => $last->last_modified_at,
                    'id' => $last->id,
                ]);
                $data[$table] = $rows->toArray();
                break;
            }

            $data[$table] = $rows->toArray();
        }

        return [
            'server_time' => now()->toIso8601String(),
            'has_more' => $hasMore,
            'next_cursor' => $nextCursor,
            'next_since' => $hasMore
                ? $sinceCarbon->toIso8601String()
                : now()->toIso8601String(),
            'data' => $data,
        ];
    }

    private function applyClinicScope($query, string $table, $user): void
    {
        if (in_array($table, ['villages', 'diagnoses'])) {
            return;
        }
        $query->where('clinic_id', $user->clinic_id);
    }
}
```

### 11.12 Sync Cursor Helper

```php
<?php

namespace App\Support\Sync;

class SyncCursor
{
    public static function encode(array $data): string
    {
        return base64_encode(json_encode($data));
    }

    public static function decode(string $cursor): array
    {
        return json_decode(base64_decode($cursor), true);
    }
}
```

### 11.13 Photo Upload Controller

```php
<?php

namespace App\Http\Controllers\Api\V1\Sync;

use App\Http\Controllers\Controller;
use App\Jobs\GenerateThumbnailJob;
use App\Models\MedicalRecordPhoto;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SyncPhotoController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'photo_id'          => ['required', 'uuid'],
            'medical_record_id' => ['required', 'uuid'],
            'client_sha256'     => ['required', 'string', 'size:64'],
            'file'              => ['required', 'file', 'mimes:jpeg', 'max:5120'],
        ]);

        $photo = MedicalRecordPhoto::with('medicalRecord')
            ->find($validated['photo_id']);

        if (!$photo) {
            return response()->json(['error' => 'metadata_not_found'], 404);
        }

        if ($photo->medical_record_id !== $validated['medical_record_id']) {
            return response()->json(['error' => 'mismatch'], 422);
        }

        if ($photo->medicalRecord->clinic_id !== $request->user()->clinic_id) {
            return response()->json(['error' => 'forbidden'], 403);
        }

        if ($photo->upload_status === 'uploaded') {
            return response()->json([
                'photo_id' => $photo->id,
                'storage_path' => $photo->storage_path,
                'thumbnail_path' => $photo->thumbnail_path,
                'already_uploaded' => true,
            ]);
        }

        $file = $request->file('file');
        $serverHash = hash_file('sha256', $file->getRealPath());
        if ($serverHash !== $validated['client_sha256']) {
            return response()->json(['error' => 'integrity_failed'], 422);
        }

        $path = $file->storeAs(
            "clinics/{$photo->medicalRecord->clinic_id}/photos/" . now()->format('Y/m'),
            $photo->id . '.jpg',
            config('filesystems.sync_photo_disk', 'local')
        );

        $photo->update([
            'storage_path' => $path,
            'upload_status' => 'uploaded',
            'file_size_bytes' => $file->getSize(),
            'origin_device_id' => $request->attributes->get('device_id'),
        ]);

        GenerateThumbnailJob::dispatch($photo);

        return response()->json([
            'photo_id' => $photo->id,
            'storage_path' => $path,
        ]);
    }
}
```

### 11.14 Status Controller

```php
<?php

namespace App\Http\Controllers\Api\V1\Sync;

use App\Http\Controllers\Controller;
use App\Models\SyncConflict;
use App\Models\SyncLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SyncStatusController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $deviceId = $request->attributes->get('device_id');

        $lastPush = SyncLog::where('device_id', $deviceId)
            ->where('direction', 'push')
            ->where('status', 'success')
            ->latest('completed_at')
            ->value('completed_at');

        $lastPull = SyncLog::where('device_id', $deviceId)
            ->where('direction', 'pull')
            ->where('status', 'success')
            ->latest('completed_at')
            ->value('completed_at');

        $pendingConflicts = SyncConflict::where('device_id', $deviceId)
            ->where('resolution', 'pending')
            ->count();

        return response()->json([
            'device_id' => $deviceId,
            'last_pushed_at' => $lastPush?->toIso8601String(),
            'last_pulled_at' => $lastPull?->toIso8601String(),
            'pending_conflicts' => $pendingConflicts,
            'server_time' => now()->toIso8601String(),
        ]);
    }
}
```

---

## 12. Açık TODO'lar

Bu doküman M3'ün Laravel ayağı için yeterli. Claude Code implementasyon
sırasında şu noktaları çözmeli:

1. **Eksik processor sınıfları** — `FarmerProcessor`, `VillageProcessor`,
   `AppointmentProcessor`, `MedicalRecordProcessor`,
   `MedicalRecordDrugProcessor`, `StockProcessor`, `StockMovementProcessor`.
   Her biri `AbstractTableProcessor`'ı extend eder, `fillable()` ve
   `validateData()` override eder.

2. **`StockMovementProcessor` özel mantığı** — `AdditiveMerge` stratejisi.
   Upsert her zaman INSERT (client UUID üretir, çakışma olmaz). Observer
   `stocks.current_quantity` güncellemesini tetikler.

3. **`MedicalRecordProcessor` özel validasyonu** — `vet_id`,
   `appointment_id`, `diagnosis_id` cross-reference checks. Silme
   durumunda ters `stock_movement(return)` observer'ı tetikler.

4. **Trigger bypass / version manuel yönetimi** — Push sırasında
   `saveQuietly()` + manuel `version = OLD.version + 1` kullanılmalı.
   Helper trait: `BumpsVersionManually`.

5. **PostgreSQL trigger'ları** — `data-model.md` bölüm 2.4'teki
   `bump_sync_columns()` fonksiyonu tüm sync tablolarına uygulanmalı.
   Migration içinde trigger CREATE edilmeli.

6. **Integration testler** — Senaryolar:
   - Basit push (yeni kayıtlar)
   - Update push (version eşleşen)
   - Conflict push (LWW — client_won)
   - Delete vs update çakışması
   - Echo prevention (kendi kaydını geri almıyor)
   - Idempotent retry (aynı client_sync_id)
   - Cursor pagination (500+ kayıt)
   - Ledger table delete reddi

7. **Flutter tarafı** — Bu dokümanın client eşleniği ayrı dokümanda:
   - Drift şeması `sync_status` kolonu
   - Push/pull queue manager
   - Exponential backoff + retry
   - Conflict UI (bildirim badge)
   - Photo upload queue

8. **Rate limiting** — Laravel `throttle` middleware, cihaz başına örn.
   60 sync/dakika.

9. **Observability** — `sync_logs` tablosu yeterli başlangıç. Üretimde
   Sentry + OpenTelemetry eklenebilir.

---

**Doküman Sonu.**
