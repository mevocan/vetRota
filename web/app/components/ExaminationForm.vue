<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'

interface ExaminationInput {
  animal_id: string
  visit_type: 'examination' | 'vaccination' | 'treatment' | 'emergency' | 'routine_check' | 'pregnancy_check'
  examined_at: string
  chief_complaint: string | null
  symptoms: string | null
  diagnosis_notes: string | null
  treatment_notes: string | null
  recommendations: string | null
  temperature_celsius: number | null
  weight_kg: number | null
  heart_rate: number | null
  respiratory_rate: number | null
  service_fee: number | null
  follow_up_needed: boolean
  follow_up_date: string | null
}

const props = defineProps<{
  initial?: Partial<ExaminationInput>
  submitLabel: string
  // animal_id'yi disardan kilitlemek isteyen sayfa (orn. hayvan detayindan "yeni muayene")
  lockAnimal?: boolean
}>()

const emit = defineEmits<{
  submit: [payload: ExaminationInput]
}>()

function nowLocal(): string {
  const d = new Date()
  d.setSeconds(0, 0)
  // datetime-local input formatı: YYYY-MM-DDTHH:mm
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`
}

function isoToLocal(iso: string | undefined | null): string {
  if (!iso) return nowLocal()
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return nowLocal()
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`
}

const state = reactive<ExaminationInput>({
  animal_id: props.initial?.animal_id ?? '',
  visit_type: props.initial?.visit_type ?? 'examination',
  examined_at: isoToLocal(props.initial?.examined_at),
  chief_complaint: props.initial?.chief_complaint ?? null,
  symptoms: props.initial?.symptoms ?? null,
  diagnosis_notes: props.initial?.diagnosis_notes ?? null,
  treatment_notes: props.initial?.treatment_notes ?? null,
  recommendations: props.initial?.recommendations ?? null,
  temperature_celsius: props.initial?.temperature_celsius ?? null,
  weight_kg: props.initial?.weight_kg ?? null,
  heart_rate: props.initial?.heart_rate ?? null,
  respiratory_rate: props.initial?.respiratory_rate ?? null,
  service_fee: props.initial?.service_fee ?? null,
  follow_up_needed: props.initial?.follow_up_needed ?? false,
  follow_up_date: props.initial?.follow_up_date ?? null
})

const schema = z.object({
  animal_id: z.string().uuid('Hayvan seçimi zorunlu.'),
  visit_type: z.enum(['examination', 'vaccination', 'treatment', 'emergency', 'routine_check', 'pregnancy_check']),
  examined_at: z.string().min(1, 'Muayene tarihi zorunlu.'),
  chief_complaint: z.string().nullable(),
  symptoms: z.string().nullable(),
  diagnosis_notes: z.string().nullable(),
  treatment_notes: z.string().nullable(),
  recommendations: z.string().nullable(),
  temperature_celsius: z.number().min(30).max(50).nullable(),
  weight_kg: z.number().min(0).max(9999.99).nullable(),
  heart_rate: z.number().int().min(0).max(500).nullable(),
  respiratory_rate: z.number().int().min(0).max(200).nullable(),
  service_fee: z.number().min(0).nullable(),
  follow_up_needed: z.boolean(),
  follow_up_date: z.string().nullable()
}).refine(
  v => !v.follow_up_needed || (v.follow_up_date && v.follow_up_date.length > 0),
  { message: 'Takip işaretliyse tarih zorunlu.', path: ['follow_up_date'] }
)

const visitOptions = [
  { label: 'Genel muayene', value: 'examination' },
  { label: 'Aşı', value: 'vaccination' },
  { label: 'Tedavi', value: 'treatment' },
  { label: 'Acil', value: 'emergency' },
  { label: 'Rutin kontrol', value: 'routine_check' },
  { label: 'Gebelik kontrolü', value: 'pregnancy_check' }
]

interface AnimalOpt {
  id: string
  ear_tag: string | null
  name: string | null
  farmer: { first_name: string; last_name: string } | null
}

const { data: animalsData } = await useApiFetch<{ data: AnimalOpt[] }>('/animals?per_page=200')

const animalOptions = computed(() =>
  (animalsData.value?.data ?? []).map(a => ({
    label: `${a.ear_tag ?? '—'}${a.name ? ` · ${a.name}` : ''}${a.farmer ? ` (${a.farmer.first_name} ${a.farmer.last_name})` : ''}`,
    value: a.id
  }))
)

const submitting = ref(false)

async function onSubmit(_event: FormSubmitEvent<ExaminationInput>) {
  submitting.value = true
  try {
    // datetime-local "YYYY-MM-DDTHH:mm" -> "YYYY-MM-DD HH:mm:00" (Laravel uyumlu)
    const examined = state.examined_at.replace('T', ' ').slice(0, 16) + ':00'
    emit('submit', { ...state, examined_at: examined })
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <UForm :schema="schema" :state="state" class="space-y-4 max-w-3xl" @submit="onSubmit">
    <UFormField label="Hayvan" name="animal_id" required>
      <USelect
        v-model="state.animal_id"
        :items="animalOptions"
        :disabled="lockAnimal"
        value-key="value"
        placeholder="Hayvan seçin"
        class="w-full"
      />
    </UFormField>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UFormField label="Ziyaret türü" name="visit_type" required>
        <USelect v-model="state.visit_type" :items="visitOptions" value-key="value" class="w-full" />
      </UFormField>
      <UFormField label="Tarih" name="examined_at" required>
        <UInput v-model="state.examined_at" type="datetime-local" />
      </UFormField>
    </div>

    <UFormField label="Şikayet / sebep" name="chief_complaint">
      <UTextarea v-model="state.chief_complaint" :rows="2" placeholder="Çiftçi/veteriner ne için geldi?" />
    </UFormField>

    <UFormField label="Bulgular / semptomlar" name="symptoms">
      <UTextarea v-model="state.symptoms" :rows="2" />
    </UFormField>

    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
      <UFormField label="Sıcaklık (°C)" name="temperature_celsius">
        <UInput v-model.number="state.temperature_celsius" type="number" step="0.1" min="30" max="50" />
      </UFormField>
      <UFormField label="Ağırlık (kg)" name="weight_kg">
        <UInput v-model.number="state.weight_kg" type="number" step="0.01" min="0" />
      </UFormField>
      <UFormField label="Nabız" name="heart_rate">
        <UInput v-model.number="state.heart_rate" type="number" min="0" />
      </UFormField>
      <UFormField label="Solunum" name="respiratory_rate">
        <UInput v-model.number="state.respiratory_rate" type="number" min="0" />
      </UFormField>
    </div>

    <UFormField label="Tanı notları" name="diagnosis_notes">
      <UTextarea v-model="state.diagnosis_notes" :rows="3" />
    </UFormField>

    <UFormField label="Tedavi notları" name="treatment_notes">
      <UTextarea v-model="state.treatment_notes" :rows="3" />
    </UFormField>

    <UFormField label="Öneriler" name="recommendations">
      <UTextarea v-model="state.recommendations" :rows="2" />
    </UFormField>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
      <UFormField label="Hizmet ücreti (TL)" name="service_fee">
        <UInput v-model.number="state.service_fee" type="number" step="0.01" min="0" />
      </UFormField>
      <UFormField label="Takip gerekli mi?" name="follow_up_needed">
        <USwitch v-model="state.follow_up_needed" />
      </UFormField>
      <UFormField label="Takip tarihi" name="follow_up_date">
        <UInput v-model="state.follow_up_date" type="date" :disabled="!state.follow_up_needed" />
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
