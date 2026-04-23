<script setup>
import { ref, computed } from 'vue'
import { router } from '@inertiajs/vue3'
import AppLayout from '../../components/AppLayout.vue'
import BookCover from '../../components/BookCover.vue'
import ProgressBar from '../../components/ProgressBar.vue'
import MarkdownEditor from '../../components/MarkdownEditor.vue'
import AppIcon from '../../components/AppIcon.vue'

const props = defineProps({
  book: Object,
  entries: Array,
  notes: Array,
  books: { type: Array, default: () => [] },
})

const activeTab = ref('logs')
const editorOpen = ref(false)
const editorEntry = ref(null)
const noteOpen = ref(false)
const noteForm = ref({ title: '', body: '' })
const noteSaving = ref(false)
const toast = ref(null)

const allBooks = computed(() => {
  if (props.books.length > 0) return props.books
  return [props.book]
})

const pct = computed(() => props.book.pages > 0 ? Math.round((props.book.current_page / props.book.pages) * 100) : 0)

function openEditor(entry = null) {
  editorEntry.value = entry
  editorOpen.value = true
}

function onSaved() {
  editorOpen.value = false
  showToast('Entrada salva com sucesso')
  router.reload({ only: ['entries', 'book'] })
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
  if (status === 'reading') return 'Em leitura'
  if (status === 'read') return 'Lido'
  return 'Na lista'
}

function renderMd(text) {
  if (!text) return ''
  let html = text
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/^> (.+)$/gm, '<blockquote>$1</blockquote>')
    .replace(/\n\n/g, '</p><p>')
    .replace(/\n/g, '<br>')
  return `<p>${html}</p>`
}

function formatDate(dateStr) {
  const parts = dateStr.split(' · ')
  return { day: parts[0], time: parts[1] }
}

function openNote() {
  noteForm.value = { title: '', body: '' }
  noteOpen.value = true
}

function saveNote() {
  if (!noteForm.value.body.trim()) return
  noteSaving.value = true
  router.post(`/books/${props.book.id}/notes`, { note: noteForm.value }, {
    onSuccess: () => {
      noteSaving.value = false
      noteOpen.value = false
      showToast('Nota salva')
      router.reload({ only: ['notes'] })
    },
    onError: () => { noteSaving.value = false },
  })
}

function deleteNote(noteId) {
  if (!confirm('Excluir esta nota?')) return
  router.delete(`/notes/${noteId}`, {
    onSuccess: () => { showToast('Nota excluída'); router.reload({ only: ['notes'] }) }
  })
}
</script>

