<script setup lang="ts">
const { apiFetch } = useApi()
const toast = useToast()

async function handleSubmit(payload: Record<string, unknown>) {
  try {
    const res = await apiFetch<{ data: { id: string } }>('/animals', {
      method: 'POST',
      body: payload
    })
    toast.add({ title: 'Hayvan eklendi.', color: 'primary' })
    await navigateTo(`/animals/${res.data.id}`)
  } catch (err: unknown) {
    const e = err as { data?: { message?: string; errors?: Record<string, string[]> } }
    const msg = e?.data?.message ?? 'Kayıt eklenemedi.'
    toast.add({ title: msg, color: 'error' })
  }
}
</script>

<template>
  <div>
    <div class="mb-6">
      <NuxtLink to="/animals" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        Hayvanlar
      </NuxtLink>
      <h2 class="text-2xl font-bold mt-2">
        Yeni hayvan
      </h2>
    </div>

    <UCard>
      <AnimalForm submit-label="Kaydet" @submit="handleSubmit" />
    </UCard>
  </div>
</template>
