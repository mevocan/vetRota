<script setup lang="ts">
// M10.1: Free → Premium upgrade ekrani + fake odeme akisi.
// proje.md §4.2 fiyat: 1.250 ₺ aylik, 12.500 ₺ yillik.
// MVP: kart bilgileri sahte, sunucuya gonderilmez; sadece UX akisi gercek.
const auth = useAuthStore()
const { apiFetch } = useApi()

const loading = ref(false)
const processing = ref(false)
const errorMsg = ref('')

const showPayModal = ref(false)
const selectedPeriod = ref<'monthly' | 'yearly'>('monthly')

// Kart form state
const cardName = ref('')
const cardNumber = ref('')
const cardExpiry = ref('')
const cardCvv = ref('')
const cardError = ref('')

interface UpgradeResp {
  tier: string
  expires_at: string | null
  is_premium: boolean
  message: string
}

const priceLabel = computed(() =>
  selectedPeriod.value === 'yearly' ? '12.500 ₺ / yıl' : '1.250 ₺ / ay'
)

function openPay(period: 'monthly' | 'yearly') {
  selectedPeriod.value = period
  cardName.value = ''
  cardNumber.value = ''
  cardExpiry.value = ''
  cardCvv.value = ''
  cardError.value = ''
  errorMsg.value = ''
  showPayModal.value = true
}

// 1234 5678 9012 3456 formatla
function onCardNumberInput(e: Event) {
  const raw = (e.target as HTMLInputElement).value.replace(/\D/g, '').slice(0, 16)
  cardNumber.value = raw.replace(/(.{4})/g, '$1 ').trim()
}

// 12/34
function onExpiryInput(e: Event) {
  const raw = (e.target as HTMLInputElement).value.replace(/\D/g, '').slice(0, 4)
  cardExpiry.value = raw.length >= 3 ? `${raw.slice(0, 2)}/${raw.slice(2)}` : raw
}

function onCvvInput(e: Event) {
  cardCvv.value = (e.target as HTMLInputElement).value.replace(/\D/g, '').slice(0, 4)
}

function validateCard(): boolean {
  cardError.value = ''
  if (cardName.value.trim().length < 3) {
    cardError.value = 'Kart üzerindeki adı girin.'
    return false
  }
  const digits = cardNumber.value.replace(/\s/g, '')
  if (digits.length < 13 || digits.length > 19) {
    cardError.value = 'Kart numarası 13–19 hane olmalı.'
    return false
  }
  if (!/^\d{2}\/\d{2}$/.test(cardExpiry.value)) {
    cardError.value = 'Son kullanma AA/YY formatında olmalı.'
    return false
  }
  const [mm, yy] = cardExpiry.value.split('/').map(Number)
  if (mm < 1 || mm > 12) {
    cardError.value = 'Ay 01–12 arasında olmalı.'
    return false
  }
  const now = new Date()
  const expYear = 2000 + yy
  const expMonth = mm
  const lastDay = new Date(expYear, expMonth, 0)
  if (lastDay < now) {
    cardError.value = 'Kartın süresi dolmuş.'
    return false
  }
  if (cardCvv.value.length < 3) {
    cardError.value = 'CVV 3–4 hane olmalı.'
    return false
  }
  return true
}

async function pay() {
  if (!validateCard()) return
  processing.value = true
  cardError.value = ''
  try {
    // Sahte odeme islemi — gercek gateway taklidi (~1.5sn).
    await new Promise(r => setTimeout(r, 1500))

    const data = await apiFetch<UpgradeResp>('/subscription/upgrade', {
      method: 'POST',
      body: { period: selectedPeriod.value }
    })
    if (data.is_premium) {
      await auth.fetchUser()
      showPayModal.value = false
      await navigateTo('/')
    }
  } catch (e: any) {
    cardError.value = e?.data?.message ?? 'Ödeme alınamadı, tekrar deneyin.'
  } finally {
    processing.value = false
  }
}

