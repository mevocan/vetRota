<script setup lang="ts">
interface ExamDetail {
  id: string
  animal_id: string
  visit_type: string
  examined_at: string
  chief_complaint: string | null
  symptoms: string | null
  diagnosis_notes: string | null
  treatment_notes: string | null
  recommendations: string | null
  temperature_celsius: string | null
  weight_kg: string | null
  heart_rate: number | null
  respiratory_rate: number | null
  service_fee: string
  follow_up_needed: boolean
  follow_up_date: string | null
  animal: {
    id: string
    ear_tag: string | null
    name: string | null
    species: string
    farmer: { id: string; first_name: string; last_name: string; phone: string } | null
    village: { id: string; name: string; district: string; city: string } | null
  } | null
  vet: { id: number; name: string; email: string } | null
  village: { id: string; name: string; district: string; city: string } | null
}

const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()

const { data } = await useApiFetch<{ data: ExamDetail }>(`/medical-records/${route.params.id}`)

const rec = computed(() => data.value?.data)

const visitLabel: Record<string, string> = {
  examination: 'Genel muayene',
  vaccination: 'Aşı',
  treatment: 'Tedavi',
  emergency: 'Acil',
  routine_check: 'Rutin kontrol',
  pregnancy_check: 'Gebelik kontrolü'
}
const visitColor: Record<string, 'primary' | 'warning' | 'error' | 'neutral'> = {
  examination: 'neutral',
  vaccination: 'primary',
  treatment: 'primary',
  emergency: 'error',
  routine_check: 'neutral',
  pregnancy_check: 'warning'
}
const speciesLabel: Record<string, string> = {
  cattle: 'Sığır', sheep: 'Koyun', goat: 'Keçi', poultry: 'Kanatlı', other: 'Diğer'
}

function fmtDate(iso: string) {
  return new Date(iso).toLocaleString('tr-TR', { dateStyle: 'long', timeStyle: 'short' })
}

function fmtMoney(b: string | null) {
  if (!b) return '—'
  const n = parseFloat(b)
  if (Number.isNaN(n)) return '—'
  return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(n)
}

async function handleDelete() {
  if (!confirm('Bu muayeneyi silmek istediğinize emin misiniz?')) return
  try {
    await apiFetch(`/medical-records/${route.params.id}`, { method: 'DELETE' })
    toast.add({ title: 'Muayene silindi.', color: 'primary' })
    await navigateTo('/examinations')
  } catch {
    toast.add({ title: 'Silme başarısız.', color: 'error' })
  }
}
</script>

