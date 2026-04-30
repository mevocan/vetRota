<script setup lang="ts">
interface Appointment {
  id: string
  scheduled_at: string
  estimated_duration_minutes: number | null
  appointment_type: string
  status: string
  reason: string | null
  farmer: { id: string; first_name: string; last_name: string; phone: string } | null
  animal: { id: string; ear_tag: string | null; name: string | null } | null
  village: { id: string; name: string; district: string } | null
}

interface Paginated<T> {
  data: T[]
  current_page: number
  last_page: number
  total: number
}

const statusFilter = ref<string | undefined>(undefined)
const typeFilter = ref<string | undefined>(undefined)
const upcomingOnly = ref(true)
const page = ref(1)

const statusOptions = [
  { label: 'Tümü', value: undefined },
  { label: 'Planlandı', value: 'planned' },
  { label: 'Onaylandı', value: 'confirmed' },
  { label: 'Sürüyor', value: 'in_progress' },
  { label: 'Tamamlandı', value: 'completed' },
  { label: 'İptal', value: 'cancelled' },
  { label: 'Gelmedi', value: 'no_show' }
]
const typeOptions = [
  { label: 'Tümü', value: undefined },
  { label: 'Ziyaret', value: 'visit' },
  { label: 'Aşı', value: 'vaccination' },
  { label: 'Takip', value: 'follow_up' },
  { label: 'Acil', value: 'emergency' },
  { label: 'Rutin kontrol', value: 'routine_check' }
]

const statusLabel: Record<string, string> = {
  planned: 'Planlandı', confirmed: 'Onaylandı', in_progress: 'Sürüyor',
  completed: 'Tamamlandı', cancelled: 'İptal', no_show: 'Gelmedi'
}
const statusColor: Record<string, 'primary' | 'warning' | 'error' | 'neutral'> = {
  planned: 'neutral', confirmed: 'primary', in_progress: 'warning',
  completed: 'primary', cancelled: 'error', no_show: 'error'
}
const typeLabel: Record<string, string> = {
  visit: 'Ziyaret', vaccination: 'Aşı', follow_up: 'Takip',
  emergency: 'Acil', routine_check: 'Rutin kontrol'
}
const typeColor: Record<string, 'primary' | 'warning' | 'error' | 'neutral'> = {
  visit: 'neutral', vaccination: 'primary', follow_up: 'warning',
  emergency: 'error', routine_check: 'neutral'
}

const queryString = computed(() => {
  const p = new URLSearchParams()
  if (statusFilter.value) p.set('status', statusFilter.value)
  if (typeFilter.value) p.set('appointment_type', typeFilter.value)
  if (upcomingOnly.value) {
    const today = new Date().toISOString().slice(0, 10)
    p.set('from', today)
  }
  p.set('page', String(page.value))
  p.set('per_page', '50')
  return p.toString()
})

const { data, pending } = await useApiFetch<Paginated<Appointment>>(
  () => `/appointments?${queryString.value}`,
  { watch: [queryString], lazy: true }
)

watch([statusFilter, typeFilter, upcomingOnly], () => { page.value = 1 })

function fmtDate(iso: string) {
  return new Date(iso).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' })
}

// Yaklaşan randevuları gün gün grupla
const groupedByDate = computed(() => {
  if (!data.value?.data) return [] as { date: string; label: string; items: Appointment[] }[]
  const groups: Record<string, Appointment[]> = {}
  for (const a of data.value.data) {
    const day = a.scheduled_at.slice(0, 10)
    if (!groups[day]) groups[day] = []
    groups[day].push(a)
  }
  return Object.entries(groups)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([date, items]) => {
      const d = new Date(date + 'T00:00:00')
      const label = d.toLocaleDateString('tr-TR', { weekday: 'long', day: 'numeric', month: 'long' })
      return { date, label, items }
    })
})
</script>

<template>
  <div class="space-y-4">
    <div class="flex items-center gap-3 flex-wrap">
      <USelect v-model="statusFilter" :items="statusOptions" value-key="value" placeholder="Durum" class="w-44" />
      <USelect v-model="typeFilter" :items="typeOptions" value-key="value" placeholder="Tür" class="w-44" />
      <UCheckbox v-model="upcomingOnly" label="Bugünden itibaren" />
      <div class="flex-1" />
      <UButton to="/appointments/new" color="primary" icon="i-lucide-plus">
        Yeni randevu
      </UButton>
    </div>

    <div v-if="pending" class="p-12 text-center text-sm text-neutral-500">
      Yükleniyor...
    </div>

    <div v-else-if="!data?.data?.length" class="p-12 text-center bg-white rounded-md border border-neutral-200">
      <UIcon name="i-lucide-calendar-x" class="w-10 h-10 text-neutral-300 mx-auto mb-3" />
      <p class="text-sm text-neutral-600 mb-4">
        {{ statusFilter || typeFilter ? 'Filtrelere uyan randevu bulunamadı.' : (upcomingOnly ? 'Yaklaşan randevu yok.' : 'Henüz randevu yok.') }}
      </p>
      <UButton to="/appointments/new" color="primary" icon="i-lucide-plus">
        Yeni randevu ekle
      </UButton>
    </div>

    <div v-else class="space-y-5">
      <div v-for="group in groupedByDate" :key="group.date">
        <div class="text-xs uppercase tracking-wide text-neutral-500 font-semibold px-1 mb-2">
          {{ group.label }}
        </div>
        <UCard :ui="{ body: 'p-0' }">
          <div class="divide-y divide-neutral-200">
            <NuxtLink
              v-for="appt in group.items"
              :key="appt.id"
              :to="`/appointments/${appt.id}`"
              class="flex items-start gap-4 px-4 py-3 hover:bg-neutral-50 transition"
            >
              <div class="text-center w-16 flex-shrink-0">
                <div class="text-xs text-neutral-500">
                  {{ fmtDate(appt.scheduled_at).split(' ')[1] }}
                </div>
                <div v-if="appt.estimated_duration_minutes" class="text-[10px] text-neutral-400 mt-0.5">
                  {{ appt.estimated_duration_minutes }} dk
                </div>
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 mb-1 flex-wrap">
                  <UBadge :color="typeColor[appt.appointment_type] ?? 'neutral'" variant="soft" size="sm">
                    {{ typeLabel[appt.appointment_type] ?? appt.appointment_type }}
                  </UBadge>
                  <UBadge :color="statusColor[appt.status] ?? 'neutral'" variant="soft" size="sm">
                    {{ statusLabel[appt.status] ?? appt.status }}
                  </UBadge>
                </div>
                <div class="text-sm font-medium">
                  <span v-if="appt.farmer">{{ appt.farmer.first_name }} {{ appt.farmer.last_name }}</span>
                  <span v-if="appt.animal" class="text-neutral-500 font-normal ml-2">
                    · {{ appt.animal.ear_tag ?? '—' }}<span v-if="appt.animal.name"> · {{ appt.animal.name }}</span>
                  </span>
                </div>
                <div class="text-xs text-neutral-500 mt-0.5">
                  <span v-if="appt.village">{{ appt.village.name }} / {{ appt.village.district }}</span>
                  <span v-if="appt.reason" class="ml-2">· {{ appt.reason }}</span>
                </div>
              </div>
              <UIcon name="i-lucide-chevron-right" class="w-4 h-4 text-neutral-300 mt-2" />
            </NuxtLink>
          </div>
        </UCard>
      </div>
    </div>
  </div>
</template>
