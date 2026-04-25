<script setup>
import { computed } from 'vue'
import { router } from '@inertiajs/vue3'
import AppIcon from './AppIcon.vue'
import BookCover from './BookCover.vue'
import logoUrl from '../assets/logo.png'

const props = defineProps({
  collapsed: Boolean,
  books: Array,
  currentScreen: String,
  currentBookId: Number,
})
const emit = defineEmits(['toggle', 'navigate', 'openEditor'])

const readingBook = computed(() => props.books?.find(b => b.status === 'reading'))

function navigate(screen, book = null) {
  emit('navigate', screen, book)
}
</script>

<template>
  <aside :class="['sidebar', { collapsed }]">
    <button class="collapse-btn" @click="$emit('toggle')" title="Recolher sidebar">
      <AppIcon :name="collapsed ? 'chevronRight' : 'chevronLeft'" :size="14" />
    </button>

    <div class="sidebar-logo">
      <img :src="logoUrl" alt="Bonfire" class="sidebar-logo-img" />
      <div class="sidebar-logo-text">Bonfire</div>
    </div>

    <nav class="sidebar-nav">
      <div
        :class="['nav-item', { active: currentScreen === 'library' }]"
        @click="navigate('library')"
        title="Biblioteca"
      >
        <AppIcon name="library" :size="16" />
        <span class="nav-label">Biblioteca</span>
      </div>

      <div class="nav-item" title="Notas Soltas" @click="navigate('notes')">
        <AppIcon name="note" :size="16" />
        <span class="nav-label">Notas Soltas</span>
      </div>

      <template v-if="readingBook">
        <div style="margin-top:16px">
          <div class="sidebar-section-label">Em leitura</div>
          <div
            :class="['nav-item', { active: currentScreen === 'book' && currentBookId === readingBook.id }]"
            style="padding:6px 8px"
            @click="navigate('book', readingBook)"
          >
            <div style="width:28px;height:38px;border-radius:3px;overflow:hidden;flex-shrink:0">
              <BookCover :book="readingBook" />
            </div>
            <div class="reading-book-info" style="min-width:0">
              <div style="font-size:13px;font-family:var(--font-serif);font-weight:500;line-height:1.2;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ readingBook.title }}</div>
              <div style="font-size:11px;color:var(--text-3);margin-top:2px">{{ readingBook.current_page }}/{{ readingBook.pages }} p.</div>
            </div>
          </div>
        </div>
      </template>

      <div style="margin-top:16px">
        <div class="sidebar-section-label">Atalhos</div>
        <div class="nav-item" style="font-size:12px" @click="$emit('openPalette')">
          <AppIcon name="command" :size="14" />
          <span class="nav-label" style="display:flex;align-items:center;gap:6px">
            Paleta <span class="kbd" style="margin-left:auto">⌘K</span>
          </span>
        </div>
        <div class="nav-item" style="font-size:12px" @click="$emit('openShortcuts')">
          <AppIcon name="keyboard" :size="14" />
          <span class="nav-label" style="display:flex;align-items:center;gap:6px">
            Atalhos <span class="kbd" style="margin-left:auto">?</span>
          </span>
        </div>
        <div class="nav-item" style="font-size:12px" @click="router.delete('/sessao')">
          <AppIcon name="logout" :size="14" />
          <span class="nav-label">Sair</span>
        </div>
      </div>
    </nav>
  </aside>
</template>

<style scoped>
.sidebar {
  position: fixed; left: 0; top: 0; bottom: 0;
  width: 240px;
  background: var(--bg-1);
  border-right: 1px solid var(--border);
  display: flex; flex-direction: column;
  transition: width 0.25s ease;
  z-index: 10;
}
.sidebar.collapsed { width: 52px; }
.sidebar-logo {
  padding: 20px 16px 16px;
  display: flex; align-items: center; gap: 10px;
  border-bottom: 1px solid var(--border);
  min-height: 60px;
}
.sidebar-logo-img {
  width: 26px; height: 26px; flex-shrink: 0; object-fit: contain;
  filter: brightness(0) invert(1) sepia(1) saturate(3) hue-rotate(5deg) brightness(1.1);
}
.sidebar-logo-text {
  font-family: var(--font-serif); font-size: 15px; font-weight: 500;
  white-space: nowrap; opacity: 1; transition: opacity 0.2s;
}
.sidebar.collapsed .sidebar-logo-text,
.sidebar.collapsed .nav-label,
.sidebar.collapsed .reading-book-info,
.sidebar.collapsed .sidebar-section-label { display: none; }
.sidebar-nav { flex: 1; overflow-y: auto; padding: 12px 8px; }
.sidebar-section-label {
  font-size: 10px; font-weight: 600; letter-spacing: 0.08em;
  color: var(--text-3); text-transform: uppercase;
  padding: 8px 8px 4px;
}
.nav-item {
  display: flex; align-items: center; gap: 10px;
  padding: 8px 8px; border-radius: var(--r);
  cursor: pointer; color: var(--text-2);
  transition: all 0.15s; user-select: none; white-space: nowrap;
}
.nav-item:hover { background: var(--bg-2); color: var(--text); }
.nav-item.active { background: var(--accent-dim); color: var(--accent); }
@media (max-width: 768px) {
  .sidebar { display: none !important; }
}
.collapse-btn {
  position: absolute; right: -12px; top: 22px;
  width: 24px; height: 24px; border-radius: 50%;
  background: var(--bg-2); border: 1px solid var(--border-2);
  display: flex; align-items: center; justify-content: center;
  color: var(--text-2); z-index: 20; transition: all 0.15s;
}
.collapse-btn:hover { background: var(--bg-3); color: var(--text); }
</style>
