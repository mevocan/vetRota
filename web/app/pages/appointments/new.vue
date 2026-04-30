<script setup lang="ts">
const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()

const presetFarmer = (route.query.farmer_id as string | undefined) || undefined
const presetAnimal = (route.query.animal_id as string | undefined) || undefined

async function handleSubmit(payload: Record<string, unknown>) {
  try {
    const res = await apiFetch<{ data: { id: string } }>('/appointments', { method: 'POST', body: payload })
    toast.add({ title: 'Randevu eklendi.', color: 'primary' })
    await navigateTo(`/appointments/${res.data.id}`)
  } catch (err: unknown) {
    const e = err as { data?: { message?: string } }
    toast.add({ title: e?.data?.message ?? 'Kayıt eklenemedi.', color: 'error' })
  }
}
</script>

<template>
  <div>
    <div class="mb-6">
      <NuxtLink to="/appointments" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        Randevular
      </NuxtLink>
      <h2 class="text-2xl font-bold mt-2">
        Yeni randevu
      </h2>
    </div>
    <UCard>
      <AppointmentForm
        :initial="{ farmer_id: presetFarmer, animal_id: presetAnimal ?? null }"
        submit-label="Kaydet"
        @submit="handleSubmit"
      />
    </UCard>
  </div>
</template>
