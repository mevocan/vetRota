<script setup lang="ts">
// M8.4: Klinik kazanci paneli — zaman serisi.

interface SeriesRow { bucket: string, billed: number, collected: number }
interface RevenueResponse {
  from: string
  to: string
  group_by: 'day' | 'week' | 'month'
  total_billed: number
  total_collected: number
  outstanding: number
  series: SeriesRow[]
}

function toIso(d: Date): string { return d.toISOString().slice(0, 10) }
const today = new Date()
const monthAgo = new Date(today); monthAgo.setDate(today.getDate() - 30)

const from = ref(toIso(monthAgo))
const to = ref(toIso(today))
const groupBy = ref<'day' | 'week' | 'month'>('day')

const groupOptions = [
  { label: 'Günlük', value: 'day' },
  { label: 'Haftalık', value: 'week' },
  { label: 'Aylık', value: 'month' }
]

const query = computed(() => {
  const p = new URLSearchParams()
  p.set('from', from.value); p.set('to', to.value); p.set('group_by', groupBy.value)
  return p.toString()
})

const { data, pending, refresh } = await useApiFetch<RevenueResponse>(
  () => `/analytics/revenue?${query.value}`,
  { lazy: true, watch: [query] }
)

const series = computed<SeriesRow[]>(() => data.value?.series ?? [])
const maxBar = computed(() => series.value.reduce((m, r) => Math.max(m, r.billed, r.collected), 0))

function fmtTl(n: number): string {
  return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(n)
}

function bucketLabel(b: string): string {
  const d = new Date(b)
  if (groupBy.value === 'month') {
    return d.toLocaleDateString('tr-TR', { month: 'short', year: '2-digit' })
  }
  return d.toLocaleDateString('tr-TR', { day: '2-digit', month: '2-digit' })
}
</script>

<template>
  <div class="space-y-6">
    <div>
      <h2 class="text-2xl font-bold mb-1">
        Klinik kazancı
      </h2>
      <p class="text-neutral-500 text-sm">
        Fatura edilen, tahsil edilen ve açık alacak. Tarih grupları arası karşılaştırma.
      </p>
    </div>

    <UCard>
      <div class="grid grid-cols-1 sm:grid-cols-4 gap-3">
        <UFormField label="Başlangıç">
          <UInput v-model="from" type="date" />
        </UFormField>
        <UFormField label="Bitiş">
          <UInput v-model="to" type="date" />
        </UFormField>
        <UFormField label="Gruplama">
          <USelect v-model="groupBy" :items="groupOptions" value-key="value" />
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
          Fatura edilen
        </div>
        <div class="text-2xl font-bold">
          {{ fmtTl(data?.total_billed ?? 0) }}
        </div>
      </UCard>
      <UCard>
        <div class="text-xs text-neutral-500">
          Tahsil edilen
        </div>
        <div class="text-2xl font-bold text-green-700">
          {{ fmtTl(data?.total_collected ?? 0) }}
        </div>
      </UCard>
      <UCard>
        <div class="text-xs text-neutral-500">
          Açık alacak (anlık)
        </div>
        <div class="text-2xl font-bold text-orange-600">
          {{ fmtTl(data?.outstanding ?? 0) }}
        </div>
      </UCard>
    </div>

    <UCard>
      <template #header>
        <div class="flex items-center gap-2">
          <UIcon name="i-lucide-bar-chart-3" class="text-primary-600" />
          <span class="font-semibold">Zaman serisi</span>
          <span class="ml-auto flex items-center gap-3 text-xs text-neutral-500">
            <span class="flex items-center gap-1">
              <span class="inline-block w-3 h-3 rounded-sm bg-primary-500" /> Fatura
            </span>
            <span class="flex items-center gap-1">
              <span class="inline-block w-3 h-3 rounded-sm bg-green-500" /> Tahsil
            </span>
          </span>
        </div>
      </template>
      <div v-if="series.length === 0 && !pending" class="text-sm text-neutral-500 py-6 text-center">
        Bu aralıkta finansal veri yok.
      </div>
      <div v-else class="space-y-2">
        <div v-for="row in series" :key="row.bucket" class="flex items-center gap-3">
          <div class="w-20 text-xs text-neutral-600 flex-shrink-0">
            {{ bucketLabel(row.bucket) }}
          </div>
          <div class="flex-1 space-y-1">
            <div class="flex items-center gap-2">
              <div class="flex-1 h-3 bg-neutral-100 rounded relative">
                <div
                  class="h-full bg-primary-500 rounded"
                  :style="{ width: maxBar > 0 ? `${(row.billed / maxBar) * 100}%` : '0%' }"
                />
              </div>
              <div class="w-24 text-right text-xs tabular-nums">
                {{ fmtTl(Number(row.billed)) }}
              </div>
            </div>
            <div class="flex items-center gap-2">
              <div class="flex-1 h-3 bg-neutral-100 rounded relative">
                <div
                  class="h-full bg-green-500 rounded"
                  :style="{ width: maxBar > 0 ? `${(row.collected / maxBar) * 100}%` : '0%' }"
                />
              </div>
              <div class="w-24 text-right text-xs tabular-nums">
                {{ fmtTl(Number(row.collected)) }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </UCard>
  </div>
</template>
