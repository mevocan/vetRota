# M1 İlerleme Takibi

> **Amaç:** M1 milestone'unun adım adım durumunu kalıcı kayda almak. Context
> sıfırlanırsa veya yeni oturum açılırsa, Claude Code bu dosyayı okuyarak
> kaldığı yerden devam edebilir.
>
> **Güncelleme kuralı:** Her adım bittikten sonra Claude Code burayı günceller
> (durum, commit hash, notlar). Tamamlanan adımları silme — geçmiş referans.

---

## Sabit Kararlar (kullanıcı onayı alındı)

| Konu | Karar |
|---|---|
| Node paket yöneticisi | npm |
| JWT paketi | `php-open-source-saver/jwt-auth` |
| Backend container modeli | `php artisan serve` (MVP) |
| PostgreSQL sürümü | 18 (en güncel stabil) |
| `.mcp.json` konumu | `backend/` |
| Commit'leri kim atar | Claude Code (kullanıcı izni var) |

---

## Adım Durumu

| # | Adım | Durum | Commit | Not |
|---|---|---|---|---|
| 0 | Dokümantasyon + `.gitignore` + PG 18 düzeltmesi | ✅ Tamam | `3ce30c4` | `dev-tools.md` takipli, AI agent satırları eklendi |
| 1 | Docker Compose iskeleti (`docker-compose.yml` + `.env.example`) | ✅ Tamam | `a7b1b97` | `docker compose config` syntax OK; up edilmedi (Laravel/Nuxt kurulmadan boş) |
| 2 | Laravel 13 projesi (`backend/`) | ✅ Tamam | `fa84aeb` | Laravel Framework 13.6.0; WSL içinden `docker run composer:latest create-project` ile kuruldu (UNC path mount sorunu nedeniyle WSL native path zorunlu) |
| 3 | PostgreSQL bağlantısı + ilk migration | ✅ Tamam | `7525a9d` | PG 18.3 healthy; backend HTTP 200; 9 tablo migrate edildi (`users`, `cache`, `jobs`, `sessions` vb.); custom Dockerfile ile sonraki up'lar hızlı |
| 4 | JWT auth iskeleti | ✅ Tamam | _bu commit_ | `php-open-source-saver/jwt-auth` v2.9; `POST /api/v1/auth/login` JWT döner; seed user `ahmet@vetrota.com.tr / sifre1234`; `/me`, `/logout`, `/refresh` endpoint'leri de var |
| 5 | Laravel Boost kurulumu | ⏳ Sırada | — | CLAUDE.md.backup şart |
| 6 | Nuxt MCP `.mcp.json`'a eklenir | ⬜ Bekliyor | — | HTTP server satırı |
| 7 | Nuxt 4 projesi (`web/`) | ⬜ Bekliyor | — | `npx nuxi@latest init web --packageManager npm` |
| 8 | Nuxt UI v4 + marka rengi | ⬜ Bekliyor | — | `vetrota-green` palette + DM Sans |
| 9 | Nuxt UI Skill + Pinia + login sayfası | ⬜ Bekliyor | — | `UAuthForm` |
| 10 | Flutter 3.41 projesi + login | ⬜ Bekliyor | — | `flutter create mobile --org tr.com.vetrota` |
| 11 | M1 doğrulama + CLAUDE.md "Mevcut Durum" güncelleme | ⬜ Bekliyor | — | dev-tools.md § 2.4 checklist |

**Durum sembolleri:** ✅ Tamam · ⏳ Devam ediyor · ⚠️ Bloke · ⬜ Bekliyor

---

## Açık Sorular / Notlar

- **WSL UNC path uyarısı:** Claude Code Git Bash (Windows) üzerinden çalışıyor
  ama working dir `\\wsl.localhost\Ubuntu\...` UNC. Docker Desktop UNC path
  mount edemiyor. Çözüm: tüm `docker run` komutları
  `wsl -d Ubuntu -- bash -c "cd /home/mcdag/projects/vetrota && docker ..."`
  şeklinde WSL içinden çalıştırılıyor. Aynı şey `docker compose up` için de
  geçerli olacak.
- Laravel kurulumu sırasında composer otomatik `php artisan migrate` koştu
  (SQLite'a, `database/database.sqlite` oluşturuldu). Adım 3'te PG'ye
  geçince bu dosya silinecek/ignore edilecek.
- `.claude/` dizini untracked; içinde Claude Code yerel ayarları olabilir.
  İlerde `.claude/settings.local.json` için ayrı gitignore satırı eklenebilir.
- Boost kurulumu interaktif — `php artisan boost:install` çalıştırılırken
  CLAUDE.md'nin ezilmesini engellemek için önce `cp CLAUDE.md CLAUDE.md.backup`.
- Adım 11'de CLAUDE.md "7. Mevcut Durum" bölümü "M2 sırada" olarak güncellenecek.

---

## Sonraki Oturum İçin Hızlı Başlangıç

Yeni bir Claude Code oturumu açıldığında:

1. `CLAUDE.md` otomatik yüklenir.
2. Bu dosyayı (`docs/m1-progress.md`) oku.
3. İlk ⏳ veya ⬜ olan adımı bul, oradan devam et.
4. Adım bittikten sonra bu dosyadaki tabloyu güncelle ve commit at.