async function cancel() {
  if (!confirm('Free pakete dönülsün mü? Premium özellikleriniz kapanır.')) return
  loading.value = true
  try {
    await apiFetch('/subscription/cancel', { method: 'POST' })
    await auth.fetchUser()
  } finally {
    loading.value = false
  }
}

const premiumFeatures = [
  { icon: 'i-lucide-map', title: 'Akıllı rota optimizasyonu', desc: 'Günlük randevular en az yakıt için sıralanır.' },
  { icon: 'i-lucide-message-square', title: 'Çiftçi SMS portalı', desc: 'Aşı/randevu SMS; şifresiz portal linki.' },
  { icon: 'i-lucide-camera', title: 'Fotoğraflı muayene', desc: 'Çevrimdışı çek, sync olduğunda yüklensin.' },
  { icon: 'i-lucide-activity', title: 'Hastalık yayılım haritası', desc: 'Köy bazlı yoğunluk + uyarı.' },
  { icon: 'i-lucide-file-text', title: 'Gün sonu PDF raporu', desc: 'Muayene/mesafe/ilaç/gelir özetli PDF.' },
  { icon: 'i-lucide-bar-chart-3', title: 'Klinik analitik paneli', desc: 'Veteriner performansı + ilaç tüketimi + gelir.' },
  { icon: 'i-lucide-bell', title: 'Aşı hatırlatma motoru', desc: 'Tekrarlayan aşı şablonu + otomatik SMS.' },
  { icon: 'i-lucide-file-text', title: 'Dijital reçete PDF', desc: 'Çiftçiye SMS linkiyle gönder.' }
]
</script>

