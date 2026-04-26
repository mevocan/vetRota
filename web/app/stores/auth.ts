import { defineStore } from 'pinia'

interface User {
  id: number
  name: string
  email: string
}

interface LoginResponse {
  access_token: string
  token_type: string
  expires_in: number
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: null as string | null,
    user: null as User | null
  }),

  getters: {
    isAuthenticated: state => !!state.token
  },

  actions: {
    async login(email: string, password: string) {
      const config = useRuntimeConfig()
      const data = await $fetch<LoginResponse>(`${config.public.apiBase}/auth/login`, {
        method: 'POST',
        body: { email, password },
        headers: { Accept: 'application/json' }
      })

      this.token = data.access_token

      this.user = await $fetch<User>(`${config.public.apiBase}/auth/me`, {
        headers: {
          Authorization: `Bearer ${data.access_token}`,
          Accept: 'application/json'
        }
      })
    },

    logout() {
      this.token = null
      this.user = null
    }
  }
})
