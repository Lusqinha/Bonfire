<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { router } from '@inertiajs/vue3'
import AppIcon from './AppIcon.vue'
import BookCover from './BookCover.vue'

const props = defineProps({
  books: Array,
  initialBook: Object,
  initialEntry: Object,
})
const emit = defineEmits(['close', 'saved'])

const statusOrder = { reading: 0, read: 1, want: 2 }
const readableBooks = computed(() =>
  [...(props.books || [])].sort((a, b) => (statusOrder[a.status] ?? 9) - (statusOrder[b.status] ?? 9))
)
const selectedBookId = ref(props.initialBook?.id || readableBooks.value[0]?.id || null)
const selectedBook = computed(() => props.books?.find(b => b.id === Number(selectedBookId.value)) || props.initialBook)

const text = ref(props.initialEntry?.body || '')
const page = ref(props.initialEntry?.page || props.initialBook?.current_page || '')
const focusMode = ref(false)
const saved = ref(false)
const saveTimer = ref(null)
const textareaRef = ref(null)

// Book selector state
const selectorOpen = ref(false)
const selectorQuery = ref('')
const selectorInputRef = ref(null)

const filteredBooks = computed(() => {
  const q = selectorQuery.value.toLowerCase()
  return readableBooks.value.filter(b =>
    !q || b.title.toLowerCase().includes(q) || b.author.toLowerCase().includes(q)
  )
})

function openSelector() {
  selectorOpen.value = true
  selectorQuery.value = ''
  setTimeout(() => selectorInputRef.value?.focus(), 10)
}

function pickBook(book) {
  selectedBookId.value = book.id
  selectorOpen.value = false
  selectorQuery.value = ''
}

function closeSelectorOnOutside(e) {
  if (!e.target.closest('.book-selector')) selectorOpen.value = false
}

watch(selectedBookId, () => {
  if (!props.initialEntry) page.value = selectedBook.value?.current_page || ''
})

watch(text, () => {
  saved.value = false
  clearTimeout(saveTimer.value)
  if (text.value) {
    saveTimer.value = setTimeout(() => { saved.value = true }, 1200)
  }
})

const wordCount = computed(() => text.value.trim() ? text.value.trim().split(/\s+/).length : 0)

const now = new Date()
const months = ['jan','fev','mar','abr','mai','jun','jul','ago','set','out','nov','dez']
const timestamp = `${now.getDate()} ${months[now.getMonth()]} · ${now.getHours()}:${String(now.getMinutes()).padStart(2,'0')}`

onMounted(() => {
  textareaRef.value?.focus()
  document.addEventListener('mousedown', closeSelectorOnOutside)
})
onUnmounted(() => {
  document.removeEventListener('mousedown', closeSelectorOnOutside)
  document.removeEventListener('keydown', handleGlobalKey)
})

function handleKey(e) {
  if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') { e.preventDefault(); save() }
  if ((e.metaKey || e.ctrlKey) && e.shiftKey && e.key.toLowerCase() === 'f') { e.preventDefault(); focusMode.value = !focusMode.value }
  if (e.key === 'Escape' && focusMode.value) focusMode.value = false
}

function handleGlobalKey(e) {
  if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return
  if (e.key === 'Escape') emit('close')
}
onMounted(() => document.addEventListener('keydown', handleGlobalKey))

function insertFormat(prefix, suffix = '') {
  const ta = textareaRef.value
  const start = ta.selectionStart, end = ta.selectionEnd
  const selected = text.value.slice(start, end)
  text.value = text.value.slice(0, start) + prefix + selected + suffix + text.value.slice(end)
  setTimeout(() => {
    ta.selectionStart = start + prefix.length
    ta.selectionEnd = end + prefix.length
    ta.focus()
  }, 0)
}