<template>
  <MarkdownEditor
    v-if="editorOpen"
    :books="allBooks"
    :initial-book="book"
    :initial-entry="editorEntry"
    @close="editorOpen = false"
    @saved="onSaved"
  />

  <AppLayout
    v-else
    :books="allBooks"
    current-screen="book"
    :current-book="book"
    :title="book.title"
    @navigate="(s, b) => { if (s === 'library') router.visit('/library'); else if (b) router.visit(`/books/${b.id}`) }"
    @open-editor="openEditor"
  >
    <div class="book-hero">
      <button class="back-btn" @click="router.visit('/library')">
        <AppIcon name="chevronLeft" :size="16" /> Biblioteca
      </button>

      <div class="book-hero-inner">
        <div class="book-hero-cover">
          <BookCover :book="book" :font-size="56" />
        </div>
        <div class="book-hero-meta">
          <div style="margin-bottom:8px">
            <span :class="['header-badge', badgeClass(book.status)]">{{ badgeLabel(book.status) }}</span>
          </div>
          <div class="book-hero-title">{{ book.title }}</div>
          <div class="book-hero-author">{{ book.author }}</div>
          <div style="display:flex;gap:12px;color:var(--text-3);font-size:12px;margin-bottom:12px">
            <span>{{ book.publisher }}</span>
            <span>·</span>
            <span>{{ book.year }}</span>
            <span>·</span>
            <span>{{ book.pages }} páginas</span>
          </div>
          <ProgressBar v-if="book.status === 'reading'" :value="book.current_page" :total="book.pages" style="max-width:280px" />
          <div class="book-hero-stats" style="margin-top:16px">
            <div class="book-stat">
              <div class="book-stat-val">{{ entries.length }}</div>
              <div class="book-stat-label">Entradas</div>
            </div>
            <div v-if="book.status === 'reading'" class="book-stat">
              <div class="book-stat-val">{{ pct }}%</div>
              <div class="book-stat-label">Progresso</div>
            </div>
            <div class="book-stat">
              <div class="book-stat-val">{{ notes.length }}</div>
              <div class="book-stat-label">Notas</div>
            </div>
          </div>
        </div>
      </div>

      <div class="book-tabs">
        <div v-for="t in [{ id:'logs', label:'Registros de Leitura' }, { id:'notes', label:'Notas Soltas' }, { id:'info', label:'Informações' }]" :key="t.id"
          :class="['book-tab', { active: activeTab === t.id }]"
          @click="activeTab = t.id"
        >{{ t.label }}</div>
      </div>
    </div>

    <div class="book-content">
      <!-- LOGS TAB -->
      <template v-if="activeTab === 'logs'">
        <div v-if="entries.length === 0" class="empty-state" style="padding-top:60px">
          <div class="empty-icon">✍️</div>
          <div class="empty-title">Nenhum registro ainda</div>
          <div class="empty-sub">Registre sua primeira sessão de leitura de "{{ book.title }}"</div>
          <button class="btn-primary" style="margin-top:20px" @click="openEditor()">
            <AppIcon name="plus" :size="14" /> Novo registro
          </button>
        </div>
        <div v-else class="timeline">
          <div v-for="entry in entries" :key="entry.id" class="timeline-entry" @click="openEditor(entry)">
            <div class="tl-date">
              <div class="tl-day">{{ formatDate(entry.created_at).day }}</div>
              <div class="tl-time">{{ formatDate(entry.created_at).time }}</div>
            </div>
            <div class="tl-dot" />
            <div class="tl-body">
              <div class="tl-page">Página {{ entry.page }}</div>
              <div class="tl-text" v-html="renderMd(entry.body)" />
            </div>
          </div>
        </div>
      </template>

      <!-- NOTES TAB -->
      <template v-else-if="activeTab === 'notes'">
        <div style="display:flex;justify-content:flex-end;margin-bottom:16px">
          <button class="btn-primary" @click="openNote">
            <AppIcon name="plus" :size="14" /> Nova nota
          </button>
        </div>
        <div v-if="notes.length === 0" class="empty-state" style="padding-top:40px">
          <div class="empty-icon">📝</div>
          <div class="empty-title">Sem notas</div>
          <div class="empty-sub">Citações, reflexões e resumos ficam aqui.</div>
        </div>
        <div v-else>
          <div v-for="note in notes" :key="note.id" class="note-card">
            <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px">
              <div class="note-card-title">{{ note.title || 'Sem título' }}</div>
              <button @click.stop="deleteNote(note.id)" style="color:var(--text-3);font-size:11px;flex-shrink:0;margin-top:2px" title="Excluir">✕</button>
            </div>
            <div class="note-card-preview">{{ note.body.slice(0, 200) }}{{ note.body.length > 200 ? '…' : '' }}</div>
            <div class="note-card-meta">{{ note.created_at }}</div>
          </div>
        </div>
      </template>

      <!-- INFO TAB -->
      <template v-else>
        <div style="display:grid;gap:0">
          <div v-for="row in [
            { label: 'Título', val: book.title },
            { label: 'Autor', val: book.author },
            { label: 'Editora', val: book.publisher },
            { label: 'Ano', val: book.year },
            { label: 'Páginas', val: book.pages },
            { label: 'Status', val: badgeLabel(book.status) },
          ]" :key="row.label" style="display:flex;padding:14px 0;border-bottom:1px solid var(--border)">
            <div style="width:120px;font-size:12px;color:var(--text-3);text-transform:uppercase;letter-spacing:0.06em;padding-top:2px">{{ row.label }}</div>
            <div style="font-size:15px">{{ row.val }}</div>
          </div>
        </div>
      </template>
    </div>

    <button v-if="book.status === 'reading'" class="fab" @click="openEditor()" title="Novo registro (N)">
      <AppIcon name="pen" :size="20" />
    </button>

    <template #toast>
      <div v-if="toast" class="toast">
        <span>✅</span>
        <span>{{ toast }}</span>
      </div>
    </template>
  </AppLayout>

  <!-- Note modal -->
  <div v-if="noteOpen" class="note-overlay" @click.self="noteOpen = false">
    <div class="note-modal">
      <div class="note-modal-header">
        <span style="font-family:var(--font-serif);font-size:16px">Nova nota</span>
        <button @click="noteOpen = false" style="color:var(--text-3)"><AppIcon name="x" :size="16" /></button>
      </div>
      <div class="note-modal-body">
        <input
          v-model="noteForm.title"
          class="note-title-input"
          placeholder="Título (opcional)"
          autofocus
        />
        <textarea
          v-model="noteForm.body"
          class="note-body-input"
          placeholder="Citação, reflexão, resumo… Use ** negrito **, * itálico *, > citação"
          rows="8"
        />
      </div>
      <div class="note-modal-footer">
        <button class="btn-secondary" @click="noteOpen = false">Cancelar</button>
        <button class="btn-primary" :disabled="!noteForm.body.trim() || noteSaving" @click="saveNote">
          <AppIcon name="check" :size="14" /> {{ noteSaving ? 'Salvando…' : 'Salvar nota' }}
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.book-hero {
  background: var(--bg-1); border-bottom: 1px solid var(--border);
  padding: 32px 32px 0;
}
.back-btn {
  display: flex; align-items: center; gap: 6px;
  color: var(--text-3); font-size: 13px; margin-bottom: 20px;
  transition: color 0.15s;
}
.back-btn:hover { color: var(--text); }
.book-hero-inner { display: flex; gap: 28px; max-width: 900px; }
.book-hero-cover {
  width: 120px; height: 168px; flex-shrink: 0; border-radius: 8px; overflow: hidden;
  box-shadow: var(--shadow);
}
.book-hero-meta { flex: 1; padding-top: 4px; }
.book-hero-title { font-family: var(--font-serif); font-size: 28px; font-weight: 500; line-height: 1.2; margin-bottom: 6px; }
.book-hero-author { font-size: 15px; color: var(--text-2); margin-bottom: 14px; }
.book-hero-stats { display: flex; gap: 20px; }
.book-stat { text-align: left; }
.book-stat-val { font-size: 20px; font-weight: 600; font-family: var(--font-serif); color: var(--accent); }
.book-stat-label { font-size: 11px; color: var(--text-3); text-transform: uppercase; letter-spacing: 0.06em; }
.book-tabs { display: flex; margin-top: 24px; }
.book-tab {
  padding: 10px 20px; font-size: 13px; font-weight: 500;
  color: var(--text-3); cursor: pointer;
  border-bottom: 2px solid transparent; transition: all 0.15s;
}
.book-tab:hover { color: var(--text-2); }
.book-tab.active { color: var(--accent); border-bottom-color: var(--accent); }
.book-content { padding: 28px 32px; max-width: 860px; }
.timeline { display: flex; flex-direction: column; }
.timeline-entry {
  display: flex; gap: 20px; padding: 16px 0;
  border-bottom: 1px solid var(--border); cursor: pointer;
}
.timeline-entry:last-child { border-bottom: none; }
.timeline-entry:hover .tl-body { color: var(--text); }
.tl-date { width: 80px; flex-shrink: 0; padding-top: 2px; }
.tl-day { font-size: 13px; font-weight: 600; }
.tl-time { font-size: 11px; color: var(--text-3); }
.tl-dot {
  width: 2px; background: var(--border-2); position: relative; flex-shrink: 0; margin: 4px 0;
}
.tl-dot::before {
  content: ''; position: absolute; top: 4px; left: -3px;
  width: 8px; height: 8px; border-radius: 50%;
  background: var(--accent); border: 2px solid var(--bg-1);
}
.tl-body { flex: 1; }
.tl-page { font-size: 11px; color: var(--accent); font-weight: 600; margin-bottom: 6px; }
.tl-text { font-size: 14px; color: var(--text-2); line-height: 1.6; }
:deep(.tl-text strong) { color: var(--text); font-weight: 500; }
:deep(.tl-text em) { font-style: italic; color: var(--text); }
:deep(.tl-text blockquote) { border-left: 2px solid var(--accent-2); padding-left: 12px; color: var(--text-2); margin: 8px 0; }
.note-card {
  background: var(--bg-1); border: 1px solid var(--border);
  border-radius: var(--r-lg); padding: 16px;
  cursor: pointer; transition: all 0.15s; margin-bottom: 10px;
}
.note-card:hover { border-color: var(--border-2); box-shadow: var(--shadow-sm); }
.note-card-title { font-family: var(--font-serif); font-size: 15px; margin-bottom: 6px; }
.note-card-preview { font-size: 13px; color: var(--text-2); line-height: 1.5; }
.note-card-meta { font-size: 11px; color: var(--text-3); margin-top: 10px; }
.fab {
  position: fixed; right: 28px; bottom: 28px; z-index: 50;
  width: 48px; height: 48px; border-radius: 50%;
  background: var(--accent); color: #1a1208;
  display: flex; align-items: center; justify-content: center;
  font-size: 22px; box-shadow: 0 4px 20px #e8a83a44;
  transition: all 0.2s;
}
.fab:hover { transform: scale(1.08); box-shadow: 0 6px 28px #e8a83a60; }
.toast {
  position: fixed; bottom: 24px; left: 50%; transform: translateX(-50%);
  background: var(--bg-2); border: 1px solid var(--border-2);
  border-radius: var(--r-lg); padding: 10px 18px;
  font-size: 13px; color: var(--text); box-shadow: var(--shadow); z-index: 400;
  display: flex; align-items: center; gap: 8px;
  animation: toastin 0.25s ease;
}
.note-overlay {
  position: fixed; inset: 0; z-index: 300;
  background: #00000070; backdrop-filter: blur(4px);
  display: flex; align-items: center; justify-content: center; padding: 24px;
}
.note-modal {
  width: 100%; max-width: 540px; background: var(--bg-1);
  border: 1px solid var(--border-2); border-radius: var(--r-lg);
  box-shadow: 0 24px 80px #00000080; display: flex; flex-direction: column;
}
.note-modal-header {
  padding: 16px 20px; border-bottom: 1px solid var(--border);
  display: flex; align-items: center; justify-content: space-between;
}
.note-modal-body { padding: 16px 20px; display: flex; flex-direction: column; gap: 12px; }
.note-title-input {
  font-family: var(--font-serif); font-size: 18px; font-weight: 500;
  color: var(--text); background: none; border: none; outline: none; width: 100%;
}
.note-title-input::placeholder { color: var(--text-3); }
.note-body-input {
  font-size: 14px; line-height: 1.7; color: var(--text);
  background: var(--bg-2); border: 1px solid var(--border-2);
  border-radius: var(--r); padding: 12px 14px;
  resize: none; width: 100%; transition: border-color 0.15s;
}
.note-body-input:focus { border-color: var(--accent-2); outline: none; }
.note-body-input::placeholder { color: var(--text-3); }
.note-modal-footer {
  padding: 14px 20px; border-top: 1px solid var(--border);
  display: flex; justify-content: flex-end; gap: 10px;
}
</style>
