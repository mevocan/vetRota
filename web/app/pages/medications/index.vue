<script setup lang="ts">
interface Stock {
  current_quantity: string
  critical_threshold: string | null
  earliest_expiry_at: string | null
  last_purchased_at: string | null
}

interface Drug {
  id: string
  name: string
  active_ingredient: string | null
  manufacturer: string | null
  drug_type: string
  unit: string
  package_size: string | null
  is_vaccine: boolean
  default_price: string | null
  stock: Stock | null
}

interface Paginated<T> {
  data: T[]
  current_page: number
  last_page: number
  total: number
}

const search = ref('')
const typeFilter = ref<string | undefined>(undefined)
const lowStockOnly = ref(false)
const page = ref(1)

const typeOptions = [
  { label: 'Tümü', value: undefined },
  { label: 'Antibiyotik', value: 'antibiotic' },
  { label: 'Aşı', value: 'vaccine' },
  { label: 'Antiparaziter', value: 'antiparasitic' },
  { label: 'Antienflamatuar', value: 'antiinflammatory' },
  { label: 'Ağrı kesici', value: 'analgesic' },
  { label: 'Vitamin', value: 'vitamin' },
  { label: 'Hormon', value: 'hormone' },
  { label: 'Diğer', value: 'other' }
]

const typeLabel: Record<string, string> = {
  antibiotic: 'Antibiyotik',
  vaccine: 'Aşı',
  antiparasitic: 'Antiparaziter',
  antiinflammatory: 'Antienflamatuar',
  analgesic: 'Ağrı kesici',
  vitamin: 'Vitamin',
  hormone: 'Hormon',
  other: 'Diğer'
}

const queryString = computed(() => {
  const p = new URLSearchParams()
  if (search.value) p.set('search', search.value)
  if (typeFilter.value) p.set('drug_type', typeFilter.value)
  if (lowStockOnly.value) p.set('low_stock_only', '1')
  p.set('page', String(page.value))
  return p.toString()
})

const { data, pending } = await useApiFetch<Paginated<Drug>>(
  () => `/drugs?${queryString.value}`,
  { watch: [queryString], lazy: true }
)

watch([search, typeFilter, lowStockOnly], () => { page.value = 1 })

function isLow(s: Stock | null): boolean {
  if (!s || s.critical_threshold === null) return false
  return parseFloat(s.current_quantity) <= parseFloat(s.critical_threshold)
}

function fmtQty(s: Stock | null, unit: string): string {
  if (!s) return '—'
  const n = parseFloat(s.current_quantity)
  return `${n} ${unit}`
}
</script>

<template>
  <div class="space-y-4">
    <div class="flex items-center gap-3 flex-wrap">
      <UInput v-model="search" placeholder="İsim, etken madde, üretici..." icon="i-lucide-search" class="flex-1 min-w-64" />
      <USelect v-model="typeFilter" :items="typeOptions" value-key="value" placeholder="Tür" class="w-44" />
      <UCheckbox v-model="lowStockOnly" label="Sadece kritik stok" />
      <UButton to="/medications/new" color="primary" icon="i-lucide-plus">
        Yeni ilaç
      </UButton>
    </div>

    <UCard :ui="{ body: 'p-0' }">
      <div v-if="pending" class="p-12 text-center text-sm text-neutral-500">
        Yükleniyor...
      </div>
      <div v-else-if="!data?.data?.length" class="p-12 text-center">
        <UIcon name="i-lucide-pill" class="w-10 h-10 text-neutral-300 mx-auto mb-3" />
        <p class="text-sm text-neutral-600 mb-4">
          {{ search || typeFilter || lowStockOnly ? 'Filtrelere uyan ilaç bulunamadı.' : 'Henüz ilaç kaydı yok.' }}
        </p>
        <UButton to="/medications/new" color="primary" icon="i-lucide-plus">
          Yeni ilaç ekle
        </UButton>
      </div>
      <table v-else class="w-full text-sm">
        <thead class="bg-neutral-50">
          <tr class="text-left text-xs uppercase tracking-wide text-neutral-500">
            <th class="px-4 py-2.5 font-semibold">İsim</th>
            <th class="px-4 py-2.5 font-semibold">Tür</th>
            <th class="px-4 py-2.5 font-semibold">Stok</th>
            <th class="px-4 py-2.5 font-semibold">SKT</th>
            <th class="px-4 py-2.5 font-semibold">Üretici</th>
            <th class="px-4 py-2.5" />
          </tr>
        </thead>
        <tbody class="divide-y divide-neutral-200">
          <tr
            v-for="drug in data.data"
            :key="drug.id"
            class="hover:bg-neutral-50"
            :class="isLow(drug.stock) ? 'bg-amber-50/50' : ''"
          >
            <td class="px-4 py-3">
              <NuxtLink :to="`/medications/${drug.id}`" class="font-medium hover:text-primary-600">
                {{ drug.name }}
              </NuxtLink>
              <div v-if="drug.active_ingredient" class="text-xs text-neutral-500">
                {{ drug.active_ingredient }}
              </div>
            </td>
            <td class="px-4 py-3">
              <UBadge :color="drug.is_vaccine ? 'primary' : 'neutral'" variant="soft" size="sm">
                {{ typeLabel[drug.drug_type] ?? drug.drug_type }}
              </UBadge>
            </td>
            <td class="px-4 py-3 font-mono">
              <span :class="isLow(drug.stock) ? 'text-amber-700 font-bold' : ''">
                {{ fmtQty(drug.stock, drug.unit) }}
              </span>
              <UBadge v-if="isLow(drug.stock)" color="warning" variant="soft" size="sm" class="ml-2">
                Kritik
              </UBadge>
            </td>
            <td class="px-4 py-3 text-xs text-neutral-500">
              {{ drug.stock?.earliest_expiry_at?.slice(0, 10) ?? '—' }}
            </td>
            <td class="px-4 py-3 text-xs text-neutral-500">
              {{ drug.manufacturer ?? '—' }}
            </td>
            <td class="px-4 py-3 text-right">
              <UButton :to="`/medications/${drug.id}`" size="xs" variant="ghost" icon="i-lucide-eye" />
            </td>
          </tr>
        </tbody>
      </table>
    </UCard>

    <div v-if="data && data.last_page > 1" class="flex items-center justify-between text-sm">
      <span class="text-neutral-500">{{ data.total }} kayıt · Sayfa {{ data.current_page }} / {{ data.last_page }}</span>
      <div class="flex gap-1">
        <UButton size="xs" variant="ghost" icon="i-lucide-chevron-left" :disabled="page <= 1" @click="page--" />
        <UButton size="xs" variant="ghost" icon="i-lucide-chevron-right" :disabled="page >= data.last_page" @click="page++" />
      </div>
    </div>
  </div>
</template>
