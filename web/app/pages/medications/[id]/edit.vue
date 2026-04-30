<script setup lang="ts">
const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()

interface DrugDetail {
  id: string
  name: string
  active_ingredient: string | null
  manufacturer: string | null
  barcode: string | null
  drug_type: 'antibiotic' | 'vaccine' | 'antiparasitic' | 'antiinflammatory' | 'analgesic' | 'vitamin' | 'hormone' | 'other'
  requires_prescription: boolean
  unit: 'ml' | 'tablet' | 'doz' | 'g' | 'flakon' | 'ampul'
  package_size: string | null
  is_vaccine: boolean
  vaccine_duration_days: number | null
  default_price: string | null
  stock: { critical_threshold: string | null } | null
}

const { data } = await useApiFetch<{ data: DrugDetail }>(`/drugs/${route.params.id}`)

const initial = computed(() => {
  if (!data.value?.data) return undefined
  const d = data.value.data
  return {
    name: d.name,
    active_ingredient: d.active_ingredient,
    manufacturer: d.manufacturer,
    barcode: d.barcode,
    drug_type: d.drug_type,
    requires_prescription: d.requires_prescription,
    unit: d.unit,
    package_size: d.package_size ? parseFloat(d.package_size) : null,
    is_vaccine: d.is_vaccine,
    vaccine_duration_days: d.vaccine_duration_days,
    default_price: d.default_price ? parseFloat(d.default_price) : null,
    critical_threshold: d.stock?.critical_threshold ? parseFloat(d.stock.critical_threshold) : null
  }
})

async function handleSubmit(payload: Record<string, unknown>) {
  try {
    await apiFetch(`/drugs/${route.params.id}`, { method: 'PUT', body: payload })
    toast.add({ title: 'İlaç güncellendi.', color: 'primary' })
    await navigateTo(`/medications/${route.params.id}`)
  } catch (err: unknown) {
    const e = err as { data?: { message?: string } }
    toast.add({ title: e?.data?.message ?? 'Güncelleme başarısız.', color: 'error' })
  }
}
</script>

<template>
  <div>
    <div class="mb-6">
      <NuxtLink :to="`/medications/${$route.params.id}`" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        İlaç detayı
      </NuxtLink>
      <h2 class="text-2xl font-bold mt-2">
        Düzenle
      </h2>
    </div>
    <UCard v-if="initial">
      <DrugForm :initial="initial" submit-label="Güncelle" @submit="handleSubmit" />
    </UCard>
  </div>
</template>
