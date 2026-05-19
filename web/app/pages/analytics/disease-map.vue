<script setup lang="ts">
// M7.6: Hastalik haritasi - Leaflet + Esri hybrid (uydu + etiket overlay).
import type { Map as LeafletMap, CircleMarker, Layer } from 'leaflet'

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

function toIso(d: Date): string {
  return d.toISOString().slice(0, 10)
}

// SSR/CSR ayni degeri uretmek icin useState (stabil), client'ta onMounted'da set.
const from = useState('disease-map-from', () => '')
const to = useState('disease-map-to', () => '')
onMounted(() => {
  if (!from.value || !to.value) {
    const now = new Date()
    const ago = new Date(now)
    ago.setDate(now.getDate() - 30)
    from.value = toIso(ago)
    to.value = toIso(now)
  }
})
const species = ref<string>('all')

const speciesOptions = [
  { label: 'Tümü', value: 'all' },
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
  if (species.value && species.value !== 'all') p.set('species', species.value)
  return p.toString()
})

const { data, pending, refresh, error } = await useApiFetch<DiseaseMapResponse>(
  () => `/analytics/disease-map?${query.value}`,
  { lazy: true, watch: [query] }
)

const villages = computed<VillageRow[]>(() => data.value?.villages ?? [])
const maxCount = computed(() => villages.value.reduce((m, v) => Math.max(m, v.case_count), 0))

const mapped = computed(() => villages.value.filter(v => v.lat !== null && v.lng !== null))

function colorFor(count: number): string {
  if (maxCount.value <= 0) return '#eab308'
  const ratio = count / maxCount.value
  if (ratio > 0.66) return '#dc2626' // kirmizi - outbreak
  if (ratio > 0.33) return '#f97316' // turuncu
  return '#eab308' // sari
}

function radiusFor(count: number): number {
  if (maxCount.value <= 0) return 8
  const ratio = count / maxCount.value
  return 8 + ratio * 22 // 8-30 px
}

// Leaflet sadece client'ta; SSR'da skip.
const mapEl = useTemplateRef<HTMLDivElement>('mapEl')
let leafletMap: LeafletMap | null = null
let markerLayer: Layer | null = null

async function initMap() {
  if (!import.meta.client || !mapEl.value || leafletMap) return
  const L = await import('leaflet')
  await import('leaflet/dist/leaflet.css')

  leafletMap = L.map(mapEl.value, {
    center: [40.15, 31.65],
    zoom: 9,
    minZoom: 5,
    maxZoom: 18,
  })

  // Esri uydu (base) + yer adi/yol overlay (transparan) - hybrid.
  L.tileLayer(
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    { attribution: 'Tiles © Esri', maxZoom: 19 },
  ).addTo(leafletMap)
  L.tileLayer(
    'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
    { maxZoom: 19 },
  ).addTo(leafletMap)

  renderMarkers(L)
}

async function renderMarkers(L?: typeof import('leaflet')) {
  if (!leafletMap) return
  const lib = L ?? (await import('leaflet'))

  if (markerLayer) {
    leafletMap.removeLayer(markerLayer)
    markerLayer = null
  }
  if (mapped.value.length === 0) return

  const group = lib.layerGroup()
  const latlngs: [number, number][] = []
  for (const v of mapped.value) {
    const color = colorFor(v.case_count)
    const marker: CircleMarker = lib.circleMarker([v.lat!, v.lng!], {
      radius: radiusFor(v.case_count),
      color,
      fillColor: color,
      fillOpacity: 0.55,
      weight: 2,
    })
    const kw = v.top_keywords.length ? ` · ${v.top_keywords.join(', ')}` : ''
    marker.bindTooltip(`<b>${v.village_name}</b> · ${v.case_count} vaka${kw}`, {
      direction: 'top',
      offset: [0, -4],
    })
    marker.addTo(group)
    latlngs.push([v.lat!, v.lng!])
  }
  group.addTo(leafletMap)
  markerLayer = group

  if (latlngs.length > 1) {
    leafletMap.fitBounds(latlngs, { padding: [40, 40] })
  } else if (latlngs.length === 1) {
    leafletMap.setView(latlngs[0], 11)
  }
}

// ClientOnly icindeki div async render edildigi icin mapEl mount aninda
// hazir olmayabilir; ref dolunca init et.
watch(mapEl, async (el) => {
  if (el && !leafletMap) {
    await initMap()
  }
}, { immediate: true })

onUnmounted(() => {
  if (leafletMap) {
    leafletMap.remove()
    leafletMap = null
    markerLayer = null
  }
})
watch(mapped, () => { void renderMarkers() })
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

    <UCard>
      <template #header>
        <div class="flex items-center gap-2">
          <UIcon name="i-lucide-map" class="text-primary-600" />
          <span class="font-semibold">Köy konumları</span>
          <span class="text-xs text-neutral-500 ml-auto">
            Kırmızı daire = outbreak şüphesi · daire büyüklüğü vaka sayısı
          </span>
        </div>
      </template>
      <ClientOnly>
        <div ref="mapEl" class="w-full h-[480px] rounded-md border border-neutral-200" />
        <template #fallback>
          <div class="w-full h-[480px] rounded-md border border-neutral-200 bg-neutral-50 flex items-center justify-center text-sm text-neutral-500">
            Harita yükleniyor…
          </div>
        </template>
      </ClientOnly>
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