<template>
  <div v-if="rec" class="space-y-6">
    <div>
      <NuxtLink to="/examinations" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        Muayeneler
      </NuxtLink>
    </div>

    <UCard>
      <div class="flex items-start gap-4">
        <div class="flex-1">
          <div class="flex items-center gap-3 mb-2">
            <UBadge :color="visitColor[rec.visit_type] ?? 'neutral'" variant="soft">
              {{ visitLabel[rec.visit_type] ?? rec.visit_type }}
            </UBadge>
            <span class="text-sm text-neutral-500">{{ fmtDate(rec.examined_at) }}</span>
          </div>
          <div class="text-2xl font-bold mb-1">
            <NuxtLink v-if="rec.animal" :to="`/animals/${rec.animal.id}`" class="hover:text-primary-600">
              <span class="font-mono">{{ rec.animal.ear_tag ?? '—' }}</span>
              <span v-if="rec.animal.name" class="text-neutral-500 ml-2 font-normal">{{ rec.animal.name }}</span>
            </NuxtLink>
          </div>
          <div class="text-sm text-neutral-500">
            {{ speciesLabel[rec.animal?.species ?? ''] ?? rec.animal?.species }}
            <template v-if="rec.animal?.farmer"> · {{ rec.animal.farmer.first_name }} {{ rec.animal.farmer.last_name }}</template>
            <template v-if="rec.village"> · {{ rec.village.name }} / {{ rec.village.district }}</template>
          </div>
        </div>
        <div class="flex gap-2">
          <UButton :to="`/examinations/${rec.id}/edit`" variant="ghost" icon="i-lucide-pencil" size="sm">
            Düzenle
          </UButton>
          <UButton color="error" variant="ghost" icon="i-lucide-trash-2" size="sm" @click="handleDelete">
            Sil
          </UButton>
        </div>
      </div>
    </UCard>

    <!-- Vital değerler -->
    <div v-if="rec.temperature_celsius || rec.weight_kg || rec.heart_rate || rec.respiratory_rate" class="grid grid-cols-2 md:grid-cols-4 gap-3">
      <UCard v-if="rec.temperature_celsius">
        <div class="text-xs text-neutral-500 mb-1">
          Sıcaklık
        </div>
        <div class="text-xl font-bold font-mono">
          {{ rec.temperature_celsius }} <span class="text-sm font-normal text-neutral-500">°C</span>
        </div>
      </UCard>
      <UCard v-if="rec.weight_kg">
        <div class="text-xs text-neutral-500 mb-1">
          Ağırlık
        </div>
        <div class="text-xl font-bold font-mono">
          {{ rec.weight_kg }} <span class="text-sm font-normal text-neutral-500">kg</span>
        </div>
      </UCard>
      <UCard v-if="rec.heart_rate">
        <div class="text-xs text-neutral-500 mb-1">
          Nabız
        </div>
        <div class="text-xl font-bold font-mono">
          {{ rec.heart_rate }} <span class="text-sm font-normal text-neutral-500">/dk</span>
        </div>
      </UCard>
      <UCard v-if="rec.respiratory_rate">
        <div class="text-xs text-neutral-500 mb-1">
          Solunum
        </div>
        <div class="text-xl font-bold font-mono">
          {{ rec.respiratory_rate }} <span class="text-sm font-normal text-neutral-500">/dk</span>
        </div>
      </UCard>
    </div>

    <UCard v-if="rec.chief_complaint">
      <template #header>
        <h3 class="font-semibold text-sm">
          Şikayet / sebep
        </h3>
      </template>
      <p class="text-sm whitespace-pre-line">
        {{ rec.chief_complaint }}
      </p>
    </UCard>

    <UCard v-if="rec.symptoms">
      <template #header>
        <h3 class="font-semibold text-sm">
          Bulgular / semptomlar
        </h3>
      </template>
      <p class="text-sm whitespace-pre-line">
        {{ rec.symptoms }}
      </p>
    </UCard>

    <UCard v-if="rec.diagnosis_notes">
      <template #header>
        <h3 class="font-semibold text-sm">
          Tanı
        </h3>
      </template>
      <p class="text-sm whitespace-pre-line">
        {{ rec.diagnosis_notes }}
      </p>
    </UCard>

    <UCard v-if="rec.treatment_notes">
      <template #header>
        <h3 class="font-semibold text-sm">
          Tedavi
        </h3>
      </template>
      <p class="text-sm whitespace-pre-line">
        {{ rec.treatment_notes }}
      </p>
    </UCard>

    <UCard v-if="rec.recommendations">
      <template #header>
        <h3 class="font-semibold text-sm">
          Öneriler
        </h3>
      </template>
      <p class="text-sm whitespace-pre-line">
        {{ rec.recommendations }}
      </p>
    </UCard>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UCard>
        <template #header>
          <h3 class="font-semibold text-sm">
            Hizmet ücreti
          </h3>
        </template>
        <div class="text-lg font-bold">
          {{ fmtMoney(rec.service_fee) }}
        </div>
      </UCard>

      <UCard>
        <template #header>
          <h3 class="font-semibold text-sm">
            Takip
          </h3>
        </template>
        <div v-if="rec.follow_up_needed" class="text-sm">
          <UBadge color="warning" variant="soft" size="sm" class="mr-2">
            Gerekli
          </UBadge>
          <span v-if="rec.follow_up_date">{{ rec.follow_up_date }}</span>
        </div>
        <div v-else class="text-sm text-neutral-400">
          Gerekmiyor
        </div>
      </UCard>
    </div>

    <UCard v-if="rec.vet">
      <template #header>
        <h3 class="font-semibold text-sm">
          Veteriner
        </h3>
      </template>
      <div class="text-sm">
        <span class="font-medium">{{ rec.vet.name }}</span>
        <span class="text-neutral-500 ml-2">{{ rec.vet.email }}</span>
      </div>
    </UCard>
  </div>
</template>
