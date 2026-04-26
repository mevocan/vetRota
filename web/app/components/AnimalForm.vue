<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'

interface AnimalInput {
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

const props = defineProps<{
  initial?: Partial<AnimalInput>
  submitLabel: string
}>()

const emit = defineEmits<{
  submit: [payload: AnimalInput]
}>()

const state = reactive<AnimalInput>({
  farmer_id: props.initial?.farmer_id ?? '',
  village_id: props.initial?.village_id ?? null,
  ear_tag: props.initial?.ear_tag ?? null,
  name: props.initial?.name ?? null,
  species: props.initial?.species ?? 'cattle',
  breed: props.initial?.breed ?? null,
  birth_date: props.initial?.birth_date ?? null,
  gender: props.initial?.gender ?? 'female',
  weight_kg: props.initial?.weight_kg ?? null,
  color: props.initial?.color ?? null,
  is_pregnant: props.initial?.is_pregnant ?? false,
  status: props.initial?.status ?? 'alive',
  notes: props.initial?.notes ?? null
})

const schema = z.object({
  farmer_id: z.string().uuid('Çiftçi seçimi zorunlu.'),
  village_id: z.string().uuid().nullable(),
  ear_tag: z.string().max(64).nullable(),
  name: z.string().max(128).nullable(),
  species: z.enum(['cattle', 'sheep', 'goat', 'poultry', 'other']),
  breed: z.string().max(128).nullable(),
  birth_date: z.string().nullable(),
  gender: z.enum(['male', 'female', 'unknown']),
  weight_kg: z.number().min(0).max(9999.99).nullable(),
  color: z.string().max(64).nullable(),
  is_pregnant: z.boolean(),
  status: z.enum(['alive', 'sold', 'deceased', 'lost']),
  notes: z.string().nullable()
})

const speciesOptions = [
  { label: 'Sığır', value: 'cattle' },
  { label: 'Koyun', value: 'sheep' },
  { label: 'Keçi', value: 'goat' },
  { label: 'Kanatlı', value: 'poultry' },
  { label: 'Diğer', value: 'other' }
]

const genderOptions = [
  { label: 'Dişi', value: 'female' },
  { label: 'Erkek', value: 'male' },
  { label: 'Belirsiz', value: 'unknown' }
]

const statusOptions = [
  { label: 'Canlı', value: 'alive' },
  { label: 'Satıldı', value: 'sold' },
  { label: 'Vefat etti', value: 'deceased' },
  { label: 'Kayboldu', value: 'lost' }
]

interface Farmer { id: string; first_name: string; last_name: string; phone: string }
interface Village { id: string; name: string; district: string }

const { data: farmersData } = await useApiFetch<{ data: Farmer[] }>('/farmers?per_page=200')
const { data: villagesData } = await useApiFetch<{ data: Village[] }>('/villages?per_page=500')

const farmerOptions = computed(() =>
  (farmersData.value?.data ?? []).map(f => ({
    label: `${f.first_name} ${f.last_name} (${f.phone})`,
    value: f.id
  }))
)

const villageOptions = computed(() => [
  { label: '— Köy yok —', value: null },
  ...(villagesData.value?.data ?? []).map(v => ({
    label: `${v.name} / ${v.district}`,
    value: v.id
  }))
])

const submitting = ref(false)

async function onSubmit(_event: FormSubmitEvent<AnimalInput>) {
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
    <UFormField label="Çiftçi" name="farmer_id" required>
      <USelect
        v-model="state.farmer_id"
        :items="farmerOptions"
        value-key="value"
        placeholder="Çiftçi seçin"
        class="w-full"
      />
    </UFormField>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Küpe no" name="ear_tag">
        <UInput v-model="state.ear_tag" placeholder="TR-06-001" />
      </UFormField>
      <UFormField label="İsim" name="name">
        <UInput v-model="state.name" placeholder="Sarıkız" />
      </UFormField>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Tür" name="species" required>
        <USelect v-model="state.species" :items="speciesOptions" value-key="value" class="w-full" />
      </UFormField>
      <UFormField label="Cinsiyet" name="gender" required>
        <USelect v-model="state.gender" :items="genderOptions" value-key="value" class="w-full" />
      </UFormField>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Irk" name="breed">
        <UInput v-model="state.breed" placeholder="Simental" />
      </UFormField>
      <UFormField label="Renk" name="color">
        <UInput v-model="state.color" />
      </UFormField>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Doğum tarihi" name="birth_date">
        <UInput v-model="state.birth_date" type="date" />
      </UFormField>
      <UFormField label="Ağırlık (kg)" name="weight_kg">
        <UInput v-model.number="state.weight_kg" type="number" step="0.01" min="0" />
      </UFormField>
    </div>

    <UFormField label="Köy" name="village_id">
      <USelect v-model="state.village_id" :items="villageOptions" value-key="value" class="w-full" />
    </UFormField>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Durum" name="status">
        <USelect v-model="state.status" :items="statusOptions" value-key="value" class="w-full" />
      </UFormField>
      <UFormField label="Gebe mi?" name="is_pregnant">
        <USwitch v-model="state.is_pregnant" />
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
