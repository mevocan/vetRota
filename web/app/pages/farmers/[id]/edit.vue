<script setup lang="ts">
const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()

interface FarmerDetail {
  id: string
  village_id: string | null
  first_name: string
  last_name: string
  phone: string
  email: string | null
  address_detail: string | null
  balance: string
  sms_notifications_enabled: boolean
  preferred_sms_language: string
  notes: string | null
}

const { data } = await useApiFetch<{ data: FarmerDetail }>(`/farmers/${route.params.id}`)

const initial = computed(() => {
  if (!data.value?.data) return undefined
  const d = data.value.data
  return {
    village_id: d.village_id,
    first_name: d.first_name,
    last_name: d.last_name,
    phone: d.phone,
    email: d.email,
    address_detail: d.address_detail,
    balance: d.balance ? parseFloat(d.balance) : null,
    sms_notifications_enabled: d.sms_notifications_enabled,
    preferred_sms_language: d.preferred_sms_language,
    notes: d.notes
  }
})

async function handleSubmit(payload: Record<string, unknown>) {
  try {
    await apiFetch(`/farmers/${route.params.id}`, {
      method: 'PUT',
      body: payload
    })
    toast.add({ title: 'Çiftçi güncellendi.', color: 'primary' })
    await navigateTo(`/farmers/${route.params.id}`)
  } catch (err: unknown) {
    const e = err as { data?: { message?: string } }
    toast.add({ title: e?.data?.message ?? 'Güncelleme başarısız.', color: 'error' })
  }
}
</script>

<template>
  <div>
    <div class="mb-6">
      <NuxtLink :to="`/farmers/${$route.params.id}`" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        Çiftçi detayı
      </NuxtLink>
      <h2 class="text-2xl font-bold mt-2">
        Düzenle
      </h2>
    </div>

    <UCard v-if="initial">
      <FarmerForm :initial="initial" submit-label="Güncelle" @submit="handleSubmit" />
    </UCard>
  </div>
</template>