function save() {
  if (!text.value.trim()) return
  const book = selectedBook.value
  if (!book) return

  const data = { reading_entry: { body: text.value, page: page.value || null } }

  if (props.initialEntry) {
    router.patch(`/livros/${book.id}/registros/${props.initialEntry.id}`, data, {
      onSuccess: () => emit('saved')
    })
  } else {
    router.post(`/livros/${book.id}/registros`, data, {
      onSuccess: () => emit('saved')
    })
  }
}
</script>

<template>
  <div :class="['editor-wrap', { 'focus-mode': focusMode }]" @keydown="handleKey">
    <div class="editor-header">
      <button class="btn-secondary" @click="$emit('close')">
        <AppIcon name="chevronLeft" :size="14" /> Voltar
      </button>
      <div class="editor-book-ref">
        <div v-if="selectedBook" style="width:20px;height:28px;border-radius:2px;overflow:hidden;flex-shrink:0">
          <BookCover :book="selectedBook" />
        </div>

        <!-- Simple select for ≤ 3 books, searchable dropdown for more -->
        <template v-if="readableBooks.length <= 3">
          <select class="editor-book-select" v-model="selectedBookId">
            <option v-if="readableBooks.length === 0" disabled value="">Nenhum livro na biblioteca</option>
            <option v-for="b in readableBooks" :key="b.id" :value="b.id">{{ b.title }} — {{ b.author }}</option>
          </select>
        </template>

        <div v-else class="book-selector" style="position:relative">
          <button class="book-selector-trigger" @click="openSelector">
            <span class="selector-title">{{ selectedBook ? selectedBook.title : 'Selecionar livro…' }}</span>
            <AppIcon name="chevronDown" :size="12" style="color:var(--text-3);flex-shrink:0" />
          </button>

          <div v-if="selectorOpen" class="selector-dropdown">
            <div class="selector-search">
              <AppIcon name="search" :size="13" style="color:var(--text-3)" />
              <input
                ref="selectorInputRef"
                v-model="selectorQuery"
                placeholder="Buscar livro…"
                @keydown.escape="selectorOpen = false"
              />
            </div>
            <div class="selector-list">
              <div
                v-if="filteredBooks.length === 0"
                class="selector-empty"
              >Nenhum resultado</div>
              <button
                v-for="b in filteredBooks"
                :key="b.id"
                :class="['selector-item', { active: b.id === selectedBookId }]"
                @click="pickBook(b)"
              >
                <div style="width:18px;height:26px;border-radius:2px;overflow:hidden;flex-shrink:0">
                  <BookCover :book="b" />
                </div>
                <div class="selector-item-info">
                  <div class="selector-item-title">{{ b.title }}</div>
                  <div class="selector-item-author">{{ b.author }}</div>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>
      <div style="flex:1" />
      <div class="editor-autosave">
        <template v-if="saved">
          <div class="autosave-dot" />
          <span>Salvo</span>
        </template>
        <span v-else style="color:var(--text-3)">Rascunho</span>
      </div>
      <button
        :class="['btn-secondary', { active: focusMode }]"
        :style="focusMode ? { color: 'var(--accent)', borderColor: 'var(--accent-2)' } : {}"
        @click="focusMode = !focusMode"
      >
        <AppIcon name="focus" :size="14" /> {{ focusMode ? 'Sair do foco' : 'Modo foco' }}
      </button>
    </div>

    <div class="editor-body">
      <div class="editor-center">
        <div class="editor-column">
          <div class="editor-page-field">
            <span class="editor-page-label">Página atual</span>
            <input class="editor-page-input" type="number" v-model="page" placeholder="—" />
            <span v-if="selectedBook" style="font-size:12px;color:var(--text-3)">de {{ selectedBook.pages }}</span>
            <span class="editor-timestamp">{{ timestamp }}</span>
          </div>

          <div :style="{ marginBottom: '16px', opacity: focusMode ? 0 : 1, transition: 'opacity 0.3s', pointerEvents: focusMode ? 'none' : 'auto' }">
            <div class="editor-toolbar">
              <button class="toolbar-btn" title="Negrito (⌘B)" @click="insertFormat('**','**')"><b>B</b></button>
              <button class="toolbar-btn" title="Itálico (⌘I)" @click="insertFormat('*','*')"><i>I</i></button>
              <div class="toolbar-sep" />
              <button class="toolbar-btn" title="Heading" @click="insertFormat('## ')">H</button>
              <button class="toolbar-btn" title="Lista" @click="insertFormat('- ')">≡</button>
              <button class="toolbar-btn" title="Citação" @click="insertFormat('> ')">"</button>
              <button class="toolbar-btn" title="Código" @click="insertFormat('`','`')" style="font-family:var(--font-mono)">&lt;&gt;</button>
            </div>
          </div>

          <textarea
            ref="textareaRef"
            class="editor-textarea"
            v-model="text"
            :style="focusMode ? { fontSize: '18px', lineHeight: '2' } : {}"
            placeholder="O que você está pensando sobre esta leitura? Use ** para negrito, * para itálico, > para citações…"
            rows="20"
          />
        </div>
      </div>
    </div>

    <div class="editor-footer">
      <span class="editor-wordcount">{{ wordCount }} palavra{{ wordCount !== 1 ? 's' : '' }}</span>
      <div style="flex:1" />
      <span style="font-size:12px;color:var(--text-3);display:flex;align-items:center;gap:5px">
        <span class="kbd">Ctrl</span><span class="kbd">Enter</span> salvar
      </span>
      <button class="btn-primary" @click="save">
        <AppIcon name="check" :size="14" /> Salvar entrada
      </button>
    </div>
  </div>
