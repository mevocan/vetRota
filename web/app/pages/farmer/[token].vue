<script setup lang="ts">
// M6.8: Çiftçi portal sayfası — SMS link'i ile şifresiz açılır.
// Backend GET /api/v1/farmer-portal/{token} endpoint'ini cağırır,
// 410 dönerse "süresi geçmiş" mesajı gösterir.
definePageMeta({
  layout: false
})

interface MedicalRecord {
  id: string
  examined_at: string | null
  visit_type: string | null
  chief_complaint: string | null
  diagnosis_notes: string | null
  treatment_notes: string | null
  recommendations: string | null
}

interface Animal {
  id: string
  name: string | null
  ear_tag: string | null
  species: string
  breed: string | null
  birth_date: string | null
  medical_records: MedicalRecord[]
}

interface UpcomingVaccination {
  id: string
  animal_id: string
  drug_name: string | null
  next_due_date: string
  interval_days: number
}

interface PortalResponse {
  clinic: { id: string; name: string; city: string | null; district: string | null }
  farmer: { id: string; first_name: string; last_name: string }
  token: { scope: string; expires_at: string }
  animals: Animal[]
  upcoming_vaccinations: UpcomingVaccination[]
}

const route = useRoute()
const token = route.params.token as string
const config = useRuntimeConfig()

const { data, error, status } = await useFetch<PortalResponse>(
  `${config.public.apiBase}/farmer-portal/${token}`,
  { server: true }
)

const isExpired = computed(() => {
  // useFetch error'da response.status'u verir.
  const e = error.value as unknown as { statusCode?: number; status?: number } | null
  const code = e?.statusCode ?? e?.status
  return code === 410 || code === 404
})

function formatDate(iso: string | null): string {
  if (!iso) return '—'
  try {
    return new Date(iso).toLocaleDateString('tr-TR', {
      day: '2-digit', month: '2-digit', year: 'numeric'
    })
  } catch {
    return iso
  }
}

function visitTypeLabel(t: string | null): string {
  const map: Record<string, string> = {
    routine: 'Rutin kontrol',
    routine_check: 'Rutin kontrol',
    vaccination: 'Aşı',
    pregnancy_check: 'Gebelik kontrolü',
    follow_up: 'Takip',
    visit: 'Saha ziyareti',
    emergency: 'Acil'
  }
  return t ? (map[t] ?? t) : '—'
}

function speciesLabel(s: string): string {
  const map: Record<string, string> = {
    cattle: 'Sığır',
    sheep: 'Koyun',
    goat: 'Keçi',
    horse: 'At',
    poultry: 'Kümes hayvanı'
  }
  return map[s] ?? s
}
</script>

