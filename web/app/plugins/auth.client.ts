// Sayfa yenilemede token'i localStorage'dan geri yukler.
export default defineNuxtPlugin(async () => {
  const auth = useAuthStore()
  auth.hydrate()
  if (auth.token && !auth.user) {
    try {
      await auth.fetchUser()
    } catch {
      auth.logout()
    }
  }
})
