<script setup lang="ts">
// M8.3: Ilac tuketim analitigi.

interface DrugRow {
  drug_id: string
  drug_name: string
  unit: string
  is_vaccine: boolean
  total_used: number
  usage_count: number
  remaining: number
  avg_per_day: number
  days_until_empty: number | null
}
interface DrugResponse { from: string, to: string, rows: DrugRow[] }

function toIso(d: Date): string { return d.toISOString().slice(0, 10) }
const today = new Date()
const monthAgo = new Date(today); monthAgo.setDate(today.getDate() - 30)

const from = ref(toIso(monthAgo))
const to = ref(toIso(today))
const query = computed(() => {
  const p = new URLSearchParams()
  p.set('from', from.value); p.set('to', to.value)
  return p.toString()
})

const { data, pending, refresh } = await useApiFetch<DrugResponse>(
  () => `/analytics/drug-consumption?${query.value}`,
  { lazy: true, watch: [query] }
)

const rows = computed<DrugRow[]>(() => data.value?.rows ?? [])
const maxUsed = computed(() => rows.value.reduce((m, r) => Math.max(m, Number(r.total_used || 0)), 0))
const lowStockCount = computed(() => rows.value.filter(r => r.days_until_empty !== null && r.days_until_empty <= 14).length)

function fmtQty(q: number): string {
  return q.toFixed(q >= 10 ? 0 : 2)
}

function stockBadge(days: number | null) {
  if (days === null) return { color: 'neutral' as const, label: 'Veri yok' }
  if (days <= 7) return { color: 'error' as const, label: `${days} gün` }
  if (days <= 14) return { color: 'warning' as const, label: `${days} gün` }
  return { color: 'success' as const, label: `${days} gün` }
}
</script>

<template>
  <div class="space-y-6">
    <div>
      <h2 class="text-2xl font-bold mb-1">
        İlaç tüketimi
      </h2>
      <p class="text-neutral-500 text-sm">
        Belirtilen aralıkta en çok kullanılan ilaçlar ve tahmini stok bitiş süresi.
      </p>
    </div>

    <UCard>
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
        <UFormField label="Başlangıç">
          <UInput v-model="from" type="date" />
        </UFormField>
        <UFormField label="Bitiş">
          <UInput v-model="to" type="date" />
        </UFormField>
        <div class="flex items-end">
          <UButton color="primary" icon="i-lucide-refresh-cw" :loading="pending" block @click="refresh()">
            Güncelle
          </UButton>
        </div>
      </div>
    </UCard>

    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <UCard>
        <div class="text-xs text-neutral-500">
          Farklı ilaç (kullanım)
        </div>
        <div class="text-2xl font-bold">
          {{ rows.length }}
        </div>
      </UCard>
      <UCard>
        <div class="text-xs text-neutral-500">
          Düşük stok (≤14 gün)
        </div>
        <div class="text-2xl font-bold text-orange-600">
          {{ lowStockCount }}
        </div>
      </UCard>
      <UCard>
        <div class="text-xs text-neutral-500">
          Aralık
        </div>
        <div class="text-sm font-semibold">
          {{ data?.from }} → {{ data?.to }}
        </div>
      </UCard>
    </div>

    <UCard>
      <div v-if="rows.length === 0 && !pending" class="text-sm text-neutral-500 py-6 text-center">
        Bu aralıkta ilaç kullanım verisi yok.
      </div>
      <table v-else class="w-full text-sm">
        <thead class="text-left text-xs text-neutral-500 border-b border-neutral-200">
          <tr>
            <th class="py-2">
              İlaç
            </th>
            <th class="py-2 text-right">
              Kullanım
            </th>
            <th class="py-2 text-right">
              Adet
            </th>
            <th class="py-2 text-right">
              Kalan stok
            </th>
            <th class="py-2 text-right">
              Günlük ort.
            </th>
            <th class="py-2 text-center">
              Tahmini bitiş
            </th>
            <th class="py-2 w-1/4">
              Pay
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in rows" :key="r.drug_id" class="border-b border-neutral-100">
            <td class="py-2 font-medium">
              {{ r.drug_name }}
              <UBadge v-if="r.is_vaccine" color="primary" variant="soft" size="xs" class="ml-1">
                aşı
              </UBadge>
            </td>
            <td class="py-2 text-right font-semibold">
              {{ fmtQty(Number(r.total_used)) }} {{ r.unit }}
            </td>
            <td class="py-2 text-right text-neutral-600">
              {{ r.usage_count }}
            </td>
            <td class="py-2 text-right text-neutral-600">
              {{ fmtQty(Number(r.remaining)) }} {{ r.unit }}
            </td>
            <td class="py-2 text-right text-neutral-600">
              {{ Number(r.avg_per_day).toFixed(2) }}
            </td>
            <td class="py-2 text-center">
              <UBadge :color="stockBadge(r.days_until_empty).color" variant="soft">
                {{ stockBadge(r.days_until_empty).label }}
              </UBadge>
            </td>
            <td class="py-2">
              <div class="w-full h-2 bg-neutral-100 rounded">
                <div
                  class="h-full bg-primary-500 rounded"
                  :style="{ width: maxUsed > 0 ? `${(Number(r.total_used) / maxUsed) * 100}%` : '0%' }"
                />
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </UCard>
  </div>
</template>
