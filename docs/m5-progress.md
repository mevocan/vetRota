# M5 İlerleme Takibi

> **Amaç:** "Randevu + Rota optimizasyonu + Gün sonu raporu"
> Bağımlılık: M3 (sync, Drift appointments tablosu hazır).

---

## M4 Devralınan Durum (2026-05-03)

- M4 kod tarafı bitti, M4.7 cihaz testi bekliyor
- `appointments` tablosu hem backend hem Drift'te zaten var (M3.1'de hazırlanmış)
- `routes` ve `route_stops` tabloları data-model.md §4 listesinde var ama henüz migration yok
- Harita kütüphanesi seçilmedi

---

## Karar: Harita — `flutter_map` (OpenStreetMap)

**`flutter_map` ✅ seçildi** çünkü:
- Ücretsiz, API key yok, billing yok (MVP için kritik)
- Kırsalda çalışırken offline tile cache yapılabilir (M5+ improvement)
- `google_maps_flutter` Google Cloud project + billing + API key + iOS bundle id whitelist gerektirir

Eksisi: street view yok, Google'ın yol çizimi yok. MVP için yeter.

---

## Karar: Rota optimizasyonu — Nearest-Neighbor (greedy)

Veterinerin başlangıç noktasından (klinik veya manuel pin) başlayıp her seferinde
en yakın bir sonraki randevuya gider. Türkiye'de tipik bir veteriner günde 10-15
köy dolaşır → O(N²) yeter, TSP solver'a gerek yok.

Mesafe metriği: **Haversine** (lat/lng arası büyük çember). Yol mesafesi değil
ama köyler arası kuş uçuşu yeterli.

---

## Karar: PDF raporu — `dompdf`

`barryvdh/laravel-dompdf` ✅. HTML template'den PDF üretir, MVP için yeter.
Async sync sırasında çalışır; isteğe bağlı: gün sonunda kuyruğa düşer veya
manuel "Bugünün raporu" butonu ile tetiklenir.

---

## Faz Özeti

| Faz | Kapsam | Durum |
|---|---|---|
| M5.1 | Backend: `routes` + `route_stops` migration + Eloquent modeller + sync kolonları | ✅ Migration + sync trigger + SyncPullService listesine eklendi |
| M5.2 | Backend: `daily_reports` migration + Eloquent + report data API endpoint | ✅ Server-only tablo, `GET /reports/daily/{date}` JSON döner |
| M5.3 | Backend: `dompdf` kurulum + report PDF generator (Blade template) + `GET /reports/daily/{date}` | ✅ `?format=pdf` ile binary PDF + `storage/app/reports/...` cache |
| M5.4 | Flutter: `flutter_map` kurulum + Drift `routes`/`route_stops` tabloları | ✅ flutter analyze temiz |
| M5.5 | Flutter: Bugünün randevuları ekranı (`AppointmentsTodayScreen`) — liste + harita toggle | ✅ AppointmentsRepository + SegmentedButton + FlutterMap markers |
| M5.6 | Flutter: "Rotayı optimize et" — nearest-neighbor + sıralı pin gösterimi + polyline | ✅ `route_optimizer.dart` (saf Dart + test) + Drift'e route + numaralı pin + polyline |
| M5.7 | Flutter: Randevu detayı → "Tamamlandı" işaretle (status=completed) + isteğe bağlı muayene formuna geç | ✅ Bottom sheet, status=completed, MR formuna animal pre-fill |
| M5.8 | Flutter: "Bugünün raporu" — backend'e tetikle, PDF indir, paylaş/aç | ✅ ReportsRepository + open_filex + AppBar butonu |
| M5.9 | Smoke test (cihaz): bugünün randevularını gör, optimize et, tamamla, raporu indir | ⬜ Cihazda elle test bekliyor |

**Durum sembolleri:** ✅ Tamam · ⏳ Yazıldı (test edilmedi) · 🟡 Kısmi · ⚠️ Bloke · ⬜ Bekliyor

---

## M5.1 — Backend: routes + route_stops

**Hedef:** Optimize edilmiş günlük rotayı saklayan tablolar hazır.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Migration `routes` (id UUID, vet_id FK, date date, total_distance_km decimal, total_duration_min int, sync kolonları) | ⬜ | Bir vet için bir tarih tek route — UNIQUE(vet_id, date) |
| 2 | Migration `route_stops` (id UUID, route_id FK, appointment_id FK nullable, sequence int, lat, lng, distance_from_prev_km, status enum, sync kolonları) | ⬜ | sequence ile sıralanır |
| 3 | Eloquent: Route + RouteStop, sync trigger'lara bağla | ⬜ | bump_sync_columns() trigger |
| 4 | SyncPullService tablo listesine ekle | ⬜ | |
| 5 | Test (Docker): migrate + M3 testleri 8/8 yeşil | ⬜ | |

---

## M5.2 — Backend: daily_reports tablosu + data API

