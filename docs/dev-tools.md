# VetRota — Geliştirme Araçları (AI Asistan Stack'i)

> **Amaç:** Bu doküman, VetRota'yı geliştirirken Claude Code'un (ve gelecekte
> kullanılabilecek diğer AI agent'ların) doğru ve güncel context ile
> çalışmasını sağlayan araçların kurulum, kullanım ve güncelleme
> rehberidir. **Son kullanıcıya hiçbir şey göstermez** — sadece
> geliştirme verimliliği için.

---

## 1. Genel Bakış

| Araç | Ne işe yarar | Nereye kurulur |
|---|---|---|
| **Laravel Boost** | Claude Code'a güncel Laravel 13 best practice'leri, MCP tool'ları (Tinker, DB query, log okuma vb.) ve 17.000+ parça Laravel ekosistem bilgisi sağlar | Laravel projesi (`backend/`) |
| **Nuxt MCP Server** | Claude Code'a Nuxt 4 dokümantasyonuna anlık erişim verir | `.mcp.json` (proje kökü) |
| **Nuxt UI Skill** | Claude Code'un Nuxt UI v4 component'lerini doğru kullanmasını sağlar (125+ component, semantic color sistemi, layout patterns) | `.claude/skills/` |

**Bu üçü olmadan da geliştirilebilir, ama:**
- Boost olmadan Claude Code Laravel 11 veya öncesi konvansiyonlara
  düşebilir; yanlış syntax üretebilir
- Nuxt MCP olmadan Claude Code Nuxt 3 (eski) yapısı ile kod yazabilir
- Nuxt UI Skill olmadan custom Tailwind component yazmaya kalkar, halbuki
  hazır UModal/UTable/UForm var

---

## 2. Kurulum Sırası (M1'in parçası)

Bu sıralama M1'in tamamlandı kriterinin parçasıdır.

### 2.1 Laravel Boost

```bash
cd backend/
composer require laravel/boost --dev
php artisan boost:install
```

Kurulum interaktif, soruları sırayla şöyle cevapla:

1. **Hangi agent'ları kullanıyorsun?** → `Claude Code` seç (boşluk + enter).
2. **Mevcut `CLAUDE.md` var mı, üzerine yazılsın mı?** → **HAYIR.** VetRota'nın
   kendi `CLAUDE.md` dosyası kök dizinde, içinde proje kuralları var.
   Boost'un içeriğini ayrı bir dosyaya (örn. `.claude/boost-rules.md`)
   yazmasını seç. Eğer böyle bir seçenek sunulmazsa, kurulum öncesi
   kendi `CLAUDE.md` dosyanı yedekle:
   ```bash
   cp CLAUDE.md CLAUDE.md.backup
   php artisan boost:install
   # Boost'un ürettiklerinden işine yarayanları kendi CLAUDE.md'ne ekle
   # sonra backup'ı geri yaz
   ```

Boost şunları üretir:
- `.mcp.json` — Claude Code'un MCP server'lara nasıl bağlanacağı
- `boost.json` — Boost'un kendi config'i
- `AGENTS.md` (varsa) — diğer agent'lar için

### 2.2 Nuxt MCP Server

Nuxt MCP **HTTP transport** kullanır, kurulum olarak `.mcp.json`'a satır
eklemekten ibaret. Boost zaten bu dosyayı üretmiş olur; üstüne ekle:

```json
{
  "mcpServers": {
    "laravel-boost": { "...": "Boost zaten ekledi" },
    "nuxt": {
      "type": "http",
      "url": "https://mcp.nuxt.com/mcp"
    }
  }
}
```

Claude Code'u yeniden başlat, MCP listesinde `nuxt` görünmeli.

### 2.3 Nuxt UI Skill

Frontend dizininde:

```bash
cd ../frontend/   # veya web/, dizin adına göre değişir
npx skills add nuxt/ui --agent claude-code
```

Bu komut `.claude/skills/nuxt-ui/` altına SKILL.md ve referans dosyaları
indirir. Claude Code chat'inde `/nuxt-ui` yazarak skill'i invoke
edebilirsin (otomatik yüklenir, manuel çağrı opsiyonel).

### 2.4 Doğrulama

Her şey çalışıyor mu kontrol için:

```bash
# Laravel Boost MCP server çalışıyor mu?
cd backend/
php artisan boost:mcp:test   # varsa; yoksa Claude Code'da MCP listesini aç

# Nuxt MCP'ye ping
curl -I https://mcp.nuxt.com/mcp   # 200 veya 405 dönmeli (HTTP MCP)

# Nuxt UI Skill yüklü mü?
ls frontend/.claude/skills/nuxt-ui/SKILL.md
```

Claude Code'da yeni bir oturum aç ve sor: "Hangi MCP tool'lara erişimin
var?" — listesinde `boost` ve `nuxt` görmeli, ayrıca `/nuxt-ui` skill
çağırıldığında doğru yüklenmeli.

---

## 3. `.gitignore` Kuralları

Bu dosyalar otomatik üretilir ve makineye/agent'a bağlı, repo'da
durmamalı:

```
# AI agent config (otomatik üretilir, regenerate edilebilir)
.mcp.json
boost.json
AGENTS.md
.claude/skills/   # skills CLI ile her zaman yeniden indirilebilir
```

**`CLAUDE.md` repo'da kalır** — VetRota'nın kendi proje kurallarını
içerir, kalıcı. Boost'un ürettiği ek kurallar varsa `.claude/boost-rules.md`
gibi ayrı bir dosyada tut, onu da repo'ya at.

---

## 4. Nuxt UI v4 — Marka Rengini Bağlama

Nuxt UI'ın default `primary` rengi mavidir. VetRota'nın yeşilini (`#2E7D32`)
bağlamak için iki dosya gerekir:

### 4.1 `app.config.ts`

```ts
export default defineAppConfig({
  ui: {
    colors: {
      primary: 'vetrota-green',
      neutral: 'slate'
    }
  }
})
```

### 4.2 `assets/css/main.css` (veya benzeri global CSS)

```css
@import "tailwindcss";
@import "@nuxt/ui";

@theme static {
  --color-vetrota-green-50:  #E8F5E9;
  --color-vetrota-green-100: #C8E6C9;
  --color-vetrota-green-200: #A5D6A7;
  --color-vetrota-green-300: #81C784;
  --color-vetrota-green-400: #66BB6A;
  --color-vetrota-green-500: #4CAF50;
  --color-vetrota-green-600: #2E7D32;  /* ana marka rengi */
  --color-vetrota-green-700: #1B5E20;
  --color-vetrota-green-800: #154518;
  --color-vetrota-green-900: #0D2C10;
  --color-vetrota-green-950: #061508;
}
```

Bu kurulum sonrası `<UButton color="primary">Kaydet</UButton>` otomatik
olarak `#2E7D32` arkaplan ile gelir. Uyarı turuncusu (`#FF9800`) için
`warning` semantic rengi Nuxt UI'da hazır, default değerleri yeterli;
isterse aynı yöntemle override edilebilir.

### 4.3 DM Sans Font

`nuxt.config.ts` içinde `@nuxt/fonts` modülü Nuxt UI ile gelir; `app.config.ts`'e ek:

```ts
ui: {
  fonts: {
    sans: 'DM Sans'
  }
}
```

---

## 5. Bakım ve Güncelleme

### Boost güncellenince

```bash
composer update laravel/boost --dev
php artisan boost:update
```

`boost:update` `.mcp.json` ve guideline dosyalarını yeniler. **Senin VetRota
CLAUDE.md'in etkilenmez** çünkü gitignore'da değil.

### Nuxt UI Skill güncellenince

```bash
npx skills update nuxt/ui --agent claude-code
```

### Nuxt MCP Server

Otomatik — uzakta çalışır, Nuxt ekibi günceller. Sen bir şey yapmazsın.

---

## 6. MVP Dışı Tutulanlar (Bilinçli Olarak)

Bu araçlar **kullanıma alınmadı**, ihtiyaç olunca geri dönülecek:

- **Laravel AI SDK** — Uygulamaya AI özelliği eklemek için (chatbot,
  fotoğraftan teşhis, ses transkripti). VetRota MVP'sinde AI feature
  yok, gerekli değil. Sonradan eklemek tek `composer require laravel/ai`.
- **Laravel MCP** (kendi uygulamayı MCP server yapmak için) — VetRota
  bir SaaS, dış AI'lar tarafından sorgulanması gerekmiyor.
- **Nuxt UI MCP Server** — Nuxt UI'ın kendi MCP'si var ama Skill yeterli
  ve daha hızlı. MCP eklenirse network round-trip artar, Skill her şeyi
  context'e koyar.
- **LLMs.txt dosyalarının manuel indirilmesi** — MCP server'lar zaten
  canlı veri verir, statik snapshot tutmak gereksiz tekrar.

---

## 7. Sorun Giderme

| Sorun | Çözüm |
|---|---|
| `php artisan boost:install` "command not found" | `composer require laravel/boost --dev` çalıştırılmamış. Önce o. |
| `.mcp.json` yok | Boost kurulumu interaktif soruda Claude Code seçilmemiş. `php artisan boost:install` tekrar çalıştır. |
| Claude Code MCP listesinde `nuxt` görünmüyor | `.mcp.json`'a manuel eklenip Claude Code yeniden başlatılmadı. Restart. |
| `/nuxt-ui` skill bulunamadı | `frontend/.claude/skills/nuxt-ui/` yok. `npx skills add nuxt/ui --agent claude-code` tekrar çalıştır. |
| Nuxt UI button mavi geliyor | `app.config.ts`'de `primary: 'vetrota-green'` yok veya CSS'te custom palette yüklenmemiş. |
| Boost CLAUDE.md'mi ezdi | `CLAUDE.md.backup`'tan geri al, Boost'un ürettiklerini `.claude/boost-rules.md`'ye taşı. |

---

**Doküman Sonu.**
