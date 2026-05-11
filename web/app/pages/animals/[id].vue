<script setup lang="ts">
interface AnimalDetail {
  id: string
  ear_tag: string | null
  name: string | null
  species: string
  breed: string | null
  gender: string
  birth_date: string | null
  weight_kg: number | null
  color: string | null
  is_pregnant: boolean
  status: string
  notes: string | null
  created_at: string
  farmer: { id: string; first_name: string; last_name: string; phone: string } | null
  village: { id: string; name: string; district: string; city: string } | null
}

interface ExamLite {
  id: string
  visit_type: string
  examined_at: string
  follow_up_needed: boolean
  follow_up_date: string | null
}

const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()

const { data, refresh } = await useApiFetch<{ data: AnimalDetail }>(`/animals/${route.params.id}`)
const { data: examsData } = await useApiFetch<{ data: ExamLite[] }>(
  `/medical-records?animal_id=${route.params.id}&per_page=10`
)

const animal = computed(() => data.value?.data)
const exams = computed(() => examsData.value?.data ?? [])

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

function fmtDate(iso: string) {
  return new Date(iso).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' })
}

const speciesLabel: Record<string, string> = {
  cattle: 'Sığır', sheep: 'Koyun', goat: 'Keçi', poultry: 'Kanatlı', other: 'Diğer'
}
const genderLabel: Record<string, string> = {
  male: 'Erkek', female: 'Dişi', unknown: 'Belirsiz'
}
const statusLabel: Record<string, string> = {
  alive: 'Canlı', sold: 'Satıldı', deceased: 'Vefat etti', lost: 'Kayboldu'
}

const ageText = computed(() => {
  if (!animal.value?.birth_date) return null
  const birth = new Date(animal.value.birth_date)
  const now = new Date()
  const months = (now.getFullYear() - birth.getFullYear()) * 12 + (now.getMonth() - birth.getMonth())
  if (months < 12) return `${months} ay`
  const years = Math.floor(months / 12)
  const remMonths = months % 12
  return remMonths ? `${years} yıl ${remMonths} ay` : `${years} yıl`
})

async function handleDelete() {
  if (!confirm('Bu hayvanı silmek istediğinize emin misiniz?')) return
  try {
    await apiFetch(`/animals/${route.params.id}`, { method: 'DELETE' })
    toast.add({ title: 'Hayvan silindi.', color: 'primary' })
    await navigateTo('/animals')
  } catch {
    toast.add({ title: 'Silme başarısız.', color: 'error' })
  }
}
</script>

