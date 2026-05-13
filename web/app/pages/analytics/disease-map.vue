<script setup lang="ts">
// M7.6: Hastalik haritasi (iskelet seviyesi).
// Backend disease-map endpoint'inden koy bazli muayene sayilari cekilir;
// liste + (lat/lng varsa) basit relative koordinat haritasi cizilir.
// Leaflet entegrasyonu sonraki iterasyona birakildi (CLAUDE.md M7 MVP).

interface VillageRow {
  village_id: string
  village_name: string
  district: string | null
  lat: number | null
  lng: number | null
  case_count: number
  top_keywords: string[]
}

interface DiseaseMapResponse {
  from: string
  to: string
  species: string | null
  total_cases: number
  villages: VillageRow[]
}

const today = new Date()
const monthAgo = new Date(today)
monthAgo.setDate(today.getDate() - 30)

function toIso(d: Date): string {
  return d.toISOString().slice(0, 10)
}

const from = ref(toIso(monthAgo))
const to = ref(toIso(today))
const species = ref<string>('')

const speciesOptions = [
  { label: 'Tümü', value: '' },
  { label: 'Sığır', value: 'cattle' },
  { label: 'Koyun', value: 'sheep' },
  { label: 'Keçi', value: 'goat' },
  { label: 'At', value: 'horse' },
  { label: 'Tavuk', value: 'chicken' }
]

const query = computed(() => {
  const p = new URLSearchParams()
  if (from.value) p.set('from', from.value)
  if (to.value) p.set('to', to.value)
  if (species.value) p.set('species', species.value)
  return p.toString()
})

const { data, pending, refresh, error } = await useApiFetch<DiseaseMapResponse>(
  () => `/analytics/disease-map?${query.value}`,
  { lazy: true, watch: [query] }
)

const villages = computed<VillageRow[]>(() => data.value?.villages ?? [])
const maxCount = computed(() => villages.value.reduce((m, v) => Math.max(m, v.case_count), 0))

// Lat/lng'i olan koylari basit bir kutuya goreli yerlestir.
const mapped = computed(() => villages.value.filter(v => v.lat !== null && v.lng !== null))

const bounds = computed(() => {
  if (mapped.value.length === 0) return null
  const lats = mapped.value.map(v => v.lat as number)
  const lngs = mapped.value.map(v => v.lng as number)
  return {
    minLat: Math.min(...lats),
    maxLat: Math.max(...lats),
    minLng: Math.min(...lngs),
    maxLng: Math.max(...lngs)
  }
})

function positionFor(v: VillageRow): { left: string, top: string } {
  const b = bounds.value
  if (!b || v.lat === null || v.lng === null) return { left: '50%', top: '50%' }
  const latRange = (b.maxLat - b.minLat) || 1
  const lngRange = (b.maxLng - b.minLng) || 1
  const xPct = ((v.lng - b.minLng) / lngRange) * 90 + 5
  const yPct = (1 - (v.lat - b.minLat) / latRange) * 90 + 5
  return { left: `${xPct}%`, top: `${yPct}%` }
}

function dotSize(count: number): number {
  if (maxCount.value <= 0) return 14
  const ratio = count / maxCount.value
  return Math.round(14 + ratio * 36) // 14px - 50px
}
</script>

<template>
  <div class="space-y-6">
    <div>
      <h2 class="text-2xl font-bold mb-1">
        Hastalık haritası
      </h2>
      <p class="text-neutral-500 text-sm">
        Köy bazında muayene yoğunluğu ve sık geçen şikâyet/belirti kelimeleri.
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
        <UFormField label="Tür">
          <USelect v-model="species" :items="speciesOptions" value-key="value" />
        </UFormField>
        <div class="flex items-end">
          <UButton
            color="primary"
            icon="i-lucide-refresh-cw"
            :loading="pending"
            block
            @click="refresh()"
          >
            Güncelle
          </UButton>
        </div>
      </div>
    </UCard>

    <div v-if="error" class="text-red-600 text-sm">
      Veri alınamadı: {{ error.message }}
    </div>

    <div v-if="data" class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <UCard>
        <div class="text-xs text-neutral-500">
          Toplam vaka
        </div>
        <div class="text-2xl font-bold">
          {{ data.total_cases }}
        </div>
      </UCard>
      <UCard>
        <div class="text-xs text-neutral-500">
          Etkilenen köy
        </div>
        <div class="text-2xl font-bold">
          {{ villages.length }}
        </div>
      </UCard>
      <UCard>
        <div class="text-xs text-neutral-500">
          Aralık
        </div>
        <div class="text-sm font-semibold">
          {{ data.from }} → {{ data.to }}
        </div>
      </UCard>
    </div>

    <UCard v-if="mapped.length > 0">
      <template #header>
        <div class="flex items-center gap-2">
          <UIcon name="i-lucide-map" class="text-primary-600" />
          <span class="font-semibold">Köy konumları</span>
          <span class="text-xs text-neutral-500 ml-auto">
            Daire büyüklüğü vaka sayısı ile orantılı
          </span>
        </div>
      </template>
      <div class="relative w-full h-[420px] bg-neutral-50 border border-neutral-200 rounded-md overflow-hidden">
        <div
          v-for="v in mapped"
          :key="v.village_id"
          class="absolute -translate-x-1/2 -translate-y-1/2 group cursor-pointer"
          :style="positionFor(v)"
        >
          <div
            class="rounded-full bg-primary-500/60 ring-2 ring-primary-700 transition hover:bg-primary-500/90"
            :style="{ width: `${dotSize(v.case_count)}px`, height: `${dotSize(v.case_count)}px` }"
          />
          <div class="absolute left-1/2 top-full mt-1 -translate-x-1/2 hidden group-hover:block bg-neutral-900 text-white text-xs px-2 py-1 rounded shadow whitespace-nowrap z-10">
            {{ v.village_name }} · {{ v.case_count }} vaka
            <span v-if="v.top_keywords.length"> · {{ v.top_keywords.join(', ') }}</span>
          </div>
        </div>
      </div>
    </UCard>

    <UCard>
      <template #header>
        <div class="font-semibold">
          Köy listesi
        </div>
      </template>
      <div v-if="villages.length === 0 && !pending" class="text-sm text-neutral-500 py-6 text-center">
        Bu aralıkta köy bazlı muayene verisi yok.
      </div>
      <table v-else class="w-full text-sm">
        <thead class="text-left text-xs text-neutral-500 border-b border-neutral-200">
          <tr>
            <th class="py-2">
              Köy
            </th>
            <th class="py-2">
              İlçe
            </th>
            <th class="py-2 text-right">
              Vaka
            </th>
            <th class="py-2">
              Sık kelimeler
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="v in villages"
            :key="v.village_id"
            class="border-b border-neutral-100"
          >
            <td class="py-2 font-medium">
              {{ v.village_name }}
            </td>
            <td class="py-2 text-neutral-600">
              {{ v.district ?? '—' }}
            </td>
            <td class="py-2 text-right font-semibold">
              <UBadge :color="v.case_count >= maxCount * 0.66 ? 'error' : v.case_count >= maxCount * 0.33 ? 'warning' : 'primary'">
                {{ v.case_count }}
              </UBadge>
            </td>
            <td class="py-2 text-neutral-600">
              <span v-if="v.top_keywords.length === 0">—</span>
              <span v-for="(kw, i) in v.top_keywords" :key="kw" class="inline-block mr-1">
                {{ kw }}<span v-if="i < v.top_keywords.length - 1">,</span>
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </UCard>
  </div>
</template>
