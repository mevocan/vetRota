<script setup lang="ts">
const auth = useAuthStore()
const route = useRoute()

const navItems = [
  { label: 'Panel', icon: 'i-lucide-layout-dashboard', to: '/', premium: false },
  { label: 'Hayvanlar', icon: 'i-lucide-paw-print', to: '/animals', premium: false },
  { label: 'Çiftçiler', icon: 'i-lucide-users', to: '/farmers', premium: false },
  { label: 'Muayeneler', icon: 'i-lucide-stethoscope', to: '/examinations', premium: false },
  { label: 'İlaç & Stok', icon: 'i-lucide-pill', to: '/medications', premium: false },
  { label: 'Randevular', icon: 'i-lucide-calendar', to: '/appointments', premium: false },
  { label: 'Hastalık haritası', icon: 'i-lucide-map', to: '/analytics/disease-map', premium: true },
  { label: 'Veteriner performansı', icon: 'i-lucide-trophy', to: '/analytics/vets', premium: true },
  { label: 'İlaç tüketimi', icon: 'i-lucide-bar-chart-3', to: '/analytics/drugs', premium: true },
  { label: 'Klinik kazancı', icon: 'i-lucide-trending-up', to: '/analytics/revenue', premium: true }
]

const pageTitle = computed(() => {
  const item = navItems.find(n => n.to === route.path || (n.to !== '/' && route.path.startsWith(n.to)))
  return item?.label ?? 'VetRota'
})

async function handleLogout() {
  auth.logout()
  await navigateTo('/login')
}
</script>

<template>
  <div class="flex h-screen bg-neutral-50">
    <!-- Sidebar -->
    <aside class="w-56 bg-white border-r border-neutral-200 flex flex-col flex-shrink-0">
      <div class="px-4 py-3 border-b border-neutral-200 flex items-center justify-center">
        <NuxtLink to="/" class="block">
          <img src="/branding/logo.png" alt="VetRota" class="h-9 w-auto">
        </NuxtLink>
      </div>
      <nav class="flex-1 p-2 space-y-0.5 overflow-y-auto">
        <NuxtLink
          v-for="item in navItems"
          :key="item.to"
          :to="item.premium && !auth.isPremium ? '/upgrade' : item.to"
          class="flex items-center gap-2.5 px-2.5 py-2 text-sm rounded-md text-neutral-600 hover:bg-neutral-100 transition"
          active-class="!bg-primary-50 !text-primary-700 font-semibold"
        >
          <UIcon :name="item.icon" class="w-4 h-4 flex-shrink-0" />
          <span class="flex-1">{{ item.label }}</span>
          <UIcon
            v-if="item.premium && !auth.isPremium"
            name="i-lucide-lock"
            class="w-3.5 h-3.5 text-amber-500"
          />
        </NuxtLink>

        <NuxtLink
          v-if="!auth.isPremium"
          to="/upgrade"
          class="flex items-center gap-2.5 px-2.5 py-2 text-sm rounded-md text-amber-700 bg-amber-50 hover:bg-amber-100 transition font-medium mt-2"
        >
          <UIcon name="i-lucide-sparkles" class="w-4 h-4 flex-shrink-0" />
          Premium'a geç
        </NuxtLink>
      </nav>
      <div class="p-3 border-t border-neutral-200">
        <ClientOnly>
          <UDropdownMenu
            :items="[[
              { label: 'Çıkış yap', icon: 'i-lucide-log-out', onSelect: handleLogout }
            ]]"
          >
            <button class="flex items-center gap-2.5 w-full text-left">
              <div class="w-8 h-8 rounded-full bg-primary-50 text-primary-700 flex items-center justify-center font-bold text-xs flex-shrink-0">
                {{ auth.user?.name?.charAt(0)?.toUpperCase() ?? 'V' }}
              </div>
              <div class="min-w-0">
                <div class="text-sm font-medium truncate">
                  {{ auth.user?.name ?? '...' }}
                </div>
                <div class="text-xs text-neutral-500 truncate">
                  {{ auth.user?.email ?? '' }}
                </div>
              </div>
            </button>
          </UDropdownMenu>
        </ClientOnly>
      </div>
    </aside>

    <!-- Main -->
    <div class="flex-1 flex flex-col overflow-hidden">
      <header class="h-13 bg-white border-b border-neutral-200 flex items-center px-6 gap-3 flex-shrink-0">
        <h1 class="font-semibold text-base flex-1">
          {{ pageTitle }}
        </h1>
        <UBadge
          v-if="auth.isPremium"
          color="primary"
          variant="soft"
          icon="i-lucide-sparkles"
        >
          Premium
        </UBadge>
        <UBadge v-else color="neutral" variant="soft">
          Free
        </UBadge>
      </header>
      <main class="flex-1 overflow-auto p-6">
        <slot />
      </main>
    </div>
  </div>
</template>
