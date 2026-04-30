<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'

interface MovementInput {
  drug_id: string
  movement_type: 'purchase' | 'usage' | 'transfer_in' | 'transfer_out' | 'adjustment' | 'waste' | 'return'
  quantity: number
  unit_price: number | null
  batch_number: string | null
  expiry_date: string | null
  supplier_name: string | null
  notes: string | null
  occurred_at: string
}

const props = defineProps<{
  drugId: string
  drugName: string
  drugUnit: string
}>()

const emit = defineEmits<{ submit: [payload: MovementInput] }>()

function nowLocal(): string {
  const d = new Date()
  d.setSeconds(0, 0)
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`
}

const state = reactive<MovementInput>({
  drug_id: props.drugId,
  movement_type: 'purchase',
  quantity: 0,
  unit_price: null,
  batch_number: null,
  expiry_date: null,
  supplier_name: null,
  notes: null,
  occurred_at: nowLocal()
})

const movementOptions = [
  { label: 'Alım (giriş)', value: 'purchase' },
  { label: 'Kullanım (çıkış)', value: 'usage' },
  { label: 'Düzeltme', value: 'adjustment' },
  { label: 'Fire / atık', value: 'waste' },
  { label: 'İade', value: 'return' }
]

// Direction helper: kullanım/fire → negatif olsun ama kullanıcı pozitif girsin
const inputQuantity = ref(0)
watch(inputQuantity, (q) => {
  const sign = ['usage', 'waste', 'transfer_out'].includes(state.movement_type) ? -1 : 1
  state.quantity = sign * Math.abs(q)
})
watch(() => state.movement_type, () => {
  // tipini değiştirince işareti güncelle
  const sign = ['usage', 'waste', 'transfer_out'].includes(state.movement_type) ? -1 : 1
  state.quantity = sign * Math.abs(inputQuantity.value)
})

const schema = z.object({
  drug_id: z.string().uuid(),
  movement_type: z.enum(['purchase', 'usage', 'transfer_in', 'transfer_out', 'adjustment', 'waste', 'return']),
  quantity: z.number().refine(n => n !== 0, 'Miktar 0 olamaz.'),
  unit_price: z.number().min(0).nullable(),
  batch_number: z.string().max(64).nullable(),
  expiry_date: z.string().nullable(),
  supplier_name: z.string().max(191).nullable(),
  notes: z.string().nullable(),
  occurred_at: z.string().min(1)
})

const submitting = ref(false)
async function onSubmit(_e: FormSubmitEvent<MovementInput>) {
  submitting.value = true
  try {
    const occurred = state.occurred_at.replace('T', ' ').slice(0, 16) + ':00'
    emit('submit', { ...state, occurred_at: occurred })
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <UForm :schema="schema" :state="state" class="space-y-4" @submit="onSubmit">
    <UAlert
      icon="i-lucide-info"
      color="neutral"
      variant="soft"
      :title="`${drugName}`"
      :description="`Birim: ${drugUnit}`"
    />

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Hareket türü" name="movement_type" required>
        <USelect v-model="state.movement_type" :items="movementOptions" value-key="value" class="w-full" />
      </UFormField>
      <UFormField label="Tarih" name="occurred_at" required>
        <UInput v-model="state.occurred_at" type="datetime-local" />
      </UFormField>
    </div>

    <UFormField
      label="Miktar"
      name="quantity"
      required
      :hint="['usage', 'waste', 'transfer_out'].includes(state.movement_type) ? `Çıkış olarak kaydedilecek (-${Math.abs(inputQuantity)})` : 'Giriş olarak kaydedilecek'"
    >
      <UInput v-model.number="inputQuantity" type="number" step="0.001" min="0" :placeholder="`Miktar (${drugUnit})`" />
    </UFormField>

    <div v-if="state.movement_type === 'purchase'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Birim fiyat (TL)" name="unit_price">
        <UInput v-model.number="state.unit_price" type="number" step="0.01" min="0" />
      </UFormField>
      <UFormField label="Tedarikçi" name="supplier_name">
        <UInput v-model="state.supplier_name" />
      </UFormField>
      <UFormField label="Lot / parti no" name="batch_number">
        <UInput v-model="state.batch_number" />
      </UFormField>
      <UFormField label="Son kullanma tarihi" name="expiry_date">
        <UInput v-model="state.expiry_date" type="date" />
      </UFormField>
    </div>

    <UFormField label="Notlar" name="notes">
      <UTextarea v-model="state.notes" :rows="2" />
    </UFormField>

    <div class="flex gap-3 pt-4 border-t border-neutral-200">
      <UButton type="submit" color="primary" :loading="submitting">
        Hareket ekle
      </UButton>
      <UButton variant="ghost" color="neutral" @click="$router.back()">
        İptal
      </UButton>
    </div>
  </UForm>
</template>
