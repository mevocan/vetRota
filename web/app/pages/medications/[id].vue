<script setup lang="ts">
interface Movement {
  id: string
  movement_type: string
  quantity: string
  unit_price: string | null
  batch_number: string | null
  expiry_date: string | null
  supplier_name: string | null
  occurred_at: string
  notes: string | null
  performed_by: { id: number; name: string } | null
}

interface DrugDetail {
  id: string
  name: string
  active_ingredient: string | null
  manufacturer: string | null
  barcode: string | null
  drug_type: string
  unit: string
  package_size: string | null
  is_vaccine: boolean
  vaccine_duration_days: number | null
  requires_prescription: boolean
  default_price: string | null
  stock: {
    id: string
    current_quantity: string
    critical_threshold: string | null
    earliest_expiry_at: string | null
    last_purchased_at: string | null
  } | null
  movements: Movement[]
}

const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()

const { data, refresh } = await useApiFetch<{ data: DrugDetail }>(`/drugs/${route.params.id}`)

const drug = computed(() => data.value?.data)

const typeLabel: Record<string, string> = {
  antibiotic: 'Antibiyotik',
  vaccine: 'Aşı',
  antiparasitic: 'Antiparaziter',
  antiinflammatory: 'Antienflamatuar',
  analgesic: 'Ağrı kesici',
  vitamin: 'Vitamin',
  hormone: 'Hormon',
  other: 'Diğer'
}
const movementLabel: Record<string, string> = {
  purchase: 'Alım',
  usage: 'Kullanım',
  transfer_in: 'Transfer giriş',
  transfer_out: 'Transfer çıkış',
  adjustment: 'Düzeltme',
  waste: 'Fire / atık',
  return: 'İade'
}
const movementColor: Record<string, 'primary' | 'warning' | 'error' | 'neutral'> = {
  purchase: 'primary',
  usage: 'neutral',
  transfer_in: 'primary',
  transfer_out: 'neutral',
  adjustment: 'warning',
  waste: 'error',
  return: 'warning'
}

function fmtDate(iso: string) {
  return new Date(iso).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' })
}

const isLow = computed(() => {
  if (!drug.value?.stock?.critical_threshold) return false
  return parseFloat(drug.value.stock.current_quantity) <= parseFloat(drug.value.stock.critical_threshold)
})

const showMovementForm = ref(false)

async function handleNewMovement(payload: Record<string, unknown>) {
  try {
    await apiFetch('/stock-movements', { method: 'POST', body: payload })
    toast.add({ title: 'Hareket kaydedildi.', color: 'primary' })
    showMovementForm.value = false
    await refresh()
  } catch (err: unknown) {
    const e = err as { data?: { message?: string } }
    toast.add({ title: e?.data?.message ?? 'Hareket kaydedilemedi.', color: 'error' })
  }
}

async function handleDelete() {
  if (!confirm('Bu ilacı silmek istediğinize emin misiniz?')) return
  try {
    await apiFetch(`/drugs/${route.params.id}`, { method: 'DELETE' })
    toast.add({ title: 'İlaç silindi.', color: 'primary' })
    await navigateTo('/medications')
  } catch {
    toast.add({ title: 'Silme başarısız.', color: 'error' })
  }
}
</script>

