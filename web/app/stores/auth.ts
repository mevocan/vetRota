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

const TOKEN_KEY = 'vetrota.token'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: null as string | null,
    user: null as User | null
  }),

  getters: {
    isAuthenticated: state => !!state.token
  },

  actions: {
    hydrate() {
      if (import.meta.client) {
        this.token = localStorage.getItem(TOKEN_KEY)
      }
    },

    async login(email: string, password: string) {
      const config = useRuntimeConfig()
      const data = await $fetch<LoginResponse>(`${config.public.apiBase}/auth/login`, {
        method: 'POST',
        body: { email, password },
        headers: { Accept: 'application/json' }
      })

      this.token = data.access_token
      if (import.meta.client) {
        localStorage.setItem(TOKEN_KEY, data.access_token)
      }

      await this.fetchUser()
    },

    async fetchUser() {
      if (!this.token) return
      const config = useRuntimeConfig()
      this.user = await $fetch<User>(`${config.public.apiBase}/auth/me`, {
        headers: {
          Authorization: `Bearer ${this.token}`,
          Accept: 'application/json'
        }
      })
    },

    logout() {
      this.token = null
      this.user = null
      if (import.meta.client) {
        localStorage.removeItem(TOKEN_KEY)
      }
    }
  }
})
