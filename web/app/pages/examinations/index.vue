<script setup lang="ts">
interface MedicalRecord {
  id: string
  visit_type: string
  examined_at: string
  follow_up_needed: boolean
  follow_up_date: string | null
  service_fee: string
  animal: {
    id: string
    ear_tag: string | null
    name: string | null
    species: string
    farmer: { first_name: string; last_name: string } | null
  } | null
  vet: { id: number; name: string } | null
  village: { id: string; name: string; district: string } | null
}

interface Paginated<T> {
  data: T[]
  current_page: number
  last_page: number
  per_page: number
  total: number
}

const search = ref('')
const visitTypeFilter = ref<string | undefined>(undefined)
const followUpOnly = ref(false)
const page = ref(1)

const visitOptions = [
  { label: 'Tümü', value: undefined },
  { label: 'Genel muayene', value: 'examination' },
  { label: 'Aşı', value: 'vaccination' },
  { label: 'Tedavi', value: 'treatment' },
  { label: 'Acil', value: 'emergency' },
  { label: 'Rutin kontrol', value: 'routine_check' },
  { label: 'Gebelik kontrolü', value: 'pregnancy_check' }
]

const visitLabel: Record<string, string> = {
  examination: 'Genel muayene',
  vaccination: 'Aşı',
  treatment: 'Tedavi',
  emergency: 'Acil',
  routine_check: 'Rutin kontrol',
  pregnancy_check: 'Gebelik'
}

const visitColor: Record<string, 'primary' | 'warning' | 'error' | 'neutral'> = {
  examination: 'neutral',
  vaccination: 'primary',
  treatment: 'primary',
  emergency: 'error',
  routine_check: 'neutral',
  pregnancy_check: 'warning'
}

const queryString = computed(() => {
  const params = new URLSearchParams()
  if (visitTypeFilter.value) params.set('visit_type', visitTypeFilter.value)
  if (followUpOnly.value) params.set('follow_up_due', '1')
  params.set('page', String(page.value))
  return params.toString()
})

const { data, pending } = await useApiFetch<Paginated<MedicalRecord>>(
  () => `/medical-records?${queryString.value}`,
  { watch: [queryString], lazy: true }
)

watch([visitTypeFilter, followUpOnly], () => { page.value = 1 })

function fmtDate(iso: string) {
  return new Date(iso).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' })
}
</script>

<template>
  <div class="space-y-4">
    <div class="flex items-center gap-3 flex-wrap">
      <USelect
        v-model="visitTypeFilter"
        :items="visitOptions"
        value-key="value"
        placeholder="Tür filtresi"
        class="w-48"
      />
      <UCheckbox v-model="followUpOnly" label="Sadece takip gerekenler" />
      <div class="flex-1" />
      <UButton to="/examinations/new" color="primary" icon="i-lucide-plus">
        Yeni muayene
      </UButton>
    </div>

    <UCard :ui="{ body: 'p-0' }">
      <div v-if="pending" class="p-12 text-center text-sm text-neutral-500">
        Yükleniyor...
      </div>

      <div v-else-if="!data?.data?.length" class="p-12 text-center">
        <UIcon name="i-lucide-stethoscope" class="w-10 h-10 text-neutral-300 mx-auto mb-3" />
        <p class="text-sm text-neutral-600 mb-4">
          {{ visitTypeFilter || followUpOnly ? 'Filtrelere uyan muayene bulunamadı.' : 'Henüz muayene kaydı yok.' }}
        </p>
        <UButton to="/examinations/new" color="primary" icon="i-lucide-plus">
          Yeni muayene ekle
        </UButton>
      </div>

      <table v-else class="w-full text-sm">
        <thead class="bg-neutral-50">
          <tr class="text-left text-xs uppercase tracking-wide text-neutral-500">
            <th class="px-4 py-2.5 font-semibold">Tarih</th>
            <th class="px-4 py-2.5 font-semibold">Tür</th>
            <th class="px-4 py-2.5 font-semibold">Hayvan</th>
            <th class="px-4 py-2.5 font-semibold">Çiftçi</th>
            <th class="px-4 py-2.5 font-semibold">Köy</th>
            <th class="px-4 py-2.5 font-semibold">Takip</th>
            <th class="px-4 py-2.5" />
          </tr>
        </thead>
        <tbody class="divide-y divide-neutral-200">
          <tr v-for="rec in data.data" :key="rec.id" class="hover:bg-neutral-50">
            <td class="px-4 py-3 whitespace-nowrap">
              <NuxtLink :to="`/examinations/${rec.id}`" class="font-medium hover:text-primary-600">
                {{ fmtDate(rec.examined_at) }}
              </NuxtLink>
            </td>
            <td class="px-4 py-3">
              <UBadge :color="visitColor[rec.visit_type] ?? 'neutral'" variant="soft" size="sm">
                {{ visitLabel[rec.visit_type] ?? rec.visit_type }}
              </UBadge>
            </td>
            <td class="px-4 py-3">
              <NuxtLink v-if="rec.animal" :to="`/animals/${rec.animal.id}`" class="hover:text-primary-600">
                <span class="font-mono">{{ rec.animal.ear_tag ?? '—' }}</span>
                <span v-if="rec.animal.name" class="text-neutral-500 ml-2">{{ rec.animal.name }}</span>
              </NuxtLink>
              <span v-else class="text-neutral-400">—</span>
            </td>
            <td class="px-4 py-3">
              <span v-if="rec.animal?.farmer">{{ rec.animal.farmer.first_name }} {{ rec.animal.farmer.last_name }}</span>
              <span v-else class="text-neutral-400">—</span>
            </td>
            <td class="px-4 py-3">{{ rec.village?.name ?? '—' }}</td>
            <td class="px-4 py-3">
              <UBadge v-if="rec.follow_up_needed" color="warning" variant="soft" size="sm">
                {{ rec.follow_up_date ?? 'Gerekli' }}
              </UBadge>
              <span v-else class="text-neutral-300">—</span>
            </td>
            <td class="px-4 py-3 text-right">
              <UButton :to="`/examinations/${rec.id}`" size="xs" variant="ghost" icon="i-lucide-eye" />
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