<template>
  <div class="min-h-screen bg-neutral-50 py-8 px-4">
    <div class="max-w-3xl mx-auto">
      <!-- Loading -->
      <div v-if="status === 'pending'" class="text-center py-16 text-neutral-500">
        <UIcon name="i-lucide-loader-2" class="w-8 h-8 animate-spin mx-auto mb-2" />
        Yükleniyor...
      </div>

      <!-- Expired / not found -->
      <UCard v-else-if="isExpired" class="text-center py-12">
        <UIcon name="i-lucide-link-2-off" class="w-12 h-12 text-orange-500 mx-auto mb-3" />
        <h1 class="text-xl font-semibold mb-2">
          Bu link süresi geçmiş
        </h1>
        <p class="text-neutral-600">
          Bu portal linki geçersiz veya süresi geçmiş. Lütfen klinik ile iletişime geçin.
        </p>
      </UCard>

      <!-- Generic error -->
      <UCard v-else-if="error" class="text-center py-12">
        <UIcon name="i-lucide-alert-circle" class="w-12 h-12 text-red-500 mx-auto mb-3" />
        <h1 class="text-xl font-semibold mb-2">
          Bir hata oluştu
        </h1>
        <p class="text-neutral-600 text-sm">
          Lütfen daha sonra tekrar deneyin.
        </p>
      </UCard>

      <!-- Content -->
      <template v-else-if="data">
        <header class="mb-6">
          <div class="flex items-center gap-3 mb-2">
            <div class="w-10 h-10 rounded-lg bg-primary-600 text-white flex items-center justify-center">
              <UIcon name="i-lucide-stethoscope" class="w-5 h-5" />
            </div>
            <div>
              <h1 class="text-lg font-semibold leading-tight">
                {{ data.clinic.name }}
              </h1>
              <p class="text-xs text-neutral-500">
                {{ [data.clinic.district, data.clinic.city].filter(Boolean).join(' / ') }}
              </p>
            </div>
          </div>
          <p class="text-sm text-neutral-700">
            Sayın <strong>{{ data.farmer.first_name }} {{ data.farmer.last_name }}</strong>,
            hayvanlarınızın sağlık geçmişi aşağıdadır.
          </p>
        </header>

        <!-- Yaklaşan aşılar -->
        <UCard v-if="data.upcoming_vaccinations.length" class="mb-6 border-orange-200 bg-orange-50/50">
          <template #header>
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-syringe" class="text-orange-600 w-4 h-4" />
              <h2 class="font-semibold text-sm">
                Yaklaşan aşılar
              </h2>
            </div>
          </template>
          <ul class="divide-y divide-orange-200">
            <li
              v-for="v in data.upcoming_vaccinations"
              :key="v.id"
              class="py-2 flex items-center justify-between text-sm"
            >
              <span class="font-medium">{{ v.drug_name ?? 'Aşı' }}</span>
              <span class="text-orange-700 font-semibold">{{ formatDate(v.next_due_date) }}</span>
            </li>
          </ul>
        </UCard>

        <!-- Hayvanlar -->
        <h2 class="text-base font-semibold mb-3">
          Hayvanlarım ({{ data.animals.length }})
        </h2>

        <div v-if="!data.animals.length" class="text-center py-8 text-neutral-500 text-sm">
          Sistemde kayıtlı hayvan yok.
        </div>

        <UCard v-for="animal in data.animals" :key="animal.id" class="mb-4">
          <template #header>
            <div class="flex items-center justify-between">
              <div>
                <h3 class="font-semibold">
                  {{ animal.name ?? `Küpe ${animal.ear_tag ?? '—'}` }}
                </h3>
                <p class="text-xs text-neutral-500">
                  {{ speciesLabel(animal.species) }}
                  <span v-if="animal.breed"> · {{ animal.breed }}</span>
                  <span v-if="animal.ear_tag"> · Küpe: {{ animal.ear_tag }}</span>
                </p>
              </div>
              <UIcon name="i-lucide-paw-print" class="text-neutral-400 w-5 h-5" />
            </div>
          </template>

          <div v-if="!animal.medical_records.length" class="text-sm text-neutral-500">
            Henüz muayene kaydı yok.
          </div>

          <ul v-else class="divide-y divide-neutral-200">
            <li v-for="mr in animal.medical_records" :key="mr.id" class="py-3">
              <div class="flex items-center justify-between mb-1">
                <span class="text-sm font-medium">{{ visitTypeLabel(mr.visit_type) }}</span>
                <span class="text-xs text-neutral-500">{{ formatDate(mr.examined_at) }}</span>
              </div>
              <p v-if="mr.chief_complaint" class="text-sm text-neutral-700">
                <strong>Şikayet:</strong> {{ mr.chief_complaint }}
              </p>
              <p v-if="mr.diagnosis_notes" class="text-sm text-neutral-700">
                <strong>Tanı:</strong> {{ mr.diagnosis_notes }}
              </p>
              <p v-if="mr.treatment_notes" class="text-sm text-neutral-700">
                <strong>Tedavi:</strong> {{ mr.treatment_notes }}
              </p>
              <p v-if="mr.recommendations" class="text-sm text-neutral-600 italic mt-1">
                {{ mr.recommendations }}
              </p>
            </li>
          </ul>
        </UCard>

        <p class="text-xs text-neutral-400 text-center mt-8">
          Bu sayfa size SMS ile gönderilen özel bir bağlantı üzerinden açılmıştır.
          VetRota — Türkiye gezici veteriner platformu.
        </p>
      </template>
    </div>
  </div>
</template>