</template>

<style scoped>
.editor-wrap {
  position: fixed; inset: 0; background: var(--bg); z-index: 100;
  display: flex; flex-direction: column;
}
.editor-header {
  height: 52px; flex-shrink: 0; border-bottom: 1px solid var(--border);
  display: flex; align-items: center; gap: 12px; padding: 0 24px;
}
.editor-book-ref { display: flex; align-items: center; gap: 8px; font-size: 13px; color: var(--text-2); }
.editor-autosave { font-size: 12px; color: var(--text-3); display: flex; align-items: center; gap: 5px; }
.autosave-dot { width: 5px; height: 5px; border-radius: 50%; background: var(--green); animation: pulse 2s infinite; }
.editor-body { flex: 1; display: flex; overflow: hidden; }
.editor-center { flex: 1; overflow-y: auto; display: flex; justify-content: center; }
.editor-column { width: 100%; max-width: 640px; padding: 48px 32px 120px; }
.editor-page-field {
  display: flex; align-items: center; gap: 10px;
  margin-bottom: 24px; padding-bottom: 20px;
  border-bottom: 1px solid var(--border);
}
.editor-page-label { font-size: 12px; color: var(--text-3); text-transform: uppercase; letter-spacing: 0.08em; }
.editor-page-input {
  width: 80px; text-align: center;
  font-size: 22px; font-weight: 600; font-family: var(--font-serif);
  color: var(--accent); background: var(--bg-2); border: 1px solid var(--border-2);
  border-radius: var(--r); padding: 4px 12px;
  -moz-appearance: textfield;
}
.editor-page-input::-webkit-outer-spin-button,
.editor-page-input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
.editor-page-input:focus { border-color: var(--accent-2); }
.editor-book-select {
  background: var(--bg-2); border: 1px solid var(--border-2);
  border-radius: var(--r); padding: 6px 12px;
  color: var(--text); font-family: var(--font-serif); font-size: 14px;
  cursor: pointer; appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%23665e4e' stroke-width='2'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
  background-repeat: no-repeat; background-position: right 10px center;
  padding-right: 30px; min-width: 160px; max-width: 300px;
  transition: border-color 0.15s;
}
.editor-book-select:focus { border-color: var(--accent-2); outline: none; }
.book-selector-trigger {
  display: flex; align-items: center; gap: 8px;
  background: var(--bg-2); border: 1px solid var(--border-2);
  border-radius: var(--r); padding: 6px 10px;
  font-family: var(--font-serif); font-size: 14px; color: var(--text);
  cursor: pointer; min-width: 160px; max-width: 300px;
  transition: border-color 0.15s;
}
.book-selector-trigger:hover, .book-selector-trigger:focus { border-color: var(--accent-2); outline: none; }
.selector-title { flex: 1; text-align: left; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.selector-dropdown {
  position: absolute; top: calc(100% + 6px); left: 0;
  width: 320px; background: var(--bg-1); border: 1px solid var(--border-2);
  border-radius: var(--r-lg); box-shadow: 0 12px 40px #00000060;
  z-index: 200; overflow: hidden;
}
.selector-search {
  display: flex; align-items: center; gap: 8px;
  padding: 10px 12px; border-bottom: 1px solid var(--border);
}
.selector-search input {
  flex: 1; font-size: 13px; color: var(--text); background: none; border: none; outline: none;
}
.selector-search input::placeholder { color: var(--text-3); }
.selector-list { max-height: 260px; overflow-y: auto; padding: 6px; }
.selector-empty { padding: 16px 12px; font-size: 13px; color: var(--text-3); text-align: center; }
.selector-item {
  display: flex; align-items: center; gap: 10px;
  width: 100%; padding: 8px 10px; border-radius: var(--r);
  text-align: left; cursor: pointer; transition: background 0.1s;
}
.selector-item:hover { background: var(--bg-2); }
.selector-item.active { background: var(--accent-dim); }
.selector-item-info { flex: 1; min-width: 0; }
.selector-item-title {
  font-family: var(--font-serif); font-size: 13px; font-weight: 500;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.selector-item-author { font-size: 11px; color: var(--text-3); margin-top: 1px; }
.editor-timestamp { font-size: 12px; color: var(--text-3); margin-left: auto; }
.editor-textarea {
  width: 100%; resize: none;
  font-size: 16px; line-height: 1.85; color: var(--text);
  background: transparent; min-height: 400px;
  font-family: var(--font-serif); letter-spacing: 0.01em;
}
.editor-textarea::placeholder { color: var(--text-3); }
.editor-toolbar {
  background: var(--bg-2); border: 1px solid var(--border-2);
  border-radius: var(--r); padding: 4px 6px;
  display: flex; gap: 2px; align-items: center;
  box-shadow: var(--shadow);
}
.toolbar-btn {
  padding: 5px 8px; border-radius: 5px; font-size: 13px; font-weight: 600;
  color: var(--text-2); transition: all 0.1s;
}
.toolbar-btn:hover { background: var(--bg-3); color: var(--text); }
.toolbar-sep { width: 1px; height: 16px; background: var(--border); margin: 0 4px; }
.editor-footer {
  position: absolute; bottom: 0; left: 0; right: 0;
  height: 52px; border-top: 1px solid var(--border);
  display: flex; align-items: center; gap: 12px;
  padding: 0 24px; background: var(--bg);
}
.editor-wordcount { font-size: 12px; color: var(--text-3); }
.focus-mode .editor-header,
.focus-mode .editor-footer { opacity: 0; transition: opacity 0.3s; }
.editor-wrap.focus-mode:hover .editor-header,
.editor-wrap.focus-mode:hover .editor-footer { opacity: 1; }

@media (max-width: 768px) {
  .editor-header { padding: 0 16px; gap: 8px; height: 52px; }
  .editor-header .btn-secondary:last-child { display: none; } /* hide focus mode btn */
  .editor-autosave { display: none; }
  .editor-column { padding: 24px 16px 180px; }
  .editor-footer {
    bottom: 58px;
    padding: 0 16px;
    height: 52px;
  }
  .editor-footer span[style] { display: none; } /* hide ctrl+enter hint */
  .editor-page-field { flex-wrap: wrap; gap: 8px; margin-bottom: 16px; }
  .editor-timestamp { margin-left: 0; width: 100%; order: 3; }
  .editor-book-select { min-width: 0; max-width: 180px; font-size: 13px; }
}
</style>
