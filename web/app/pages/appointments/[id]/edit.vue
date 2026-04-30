<script setup lang="ts">
const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()

interface ApptDetail {
  id: string
  farmer_id: string
  animal_id: string | null
  scheduled_at: string
  estimated_duration_minutes: number | null
  appointment_type: 'visit' | 'vaccination' | 'follow_up' | 'emergency' | 'routine_check'
  reason: string | null
  notes: string | null
  status: 'planned' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled' | 'no_show'
}

const { data } = await useApiFetch<{ data: ApptDetail }>(`/appointments/${route.params.id}`)

const initial = computed(() => {
  if (!data.value?.data) return undefined
  const d = data.value.data
  return {
    farmer_id: d.farmer_id,
    animal_id: d.animal_id,
    scheduled_at: d.scheduled_at,
    estimated_duration_minutes: d.estimated_duration_minutes,
    appointment_type: d.appointment_type,
    reason: d.reason,
    notes: d.notes,
    status: d.status
  }
})

async function handleSubmit(payload: Record<string, unknown>) {
  try {
    await apiFetch(`/appointments/${route.params.id}`, { method: 'PUT', body: payload })
    toast.add({ title: 'Randevu güncellendi.', color: 'primary' })
    await navigateTo(`/appointments/${route.params.id}`)
  } catch (err: unknown) {
    const e = err as { data?: { message?: string } }
    toast.add({ title: e?.data?.message ?? 'Güncelleme başarısız.', color: 'error' })
  }
}
</script>

<template>
  <div>
    <div class="mb-6">
      <NuxtLink :to="`/appointments/${$route.params.id}`" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        Randevu detayı
      </NuxtLink>
      <h2 class="text-2xl font-bold mt-2">
        Düzenle
      </h2>
    </div>
    <UCard v-if="initial">
      <AppointmentForm :initial="initial" submit-label="Güncelle" :show-status="true" @submit="handleSubmit" />
    </UCard>
  </div>
</template>
