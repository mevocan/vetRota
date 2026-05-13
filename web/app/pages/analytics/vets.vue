<script setup lang="ts">
// M8.2: Veteriner performans paneli.

interface VetRow {
  vet_id: number | string
  vet_name: string | null
  exam_count: number
  total_fee: number
  total_km: number
  days_active: number
  avg_exam_per_day: number | null
}
interface VetResponse {
  from: string
  to: string
  rows: VetRow[]
}

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

const { data, pending, refresh } = await useApiFetch<VetResponse>(
  () => `/analytics/vet-performance?${query.value}`,
  { lazy: true, watch: [query] }
)

const rows = computed<VetRow[]>(() => data.value?.rows ?? [])
const maxCount = computed(() => rows.value.reduce((m, r) => Math.max(m, r.exam_count), 0))
const totalExams = computed(() => rows.value.reduce((s, r) => s + r.exam_count, 0))
const totalFee = computed(() => rows.value.reduce((s, r) => s + Number(r.total_fee || 0), 0))
const totalKm = computed(() => rows.value.reduce((s, r) => s + Number(r.total_km || 0), 0))

function fmtTl(n: number): string {
  return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(n)
}
</script>

<template>
  <div class="space-y-6">
    <div>
      <h2 class="text-2xl font-bold mb-1">
        Veteriner performansı
      </h2>
      <p class="text-neutral-500 text-sm">
        Belirtilen aralıkta her veterinerin muayene sayısı, gezdiği km ve fatura edilen tutar.
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
          Toplam muayene
        </div>
        <div class="text-2xl font-bold">
          {{ totalExams }}
        </div>
      </UCard>
      <UCard>
        <div class="text-xs text-neutral-500">
          Toplam km
        </div>
        <div class="text-2xl font-bold">
          {{ totalKm.toFixed(0) }}
        </div>
      </UCard>
      <UCard>
        <div class="text-xs text-neutral-500">
          Toplam fatura
        </div>
        <div class="text-2xl font-bold">
          {{ fmtTl(totalFee) }}
        </div>
      </UCard>
    </div>

    <UCard>
      <div v-if="rows.length === 0 && !pending" class="text-sm text-neutral-500 py-6 text-center">
        Bu aralıkta veriniz yok.
      </div>
      <table v-else class="w-full text-sm">
        <thead class="text-left text-xs text-neutral-500 border-b border-neutral-200">
          <tr>
            <th class="py-2">
              Veteriner
            </th>
            <th class="py-2 text-right">
              Muayene
            </th>
            <th class="py-2 text-right">
              Aktif gün
            </th>
            <th class="py-2 text-right">
              Ortalama / gün
            </th>
            <th class="py-2 text-right">
              Km
            </th>
            <th class="py-2 text-right">
              Fatura (₺)
            </th>
            <th class="py-2 w-1/4">
              Pay
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(r, i) in rows" :key="r.vet_id" class="border-b border-neutral-100">
            <td class="py-2 font-medium">
              <span v-if="i < 3" class="inline-block mr-1">
                <UBadge :color="i === 0 ? 'warning' : 'primary'" variant="soft">
                  #{{ i + 1 }}
                </UBadge>
              </span>
              {{ r.vet_name ?? '—' }}
            </td>
            <td class="py-2 text-right font-semibold">
              {{ r.exam_count }}
            </td>
            <td class="py-2 text-right text-neutral-600">
              {{ r.days_active }}
            </td>
            <td class="py-2 text-right text-neutral-600">
              {{ r.avg_exam_per_day ?? '—' }}
            </td>
            <td class="py-2 text-right text-neutral-600">
              {{ Number(r.total_km).toFixed(1) }}
            </td>
            <td class="py-2 text-right">
              {{ fmtTl(Number(r.total_fee)) }}
            </td>
            <td class="py-2">
              <div class="w-full h-2 bg-neutral-100 rounded">
                <div
                  class="h-full bg-primary-500 rounded"
                  :style="{ width: maxCount > 0 ? `${(r.exam_count / maxCount) * 100}%` : '0%' }"
                />
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </UCard>
  </div>
</template>
