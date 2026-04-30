<script setup lang="ts">
const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()

// "Yeni muayene" linkleri opsiyonel olarak ?animal_id=... ile gelir (hayvan detayindan).
const presetAnimalId = (route.query.animal_id as string | undefined) || undefined

async function handleSubmit(payload: Record<string, unknown>) {
  try {
    const res = await apiFetch<{ data: { id: string } }>('/medical-records', {
      method: 'POST',
      body: payload
    })
    toast.add({ title: 'Muayene eklendi.', color: 'primary' })
    await navigateTo(`/examinations/${res.data.id}`)
  } catch (err: unknown) {
    const e = err as { data?: { message?: string } }
    toast.add({ title: e?.data?.message ?? 'Kayıt eklenemedi.', color: 'error' })
  }
}
</script>

<template>
  <div>
    <div class="mb-6">
      <NuxtLink to="/examinations" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        Muayeneler
      </NuxtLink>
      <h2 class="text-2xl font-bold mt-2">
        Yeni muayene
      </h2>
    </div>

    <UCard>
      <ExaminationForm
        :initial="presetAnimalId ? { animal_id: presetAnimalId } : undefined"
        :lock-animal="!!presetAnimalId"
        submit-label="Kaydet"
        @submit="handleSubmit"
      />
    </UCard>
  </div>
</template>
