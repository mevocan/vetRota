<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'

interface FarmerInput {
  village_id: string | null
  first_name: string
  last_name: string
  phone: string
  email: string | null
  address_detail: string | null
  balance: number | null
  sms_notifications_enabled: boolean
  preferred_sms_language: string
  notes: string | null
}

const props = defineProps<{
  initial?: Partial<FarmerInput>
  submitLabel: string
}>()

const emit = defineEmits<{
  submit: [payload: FarmerInput]
}>()

const state = reactive<FarmerInput>({
  village_id: props.initial?.village_id ?? null,
  first_name: props.initial?.first_name ?? '',
  last_name: props.initial?.last_name ?? '',
  phone: props.initial?.phone ?? '',
  email: props.initial?.email ?? null,
  address_detail: props.initial?.address_detail ?? null,
  balance: props.initial?.balance ?? null,
  sms_notifications_enabled: props.initial?.sms_notifications_enabled ?? true,
  preferred_sms_language: props.initial?.preferred_sms_language ?? 'tr',
  notes: props.initial?.notes ?? null
})

const schema = z.object({
  village_id: z.string().uuid().nullable(),
  first_name: z.string().min(1, 'Ad zorunlu.').max(128),
  last_name: z.string().min(1, 'Soyad zorunlu.').max(128),
  phone: z.string().min(1, 'Telefon zorunlu.').max(32),
  email: z.string().email('Geçerli bir e-posta girin.').nullable().or(z.literal('').transform(() => null)),
  address_detail: z.string().nullable(),
  balance: z.number().nullable(),
  sms_notifications_enabled: z.boolean(),
  preferred_sms_language: z.string().max(10),
  notes: z.string().nullable()
})

interface Village { id: string; name: string; district: string }

const { data: villagesData } = await useApiFetch<{ data: Village[] }>('/villages?per_page=500')

const villageOptions = computed(() => [
  { label: '— Köy yok —', value: null },
  ...(villagesData.value?.data ?? []).map(v => ({
    label: `${v.name} / ${v.district}`,
    value: v.id
  }))
])

const submitting = ref(false)

async function onSubmit(_event: FormSubmitEvent<FarmerInput>) {
  submitting.value = true
  try {
    emit('submit', { ...state })
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <UForm :schema="schema" :state="state" class="space-y-4 max-w-2xl" @submit="onSubmit">
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Ad" name="first_name" required>
        <UInput v-model="state.first_name" />
      </UFormField>
      <UFormField label="Soyad" name="last_name" required>
        <UInput v-model="state.last_name" />
      </UFormField>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Telefon" name="phone" required>
        <UInput v-model="state.phone" placeholder="5551110000" />
      </UFormField>
      <UFormField label="E-posta" name="email">
        <UInput v-model="state.email" type="email" placeholder="ornek@eposta.com" />
      </UFormField>
    </div>

    <UFormField label="Köy" name="village_id">
      <USelect v-model="state.village_id" :items="villageOptions" value-key="value" class="w-full" />
    </UFormField>

    <UFormField label="Adres detayı" name="address_detail">
      <UTextarea v-model="state.address_detail" :rows="2" />
    </UFormField>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Bakiye (TL)" name="balance" hint="Negatif değer borcu, pozitif alacağı gösterir.">
        <UInput v-model.number="state.balance" type="number" step="0.01" />
      </UFormField>
      <UFormField label="SMS bildirimleri" name="sms_notifications_enabled">
        <USwitch v-model="state.sms_notifications_enabled" />
      </UFormField>
    </div>

    <UFormField label="Notlar" name="notes">
      <UTextarea v-model="state.notes" :rows="3" />
    </UFormField>

    <div class="flex gap-3 pt-4 border-t border-neutral-200">
      <UButton type="submit" color="primary" :loading="submitting">
        {{ submitLabel }}
      </UButton>
      <UButton variant="ghost" color="neutral" @click="$router.back()">
        İptal
      </UButton>
    </div>
  </UForm>
</template>
