<script setup lang="ts">
interface PaymentRow {
  id: string
  amount: string | number
  method: string
  paid_at: string
  notes: string | null
}

interface AnimalLite {
  id: string
  ear_tag: string | null
  name: string | null
  species: string
  gender: string
  status: string
}

interface FarmerDetail {
  id: string
  first_name: string
  last_name: string
  phone: string
  email: string | null
  address_detail: string | null
  balance: string
  sms_notifications_enabled: boolean
  preferred_sms_language: string
  notes: string | null
  animals_count: number
  created_at: string
  village: { id: string; name: string; district: string; city: string } | null
  animals: AnimalLite[]
}

const route = useRoute()
const { apiFetch } = useApi()
const toast = useToast()

const { data, refresh } = await useApiFetch<{ data: FarmerDetail }>(`/farmers/${route.params.id}`)
const { data: paymentsData, refresh: refreshPayments } = await useApiFetch<{ data: PaymentRow[] }>(
  `/payments?farmer_id=${route.params.id}&per_page=50`
)

const farmer = computed(() => data.value?.data)
const payments = computed(() => paymentsData.value?.data ?? [])

const showPaymentForm = ref(false)
const savingPayment = ref(false)
const paymentForm = reactive({
  amount: '',
  method: 'cash',
  notes: ''
})

function resetPayment() {
  paymentForm.amount = ''
  paymentForm.method = 'cash'
  paymentForm.notes = ''
}

async function submitPayment() {
  const amt = parseFloat(paymentForm.amount.replace(',', '.'))
  if (Number.isNaN(amt) || amt <= 0) {
    toast.add({ title: 'Geçerli bir tutar girin', color: 'error' })
    return
  }
  savingPayment.value = true
  try {
    await apiFetch('/payments', {
      method: 'POST',
      body: {
        farmer_id: route.params.id,
        amount: amt,
        method: paymentForm.method,
        notes: paymentForm.notes || null
      }
    })
    toast.add({ title: 'Ödeme kaydedildi', color: 'success' })
    showPaymentForm.value = false
    resetPayment()
    await Promise.all([refresh(), refreshPayments()])
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : 'Bilinmeyen hata'
    toast.add({ title: 'Kayıt başarısız: ' + msg, color: 'error' })
  } finally {
    savingPayment.value = false
  }
}

function fmtPaidAt(iso: string) {
  return new Date(iso).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' })
}
function fmtAmount(a: string | number) {
  const n = typeof a === 'number' ? a : parseFloat(a)
  return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(n)
}
const methodLabel: Record<string, string> = {
  cash: 'Nakit', transfer: 'Havale', other: 'Diğer'
}

const speciesLabel: Record<string, string> = {
  cattle: 'Sığır', sheep: 'Koyun', goat: 'Keçi', poultry: 'Kanatlı', other: 'Diğer'
}
const genderLabel: Record<string, string> = {
  male: 'Erkek', female: 'Dişi', unknown: 'Belirsiz'
}
const statusLabel: Record<string, string> = {
  alive: 'Canlı', sold: 'Satıldı', deceased: 'Vefat etti', lost: 'Kayboldu'
}

function formatBalance(b: string) {
  const n = parseFloat(b)
  if (Number.isNaN(n)) return '—'
  return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 2 }).format(n)
}

async function handleDelete() {
  if (!confirm('Bu çiftçiyi silmek istediğinize emin misiniz?')) return
  try {
    await apiFetch(`/farmers/${route.params.id}`, { method: 'DELETE' })
    toast.add({ title: 'Çiftçi silindi.', color: 'primary' })
    await navigateTo('/farmers')
  } catch {
    toast.add({ title: 'Silme başarısız.', color: 'error' })
  }
}
</script>

