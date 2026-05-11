import type { UseFetchOptions } from 'nuxt/app'

// JWT header'i otomatik ekleyen, 401'de logout'a yonlendiren $fetch wrapper.
export function useApi() {
  const auth = useAuthStore()
  const config = useRuntimeConfig()
  const baseURL = config.public.apiBase

  const apiFetch = $fetch.create({
    baseURL,
    onRequest({ options }) {
      const headers = new Headers(options.headers)
      headers.set('Accept', 'application/json')
      if (auth.token) {
        headers.set('Authorization', `Bearer ${auth.token}`)
      }
      options.headers = headers
    },
    onResponseError({ response }) {
      if (response.status === 401) {
        auth.logout()
        navigateTo('/login')
      }
    }
  })

  return { apiFetch }
}

// useFetch versiyonu (SSR + reactive icin).
export function useApiFetch<T>(url: string | (() => string), options: UseFetchOptions<T> = {}) {
  const auth = useAuthStore()
  const config = useRuntimeConfig()

  return useFetch<T>(url, {
    baseURL: config.public.apiBase,
    // Auth-gerektiren panel sayfalari SSR'da JWT'ye erisemiyor
    // (localStorage server'da yok); request 401 doner, sayfa bos kalir.
    // Login arkasi SPA modu: sadece client-side fetch.
    server: false,
    ...options,
    onRequest(ctx) {
      const headers = new Headers(ctx.options.headers)
      headers.set('Accept', 'application/json')
      if (auth.token) {
        headers.set('Authorization', `Bearer ${auth.token}`)
      }
      ctx.options.headers = headers
      if (typeof options.onRequest === 'function') options.onRequest(ctx)
    },
    onResponseError(ctx) {
      if (ctx.response.status === 401) {
        auth.logout()
        navigateTo('/login')
      }
      if (typeof options.onResponseError === 'function') options.onResponseError(ctx)
    }
  })
}
