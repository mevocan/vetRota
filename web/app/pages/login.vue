<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'

definePageMeta({ layout: 'auth' })

const auth = useAuthStore()

const schema = z.object({
  email: z.string().email('Geçerli bir e-posta giriniz.'),
  password: z.string().min(6, 'Şifre en az 6 karakter olmalı.')
})

type Schema = z.output<typeof schema>

const state = reactive({
  email: '',
  password: ''
})

const errorMessage = ref<string | null>(null)
const loading = ref(false)

async function onSubmit(event: FormSubmitEvent<Schema>) {
  errorMessage.value = null
  loading.value = true
  try {
    await auth.login(event.data.email, event.data.password)
    await navigateTo('/')
  } catch (err: unknown) {
    const fetchErr = err as { data?: { message?: string } }
    errorMessage.value = fetchErr?.data?.message ?? 'Giriş başarısız.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <UContainer class="flex min-h-screen items-center justify-center">
    <UCard class="w-full max-w-md">
      <template #header>
        <div class="flex flex-col items-center gap-2 py-2">
          <img src="/branding/logo.png" alt="VetRota" class="h-16 w-auto">
          <p class="text-sm text-neutral-500">
            Gezici veteriner saha paneli
          </p>
        </div>
      </template>

      <UForm
        :schema="schema"
        :state="state"
        class="space-y-4"
        @submit="onSubmit"
      >
        <UFormField label="E-posta" name="email" required>
          <UInput v-model="state.email" type="email" autocomplete="email" class="w-full" />
        </UFormField>

        <UFormField label="Şifre" name="password" required>
          <UInput v-model="state.password" type="password" autocomplete="current-password" class="w-full" />
        </UFormField>

        <UAlert
          v-if="errorMessage"
          color="error"
          variant="soft"
          :title="errorMessage"
        />

        <UButton type="submit" color="primary" block :loading="loading">
          Giriş yap
        </UButton>
      </UForm>
    </UCard>
  </UContainer>
</template>
