<script setup lang="ts">
interface Animal {
  id: string
  ear_tag: string | null
  name: string | null
  species: string
  gender: string
  status: string
  birth_date: string | null
  farmer: { id: string; first_name: string; last_name: string; phone: string } | null
  village: { id: string; name: string; district: string; city: string } | null
  created_at: string
}

interface Paginated<T> {
  data: T[]
  current_page: number
  last_page: number
  per_page: number
  total: number
}

const search = ref('')
const speciesFilter = ref<string | undefined>(undefined)
const page = ref(1)

const speciesOptions = [
  { label: 'Tümü', value: undefined },
  { label: 'Sığır', value: 'cattle' },
  { label: 'Koyun', value: 'sheep' },
  { label: 'Keçi', value: 'goat' },
  { label: 'Kanatlı', value: 'poultry' },
  { label: 'Diğer', value: 'other' }
]

const speciesLabel: Record<string, string> = {
  cattle: 'Sığır',
  sheep: 'Koyun',
  goat: 'Keçi',
  poultry: 'Kanatlı',
  other: 'Diğer'
}

const genderLabel: Record<string, string> = {
  male: 'Erkek',
  female: 'Dişi',
  unknown: 'Belirsiz'
}

const queryString = computed(() => {
  const params = new URLSearchParams()
  if (search.value) params.set('search', search.value)
  if (speciesFilter.value) params.set('species', speciesFilter.value)
  params.set('page', String(page.value))
  return params.toString()
})

const { data, pending, refresh } = await useApiFetch<Paginated<Animal>>(
  () => `/animals?${queryString.value}`,
  { watch: [queryString], lazy: true }
)

watch([search, speciesFilter], () => { page.value = 1 })
</script>

<template>
  <div class="space-y-4">
    <div class="flex items-center gap-3 flex-wrap">
      <UInput
        v-model="search"
        placeholder="Küpe no veya isim ara..."
        icon="i-lucide-search"
        class="flex-1 min-w-64"
      />
      <USelect
        v-model="speciesFilter"
        :items="speciesOptions"
        value-key="value"
        placeholder="Tür filtresi"
        class="w-44"
      />
      <UButton to="/animals/new" color="primary" icon="i-lucide-plus">
        Yeni hayvan
      </UButton>
    </div>

    <UCard :ui="{ body: 'p-0' }">
      <div v-if="pending" class="p-12 text-center text-sm text-neutral-500">
        Yükleniyor...
      </div>

      <div v-else-if="!data?.data?.length" class="p-12 text-center">
        <UIcon name="i-lucide-paw-print" class="w-10 h-10 text-neutral-300 mx-auto mb-3" />
        <p class="text-sm text-neutral-600 mb-4">
          {{ search || speciesFilter ? 'Filtrelere uyan hayvan bulunamadı.' : 'Henüz hayvan kaydı yok.' }}
        </p>
        <UButton to="/animals/new" color="primary" icon="i-lucide-plus">
          Yeni hayvan ekle
        </UButton>
      </div>

      <table v-else class="w-full text-sm">
        <thead class="bg-neutral-50">
          <tr class="text-left text-xs uppercase tracking-wide text-neutral-500">
            <th class="px-4 py-2.5 font-semibold">Küpe / İsim</th>
            <th class="px-4 py-2.5 font-semibold">Tür</th>
            <th class="px-4 py-2.5 font-semibold">Cinsiyet</th>
            <th class="px-4 py-2.5 font-semibold">Çiftçi</th>
            <th class="px-4 py-2.5 font-semibold">Köy</th>
            <th class="px-4 py-2.5 font-semibold">Durum</th>
            <th class="px-4 py-2.5" />
          </tr>
        </thead>
        <tbody class="divide-y divide-neutral-200">
          <tr v-for="animal in data.data" :key="animal.id" class="hover:bg-neutral-50">
            <td class="px-4 py-3">
              <NuxtLink :to="`/animals/${animal.id}`" class="font-medium hover:text-primary-600">
                <span class="font-mono">{{ animal.ear_tag ?? '—' }}</span>
                <span v-if="animal.name" class="text-neutral-500 ml-2">{{ animal.name }}</span>
              </NuxtLink>
            </td>
            <td class="px-4 py-3">{{ speciesLabel[animal.species] ?? animal.species }}</td>
            <td class="px-4 py-3">{{ genderLabel[animal.gender] ?? animal.gender }}</td>
            <td class="px-4 py-3">
              <span v-if="animal.farmer">{{ animal.farmer.first_name }} {{ animal.farmer.last_name }}</span>
              <span v-else class="text-neutral-400">—</span>
            </td>
            <td class="px-4 py-3">{{ animal.village?.name ?? '—' }}</td>
            <td class="px-4 py-3">
              <UBadge :color="animal.status === 'alive' ? 'primary' : 'neutral'" variant="soft" size="sm">
                {{ animal.status === 'alive' ? 'Canlı' : animal.status }}
              </UBadge>
            </td>
            <td class="px-4 py-3 text-right">
              <UButton :to="`/animals/${animal.id}`" size="xs" variant="ghost" icon="i-lucide-eye" />
            </td>
          </tr>
        </tbody>
      </table>
    </UCard>

    <div v-if="data && data.last_page > 1" class="flex items-center justify-between text-sm">
      <span class="text-neutral-500">
        {{ data.total }} kayıt · Sayfa {{ data.current_page }} / {{ data.last_page }}
      </span>
      <div class="flex gap-1">
        <UButton size="xs" variant="ghost" icon="i-lucide-chevron-left" :disabled="page <= 1" @click="page--" />
        <UButton size="xs" variant="ghost" icon="i-lucide-chevron-right" :disabled="page >= data.last_page" @click="page++" />
      </div>
    </div>
  </div>
</template>
