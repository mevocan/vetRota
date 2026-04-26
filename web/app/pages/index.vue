<script setup lang="ts">
const auth = useAuthStore()

interface AnimalListResponse {
  data: Array<{ id: string; ear_tag: string | null; name: string | null; created_at: string }>
  total: number
}

const { data: animals } = await useApiFetch<AnimalListResponse>('/animals?per_page=5', { lazy: true })

const stats = computed(() => [
  { label: 'Toplam hayvan', value: animals.value?.total ?? 0, icon: 'i-lucide-paw-print', color: 'primary' },
  { label: 'Bugün muayene', value: 0, icon: 'i-lucide-stethoscope', color: 'neutral' },
  { label: 'Bekleyen randevu', value: 0, icon: 'i-lucide-calendar', color: 'neutral' },
  { label: 'Düşük stok', value: 0, icon: 'i-lucide-pill', color: 'neutral' }
])
</script>

<template>
  <div class="space-y-6">
    <div>
      <h2 class="text-2xl font-bold mb-1">
        Hoş geldiniz, {{ auth.user?.name?.split(' ')?.[0] ?? '' }}
      </h2>
      <p class="text-neutral-500 text-sm">
        Bugün {{ new Date().toLocaleDateString('tr-TR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }) }}
      </p>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <UCard v-for="stat in stats" :key="stat.label">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-lg bg-primary-50 text-primary-700 flex items-center justify-center">
            <UIcon :name="stat.icon" class="w-5 h-5" />
          </div>
          <div>
            <div class="text-2xl font-bold leading-none">
              {{ stat.value }}
            </div>
            <div class="text-xs text-neutral-500 mt-1">
              {{ stat.label }}
            </div>
          </div>
        </div>
      </UCard>
    </div>

    <UCard>
      <template #header>
        <div class="flex items-center justify-between">
          <h3 class="font-semibold">
            Son hayvan kayıtları
          </h3>
          <UButton to="/animals" size="xs" variant="ghost" trailing-icon="i-lucide-arrow-right">
            Tümü
          </UButton>
        </div>
      </template>

      <div v-if="!animals?.data?.length" class="text-center py-8 text-sm text-neutral-500">
        Henüz hayvan kaydı yok.
        <NuxtLink to="/animals/new" class="text-primary-600 ml-1">
          İlk hayvanı ekleyin
        </NuxtLink>
      </div>
      <ul v-else class="divide-y divide-neutral-200">
        <li v-for="a in animals.data" :key="a.id" class="py-3 flex items-center gap-3">
          <UIcon name="i-lucide-paw-print" class="text-neutral-400 w-4 h-4" />
          <div class="flex-1">
            <NuxtLink :to="`/animals/${a.id}`" class="text-sm font-medium hover:text-primary-600">
              {{ a.ear_tag ?? a.name ?? 'İsimsiz' }}
            </NuxtLink>
          </div>
          <span class="text-xs text-neutral-500">
            {{ new Date(a.created_at).toLocaleDateString('tr-TR') }}
          </span>
        </li>
      </ul>
    </UCard>
  </div>
</template>
