<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { router } from '@inertiajs/vue3'
import AppSidebar from './AppSidebar.vue'
import CommandPalette from './CommandPalette.vue'
import ShortcutsModal from './ShortcutsModal.vue'
import AppIcon from './AppIcon.vue'

const props = defineProps({
  books: { type: Array, default: () => [] },
  currentScreen: { type: String, default: 'library' },
  currentBook: { type: Object, default: null },
  title: String,
  badge: String,
})
const emit = defineEmits(['navigate', 'openEditor'])

const sidebarCollapsed = ref(false)
const cmdOpen = ref(false)
const shortcutsOpen = ref(false)

function handleKeydown(e) {
  const ctrl = e.ctrlKey || e.metaKey
  // Ctrl+K: command palette (overrides browser address bar focus)
  if (ctrl && e.key === 'k') { e.preventDefault(); cmdOpen.value = true; return }
  if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA' || e.target.tagName === 'SELECT') return
  if (e.key === '?' && !e.shiftKey) { shortcutsOpen.value = true; return }
  if (e.key === 'Escape') { cmdOpen.value = false; shortcutsOpen.value = false; return }
  // G chord navigation
  if (e.key === 'g' && !ctrl) {
    const next = (e2) => {
      if (e2.key === 'l' || e2.key === 'h') emit('navigate', 'library')
    }
    document.addEventListener('keydown', next, { once: true })
  }
}
onMounted(() => document.addEventListener('keydown', handleKeydown))
onUnmounted(() => document.removeEventListener('keydown', handleKeydown))

function badgeClass(status) {
  if (status === 'reading') return 'badge-reading'
  if (status === 'read') return 'badge-read'
  return 'badge-want'
}
function badgeLabel(status) {
  if (status === 'reading') return 'Em leitura'
  if (status === 'read') return 'Lido'
  return 'Quero ler'
}
</script>

<template>
  <div style="height:100%;overflow:hidden">
    <AppSidebar
      :collapsed="sidebarCollapsed"
      :books="books"
      :current-screen="currentScreen"
      :current-book-id="currentBook?.id"
      @toggle="sidebarCollapsed = !sidebarCollapsed"
      @navigate="(s, b) => $emit('navigate', s, b)"
      @open-palette="cmdOpen = true"
      @open-shortcuts="shortcutsOpen = true"
    />

    <div :class="['main', { 'sidebar-collapsed': sidebarCollapsed }]">
      <header class="app-header">
        <div class="header-title">{{ title }}</div>
        <span
          v-if="currentBook"
          :class="['header-badge', badgeClass(currentBook.status)]"
        >{{ badgeLabel(currentBook.status) }}</span>
        <div style="flex:1" />
        <button class="cmd-btn" @click="cmdOpen = true">
          <AppIcon name="search" :size="14" />
          <span>Buscar</span>
          <span class="kbd">Ctrl+K</span>
        </button>
        <button class="cmd-btn" style="padding:5px 8px" @click="shortcutsOpen = true">
          <AppIcon name="keyboard" :size="14" />
        </button>
      </header>

      <main class="main-content">
        <slot />
      </main>
    </div>

    <CommandPalette
      v-if="cmdOpen"
      :books="books"
      @close="cmdOpen = false"
      @navigate="(s, b) => { $emit('navigate', s, b); cmdOpen = false }"
      @open-editor="(b) => { $emit('openEditor', b); cmdOpen = false }"
    />
    <ShortcutsModal v-if="shortcutsOpen" @close="shortcutsOpen = false" />

    <!-- bottom nav: mobile only -->
    <nav class="bottom-nav">
      <button
        :class="['bnav-item', { active: currentScreen === 'library' }]"
        @click="$emit('navigate', 'library')"
      >
        <AppIcon name="library" :size="22" />
        <span>Biblioteca</span>
      </button>
      <button
        :class="['bnav-item', { active: currentScreen === 'book' }]"
        @click="currentBook ? $emit('navigate', 'book', currentBook) : $emit('navigate', 'library')"
      >
        <AppIcon name="book" :size="22" />
        <span>Lendo</span>
      </button>
      <button class="bnav-item bnav-cta" @click="$emit('openEditor', null)">
        <AppIcon name="pen" :size="20" />
        <span>Entrada</span>
      </button>
      <button class="bnav-item" @click="cmdOpen = true">
        <AppIcon name="search" :size="22" />
        <span>Buscar</span>
      </button>
      <button class="bnav-item" @click="router.delete('/sessao')">
        <AppIcon name="logout" :size="22" />
        <span>Sair</span>
      </button>
    </nav>

    <slot name="toast" />
  </div>
</template>

<style scoped>
.main {
  position: fixed; top: 0; right: 0; bottom: 0;
  left: 240px; transition: left 0.25s ease;
  display: flex; flex-direction: column; overflow: hidden;
}
.main.sidebar-collapsed { left: 52px; }
.app-header {
  height: 52px; flex-shrink: 0;
  border-bottom: 1px solid var(--border);
  display: flex; align-items: center; gap: 12px;
  padding: 0 24px; background: var(--bg);
}
.header-title {
  font-family: var(--font-serif); font-size: 16px; font-weight: 500;
}
.cmd-btn {
  display: flex; align-items: center; gap: 6px;
  padding: 5px 10px; border-radius: var(--r);
  background: var(--bg-2); border: 1px solid var(--border);
  color: var(--text-2); font-size: 12px; transition: all 0.15s;
}
.cmd-btn:hover { border-color: var(--border-2); color: var(--text); }
.main-content { flex: 1; overflow-y: auto; }

.bottom-nav { display: none; }

@media (max-width: 768px) {
  .main { left: 0 !important; bottom: 58px; }
  .app-header { display: none; }
  .cmd-btn .kbd { display: none; }

  .bottom-nav {
    display: flex;
    position: fixed; bottom: 0; left: 0; right: 0;
    height: 58px; z-index: 200;
    background: var(--bg-1); border-top: 1px solid var(--border);
    padding: 0 4px env(safe-area-inset-bottom, 0);
  }
  .bnav-item {
    flex: 1; display: flex; flex-direction: column;
    align-items: center; justify-content: center; gap: 3px;
    font-size: 10px; color: var(--text-3);
    background: none; border: none; cursor: pointer;
    padding: 6px 4px; border-radius: var(--r);
    transition: color 0.15s;
  }
  .bnav-item:hover, .bnav-item.active { color: var(--accent); }
  .bnav-cta {
    color: var(--accent);
  }
}
</style>