<template>
  <div class="max-w-4xl mx-auto">
    <div v-if="auth.isPremium" class="bg-primary-50 border border-primary-200 rounded-lg p-6 mb-6">
      <div class="flex items-center gap-3">
        <UIcon name="i-lucide-sparkles" class="w-6 h-6 text-primary-700" />
        <div class="flex-1">
          <h2 class="font-semibold text-lg">
            Premium aktif
          </h2>
          <p class="text-sm text-neutral-600">
            Bitiş: {{ auth.user?.subscription_expires_at ? new Date(auth.user.subscription_expires_at).toLocaleDateString('tr-TR') : '—' }}
          </p>
        </div>
        <UButton color="neutral" variant="ghost" :loading="loading" @click="cancel">
          Free'ye dön
        </UButton>
      </div>
    </div>

    <div v-else>
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold mb-2">
          Premium'a geçin
        </h1>
        <p class="text-neutral-600">
          Sahada çalışan veterineri için tasarlanmış tüm gelişmiş özellikler.
        </p>
      </div>

      <div class="grid md:grid-cols-2 gap-4 mb-8">
        <div
          v-for="f in premiumFeatures"
          :key="f.title"
          class="bg-white border border-neutral-200 rounded-lg p-4 flex gap-3"
        >
          <UIcon :name="f.icon" class="w-5 h-5 text-primary-700 mt-0.5 flex-shrink-0" />
          <div>
            <div class="font-semibold text-sm">
              {{ f.title }}
            </div>
            <div class="text-xs text-neutral-600 mt-0.5">
              {{ f.desc }}
            </div>
          </div>
        </div>
      </div>

      <div class="grid md:grid-cols-2 gap-4">
        <div class="border border-neutral-200 rounded-lg p-6 bg-white">
          <div class="text-sm font-medium text-neutral-500">
            Aylık
          </div>
          <div class="text-3xl font-bold mt-1">
            1.250 ₺
          </div>
          <div class="text-xs text-neutral-500 mb-4">
            /ay
          </div>
          <UButton block size="lg" @click="openPay('monthly')">
            Aylık Premium'a geç
          </UButton>
        </div>

        <div class="border-2 border-primary-500 rounded-lg p-6 bg-primary-50 relative">
          <UBadge color="primary" class="absolute -top-2 right-4">
            %17 indirim
          </UBadge>
          <div class="text-sm font-medium text-neutral-500">
            Yıllık
          </div>
          <div class="text-3xl font-bold mt-1">
            12.500 ₺
          </div>
          <div class="text-xs text-neutral-500 mb-4">
            /yıl (1.042 ₺/ay)
          </div>
          <UButton block size="lg" color="primary" @click="openPay('yearly')">
            Yıllık Premium'a geç
          </UButton>
        </div>
      </div>

      <UAlert
        v-if="errorMsg"
        color="error"
        :title="errorMsg"
        class="mt-4"
      />

      <p class="text-xs text-neutral-500 text-center mt-6">
        Güvenli ödeme — kart bilgileriniz şifrelenir.
      </p>
    </div>

    <!-- M10.1: Fake odeme modali -->
    <UModal v-model:open="showPayModal" :ui="{ content: 'max-w-md' }">
      <template #content>
        <div class="p-6">
          <div class="flex items-center gap-2 mb-1">
            <UIcon name="i-lucide-credit-card" class="w-5 h-5 text-primary-700" />
            <h3 class="text-lg font-bold">
              Ödeme bilgileri
            </h3>
          </div>
          <p class="text-sm text-neutral-600 mb-4">
            Premium paket — <span class="font-semibold">{{ priceLabel }}</span>
          </p>

          <div class="space-y-3">
            <div>
              <label class="text-xs font-medium text-neutral-700 mb-1 block">Kart üzerindeki ad</label>
              <input
                v-model="cardName"
                type="text"
                placeholder="Ahmet Yılmaz"
                class="w-full px-3 py-2 border border-neutral-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                :disabled="processing"
              >
            </div>
            <div>
              <label class="text-xs font-medium text-neutral-700 mb-1 block">Kart numarası</label>
              <input
                :value="cardNumber"
                type="text"
                placeholder="1234 5678 9012 3456"
                inputmode="numeric"
                class="w-full px-3 py-2 border border-neutral-300 rounded-md text-sm font-mono tracking-wider focus:outline-none focus:ring-2 focus:ring-primary-500"
                :disabled="processing"
                @input="onCardNumberInput"
              >
            </div>
            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="text-xs font-medium text-neutral-700 mb-1 block">Son kullanma</label>
                <input
                  :value="cardExpiry"
                  type="text"
                  placeholder="AA/YY"
                  inputmode="numeric"
                  class="w-full px-3 py-2 border border-neutral-300 rounded-md text-sm font-mono focus:outline-none focus:ring-2 focus:ring-primary-500"
                  :disabled="processing"
                  @input="onExpiryInput"
                >
              </div>
              <div>
                <label class="text-xs font-medium text-neutral-700 mb-1 block">CVV</label>
                <input
                  :value="cardCvv"
                  type="text"
                  placeholder="123"
                  inputmode="numeric"
                  class="w-full px-3 py-2 border border-neutral-300 rounded-md text-sm font-mono focus:outline-none focus:ring-2 focus:ring-primary-500"
                  :disabled="processing"
                  @input="onCvvInput"
                >
              </div>
            </div>
          </div>

          <UAlert
            v-if="cardError"
            color="error"
            :title="cardError"
            class="mt-3"
          />

          <div class="flex gap-2 mt-5">
            <UButton
              color="neutral"
              variant="ghost"
              :disabled="processing"
              @click="showPayModal = false"
            >
              Vazgeç
            </UButton>
            <UButton
              block
              color="primary"
              :loading="processing"
              class="flex-1"
              @click="pay"
            >
              {{ processing ? 'İşleniyor…' : `${priceLabel} öde` }}
            </UButton>
          </div>

          <p class="text-[11px] text-neutral-500 text-center mt-4">
            <UIcon name="i-lucide-lock" class="w-3 h-3 inline -mt-0.5" />
            256-bit SSL ile şifreli bağlantı
          </p>
        </div>
      </template>
    </UModal>
  </div>
</template>