<template>
  <div v-if="animal" class="space-y-6">
    <div>
      <NuxtLink to="/animals" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        Hayvanlar
      </NuxtLink>
    </div>

    <UCard>
      <div class="flex items-start gap-4">
        <div class="flex-1">
          <div class="font-mono text-2xl font-bold mb-1">
            {{ animal.ear_tag ?? 'Küpe yok' }}
          </div>
          <div v-if="animal.name" class="text-neutral-500 mb-3">
            {{ animal.name }}
          </div>
          <div class="flex flex-wrap gap-x-6 gap-y-2 text-sm">
            <div>
              <span class="text-neutral-500 text-xs">Tür: </span>
              <span class="font-medium">{{ speciesLabel[animal.species] ?? animal.species }}</span>
              <span v-if="animal.breed" class="text-neutral-500"> · {{ animal.breed }}</span>
            </div>
            <div>
              <span class="text-neutral-500 text-xs">Cinsiyet: </span>
              <span class="font-medium">{{ genderLabel[animal.gender] ?? animal.gender }}</span>
            </div>
            <div v-if="ageText">
              <span class="text-neutral-500 text-xs">Yaş: </span>
              <span class="font-medium">{{ ageText }}</span>
            </div>
            <div v-if="animal.weight_kg">
              <span class="text-neutral-500 text-xs">Ağırlık: </span>
              <span class="font-medium">{{ animal.weight_kg }} kg</span>
            </div>
            <div>
              <span class="text-neutral-500 text-xs">Durum: </span>
              <UBadge :color="animal.status === 'alive' ? 'primary' : 'neutral'" variant="soft" size="sm">
                {{ statusLabel[animal.status] ?? animal.status }}
              </UBadge>
            </div>
            <div v-if="animal.is_pregnant">
              <UBadge color="warning" variant="soft" size="sm">
                Gebe
              </UBadge>
            </div>
          </div>
        </div>
        <div class="flex gap-2">
          <UButton :to="`/animals/${animal.id}/vaccinations`" variant="ghost" icon="i-lucide-syringe" size="sm">
            Aşı planları
          </UButton>
          <UButton :to="`/animals/${animal.id}/edit`" variant="ghost" icon="i-lucide-pencil" size="sm">
            Düzenle
          </UButton>
          <UButton color="error" variant="ghost" icon="i-lucide-trash-2" size="sm" @click="handleDelete">
            Sil
          </UButton>
        </div>
      </div>
    </UCard>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UCard>
        <template #header>
          <h3 class="font-semibold text-sm">
            Sahibi
          </h3>
        </template>
        <div v-if="animal.farmer" class="space-y-1 text-sm">
          <div class="font-medium">
            {{ animal.farmer.first_name }} {{ animal.farmer.last_name }}
          </div>
          <div class="text-neutral-500">
            {{ animal.farmer.phone }}
          </div>
        </div>
        <div v-else class="text-sm text-neutral-400">
          —
        </div>
      </UCard>

      <UCard>
        <template #header>
          <h3 class="font-semibold text-sm">
            Köy
          </h3>
        </template>
        <div v-if="animal.village" class="space-y-1 text-sm">
          <div class="font-medium">
            {{ animal.village.name }}
          </div>
          <div class="text-neutral-500">
            {{ animal.village.district }} / {{ animal.village.city }}
          </div>
        </div>
        <div v-else class="text-sm text-neutral-400">
          —
        </div>
      </UCard>
    </div>

    <UCard :ui="{ body: 'p-0' }">
      <template #header>
        <div class="flex items-center justify-between">
          <h3 class="font-semibold text-sm">
            Son muayeneler ({{ exams.length }})
          </h3>
          <UButton :to="`/examinations/new?animal_id=${animal.id}`" size="xs" variant="ghost" icon="i-lucide-plus">
            Yeni muayene
          </UButton>
        </div>
      </template>
      <div v-if="!exams.length" class="p-8 text-center text-sm text-neutral-500">
        Bu hayvanın henüz muayene kaydı yok.
      </div>
      <table v-else class="w-full text-sm">
        <thead class="bg-neutral-50">
          <tr class="text-left text-xs uppercase tracking-wide text-neutral-500">
            <th class="px-4 py-2.5 font-semibold">Tarih</th>
            <th class="px-4 py-2.5 font-semibold">Tür</th>
            <th class="px-4 py-2.5 font-semibold">Takip</th>
            <th class="px-4 py-2.5" />
          </tr>
        </thead>
        <tbody class="divide-y divide-neutral-200">
          <tr v-for="ex in exams" :key="ex.id" class="hover:bg-neutral-50">
            <td class="px-4 py-3 whitespace-nowrap">
              <NuxtLink :to="`/examinations/${ex.id}`" class="font-medium hover:text-primary-600">
                {{ fmtDate(ex.examined_at) }}
              </NuxtLink>
            </td>
            <td class="px-4 py-3">
              <UBadge :color="visitColor[ex.visit_type] ?? 'neutral'" variant="soft" size="sm">
                {{ visitLabel[ex.visit_type] ?? ex.visit_type }}
              </UBadge>
            </td>
            <td class="px-4 py-3">
              <UBadge v-if="ex.follow_up_needed" color="warning" variant="soft" size="sm">
                {{ ex.follow_up_date ?? 'Gerekli' }}
              </UBadge>
              <span v-else class="text-neutral-300">—</span>
            </td>
            <td class="px-4 py-3 text-right">
              <UButton :to="`/examinations/${ex.id}`" size="xs" variant="ghost" icon="i-lucide-eye" />
            </td>
          </tr>
        </tbody>
      </table>
    </UCard>

    <UCard v-if="animal.notes">
      <template #header>
        <h3 class="font-semibold text-sm">
          Notlar
        </h3>
      </template>
      <p class="text-sm whitespace-pre-line">
        {{ animal.notes }}
      </p>
    </UCard>
  </div>
</template>
