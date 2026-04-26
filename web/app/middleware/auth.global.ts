// Login disindaki tum sayfalar icin auth zorunlu.
const PUBLIC_PATHS = ['/login']

export default defineNuxtRouteMiddleware((to) => {
  if (import.meta.server) return // hydrate client'ta calisir

  const auth = useAuthStore()
  if (!auth.isAuthenticated && !PUBLIC_PATHS.includes(to.path)) {
    return navigateTo('/login')
  }
  if (auth.isAuthenticated && to.path === '/login') {
    return navigateTo('/')
  }
})
