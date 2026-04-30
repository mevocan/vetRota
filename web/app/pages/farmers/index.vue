<script setup lang="ts">
interface Farmer {
  id: string
  first_name: string
  last_name: string
  phone: string
  email: string | null
  balance: string
  animals_count: number
  village: { id: string; name: string; district: string; city: string } | null
}

interface Paginated<T> {
  data: T[]
  current_page: number
  last_page: number
  per_page: number
  total: number
}

const search = ref('')
const page = ref(1)

const queryString = computed(() => {
  const params = new URLSearchParams()
  if (search.value) params.set('search', search.value)
  params.set('page', String(page.value))
  return params.toString()
})

const { data, pending } = await useApiFetch<Paginated<Farmer>>(
  () => `/farmers?${queryString.value}`,
  { watch: [queryString], lazy: true }
)

watch(search, () => { page.value = 1 })

function formatBalance(b: string) {
  const n = parseFloat(b)
  if (Number.isNaN(n) || n === 0) return '—'
  return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 2 }).format(n)
}
</script>

<template>
  <div class="space-y-4">
    <div class="flex items-center gap-3 flex-wrap">
      <UInput
        v-model="search"
        placeholder="Ad, soyad veya telefon ara..."
        icon="i-lucide-search"
        class="flex-1 min-w-64"
      />
      <UButton to="/farmers/new" color="primary" icon="i-lucide-plus">
        Yeni çiftçi
      </UButton>
    </div>

    <UCard :ui="{ body: 'p-0' }">
      <div v-if="pending" class="p-12 text-center text-sm text-neutral-500">
        Yükleniyor...
      </div>

      <div v-else-if="!data?.data?.length" class="p-12 text-center">
        <UIcon name="i-lucide-users" class="w-10 h-10 text-neutral-300 mx-auto mb-3" />
        <p class="text-sm text-neutral-600 mb-4">
          {{ search ? 'Aramaya uyan çiftçi bulunamadı.' : 'Henüz çiftçi kaydı yok.' }}
        </p>
        <UButton to="/farmers/new" color="primary" icon="i-lucide-plus">
          Yeni çiftçi ekle
        </UButton>
      </div>

      <table v-else class="w-full text-sm">
        <thead class="bg-neutral-50">
          <tr class="text-left text-xs uppercase tracking-wide text-neutral-500">
            <th class="px-4 py-2.5 font-semibold">Ad Soyad</th>
            <th class="px-4 py-2.5 font-semibold">Telefon</th>
            <th class="px-4 py-2.5 font-semibold">Köy</th>
            <th class="px-4 py-2.5 font-semibold">Hayvan</th>
            <th class="px-4 py-2.5 font-semibold">Bakiye</th>
            <th class="px-4 py-2.5" />
          </tr>
        </thead>
        <tbody class="divide-y divide-neutral-200">
          <tr v-for="farmer in data.data" :key="farmer.id" class="hover:bg-neutral-50">
            <td class="px-4 py-3">
              <NuxtLink :to="`/farmers/${farmer.id}`" class="font-medium hover:text-primary-600">
                {{ farmer.first_name }} {{ farmer.last_name }}
              </NuxtLink>
              <div v-if="farmer.email" class="text-xs text-neutral-500">
                {{ farmer.email }}
              </div>
            </td>
            <td class="px-4 py-3 font-mono text-xs">
              {{ farmer.phone }}
            </td>
            <td class="px-4 py-3">
              <span v-if="farmer.village">{{ farmer.village.name }} <span class="text-neutral-400">/ {{ farmer.village.district }}</span></span>
              <span v-else class="text-neutral-400">—</span>
            </td>
            <td class="px-4 py-3">
              <UBadge variant="soft" color="neutral" size="sm">
                {{ farmer.animals_count }}
              </UBadge>
            </td>
            <td class="px-4 py-3" :class="parseFloat(farmer.balance) < 0 ? 'text-red-600 font-medium' : ''">
              {{ formatBalance(farmer.balance) }}
            </td>
            <td class="px-4 py-3 text-right">
              <UButton :to="`/farmers/${farmer.id}`" size="xs" variant="ghost" icon="i-lucide-eye" />
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