<template>
  <div v-if="farmer" class="space-y-6">
    <div>
      <NuxtLink to="/farmers" class="text-sm text-neutral-500 hover:text-primary-600 inline-flex items-center gap-1">
        <UIcon name="i-lucide-arrow-left" class="w-3.5 h-3.5" />
        Çiftçiler
      </NuxtLink>
    </div>

    <UCard>
      <div class="flex items-start gap-4">
        <div class="flex-1">
          <div class="text-2xl font-bold mb-1">
            {{ farmer.first_name }} {{ farmer.last_name }}
          </div>
          <div class="flex flex-wrap gap-x-6 gap-y-2 text-sm">
            <div>
              <span class="text-neutral-500 text-xs">Telefon: </span>
              <span class="font-mono font-medium">{{ farmer.phone }}</span>
            </div>
            <div v-if="farmer.email">
              <span class="text-neutral-500 text-xs">E-posta: </span>
              <span class="font-medium">{{ farmer.email }}</span>
            </div>
            <div>
              <span class="text-neutral-500 text-xs">Hayvan: </span>
              <span class="font-medium">{{ farmer.animals_count }}</span>
            </div>
            <div>
              <span class="text-neutral-500 text-xs">Bakiye: </span>
              <span class="font-medium" :class="parseFloat(farmer.balance) < 0 ? 'text-red-600' : ''">
                {{ formatBalance(farmer.balance) }}
              </span>
            </div>
            <div v-if="farmer.sms_notifications_enabled">
              <UBadge color="primary" variant="soft" size="sm">
                SMS açık
              </UBadge>
            </div>
          </div>
        </div>
        <div class="flex gap-2">
          <UButton variant="solid" icon="i-lucide-wallet" size="sm" @click="showPaymentForm = !showPaymentForm">
            Ödeme al
          </UButton>
          <UButton :to="`/farmers/${farmer.id}/edit`" variant="ghost" icon="i-lucide-pencil" size="sm">
            Düzenle
          </UButton>
          <UButton color="error" variant="ghost" icon="i-lucide-trash-2" size="sm" @click="handleDelete">
            Sil
          </UButton>
        </div>
      </div>
    </UCard>

    <UCard v-if="showPaymentForm">
      <template #header>
        <h3 class="font-semibold text-sm">
          Yeni ödeme
        </h3>
      </template>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
        <UFormField label="Tutar (TL)" required>
          <UInput v-model="paymentForm.amount" placeholder="0.00" />
        </UFormField>
        <UFormField label="Yöntem">
          <USelect
            v-model="paymentForm.method"
            :items="[
              { label: 'Nakit', value: 'cash' },
              { label: 'Havale', value: 'transfer' },
              { label: 'Diğer', value: 'other' }
            ]"
          />
        </UFormField>
        <UFormField label="Not">
          <UInput v-model="paymentForm.notes" placeholder="(opsiyonel)" />
        </UFormField>
      </div>
      <div class="flex justify-end gap-2 mt-3">
        <UButton variant="ghost" @click="showPaymentForm = false">
          İptal
        </UButton>
        <UButton :loading="savingPayment" @click="submitPayment">
          Kaydet
        </UButton>
      </div>
    </UCard>

    <UCard :ui="{ body: 'p-0' }">
      <template #header>
        <h3 class="font-semibold text-sm">
          Ödeme geçmişi ({{ payments.length }})
        </h3>
      </template>
      <div v-if="!payments.length" class="text-sm text-neutral-500 p-4">
        Henüz ödeme kaydı yok.
      </div>
      <table v-else class="w-full text-sm">
        <thead class="text-xs text-neutral-500 border-b">
          <tr>
            <th class="text-left p-3">Tarih</th>
            <th class="text-left p-3">Yöntem</th>
            <th class="text-right p-3">Tutar</th>
            <th class="text-left p-3">Not</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in payments" :key="p.id" class="border-b last:border-0">
            <td class="p-3">{{ fmtPaidAt(p.paid_at) }}</td>
            <td class="p-3">{{ methodLabel[p.method] ?? p.method }}</td>
            <td class="p-3 text-right font-medium text-green-700">
              + {{ fmtAmount(p.amount) }}
            </td>
            <td class="p-3 text-neutral-600">{{ p.notes ?? '—' }}</td>
          </tr>
        </tbody>
      </table>
    </UCard>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <UCard>
        <template #header>
          <h3 class="font-semibold text-sm">
            Köy
          </h3>
        </template>
        <div v-if="farmer.village" class="space-y-1 text-sm">
          <div class="font-medium">
            {{ farmer.village.name }}
          </div>
          <div class="text-neutral-500">
            {{ farmer.village.district }} / {{ farmer.village.city }}
          </div>
        </div>
        <div v-else class="text-sm text-neutral-400">
          —
        </div>
      </UCard>

      <UCard>
        <template #header>
          <h3 class="font-semibold text-sm">
            Adres
          </h3>
        </template>
        <p v-if="farmer.address_detail" class="text-sm whitespace-pre-line">
          {{ farmer.address_detail }}
        </p>
        <div v-else class="text-sm text-neutral-400">
          —
        </div>
      </UCard>
    </div>

    <UCard :ui="{ body: 'p-0' }">
      <template #header>
        <div class="flex items-center justify-between">
          <h3 class="font-semibold text-sm">
            Hayvanları ({{ farmer.animals_count }})
          </h3>
          <UButton :to="`/animals/new?farmer_id=${farmer.id}`" size="xs" variant="ghost" icon="i-lucide-plus">
            Yeni hayvan
          </UButton>
        </div>
      </template>
      <div v-if="!farmer.animals.length" class="p-8 text-center text-sm text-neutral-500">
        Bu çiftçinin henüz hayvan kaydı yok.
      </div>
      <table v-else class="w-full text-sm">
        <thead class="bg-neutral-50">
          <tr class="text-left text-xs uppercase tracking-wide text-neutral-500">
            <th class="px-4 py-2.5 font-semibold">Küpe / İsim</th>
            <th class="px-4 py-2.5 font-semibold">Tür</th>
            <th class="px-4 py-2.5 font-semibold">Cinsiyet</th>
            <th class="px-4 py-2.5 font-semibold">Durum</th>
            <th class="px-4 py-2.5" />
          </tr>
        </thead>
        <tbody class="divide-y divide-neutral-200">
          <tr v-for="animal in farmer.animals" :key="animal.id" class="hover:bg-neutral-50">
            <td class="px-4 py-3">
              <NuxtLink :to="`/animals/${animal.id}`" class="font-medium hover:text-primary-600">
                <span class="font-mono">{{ animal.ear_tag ?? '—' }}</span>
                <span v-if="animal.name" class="text-neutral-500 ml-2">{{ animal.name }}</span>
              </NuxtLink>
            </td>
            <td class="px-4 py-3">{{ speciesLabel[animal.species] ?? animal.species }}</td>
            <td class="px-4 py-3">{{ genderLabel[animal.gender] ?? animal.gender }}</td>
            <td class="px-4 py-3">
              <UBadge :color="animal.status === 'alive' ? 'primary' : 'neutral'" variant="soft" size="sm">
                {{ statusLabel[animal.status] ?? animal.status }}
              </UBadge>
            </td>
            <td class="px-4 py-3 text-right">
              <UButton :to="`/animals/${animal.id}`" size="xs" variant="ghost" icon="i-lucide-eye" />
            </td>
          </tr>
        </tbody>
      </table>
    </UCard>

    <UCard v-if="farmer.notes">
      <template #header>
        <h3 class="font-semibold text-sm">
          Notlar
        </h3>
      </template>
      <p class="text-sm whitespace-pre-line">
        {{ farmer.notes }}
      </p>
    </UCard>
  </div>
</template>
