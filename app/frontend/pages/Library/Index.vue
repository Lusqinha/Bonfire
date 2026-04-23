<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { router, usePage } from '@inertiajs/vue3'
import AppLayout from '../../components/AppLayout.vue'
import BookCover from '../../components/BookCover.vue'
import ProgressBar from '../../components/ProgressBar.vue'
import MarkdownEditor from '../../components/MarkdownEditor.vue'
import BookFormModal from '../../components/BookFormModal.vue'
import AppIcon from '../../components/AppIcon.vue'

const props = defineProps({ books: Array })

const page = usePage()
const viewMode = ref('grid')
const activeTab = ref('all')
const search = ref('')
const editorOpen = ref(false)
const editorBook = ref(null)
const bookFormOpen = ref(false)
const toast = ref(null)
const searchRef = ref(null)

const counts = computed(() => ({
  all: props.books.length,
  reading: props.books.filter(b => b.status === 'reading').length,
  read: props.books.filter(b => b.status === 'read').length,
  want: props.books.filter(b => b.status === 'want').length,
}))

const tabs = [
  { id: 'all', label: 'Todos' },
  { id: 'reading', label: 'Lendo' },
  { id: 'read', label: 'Lidos' },
  { id: 'want', label: 'Quero ler' },
]

const filtered = computed(() => props.books.filter(b => {
  const matchSearch = !search.value || b.title.toLowerCase().includes(search.value.toLowerCase()) || b.author.toLowerCase().includes(search.value.toLowerCase())
  const matchTab = activeTab.value === 'all' || b.status === activeTab.value
  return matchSearch && matchTab
}))

function handleNavigate(screen, book = null) {
  if (screen === 'library') return
  if (screen === 'book' && book) router.visit(`/books/${book.id}`)
}

function openEditor(book) {
  editorBook.value = book
  editorOpen.value = true
}

function onSaved() {
  editorOpen.value = false
  showToast('Entrada salva com sucesso')
  router.reload({ only: ['books'] })
}

function showToast(msg) {
  toast.value = msg
  setTimeout(() => { toast.value = null }, 2500)
}

function badgeClass(status) {
  if (status === 'reading') return 'badge-reading'
  if (status === 'read') return 'badge-read'
  return 'badge-want'
}
function badgeLabel(status) {
  if (status === 'reading') return 'Lendo'
  if (status === 'read') return 'Lido'
  return 'Tenho'
}

function handleKeydown(e) {
  if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA' || e.target.tagName === 'SELECT') return
  if (e.ctrlKey || e.metaKey) return
  if (e.key === 'n' || e.key === 'N') openEditor(null)
  if (e.key === 'a' || e.key === 'A') bookFormOpen.value = true
  if (e.key === 'v' || e.key === 'V') viewMode.value = viewMode.value === 'grid' ? 'list' : 'grid'
  if (e.key === '/') { e.preventDefault(); searchRef.value?.focus() }
}
onMounted(() => document.addEventListener('keydown', handleKeydown))
onUnmounted(() => document.removeEventListener('keydown', handleKeydown))
</script>

<template>
  <MarkdownEditor
    v-if="editorOpen"
    :books="books"
    :initial-book="editorBook"
    @close="editorOpen = false"
    @saved="onSaved"
  />

  <template v-else>
  <AppLayout
    :books="books"
    current-screen="library"
    title="Biblioteca"
    @navigate="handleNavigate"
    @open-editor="openEditor"
  >
    <div style="background:var(--bg)">
      <div class="library-header">
        <div>
          <div class="library-title">Biblioteca</div>
          <div class="library-subtitle">{{ books.length }} livros · {{ counts.reading }} em leitura</div>
        </div>
        <div style="display:flex;align-items:center;gap:10px">
          <div class="view-toggle">
            <button :class="['view-btn', { active: viewMode === 'grid' }]" @click="viewMode = 'grid'"><AppIcon name="grid" :size="14" /></button>
            <button :class="['view-btn', { active: viewMode === 'list' }]" @click="viewMode = 'list'"><AppIcon name="list" :size="14" /></button>
          </div>
          <button class="btn-secondary" @click="bookFormOpen = true">
            <AppIcon name="plus" :size="14" /> Livro
          </button>
          <button class="btn-primary" @click="openEditor(null)">
            <AppIcon name="pen" :size="14" /> Nova entrada
          </button>
        </div>
      </div>

      <div class="search-bar">
        <AppIcon name="search" :size="16" />
        <input ref="searchRef" v-model="search" placeholder="Buscar livros, autores…" />
        <button v-if="search" @click="search = ''" style="color:var(--text-3)"><AppIcon name="x" :size="14" /></button>
      </div>

      <div class="status-tabs">
        <div
          v-for="t in tabs" :key="t.id"
          :class="['status-tab', { active: activeTab === t.id }]"
          @click="activeTab = t.id"
        >
          {{ t.label }} <span style="opacity:0.6;font-size:12px">({{ counts[t.id] }})</span>
        </div>
      </div>

      <div v-if="filtered.length === 0" class="empty-state">
        <div class="empty-icon">📚</div>
        <div class="empty-title">Nenhum livro aqui</div>
        <div class="empty-sub">Adicione livros à sua biblioteca para começar a registrar suas leituras.</div>
      </div>

      <div v-else-if="viewMode === 'grid'" class="book-grid">
        <div
          v-for="book in filtered" :key="book.id"
          class="book-card"
          @click="router.visit(`/books/${book.id}`)"
        >
          <div class="book-cover">
            <BookCover :book="book" />
          </div>
          <div class="book-card-info">
            <div class="book-card-title">{{ book.title }}</div>
            <div class="book-card-author">{{ book.author }}</div>
            <div style="margin-top:8px;display:flex;align-items:center;gap:6px">
              <span :class="['header-badge', badgeClass(book.status)]">{{ badgeLabel(book.status) }}</span>
            </div>
            <ProgressBar v-if="book.status === 'reading'" :value="book.current_page" :total="book.pages" style="margin-top:8px" />
          </div>
        </div>

        <div
          class="add-book-card"
          @click="bookFormOpen = true"
        >
          <AppIcon name="plus" :size="24" />
          <span style="font-size:12px">Adicionar livro</span>
        </div>
      </div>

      <div v-else class="book-list">
        <div
          v-for="book in filtered" :key="book.id"
          class="book-list-item"
          @click="router.visit(`/books/${book.id}`)"
        >
          <div style="width:36px;height:50px;border-radius:4px;overflow:hidden;flex-shrink:0">
            <BookCover :book="book" />
          </div>
          <div class="book-list-info">
            <div class="book-list-title">{{ book.title }}</div>
            <div class="book-list-author">{{ book.author }} · {{ book.year }}</div>
            <ProgressBar v-if="book.status === 'reading'" :value="book.current_page" :total="book.pages" style="margin-top:6px;max-width:200px" />
          </div>
          <div class="book-list-meta">
            <span :class="['header-badge', badgeClass(book.status)]">{{ badgeLabel(book.status) }}</span>
            <span style="font-size:12px;color:var(--text-3)">{{ book.pages }} p.</span>
            <span v-if="book.entries_count > 0" style="font-size:12px;color:var(--text-3)">{{ book.entries_count }} entrada{{ book.entries_count > 1 ? 's' : '' }}</span>
          </div>
          <AppIcon name="chevronRight" :size="16" />
        </div>
      </div>
    </div>

    <template #toast>
      <div v-if="toast" class="toast">
        <span>✅</span>
        <span>{{ toast }}</span>
      </div>
    </template>
  </AppLayout>

  <BookFormModal v-if="bookFormOpen" @close="bookFormOpen = false" />
  </template>
