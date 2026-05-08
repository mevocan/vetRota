// Login + ciftci portal disindaki tum sayfalar icin auth zorunlu.
const PUBLIC_PATHS = ['/login']
const PUBLIC_PREFIXES = ['/farmer/'] // /farmer/[token] — SMS link'i

function isPublic(path: string): boolean {
  if (PUBLIC_PATHS.includes(path)) return true
  return PUBLIC_PREFIXES.some(prefix => path.startsWith(prefix))
}

export default defineNuxtRouteMiddleware((to) => {
  if (import.meta.server) return // hydrate client'ta calisir

  const auth = useAuthStore()
  if (!auth.isAuthenticated && !isPublic(to.path)) {
    return navigateTo('/login')
  }
  if (auth.isAuthenticated && to.path === '/login') {
    return navigateTo('/')
  }
})
