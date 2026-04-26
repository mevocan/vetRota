<script setup lang="ts">
const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()

interface AnimalDetail {
  id: string
  farmer_id: string
  village_id: string | null
  ear_tag: string | null
  name: string | null
  species: 'cattle' | 'sheep' | 'goat' | 'poultry' | 'other'
  breed: string | null
  birth_date: string | null
  gender: 'male' | 'female' | 'unknown'
  weight_kg: number | null
  color: string | null
  is_pregnant: boolean
  status: 'alive' | 'sold' | 'deceased' | 'lost'
  notes: string | null
}

const { data } = await useApiFetch<{ data: AnimalDetail }>(`/animals/${route.params.id}`)

const initial = computed(() => {
  if (!data.value?.data) return undefined
  const d = data.value.data
  return {
    farmer_id: d.farmer_id,
    village_id: d.village_id,
    ear_tag: d.ear_tag,
    name: d.name,
    species: d.species,
    breed: d.breed,
    birth_date: d.birth_date,
    gender: d.gender,
    weight_kg: d.weight_kg,
    color: d.color,
    is_pregnant: d.is_pregnant,
    status: d.status,
    notes: d.notes
  }
})

async function handleSubmit(payload: Record<string, unknown>) {
  try {
    await apiFetch(`/animals/${route.params.id}`, {
      method: 'PUT',
      body: payload
    })
    toast.add({ title: 'Hayvan güncellendi.', color: 'primary' })
    await navigateTo(`/animals/${route.params.id}`)
  } catch (err: unknown) {
    const e = err as { data?: { message?: string } }
    toast.add({ title: e?.data?.message ?? 'Güncelleme başarısız.', color: 'error' })
  }
}
</script>

<template>
  <div>
    <div class="mb-6">
      <NuxtLink :to="`/animals/${$route.params.id}`" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        Hayvan detayı
      </NuxtLink>
      <h2 class="text-2xl font-bold mt-2">
        Düzenle
      </h2>
    </div>

    <UCard v-if="initial">
      <AnimalForm :initial="initial" submit-label="Güncelle" @submit="handleSubmit" />
    </UCard>
  </div>
</template>
