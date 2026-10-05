# VetRota

An **offline-first** field management platform for traveling vets in rural areas: appointments, animal and examination records, drug stock, route ordering and a farmer portal. It works without internet in the village and syncs with the server once a connection returns.

> Tagline: *"Uninterrupted diagnosis in the field. Smart routes."*
> Marketing site: [vetrota.com.tr](https://vetrota.com.tr)

Built solo: product definition, data model, backend, web panel, mobile app, UI/UX and brand identity.

## The problem

A traveling vet visits 10-15 villages a day. There is no internet in barns and mountain villages, so they write down which animal got what in a notebook and re-enter it at the computer in the evening. Cloud-based clinic software does not work in this environment. Finding the farmer not at home is another common time sink.

## Three users, three surfaces

| User | Surface | Technology |
|---|---|---|
| Traveling vet | Mobile app that works offline | Flutter + Drift (SQLite) |
| Clinic owner / secretary | Web panel: records, analytics, reports | Nuxt 4 + Nuxt UI + Pinia |
| Farmer | Passwordless portal opened from an SMS link (`/farmer/[token]`) | Nuxt, token-based |

All three talk to a single REST API: Laravel 13 (PHP 8.4) + PostgreSQL 18, JWT authentication, started with Docker Compose.

```
Flutter (Drift ↔ Sync Manager) ──HTTPS/JWT──▶ Laravel API ──▶ PostgreSQL
                                                  ▲
                              Nuxt web panel + farmer portal
```

## Architecture decisions

**Offline-first, server second.** No mobile screen waits on the network: it reads from the local database first, and writes go to Drift first and then into a sync queue. That is why IDs are generated on the client (UUID/ULID, no auto-increment), and why values assigned by the server (such as a prescription number) show as a "Draft" while offline.

**The sync protocol was designed on its own** ([docs/sync-api.md](docs/sync-api.md)):
- `push` and `pull` are separate endpoints: field networks are unreliable, so these are two separate, retryable steps.
- Pull is a cursor-based delta (`last_modified_at` + `id`). To avoid clock-skew problems, the timestamp is written by a database trigger, not by the client.
- Push is a single transaction: all or nothing. A repeated request does not change the result (idempotency).
- On conflicts **the client wins (last-write-wins)**: field data is canonical, and what the vet wrote must not disappear. Every resolution is recorded in the `sync_conflicts` table as an audit trail.
- **Ledger tables** such as stock and payments are never deleted or overwritten; movements from two devices are summed, and a delete request is added as a reversing movement.
- `origin_device_id` keeps a device from pulling back what it just wrote.
- Tables are processed in foreign-key order; multi-tenancy is separated with `clinic_id`.

**Route optimization: deliberately simple.** The day's appointments are ordered with *nearest-neighbor* (greedy), using straight-line Haversine distance ([route_optimizer.dart](mobile/lib/util/route_optimizer.dart)). For 10-15 stops O(N²) is enough; adding a full TSP solver or a maps API would be extra complexity and cost at this scale. Because the computation runs on the device, routing works offline too. It does not account for the road network, which is a known limit.

**Anything that depends on a real server is called out.** Features that need internet, like SMS and PDF generation, were designed with their offline behavior stated.

## Features

- Animal records (quick lookup by ear tag), herd-level bulk actions, pregnancy tracking
- Examination records, offline photo capture, and a chronological photo comparison for the same animal
- Drugs and stock: atomic stock deduction with each examination, stock ledger
- Appointment calendar and daily route (ordered stops on a map, total km)
- Vaccination plan templates and a scheduled job that scans upcoming vaccinations
- Farmer portal (SMS link), debt/payment tracking, digital prescription PDF, animal QR labels
- Disease spread map, daily PDF report
- Clinic analytics: vet performance, drug consumption, revenue
- Free / Premium plan split (routing, farmer portal and map are locked in Premium)

## Project structure

```
backend/   Laravel 13 API (sync services, SMS queue, PDF, analytics)
web/       Nuxt 4 clinic panel and farmer portal
mobile/    Flutter app (Drift, sync manager, map)
docs/      Design decisions: data model (32 tables), sync protocol, milestone plan (in Turkish)
logo/      Brand assets
```

Development docs live under `docs/` and are the source of truth for decisions ([plan.md](docs/plan.md), [data-model.md](docs/data-model.md), [sync-api.md](docs/sync-api.md)). They are written in Turkish.

## Running it

```bash
cp .env.example .env
docker compose up -d                       # Laravel + PostgreSQL + Nuxt
docker compose exec backend php artisan migrate --seed
```

For mobile, under `mobile/`:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # for the Android emulator
```

The seeder creates a demo clinic with farmers, animals and examinations.

## Status and known limits

An honest picture, because this is a portfolio project and not a system in production use:

- **SMS is not real.** `LogSmsSender` writes the message to the log; nothing reaches a phone. The driver interface is ready, but no real provider is connected.
- **Sync tests.** The backend has integration tests for the sync flow; the end-to-end mobile flow was tried on an emulator/device (appointment pull, examination and photo push). **The conflict scenario where two devices edit the same record offline has not been verified on a device yet.**
- **Routing** uses straight-line distance, not the road network.
- The disease map on the web is a simple visualization for now; the mobile side uses `flutter_map`.
- A production deploy guide (`docs/deploy-railway.md`) is ready; no permanent live environment is kept in this repo.
