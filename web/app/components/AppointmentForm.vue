<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'

interface AppointmentInput {
  farmer_id: string
  animal_id: string | null
  scheduled_at: string
  estimated_duration_minutes: number | null
  appointment_type: 'visit' | 'vaccination' | 'follow_up' | 'emergency' | 'routine_check'
  reason: string | null
  notes: string | null
  status: 'planned' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled' | 'no_show'
}

const props = defineProps<{
  initial?: Partial<AppointmentInput>
  submitLabel: string
  showStatus?: boolean
}>()

const emit = defineEmits<{ submit: [payload: AppointmentInput] }>()

function nowLocal(addMinutes = 60): string {
  const d = new Date()
  d.setMinutes(d.getMinutes() + addMinutes, 0, 0)
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

const state = reactive<AppointmentInput>({
  farmer_id: props.initial?.farmer_id ?? '',
  animal_id: props.initial?.animal_id ?? null,
  scheduled_at: isoToLocal(props.initial?.scheduled_at),
  estimated_duration_minutes: props.initial?.estimated_duration_minutes ?? 30,
  appointment_type: props.initial?.appointment_type ?? 'visit',
  reason: props.initial?.reason ?? null,
  notes: props.initial?.notes ?? null,
  status: props.initial?.status ?? 'planned'
})

const schema = z.object({
  farmer_id: z.string().uuid('Çiftçi seçimi zorunlu.'),
  animal_id: z.string().uuid().nullable(),
  scheduled_at: z.string().min(1, 'Tarih zorunlu.'),
  estimated_duration_minutes: z.number().int().min(5).max(480).nullable(),
  appointment_type: z.enum(['visit', 'vaccination', 'follow_up', 'emergency', 'routine_check']),
  reason: z.string().nullable(),
  notes: z.string().nullable(),
  status: z.enum(['planned', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show'])
})

const typeOptions = [
  { label: 'Ziyaret', value: 'visit' },
  { label: 'Aşı', value: 'vaccination' },
  { label: 'Takip', value: 'follow_up' },
  { label: 'Acil', value: 'emergency' },
  { label: 'Rutin kontrol', value: 'routine_check' }
]

const statusOptions = [
  { label: 'Planlandı', value: 'planned' },
  { label: 'Onaylandı', value: 'confirmed' },
  { label: 'Sürüyor', value: 'in_progress' },
  { label: 'Tamamlandı', value: 'completed' },
  { label: 'İptal', value: 'cancelled' },
  { label: 'Gelmedi', value: 'no_show' }
]

interface Farmer { id: string; first_name: string; last_name: string; phone: string; village_id: string | null }
interface Animal { id: string; ear_tag: string | null; name: string | null; farmer_id: string }

const { data: farmersData } = await useApiFetch<{ data: Farmer[] }>('/farmers?per_page=200')
const { data: animalsData } = await useApiFetch<{ data: Animal[] }>('/animals?per_page=200')

const farmerOptions = computed(() =>
  (farmersData.value?.data ?? []).map(f => ({
    label: `${f.first_name} ${f.last_name} (${f.phone})`,
    value: f.id
  }))
)

const animalOptions = computed(() => {
  const all = animalsData.value?.data ?? []
  const filtered = state.farmer_id ? all.filter(a => a.farmer_id === state.farmer_id) : all
  return [
    { label: '— Hayvan belirtilmedi —', value: null },
    ...filtered.map(a => ({
      label: `${a.ear_tag ?? '—'}${a.name ? ` · ${a.name}` : ''}`,
      value: a.id
    }))
  ]
})

// farmer değişince hayvan reset
watch(() => state.farmer_id, (fid, old) => {
  if (old && fid !== old) state.animal_id = null
})

const submitting = ref(false)
async function onSubmit(_e: FormSubmitEvent<AppointmentInput>) {
  submitting.value = true
  try {
    const scheduled = state.scheduled_at.replace('T', ' ').slice(0, 16) + ':00'
    emit('submit', { ...state, scheduled_at: scheduled })
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <UForm :schema="schema" :state="state" class="space-y-4 max-w-2xl" @submit="onSubmit">
    <UFormField label="Çiftçi" name="farmer_id" required>
      <USelect v-model="state.farmer_id" :items="farmerOptions" value-key="value" placeholder="Çiftçi seçin" class="w-full" />
    </UFormField>

    <UFormField label="Hayvan" name="animal_id" hint="Tüm sürü için bırakabilirsiniz.">
      <USelect v-model="state.animal_id" :items="animalOptions" value-key="value" class="w-full" :disabled="!state.farmer_id" />
    </UFormField>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <UFormField label="Tarih ve saat" name="scheduled_at" required>
        <UInput v-model="state.scheduled_at" type="datetime-local" />
      </UFormField>
      <UFormField label="Süre (dakika)" name="estimated_duration_minutes">
        <UInput v-model.number="state.estimated_duration_minutes" type="number" min="5" max="480" step="5" />
      </UFormField>
      <UFormField label="Tür" name="appointment_type" required>
        <USelect v-model="state.appointment_type" :items="typeOptions" value-key="value" class="w-full" />
      </UFormField>
    </div>

    <UFormField label="Sebep" name="reason">
      <UInput v-model="state.reason" placeholder="Kısa açıklama" />
    </UFormField>

    <UFormField label="Notlar" name="notes">
      <UTextarea v-model="state.notes" :rows="2" />
    </UFormField>

    <UFormField v-if="showStatus" label="Durum" name="status">
      <USelect v-model="state.status" :items="statusOptions" value-key="value" class="w-full" />
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