**Hedef:** Günün özetini hesaplayan endpoint var.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Migration `daily_reports` (id UUID, vet_id FK, date date, animals_visited int, medical_records_count int, total_distance_km, total_revenue, drugs_used_jsonb, generated_at, pdf_path nullable) | ⬜ | server-side, sync'e dahil değil (data-model.md §3 — server-only) |
| 2 | `DailyReportController::summary($date)` — vet_id JWT'den, tarih path'ten; query medical_records + stock_movements + routes; JSON döner | ⬜ | |
| 3 | Route: `GET /api/v1/reports/daily/{date}` | ⬜ | auth:api |
| 4 | Test (Docker): curl → 200 + JSON şema doğrulama | ⬜ | |

---

## M5.3 — Backend: PDF üretici

**Hedef:** Aynı endpoint `?format=pdf` ile binary PDF döner.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `composer require barryvdh/laravel-dompdf` | ⬜ | |
| 2 | Blade template `resources/views/reports/daily.blade.php` (klinik logo, tarih, vet adı, tablo) | ⬜ | |
| 3 | `DailyReportController::pdf($date)` — daily_reports satırını üret/güncelle, dompdf ile render et, `storage/app/reports/...` kaydet, file döndür | ⬜ | |
| 4 | Test (Docker): curl `?format=pdf` → application/pdf header + dosya | ⬜ | |

---

## M5.4 — Flutter: flutter_map + Drift tablolar

**Hedef:** Harita çizilebiliyor, rota lokal saklanıyor.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `flutter_map` ^7.x + `latlong2` package | ⬜ | OSM tile provider default |
| 2 | Drift `Routes` + `RouteStops` tablosu (sync kolonları) | ⬜ | schema v2 → v3 |
| 3 | `RoutesRepository` — watchToday(), createOptimizedRoute(stops), markStopVisited | ⬜ | |
| 4 | sync_mappers ekle, sync_repository pull tablo listesine ekle | ⬜ | |

---

## M5.5 — Bugünün randevuları ekranı

**Hedef:** Veteriner sabah açar, bugünün randevularını görür.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `AppointmentsRepository.watchToday()` — `scheduled_at` bugün olanlar | ⬜ | |
| 2 | `AppointmentsTodayScreen` — Liste / Harita toggle (SegmentedButton) | ⬜ | |
| 3 | Liste: çiftçi adı + köy + saat + status badge; tap → randevu detayı | ⬜ | |
| 4 | Harita: `FlutterMap` + her randevu için `Marker` (animal.village.lat/lng veya farmer adresinden) | ⬜ | Lat/lng yoksa marker'a koyma, listede uyarı |
| 5 | AppBar veya Drawer'dan navigasyon (yeni "Randevular" sekmesi) | ⬜ | Bottom nav veya drawer — karar M5.5'te |

---

## M5.6 — Rotayı optimize et

**Hedef:** "Optimize et" butonu nearest-neighbor ile sırayı belirler ve harita üzerinde gösterir.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | `lib/util/route_optimizer.dart` — `List<LatLng> nearestNeighbor(start, points)` saf Dart fonksiyonu | ⬜ | Test yazılır (`test/route_optimizer_test.dart`) |
| 2 | Haversine helper (`distanceKm(LatLng a, LatLng b)`) | ⬜ | |
| 3 | "Rotayı optimize et" FAB → başlangıç noktası seç (mevcut konum / klinik / manuel) | ⬜ | `geolocator` veya manuel; MVP'de manuel pin |
| 4 | Optimize sonrası: `routes` + `route_stops` Drift'e yazılır (sync push'a gider) | ⬜ | |
| 5 | Harita üzerine sıralı pin (1-2-3...) + Polyline | ⬜ | |

---

## M5.7 — Randevuyu tamamla

**Hedef:** Veterinerin bir randevuyu kapatması + opsiyonel muayene oluşturması.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Randevu detayı: "Tamamla" butonu → status=completed, completed_at=now | ⬜ | |
| 2 | "Tamamla + muayene gir" → MR formuna animal pre-fill ile geç | ⬜ | |
| 3 | Tamamlanmış randevular listede gri/üstü çizili görünür | ⬜ | |

---

## M5.8 — Bugünün raporu

**Hedef:** Tek tuşla PDF indir.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | AppBar'da "Rapor" butonu (yalnızca AppointmentsTodayScreen'de) | ⬜ | |
| 2 | `ReportsRepository.fetchTodayPdf()` — Dio binary download → app docs `reports/<date>.pdf` | ⬜ | |
| 3 | `open_filex` veya `share_plus` ile aç/paylaş | ⬜ | Karar: open_filex daha basit |
| 4 | Offline ise "İnternet bağlantısı gerekli" mesajı | ⬜ | |

---

## M5.9 — Smoke test

| # | Adım | Durum |
|---|---|---|
| 1 | Backend'e seed: 3-4 köy lat/lng + 5 randevu bugün için | ⬜ |
| 2 | Flutter sync → Randevular ekranı 5 randevuyu liste/haritada gösterir | ⬜ |
| 3 | "Optimize et" → nearest-neighbor sırası gelir, polyline çizilir | ⬜ |
| 4 | Bir randevuyu "Tamamla + muayene gir" ile kapat | ⬜ |
| 5 | "Bugünün raporu" → PDF indir, aç, içerikte: 1 muayene, X km mesafe | ⬜ |

---

**Doküman Sonu.**
