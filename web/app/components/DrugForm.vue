<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'

interface DrugInput {
  name: string
  active_ingredient: string | null
  manufacturer: string | null
  barcode: string | null
  drug_type: 'antibiotic' | 'vaccine' | 'antiparasitic' | 'antiinflammatory' | 'analgesic' | 'vitamin' | 'hormone' | 'other'
  requires_prescription: boolean
  unit: 'ml' | 'tablet' | 'doz' | 'g' | 'flakon' | 'ampul'
  package_size: number | null
  is_vaccine: boolean
  vaccine_duration_days: number | null
  default_price: number | null
  critical_threshold: number | null
}

const props = defineProps<{
  initial?: Partial<DrugInput>
  submitLabel: string
}>()

const emit = defineEmits<{ submit: [payload: DrugInput] }>()

const state = reactive<DrugInput>({
  name: props.initial?.name ?? '',
  active_ingredient: props.initial?.active_ingredient ?? null,
  manufacturer: props.initial?.manufacturer ?? null,
  barcode: props.initial?.barcode ?? null,
  drug_type: props.initial?.drug_type ?? 'antibiotic',
  requires_prescription: props.initial?.requires_prescription ?? true,
  unit: props.initial?.unit ?? 'ml',
  package_size: props.initial?.package_size ?? null,
  is_vaccine: props.initial?.is_vaccine ?? false,
  vaccine_duration_days: props.initial?.vaccine_duration_days ?? null,
  default_price: props.initial?.default_price ?? null,
  critical_threshold: props.initial?.critical_threshold ?? null
})

const schema = z.object({
  name: z.string().min(1, 'İlaç adı zorunlu.').max(191),
  active_ingredient: z.string().max(191).nullable(),
  manufacturer: z.string().max(191).nullable(),
  barcode: z.string().max(64).nullable(),
  drug_type: z.enum(['antibiotic', 'vaccine', 'antiparasitic', 'antiinflammatory', 'analgesic', 'vitamin', 'hormone', 'other']),
  requires_prescription: z.boolean(),
  unit: z.enum(['ml', 'tablet', 'doz', 'g', 'flakon', 'ampul']),
  package_size: z.number().min(0).nullable(),
  is_vaccine: z.boolean(),
  vaccine_duration_days: z.number().int().min(1).nullable(),
  default_price: z.number().min(0).nullable(),
  critical_threshold: z.number().min(0).nullable()
})

const drugTypeOptions = [
  { label: 'Antibiyotik', value: 'antibiotic' },
  { label: 'Aşı', value: 'vaccine' },
  { label: 'Antiparaziter', value: 'antiparasitic' },
  { label: 'Antienflamatuar', value: 'antiinflammatory' },
  { label: 'Ağrı kesici', value: 'analgesic' },
  { label: 'Vitamin', value: 'vitamin' },
  { label: 'Hormon', value: 'hormone' },
  { label: 'Diğer', value: 'other' }
]

const unitOptions = [
  { label: 'ml', value: 'ml' },
  { label: 'tablet', value: 'tablet' },
  { label: 'doz', value: 'doz' },
  { label: 'g', value: 'g' },
  { label: 'flakon', value: 'flakon' },
  { label: 'ampul', value: 'ampul' }
]

// drug_type == vaccine secilince is_vaccine de true olsun
watch(() => state.drug_type, (t) => {
  if (t === 'vaccine') state.is_vaccine = true
})

const submitting = ref(false)
async function onSubmit(_e: FormSubmitEvent<DrugInput>) {
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
    <UFormField label="İlaç adı" name="name" required>
      <UInput v-model="state.name" />
    </UFormField>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Etken madde" name="active_ingredient">
        <UInput v-model="state.active_ingredient" />
      </UFormField>
      <UFormField label="Üretici" name="manufacturer">
        <UInput v-model="state.manufacturer" />
      </UFormField>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <UFormField label="Tür" name="drug_type" required>
        <USelect v-model="state.drug_type" :items="drugTypeOptions" value-key="value" class="w-full" />
      </UFormField>
      <UFormField label="Birim" name="unit" required>
        <USelect v-model="state.unit" :items="unitOptions" value-key="value" class="w-full" />
      </UFormField>
      <UFormField label="Ambalaj" name="package_size" hint="Birim cinsinden">
        <UInput v-model.number="state.package_size" type="number" step="0.01" min="0" />
      </UFormField>
    </div>

    <UFormField label="Barkod" name="barcode">
      <UInput v-model="state.barcode" />
    </UFormField>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
      <UFormField label="Reçete gerekli" name="requires_prescription">
        <USwitch v-model="state.requires_prescription" />
      </UFormField>
      <UFormField label="Aşı" name="is_vaccine">
        <USwitch v-model="state.is_vaccine" />
      </UFormField>
      <UFormField v-if="state.is_vaccine" label="Koruma süresi (gün)" name="vaccine_duration_days">
        <UInput v-model.number="state.vaccine_duration_days" type="number" min="1" />
      </UFormField>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Birim fiyat (TL)" name="default_price">
        <UInput v-model.number="state.default_price" type="number" step="0.01" min="0" />
      </UFormField>
      <UFormField label="Kritik stok eşiği" name="critical_threshold" hint="Bu seviyenin altında uyarı.">
        <UInput v-model.number="state.critical_threshold" type="number" step="0.01" min="0" />
      </UFormField>
    </div>

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
