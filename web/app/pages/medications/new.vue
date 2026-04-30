<script setup lang="ts">
const { apiFetch } = useApi()
const toast = useToast()

async function handleSubmit(payload: Record<string, unknown>) {
  try {
    const res = await apiFetch<{ data: { id: string } }>('/drugs', { method: 'POST', body: payload })
    toast.add({ title: 'İlaç eklendi.', color: 'primary' })
    await navigateTo(`/medications/${res.data.id}`)
  } catch (err: unknown) {
    const e = err as { data?: { message?: string } }
    toast.add({ title: e?.data?.message ?? 'Kayıt eklenemedi.', color: 'error' })
  }
}
</script>

<template>
  <div>
    <div class="mb-6">
      <NuxtLink to="/medications" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        İlaçlar & Stok
      </NuxtLink>
      <h2 class="text-2xl font-bold mt-2">
        Yeni ilaç
      </h2>
    </div>
    <UCard>
      <DrugForm submit-label="Kaydet" @submit="handleSubmit" />
    </UCard>
  </div>
</template>
