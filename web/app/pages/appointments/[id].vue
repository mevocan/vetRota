<script setup lang="ts">
interface ApptDetail {
  id: string
  scheduled_at: string
  estimated_duration_minutes: number | null
  appointment_type: string
  status: string
  status_changed_at: string | null
  reason: string | null
  notes: string | null
  farmer: { id: string; first_name: string; last_name: string; phone: string; email: string | null } | null
  animal: { id: string; ear_tag: string | null; name: string | null; species: string } | null
  vet: { id: number; name: string; email: string } | null
  village: { id: string; name: string; district: string; city: string } | null
}

const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()

const { data, refresh } = await useApiFetch<{ data: ApptDetail }>(`/appointments/${route.params.id}`)

const appt = computed(() => data.value?.data)

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

function fmtDate(iso: string) {
  return new Date(iso).toLocaleString('tr-TR', { dateStyle: 'long', timeStyle: 'short', weekday: 'long' })
}

async function changeStatus(newStatus: string) {
  try {
    await apiFetch(`/appointments/${route.params.id}`, { method: 'PUT', body: { status: newStatus } })
    toast.add({ title: `Durum: ${statusLabel[newStatus] ?? newStatus}`, color: 'primary' })
    await refresh()
  } catch (err: unknown) {
    const e = err as { data?: { message?: string } }
    toast.add({ title: e?.data?.message ?? 'Durum güncellenemedi.', color: 'error' })
  }
}

async function handleDelete() {
  if (!confirm('Bu randevuyu silmek istediğinize emin misiniz?')) return
  try {
    await apiFetch(`/appointments/${route.params.id}`, { method: 'DELETE' })
    toast.add({ title: 'Randevu silindi.', color: 'primary' })
    await navigateTo('/appointments')
  } catch {
    toast.add({ title: 'Silme başarısız.', color: 'error' })
  }
}

// Hangi durum geçişleri gösterilecek (bugünkü duruma göre)
const nextStatuses = computed(() => {
  if (!appt.value) return []
  const transitions: Record<string, string[]> = {
    planned: ['confirmed', 'in_progress', 'cancelled', 'no_show'],
    confirmed: ['in_progress', 'completed', 'cancelled', 'no_show'],
    in_progress: ['completed', 'cancelled'],
    completed: [],
    cancelled: ['planned'],
    no_show: ['planned']
  }
  return transitions[appt.value.status] ?? []
})
</script>

<template>
  <div v-if="appt" class="space-y-6">
    <div>
      <NuxtLink to="/appointments" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        Randevular
      </NuxtLink>
    </div>

    <UCard>
      <div class="flex items-start gap-4">
        <div class="flex-1">
          <div class="flex items-center gap-2 mb-2 flex-wrap">
            <UBadge variant="soft">
              {{ typeLabel[appt.appointment_type] ?? appt.appointment_type }}
            </UBadge>
            <UBadge :color="statusColor[appt.status] ?? 'neutral'" variant="solid">
              {{ statusLabel[appt.status] ?? appt.status }}
            </UBadge>
          </div>
          <h2 class="text-2xl font-bold mb-1">
            {{ fmtDate(appt.scheduled_at) }}
          </h2>
          <div v-if="appt.estimated_duration_minutes" class="text-sm text-neutral-500">
            Tahmini süre: {{ appt.estimated_duration_minutes }} dakika
          </div>
        </div>
        <div class="flex gap-2">
          <UButton :to="`/appointments/${appt.id}/edit`" variant="ghost" icon="i-lucide-pencil" size="sm">
            Düzenle
          </UButton>
          <UButton color="error" variant="ghost" icon="i-lucide-trash-2" size="sm" @click="handleDelete">
            Sil
          </UButton>
        </div>
      </div>

      <!-- Hızlı durum aksiyonları -->
      <div v-if="nextStatuses.length" class="flex gap-2 flex-wrap pt-4 mt-4 border-t border-neutral-200">
        <span class="text-xs text-neutral-500 self-center mr-1">Durumu değiştir:</span>
        <UButton
          v-for="s in nextStatuses"
          :key="s"
          size="xs"
          :color="statusColor[s] ?? 'neutral'"
          variant="soft"
          @click="changeStatus(s)"
        >
          {{ statusLabel[s] ?? s }}
        </UButton>
      </div>
    </UCard>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UCard>
        <template #header>
          <h3 class="font-semibold text-sm">
            Çiftçi
          </h3>
        </template>
        <div v-if="appt.farmer" class="space-y-1 text-sm">
          <NuxtLink :to="`/farmers/${appt.farmer.id}`" class="font-medium hover:text-primary-600">
            {{ appt.farmer.first_name }} {{ appt.farmer.last_name }}
          </NuxtLink>
          <div class="text-neutral-500 font-mono text-xs">
            {{ appt.farmer.phone }}
          </div>
          <div v-if="appt.farmer.email" class="text-neutral-500 text-xs">
            {{ appt.farmer.email }}
          </div>
        </div>
      </UCard>

      <UCard>
        <template #header>
          <h3 class="font-semibold text-sm">
            Hayvan
          </h3>
        </template>
        <div v-if="appt.animal" class="space-y-1 text-sm">
          <NuxtLink :to="`/animals/${appt.animal.id}`" class="font-medium hover:text-primary-600">
            <span class="font-mono">{{ appt.animal.ear_tag ?? '—' }}</span>
            <span v-if="appt.animal.name" class="text-neutral-500 ml-2">{{ appt.animal.name }}</span>
          </NuxtLink>
          <div class="text-xs text-neutral-500">
            {{ appt.animal.species }}
          </div>
        </div>
        <div v-else class="text-sm text-neutral-400">
          Tüm sürü için
        </div>
      </UCard>

      <UCard v-if="appt.village">
        <template #header>
          <h3 class="font-semibold text-sm">
            Köy
          </h3>
        </template>
        <div class="text-sm">
          <div class="font-medium">
            {{ appt.village.name }}
          </div>
          <div class="text-neutral-500">
            {{ appt.village.district }} / {{ appt.village.city }}
          </div>
        </div>
      </UCard>

      <UCard v-if="appt.vet">
        <template #header>
          <h3 class="font-semibold text-sm">
            Veteriner
          </h3>
        </template>
        <div class="text-sm">
          <span class="font-medium">{{ appt.vet.name }}</span>
        </div>
      </UCard>
    </div>

    <UCard v-if="appt.reason">
      <template #header>
        <h3 class="font-semibold text-sm">
          Sebep
        </h3>
      </template>
      <p class="text-sm whitespace-pre-line">
        {{ appt.reason }}
      </p>
    </UCard>

    <UCard v-if="appt.notes">
      <template #header>
        <h3 class="font-semibold text-sm">
          Notlar
        </h3>
      </template>
      <p class="text-sm whitespace-pre-line">
        {{ appt.notes }}
      </p>
    </UCard>

    <UCard v-if="appt.status === 'completed'">
      <template #header>
        <h3 class="font-semibold text-sm">
          Sonraki adım
        </h3>
      </template>
      <UButton
        v-if="appt.animal"
        :to="`/examinations/new?animal_id=${appt.animal.id}`"
        color="primary"
        icon="i-lucide-stethoscope"
        size="sm"
      >
        Bu randevu için muayene kaydı oluştur
      </UButton>
      <p v-else class="text-sm text-neutral-500">
        Hayvana özgü muayene kaydı için randevuya bir hayvan eklenmeli.
      </p>
    </UCard>
  </div>
</template>
