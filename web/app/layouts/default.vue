<script setup lang="ts">
const auth = useAuthStore()
const route = useRoute()

const navItems = [
  { label: 'Panel', icon: 'i-lucide-layout-dashboard', to: '/' },
  { label: 'Hayvanlar', icon: 'i-lucide-paw-print', to: '/animals' },
  { label: 'Çiftçiler', icon: 'i-lucide-users', to: '/farmers' },
  { label: 'Muayeneler', icon: 'i-lucide-stethoscope', to: '/examinations' },
  { label: 'İlaç & Stok', icon: 'i-lucide-pill', to: '/medications' },
  { label: 'Randevular', icon: 'i-lucide-calendar', to: '/appointments' }
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
      <div class="px-4 py-3 border-b border-neutral-200 flex items-center gap-2">
        <UIcon name="i-lucide-leaf" class="text-primary-600 w-6 h-6" />
        <span class="font-bold text-lg">VetRota</span>
      </div>
      <nav class="flex-1 p-2 space-y-0.5 overflow-y-auto">
        <NuxtLink
          v-for="item in navItems"
          :key="item.to"
          :to="item.to"
          class="flex items-center gap-2.5 px-2.5 py-2 text-sm rounded-md text-neutral-600 hover:bg-neutral-100 transition"
          active-class="!bg-primary-50 !text-primary-700 font-semibold"
        >
          <UIcon :name="item.icon" class="w-4 h-4 flex-shrink-0" />
          {{ item.label }}
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
      </header>
      <main class="flex-1 overflow-auto p-6">
        <slot />
      </main>
    </div>
  </div>
</template>
