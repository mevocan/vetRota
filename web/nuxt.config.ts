// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  modules: [
    '@nuxt/eslint',
    '@nuxt/ui',
    '@pinia/nuxt'
  ],

  devtools: {
    enabled: true
  },

  // MVP tek tema: light. Sistem tercihini takip etmesin, sayfa
  // wrapper'lari (bg-neutral-50) ile UCard arasinda kontrast bozulmasin.
  colorMode: {
    preference: 'light',
    fallback: 'light',
    classSuffix: '',
    storageKey: 'vetrota-color-mode-v2'
  },

  css: ['~/assets/css/main.css'],

  runtimeConfig: {
    // Sunucu tarafi (SSR / Nitro) icin: container icinde 'backend:8000'
    // docker network DNS uzerinden cozulur. Tarayicidan asla erisilemez.
    apiBaseServer: process.env.NUXT_API_BASE_SERVER || 'http://backend:8000/api/v1',
    public: {
      apiBase: process.env.NUXT_PUBLIC_API_BASE || 'http://localhost:8000/api/v1'
    }
  },

  compatibilityDate: '2025-01-15',

  app: {
    head: {
      title: 'VetRota',
      link: [
        { rel: 'icon', type: 'image/png', href: '/branding/favicon.png' }
      ]
    }
  },


  eslint: {
    config: {
      stylistic: {
        commaDangle: 'never',
        braceStyle: '1tbs'
      }
    }
  }
})