<template>
  <div v-if="drug" class="space-y-6">
    <div>
      <NuxtLink to="/medications" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        İlaçlar & Stok
      </NuxtLink>
    </div>

    <UCard>
      <div class="flex items-start gap-4">
        <div class="flex-1">
          <div class="flex items-center gap-3 mb-2">
            <UBadge :color="drug.is_vaccine ? 'primary' : 'neutral'" variant="soft">
              {{ typeLabel[drug.drug_type] ?? drug.drug_type }}
            </UBadge>
            <UBadge v-if="drug.requires_prescription" color="warning" variant="soft" size="sm">
              Reçeteli
            </UBadge>
            <UBadge v-if="drug.is_vaccine && drug.vaccine_duration_days" color="primary" variant="soft" size="sm">
              {{ drug.vaccine_duration_days }} gün koruma
            </UBadge>
          </div>
          <h2 class="text-2xl font-bold mb-1">
            {{ drug.name }}
          </h2>
          <div class="text-sm text-neutral-500">
            <template v-if="drug.active_ingredient">{{ drug.active_ingredient }}</template>
            <template v-if="drug.manufacturer"> · {{ drug.manufacturer }}</template>
            <template v-if="drug.package_size"> · {{ drug.package_size }} {{ drug.unit }}</template>
            <template v-if="drug.barcode"> · {{ drug.barcode }}</template>
          </div>
        </div>
        <div class="flex gap-2">
          <UButton :to="`/medications/${drug.id}/edit`" variant="ghost" icon="i-lucide-pencil" size="sm">
            Düzenle
          </UButton>
          <UButton color="error" variant="ghost" icon="i-lucide-trash-2" size="sm" @click="handleDelete">
            Sil
          </UButton>
        </div>
      </div>
    </UCard>

    <!-- Stok özeti -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
      <UCard>
        <div class="text-xs text-neutral-500 mb-1">
          Mevcut stok
        </div>
        <div class="text-2xl font-bold font-mono" :class="isLow ? 'text-amber-700' : ''">
          {{ drug.stock?.current_quantity ?? '0' }}
          <span class="text-sm font-normal text-neutral-500">{{ drug.unit }}</span>
        </div>
        <UBadge v-if="isLow" color="warning" variant="soft" size="sm" class="mt-2">
          Kritik seviye
        </UBadge>
      </UCard>
      <UCard>
        <div class="text-xs text-neutral-500 mb-1">
          Kritik eşik
        </div>
        <div class="text-2xl font-bold font-mono">
          {{ drug.stock?.critical_threshold ?? '—' }}
          <span v-if="drug.stock?.critical_threshold" class="text-sm font-normal text-neutral-500">{{ drug.unit }}</span>
        </div>
      </UCard>
      <UCard>
        <div class="text-xs text-neutral-500 mb-1">
          En yakın SKT
        </div>
        <div class="text-lg font-bold">
          {{ drug.stock?.earliest_expiry_at?.slice(0, 10) ?? '—' }}
        </div>
      </UCard>
      <UCard>
        <div class="text-xs text-neutral-500 mb-1">
          Son alım
        </div>
        <div class="text-lg font-bold">
          {{ drug.stock?.last_purchased_at ? fmtDate(drug.stock.last_purchased_at) : '—' }}
        </div>
      </UCard>
    </div>

    <UCard>
      <template #header>
        <div class="flex items-center justify-between">
          <h3 class="font-semibold text-sm">
            Stok hareketi
          </h3>
          <UButton v-if="!showMovementForm" size="xs" color="primary" icon="i-lucide-plus" @click="showMovementForm = true">
            Yeni hareket
          </UButton>
          <UButton v-else size="xs" variant="ghost" color="neutral" @click="showMovementForm = false">
            Kapat
          </UButton>
        </div>
      </template>
      <StockMovementForm
        v-if="showMovementForm"
        :drug-id="drug.id"
        :drug-name="drug.name"
        :drug-unit="drug.unit"
        @submit="handleNewMovement"
      />
      <p v-else class="text-sm text-neutral-500">
        Stok hareketi eklemek için yukarıdaki butona basın. Alım = pozitif giriş, kullanım/fire = negatif çıkış olarak otomatik kaydedilir.
      </p>
    </UCard>

    <UCard :ui="{ body: 'p-0' }">
      <template #header>
        <h3 class="font-semibold text-sm">
          Hareket geçmişi (son {{ drug.movements?.length ?? 0 }})
        </h3>
      </template>
      <div v-if="!drug.movements?.length" class="p-8 text-center text-sm text-neutral-500">
        Henüz hareket yok.
      </div>
      <table v-else class="w-full text-sm">
        <thead class="bg-neutral-50">
          <tr class="text-left text-xs uppercase tracking-wide text-neutral-500">
            <th class="px-4 py-2.5 font-semibold">Tarih</th>
            <th class="px-4 py-2.5 font-semibold">Tür</th>
            <th class="px-4 py-2.5 font-semibold">Miktar</th>
            <th class="px-4 py-2.5 font-semibold">Lot / SKT</th>
            <th class="px-4 py-2.5 font-semibold">Kim</th>
            <th class="px-4 py-2.5 font-semibold">Not</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-neutral-200">
          <tr v-for="m in drug.movements" :key="m.id" class="hover:bg-neutral-50">
            <td class="px-4 py-3 whitespace-nowrap text-xs">
              {{ fmtDate(m.occurred_at) }}
            </td>
            <td class="px-4 py-3">
              <UBadge :color="movementColor[m.movement_type] ?? 'neutral'" variant="soft" size="sm">
                {{ movementLabel[m.movement_type] ?? m.movement_type }}
              </UBadge>
            </td>
            <td class="px-4 py-3 font-mono" :class="parseFloat(m.quantity) < 0 ? 'text-red-600' : 'text-emerald-700'">
              {{ parseFloat(m.quantity) > 0 ? '+' : '' }}{{ m.quantity }} {{ drug.unit }}
            </td>
            <td class="px-4 py-3 text-xs text-neutral-500">
              <div v-if="m.batch_number">
                Lot: {{ m.batch_number }}
              </div>
              <div v-if="m.expiry_date">
                SKT: {{ m.expiry_date.slice(0, 10) }}
              </div>
              <span v-if="!m.batch_number && !m.expiry_date">—</span>
            </td>
            <td class="px-4 py-3 text-xs">
              {{ m.performed_by?.name ?? '—' }}
            </td>
            <td class="px-4 py-3 text-xs text-neutral-500 max-w-xs truncate">
              {{ m.notes ?? (m.supplier_name ? `Tedarikçi: ${m.supplier_name}` : '—') }}
            </td>
          </tr>
        </tbody>
      </table>
    </UCard>
  </div>
</template>
