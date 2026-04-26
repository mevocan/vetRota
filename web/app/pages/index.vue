<script setup lang="ts">
const auth = useAuthStore()

if (import.meta.client && !auth.isAuthenticated) {
  await navigateTo('/login')
}
</script>

<template>
  <UContainer class="py-12">
    <UCard>
      <template #header>
        <h1 class="text-2xl font-semibold">
          VetRota Panel
        </h1>
      </template>

      <div v-if="auth.user" class="space-y-2">
        <p>
          Hoş geldiniz, <strong>{{ auth.user.name }}</strong>
        </p>
        <p class="text-sm text-neutral-500">
          {{ auth.user.email }}
        </p>
        <UButton color="primary" variant="subtle" @click="auth.logout(); navigateTo('/login')">
          Çıkış yap
        </UButton>
      </div>
      <div v-else>
        <UButton to="/login" color="primary">
          Giriş yap
        </UButton>
      </div>
    </UCard>
  </UContainer>
</template>
