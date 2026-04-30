<script setup lang="ts">
const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()

interface ExamDetail {
  id: string
  animal_id: string
  visit_type: 'examination' | 'vaccination' | 'treatment' | 'emergency' | 'routine_check' | 'pregnancy_check'
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
  service_fee: string | null
  follow_up_needed: boolean
  follow_up_date: string | null
}

const { data } = await useApiFetch<{ data: ExamDetail }>(`/medical-records/${route.params.id}`)

const initial = computed(() => {
  if (!data.value?.data) return undefined
  const d = data.value.data
  return {
    animal_id: d.animal_id,
    visit_type: d.visit_type,
    examined_at: d.examined_at,
    chief_complaint: d.chief_complaint,
    symptoms: d.symptoms,
    diagnosis_notes: d.diagnosis_notes,
    treatment_notes: d.treatment_notes,
    recommendations: d.recommendations,
    temperature_celsius: d.temperature_celsius ? parseFloat(d.temperature_celsius) : null,
    weight_kg: d.weight_kg ? parseFloat(d.weight_kg) : null,
    heart_rate: d.heart_rate,
    respiratory_rate: d.respiratory_rate,
    service_fee: d.service_fee ? parseFloat(d.service_fee) : null,
    follow_up_needed: d.follow_up_needed,
    follow_up_date: d.follow_up_date
  }
})

async function handleSubmit(payload: Record<string, unknown>) {
  try {
    await apiFetch(`/medical-records/${route.params.id}`, {
      method: 'PUT',
      body: payload
    })
    toast.add({ title: 'Muayene güncellendi.', color: 'primary' })
    await navigateTo(`/examinations/${route.params.id}`)
  } catch (err: unknown) {
    const e = err as { data?: { message?: string } }
    toast.add({ title: e?.data?.message ?? 'Güncelleme başarısız.', color: 'error' })
  }
}
</script>

<template>
  <div>
    <div class="mb-6">
      <NuxtLink :to="`/examinations/${$route.params.id}`" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        Muayene detayı
      </NuxtLink>
      <h2 class="text-2xl font-bold mt-2">
        Düzenle
      </h2>
    </div>

    <UCard v-if="initial">
      <ExaminationForm :initial="initial" submit-label="Güncelle" @submit="handleSubmit" />
    </UCard>
  </div>
</template>
