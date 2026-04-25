<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { router } from '@inertiajs/vue3'
import AppIcon from './AppIcon.vue'

const props = defineProps({ books: Array })
const emit = defineEmits(['close', 'navigate', 'openEditor'])

const query = ref('')
const selected = ref(0)
const inputRef = ref(null)

onMounted(() => inputRef.value?.focus())

const actions = [
  { type: 'action', label: 'Nova entrada de leitura', icon: '✍️', sub: 'Registrar sessão', action: () => { emit('close'); emit('openEditor', null) } },
  { type: 'action', label: 'Ir para Biblioteca', icon: '📚', sub: 'G + L', action: () => { emit('navigate', 'library'); emit('close') } },
  { type: 'action', label: 'Atalhos de teclado', icon: '⌨️', sub: '?', action: () => emit('close') },
]

const filteredBooks = computed(() =>
  !query.value ? props.books : props.books.filter(b =>
    b.title.toLowerCase().includes(query.value.toLowerCase()) ||
    b.author.toLowerCase().includes(query.value.toLowerCase())
  )
)
const filteredActions = computed(() =>
  !query.value ? actions : actions.filter(a => a.label.toLowerCase().includes(query.value.toLowerCase()))
)
const allItems = computed(() => [
  ...filteredBooks.value.map(b => ({ ...b, _type: 'book' })),
  ...filteredActions.value
])

watch(query, () => { selected.value = 0 })

function handleKey(e) {
  if (e.key === 'ArrowDown') { e.preventDefault(); selected.value = Math.min(selected.value + 1, allItems.value.length - 1) }
  if (e.key === 'ArrowUp') { e.preventDefault(); selected.value = Math.max(selected.value - 1, 0) }
  if (e.key === 'Enter') {
    const item = allItems.value[selected.value]
    if (!item) return
    if (item._type === 'book') { emit('navigate', 'book', item); emit('close') }
    else if (item.action) item.action()
  }
  if (e.key === 'Escape') emit('close')
}

function statusLabel(b) {
  if (b.status === 'reading') return `pág. ${b.current_page}/${b.pages}`
  if (b.status === 'read') return 'Lido'
  return 'Na lista'
}
</script>

<template>
  <div class="overlay" @click="$emit('close')">
    <div class="cmd-palette" @click.stop>
      <div class="cmd-search">
        <AppIcon name="search" :size="18" />
        <input ref="inputRef" v-model="query" @keydown="handleKey" placeholder="Buscar livros, ações…" />
        <button v-if="query" @click="query = ''" style="color:var(--text-3)"><AppIcon name="x" :size="16" /></button>
      </div>
      <div class="cmd-results">
        <template v-if="filteredBooks.length > 0">
          <div class="cmd-section-label">Livros</div>
          <div
            v-for="(book, i) in filteredBooks"
            :key="book.id"
            :class="['cmd-item', { selected: selected === i }]"
            @click="$emit('navigate', 'book', book); $emit('close')"
            @mouseenter="selected = i"
          >
            <div class="cmd-item-icon" :style="{ background: book.gradient }">{{ book.emoji || '📖' }}</div>
            <div style="flex:1">
              <div class="cmd-item-label">{{ book.title }}</div>
              <div class="cmd-item-sub">{{ book.author }} · {{ statusLabel(book) }}</div>
            </div>
            <button
              v-if="book.status === 'reading'"
              style="font-size:11px;color:var(--accent);background:var(--accent-dim);padding:3px 8px;border-radius:4px"
              @click.stop="$emit('openEditor', book); $emit('close')"
            >+ Registro</button>
          </div>
        </template>
        <template v-if="filteredActions.length > 0">
          <div class="cmd-section-label">Ações</div>
          <div
            v-for="(item, i) in filteredActions"
            :key="i"
            :class="['cmd-item', { selected: selected === filteredBooks.length + i }]"
            @click="item.action()"
            @mouseenter="selected = filteredBooks.length + i"
          >
            <div class="cmd-item-icon">{{ item.icon }}</div>
            <div class="cmd-item-label">{{ item.label }}</div>
            <span v-if="item.sub" class="kbd">{{ item.sub }}</span>
          </div>
        </template>
        <div v-if="allItems.length === 0" style="padding:32px;text-align:center;color:var(--text-3)">
          Nenhum resultado para "{{ query }}"
        </div>
      </div>
      <div class="cmd-footer">
        <span class="cmd-hint"><span class="kbd">↑↓</span> navegar</span>
        <span class="cmd-hint"><span class="kbd">↵</span> abrir</span>
        <span class="cmd-hint"><span class="kbd">esc</span> fechar</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.overlay {
  position: fixed; inset: 0; z-index: 200;
  background: #00000060; backdrop-filter: blur(4px);
  display: flex; align-items: flex-start; justify-content: center;
  padding-top: 100px;
}
.cmd-palette {
  width: 560px; background: var(--bg-1);
  border: 1px solid var(--border-2); border-radius: var(--r-lg);
  box-shadow: 0 24px 80px #00000080; overflow: hidden;
}
.cmd-search {
  display: flex; align-items: center; gap: 12px;
  padding: 14px 16px; border-bottom: 1px solid var(--border);
}
.cmd-search input { flex: 1; font-size: 16px; color: var(--text); background: none; border: none; outline: none; }
.cmd-search input::placeholder { color: var(--text-3); }
.cmd-results { max-height: 360px; overflow-y: auto; padding: 8px; }
.cmd-section-label {
  font-size: 10px; font-weight: 600; letter-spacing: 0.08em;
  text-transform: uppercase; color: var(--text-3); padding: 8px 8px 4px;
}
.cmd-item {
  display: flex; align-items: center; gap: 12px;
  padding: 9px 10px; border-radius: var(--r);
  cursor: pointer; transition: background 0.1s;
}
.cmd-item:hover, .cmd-item.selected { background: var(--bg-2); }
.cmd-item.selected { background: var(--accent-dim); }
.cmd-item-icon {
  width: 30px; height: 30px; border-radius: 6px;
  background: var(--bg-2); display: flex; align-items: center; justify-content: center;
  font-size: 14px; flex-shrink: 0;
}
.cmd-item.selected .cmd-item-icon { background: var(--accent-dim); }
.cmd-item-label { font-size: 14px; flex: 1; }
.cmd-item-sub { font-size: 12px; color: var(--text-3); }
.cmd-footer {
  padding: 10px 16px; border-top: 1px solid var(--border);
  display: flex; gap: 16px; align-items: center;
}
.cmd-hint { display: flex; align-items: center; gap: 5px; font-size: 11px; color: var(--text-3); }

@media (max-width: 768px) {
  .overlay {
    align-items: flex-start;
    padding-top: 0;
    background: #00000080;
  }
  .cmd-palette {
    width: 100%;
    border-radius: 0 0 var(--r-lg) var(--r-lg);
    border-left: none; border-right: none; border-top: none;
    max-height: 70dvh;
    display: flex; flex-direction: column;
  }
  .cmd-results { flex: 1; max-height: unset; overflow-y: auto; }
  .cmd-footer { display: none; }
  .cmd-search input { font-size: 16px; }
}
</style>
