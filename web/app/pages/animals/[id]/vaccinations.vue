<script setup lang="ts">
// M6.9: Hayvan icin asi planlari (CRUD).
// Liste + yeni plan formu + plani devre disi birakma.
interface VaccineSchedule {
  id: string
  animal_id: string
  drug_id: string
  interval_days: number
  first_due_date: string
  next_due_date: string
  remind_days_before: number
  is_active: boolean
  notes: string | null
  drug?: { id: string; name: string; is_vaccine: boolean }
}

interface DrugLite {
  id: string
  name: string
  is_vaccine: boolean
}

const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()
const animalId = route.params.id as string

const { data: schedulesData, refresh } = await useApiFetch<{ data: VaccineSchedule[] }>(
  `/vaccine-schedules?animal_id=${animalId}&only_active=0&per_page=100`
)
const { data: drugsData } = await useApiFetch<{ data: DrugLite[] }>(
  '/drugs?per_page=200'
)

const schedules = computed(() => schedulesData.value?.data ?? [])
const vaccineDrugs = computed(() =>
  (drugsData.value?.data ?? []).filter(d => d.is_vaccine)
)

const showForm = ref(false)
const saving = ref(false)
const form = reactive({
  drug_id: '',
  interval_days: 365,
  next_due_date: '',
  remind_days_before: 7,
  notes: ''
})

function resetForm() {
  form.drug_id = ''
  form.interval_days = 365
  form.next_due_date = ''
  form.remind_days_before = 7
  form.notes = ''
}

async function submit() {
  if (!form.drug_id || !form.next_due_date) {
    toast.add({ title: 'Aşı ve tarih zorunlu', color: 'error' })
    return
  }
  saving.value = true
  try {
    await apiFetch('/vaccine-schedules', {
      method: 'POST',
      body: {
        animal_id: animalId,
        drug_id: form.drug_id,
        interval_days: form.interval_days,
        next_due_date: form.next_due_date,
        remind_days_before: form.remind_days_before,
        notes: form.notes || null
      }
    })
    toast.add({ title: 'Aşı planı eklendi', color: 'success' })
    showForm.value = false
    resetForm()
    await refresh()
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : 'Bilinmeyen hata'
    toast.add({ title: 'Kayıt başarısız: ' + msg, color: 'error' })
  } finally {
    saving.value = false
  }
}

async function deactivate(s: VaccineSchedule) {
  if (!confirm(`"${s.drug?.name ?? 'Aşı'}" planını devre dışı bırak?`)) return
  try {
    await apiFetch(`/vaccine-schedules/${s.id}`, { method: 'DELETE' })
    toast.add({ title: 'Plan devre dışı', color: 'success' })
    await refresh()
  } catch {
    toast.add({ title: 'İşlem başarısız', color: 'error' })
  }
}

function formatDate(d: string | null): string {
  if (!d) return '—'
  return new Date(d).toLocaleDateString('tr-TR')
}
</script>

<template>
  <div class="space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">
        Aşı planları
      </h2>
      <UButton
        :icon="showForm ? 'i-lucide-x' : 'i-lucide-plus'"
        size="sm"
        @click="showForm = !showForm"
      >
        {{ showForm ? 'Vazgeç' : 'Yeni plan' }}
      </UButton>
    </div>

    <UCard v-if="showForm">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <UFormField label="Aşı" required>
          <USelect
            v-model="form.drug_id"
            :items="vaccineDrugs.map(d => ({ label: d.name, value: d.id }))"
            placeholder="Aşı seçin"
          />
        </UFormField>
        <UFormField label="İlk uygulama tarihi" required>
          <UInput v-model="form.next_due_date" type="date" />
        </UFormField>
        <UFormField label="Tekrar aralığı (gün)">
          <UInput v-model.number="form.interval_days" type="number" min="1" />
        </UFormField>
        <UFormField label="Hatırlatma (gün önce)">
          <UInput v-model.number="form.remind_days_before" type="number" min="0" />
        </UFormField>
        <UFormField label="Not" class="md:col-span-2">
          <UTextarea v-model="form.notes" :rows="2" />
        </UFormField>
      </div>
      <template #footer>
        <div class="flex justify-end gap-2">
          <UButton variant="ghost" @click="showForm = false">
            İptal
          </UButton>
          <UButton :loading="saving" @click="submit">
            Kaydet
          </UButton>
        </div>
      </template>
    </UCard>

    <UCard v-if="!schedules.length" class="text-center py-8">
      <p class="text-sm text-neutral-500">
        Bu hayvan için tanımlı aşı planı yok.
      </p>
    </UCard>

    <UCard v-for="s in schedules" :key="s.id">
      <div class="flex items-center justify-between">
        <div>
          <div class="flex items-center gap-2 mb-1">
            <UIcon name="i-lucide-syringe" class="w-4 h-4 text-primary-600" />
            <h3 class="font-semibold">
              {{ s.drug?.name ?? 'Aşı' }}
            </h3>
            <UBadge v-if="!s.is_active" color="neutral" variant="subtle" size="xs">
              Devre dışı
            </UBadge>
          </div>
          <p class="text-sm text-neutral-600">
            Sonraki: <strong>{{ formatDate(s.next_due_date) }}</strong>
            · Her {{ s.interval_days }} günde bir
            · {{ s.remind_days_before }} gün önce hatırlatma
          </p>
          <p v-if="s.notes" class="text-xs text-neutral-500 mt-1 italic">
            {{ s.notes }}
          </p>
        </div>
        <UButton
          v-if="s.is_active"
          icon="i-lucide-trash-2"
          size="xs"
          variant="ghost"
          color="error"
          @click="deactivate(s)"
        />
      </div>
    </UCard>
  </div>
</template>