</template>

<style scoped>
.library-header {
  padding: 32px 32px 20px;
  display: flex; align-items: flex-end; justify-content: space-between;
}
.library-title { font-family: var(--font-serif); font-size: 28px; font-weight: 500; }
.library-subtitle { color: var(--text-2); font-size: 13px; margin-top: 2px; }
.view-toggle { display: flex; background: var(--bg-2); border-radius: var(--r); padding: 3px; gap: 2px; }
.view-btn { padding: 5px 8px; border-radius: 6px; color: var(--text-3); transition: all 0.15s; }
.view-btn.active { background: var(--bg-3); color: var(--text); }
.view-btn:hover:not(.active) { color: var(--text-2); }
.search-bar {
  margin: 0 32px 20px;
  background: var(--bg-1); border: 1px solid var(--border);
  border-radius: var(--r); padding: 10px 14px;
  display: flex; align-items: center; gap: 10px;
  transition: border-color 0.15s;
}
.search-bar:focus-within { border-color: var(--border-2); }
.search-bar input { flex: 1; font-size: 14px; color: var(--text); background: none; border: none; outline: none; }
.search-bar input::placeholder { color: var(--text-3); }
.status-tabs {
  display: flex; gap: 4px; margin: 0 32px 24px;
  border-bottom: 1px solid var(--border);
}
.status-tab {
  padding: 8px 16px; font-size: 13px; font-weight: 500;
  color: var(--text-3); cursor: pointer;
  border-bottom: 2px solid transparent; margin-bottom: -1px;
  transition: all 0.15s;
}
.status-tab:hover { color: var(--text-2); }
.status-tab.active { color: var(--accent); border-bottom-color: var(--accent); }
.book-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 20px; padding: 0 32px 32px;
}
.book-card {
  cursor: pointer; border-radius: var(--r-lg); overflow: hidden;
  background: var(--bg-1); border: 1px solid var(--border);
  transition: all 0.2s;
}
.book-card:hover { border-color: var(--border-2); transform: translateY(-2px); box-shadow: var(--shadow); }
.book-cover { aspect-ratio: 2/3; position: relative; overflow: hidden; }
.book-card-info { padding: 12px; }
.book-card-title { font-family: var(--font-serif); font-size: 14px; font-weight: 500; line-height: 1.3; margin-bottom: 3px; }
.book-card-author { font-size: 12px; color: var(--text-2); }
.add-book-card {
  border-radius: var(--r-lg); border: 2px dashed var(--border);
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  aspect-ratio: 3/4; cursor: pointer; color: var(--text-3); transition: all 0.15s; gap: 8px;
}
.add-book-card:hover { border-color: var(--border-2); color: var(--text-2); }
.book-list { padding: 0 32px 32px; display: flex; flex-direction: column; gap: 2px; }
.book-list-item {
  display: flex; align-items: center; gap: 16px;
  padding: 12px 14px; border-radius: var(--r);
  cursor: pointer; transition: background 0.15s;
  border: 1px solid transparent;
}
.book-list-item:hover { background: var(--bg-1); border-color: var(--border); }
.book-list-info { flex: 1; min-width: 0; }
.book-list-title { font-family: var(--font-serif); font-size: 15px; font-weight: 500; }
.book-list-author { font-size: 12px; color: var(--text-2); }
.book-list-meta { display: flex; align-items: center; gap: 12px; }
.toast {
  position: fixed; bottom: 24px; left: 50%; transform: translateX(-50%);
  background: var(--bg-2); border: 1px solid var(--border-2);
  border-radius: var(--r-lg); padding: 10px 18px;
  font-size: 13px; color: var(--text); box-shadow: var(--shadow); z-index: 400;
  display: flex; align-items: center; gap: 8px;
  animation: toastin 0.25s ease;
}
</style>
