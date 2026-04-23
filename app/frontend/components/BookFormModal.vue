<script setup>
import { ref, watch } from 'vue'
import { router } from '@inertiajs/vue3'
import AppIcon from './AppIcon.vue'

const emit = defineEmits(['close'])

const GRADIENTS = [
  'linear-gradient(135deg, #3d2008 0%, #7a3a12 100%)',
  'linear-gradient(135deg, #12281a 0%, #2d5a3d 100%)',
  'linear-gradient(135deg, #111a2a 0%, #2a3f5f 100%)',
  'linear-gradient(135deg, #1e140a 0%, #4a3520 100%)',
  'linear-gradient(135deg, #0a1820 0%, #1a3a4a 100%)',
  'linear-gradient(135deg, #240f18 0%, #5a2d3a 100%)',
  'linear-gradient(135deg, #1a1228 0%, #3d2d5a 100%)',
  'linear-gradient(135deg, #0d1f1a 0%, #1a4a3a 100%)',
]
const EMOJIS = ['📖','📚','🌍','🏔️','🌊','🎭','🔮','🌙','⚡','🎨','🧠','🌿']

const query = ref('')
const results = ref([])
const searching = ref(false)
const searchTimer = ref(null)
const step = ref('search') // 'search' | 'form'
const saving = ref(false)

const form = ref({
  title: '', author: '', publisher: '', year: '', pages: '',
  status: 'want', emoji: '📖',
  gradient: GRADIENTS[0],
  cover_url: '',
})

watch(query, (val) => {
  clearTimeout(searchTimer.value)
  if (!val.trim()) { results.value = []; return }
  searchTimer.value = setTimeout(() => searchGoogleBooks(val), 400)
})

async function searchGoogleBooks(q) {
  searching.value = true
  try {
    const params = new URLSearchParams({
      q,
      maxResults: 10,
      printType: 'books',
      langRestrict: 'pt',
      country: 'BR',
      orderBy: 'relevance',
    })
    const res = await fetch(`https://www.googleapis.com/books/v1/volumes?${params}`)
    const data = await res.json()
    results.value = (data.items || []).map(item => {
      const v = item.volumeInfo
      return {
        title: v.title || '',
        subtitle: v.subtitle || '',
        author: (v.authors || []).join(', '),
        publisher: v.publisher || '',
        year: v.publishedDate?.slice(0, 4) || '',
        pages: v.pageCount || '',
        cover: v.imageLinks?.thumbnail?.replace('http:', 'https:').replace('zoom=1', 'zoom=3') || null,
        description: v.description?.slice(0, 200) || '',
      }
    })
  } catch {
    results.value = []
  } finally {
    searching.value = false
  }
}

function selectResult(r) {
  form.value = {
    title: r.subtitle ? `${r.title}: ${r.subtitle}` : r.title,
    author: r.author,
    publisher: r.publisher,
    year: r.year,
    pages: r.pages,
    status: 'want',
    emoji: EMOJIS[Math.floor(Math.random() * EMOJIS.length)],
    gradient: GRADIENTS[Math.floor(Math.random() * GRADIENTS.length)],
    cover_url: r.cover || '',
  }
  step.value = 'form'
}

function fillManual() {
  form.value = { title: query.value, author: '', publisher: '', year: '', pages: '', status: 'want', emoji: '📖', gradient: GRADIENTS[0] }
  step.value = 'form'
}

function save() {
  saving.value = true
  router.post('/livros', { book: { ...form.value } }, {
    onSuccess: () => { saving.value = false; emit('close') },
    onError: () => { saving.value = false },
  })
}

</script>

<template>
  <div class="overlay" @click="$emit('close')">
    <div class="modal" @click.stop>
      <div class="modal-header">
        <div class="modal-title">{{ step === 'search' ? 'Adicionar livro' : form.title || 'Novo livro' }}</div>
        <button @click="$emit('close')" style="color:var(--text-3)"><AppIcon name="x" :size="18" /></button>
      </div>

      <!-- STEP: SEARCH -->
      <template v-if="step === 'search'">
        <div class="search-box">
          <AppIcon name="search" :size="16" />
          <input v-model="query" placeholder="Título, autor ou ISBN…" autofocus />
          <div v-if="searching" class="spinner" />
        </div>

        <div class="results">
          <div v-if="results.length === 0 && query && !searching" class="no-results">
            Nenhum resultado.
            <button class="link-btn" @click="fillManual">Adicionar manualmente</button>
          </div>

          <div
            v-for="r in results" :key="r.title + r.author"
            class="result-item"
            @click="selectResult(r)"
          >
            <div class="result-cover">
              <img v-if="r.cover" :src="r.cover" :alt="r.title" />
              <span v-else style="font-size:20px">📖</span>
            </div>
            <div class="result-info">
              <div class="result-title">{{ r.title }}<span v-if="r.subtitle" style="color:var(--text-3)"> — {{ r.subtitle }}</span></div>
              <div class="result-meta">{{ r.author }}<template v-if="r.year"> · {{ r.year }}</template><template v-if="r.pages"> · {{ r.pages }} p.</template></div>
              <div v-if="r.description" class="result-desc">{{ r.description }}…</div>
            </div>
            <AppIcon name="chevronRight" :size="16" style="color:var(--text-3);flex-shrink:0" />
          </div>

          <button v-if="query && results.length > 0" class="manual-btn" @click="fillManual">
            Não encontrei — adicionar manualmente
          </button>

          <div v-if="!query" class="hint">
            <button class="link-btn" @click="fillManual">Adicionar manualmente →</button>
          </div>
        </div>
      </template>

      <!-- STEP: FORM -->
      <template v-else>
        <div class="form-body">
          <button class="back-link" @click="step = 'search'">
            <AppIcon name="chevronLeft" :size="14" /> Voltar à busca
          </button>

          <div class="form-grid">
            <div class="field full">
              <label>Título *</label>
              <input v-model="form.title" placeholder="Título do livro" />
            </div>
            <div class="field full">
              <label>Autor *</label>
              <input v-model="form.author" placeholder="Nome do autor" />
            </div>
            <div class="field">
              <label>Editora</label>
              <input v-model="form.publisher" placeholder="Editora" />
            </div>
            <div class="field half">
              <label>Ano</label>
              <input v-model="form.year" type="number" placeholder="2024" />
            </div>
            <div class="field half">
              <label>Páginas</label>
              <input v-model="form.pages" type="number" placeholder="320" />
            </div>
            <div class="field">
              <label>Status</label>
              <select v-model="form.status">
                <option value="want">Quero ler</option>
                <option value="reading">Lendo</option>
                <option value="read">Já li</option>
              </select>
            </div>

            <div class="field full">
              <label>Capa</label>
              <div v-if="form.cover_url" class="cover-preview">
                <img :src="form.cover_url" alt="Capa" />
                <button class="cover-remove" @click="form.cover_url = ''" title="Remover capa">✕</button>
              </div>
              <template v-else>
                <div class="emoji-grid" style="margin-bottom:12px">
                  <button
                    v-for="e in EMOJIS" :key="e"
                    :class="['emoji-btn', { active: form.emoji === e }]"
                    @click="form.emoji = e"
                  >{{ e }}</button>
                </div>
                <div class="gradient-grid">
                  <button
                    v-for="(g, i) in GRADIENTS" :key="i"
                    :class="['gradient-btn', { active: form.gradient === g }]"
                    :style="{ background: g }"
                    @click="form.gradient = g"
                  />
                </div>
              </template>
            </div>
          </div>
        </div>

        <div class="form-footer">
          <button class="btn-secondary" @click="$emit('close')">Cancelar</button>
          <button class="btn-primary" :disabled="!form.title || !form.author || saving" @click="save">
            <AppIcon name="plus" :size="14" /> {{ saving ? 'Salvando…' : 'Adicionar livro' }}
          </button>
        </div>
      </template>
    </div>
  </div>
</template>

<style scoped>
.overlay {
  position: fixed; inset: 0; z-index: 250;
  background: #00000070; backdrop-filter: blur(4px);
  display: flex; align-items: flex-start; justify-content: center;
  padding-top: 80px;
}
.modal {
  width: 560px; max-height: calc(100vh - 120px);
  background: var(--bg-1); border: 1px solid var(--border-2);
  border-radius: var(--r-lg); box-shadow: 0 24px 80px #00000080;
  display: flex; flex-direction: column; overflow: hidden;
}
.modal-header {
  padding: 20px 20px 16px; border-bottom: 1px solid var(--border);
  display: flex; align-items: center; justify-content: space-between;
  flex-shrink: 0;
}
.modal-title { font-family: var(--font-serif); font-size: 18px; font-weight: 500; }
.search-box {
  display: flex; align-items: center; gap: 10px;
  padding: 14px 16px; border-bottom: 1px solid var(--border);
  flex-shrink: 0;
}
.search-box input { flex: 1; font-size: 15px; background: none; border: none; outline: none; color: var(--text); }
.search-box input::placeholder { color: var(--text-3); }
.spinner {
  width: 16px; height: 16px; border-radius: 50%;
  border: 2px solid var(--border-2); border-top-color: var(--accent);
  animation: spin 0.6s linear infinite; flex-shrink: 0;
}
@keyframes spin { to { transform: rotate(360deg); } }
.results { overflow-y: auto; padding: 8px; }
.result-item {
  display: flex; align-items: center; gap: 12px;
  padding: 10px 10px; border-radius: var(--r);
  cursor: pointer; transition: background 0.1s;
}
.result-item:hover { background: var(--bg-2); }
.result-cover {
  width: 36px; height: 50px; border-radius: 3px; flex-shrink: 0;
  background: var(--bg-3); display: flex; align-items: center; justify-content: center;
  overflow: hidden;
}
.result-cover img { width: 100%; height: 100%; object-fit: cover; }
.result-info { flex: 1; min-width: 0; }
.result-title { font-family: var(--font-serif); font-size: 14px; font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.result-meta { font-size: 12px; color: var(--text-3); margin-top: 2px; }
.result-desc { font-size: 11px; color: var(--text-3); margin-top: 3px; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.no-results { padding: 24px 16px; font-size: 13px; color: var(--text-3); display: flex; align-items: center; gap: 8px; }
.hint { padding: 20px 16px; font-size: 13px; color: var(--text-3); display: flex; flex-direction: column; gap: 8px; }
.link-btn { background: none; border: none; color: var(--accent); font-size: 13px; cursor: pointer; padding: 0; }
.manual-btn {
  width: 100%; text-align: left; padding: 10px 10px;
  font-size: 12px; color: var(--text-3); border-radius: var(--r);
  transition: background 0.1s; cursor: pointer;
  background: none; border: none;
}
.manual-btn:hover { background: var(--bg-2); color: var(--text-2); }
.back-link {
  display: inline-flex; align-items: center; gap: 4px;
  font-size: 12px; color: var(--text-3); cursor: pointer;
  background: none; border: none; margin-bottom: 16px; transition: color 0.15s;
}
.back-link:hover { color: var(--text); }
.form-body { overflow-y: auto; padding: 16px 20px; flex: 1; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.field { display: flex; flex-direction: column; gap: 5px; }
.field.full { grid-column: 1 / -1; }
.field.half { }
.field label { font-size: 11px; color: var(--text-3); text-transform: uppercase; letter-spacing: 0.06em; }
.field input, .field select {
  background: var(--bg-2); border: 1px solid var(--border-2);
  border-radius: var(--r); padding: 8px 10px;
  font-size: 14px; color: var(--text); transition: border-color 0.15s;
}
.field input:focus, .field select:focus { border-color: var(--accent-2); outline: none; }
.field input::placeholder { color: var(--text-3); }
.field select { cursor: pointer; appearance: none; }
.emoji-grid { display: flex; flex-wrap: wrap; gap: 6px; }
.emoji-btn {
  width: 36px; height: 36px; border-radius: var(--r);
  background: var(--bg-2); border: 1px solid var(--border);
  font-size: 18px; cursor: pointer; transition: all 0.1s;
  display: flex; align-items: center; justify-content: center;
}
.emoji-btn:hover { border-color: var(--border-2); }
.emoji-btn.active { border-color: var(--accent); background: var(--accent-dim); }
.gradient-grid { display: flex; flex-wrap: wrap; gap: 8px; }
.gradient-btn {
  width: 40px; height: 28px; border-radius: 6px;
  border: 2px solid transparent; cursor: pointer; transition: all 0.1s;
}
.gradient-btn:hover { transform: scale(1.1); }
.gradient-btn.active { border-color: var(--accent); }
.cover-preview {
  position: relative; display: inline-block;
  width: 80px; height: 120px; border-radius: var(--r); overflow: hidden;
  border: 1px solid var(--border-2);
}
.cover-preview img { width: 100%; height: 100%; object-fit: cover; }
.cover-remove {
  position: absolute; top: 4px; right: 4px;
  background: #000000aa; border: none; border-radius: 50%;
  color: #fff; font-size: 10px; width: 20px; height: 20px;
  cursor: pointer; display: flex; align-items: center; justify-content: center;
  line-height: 1;
}
.form-footer {
  padding: 14px 20px; border-top: 1px solid var(--border);
  display: flex; justify-content: flex-end; gap: 10px; flex-shrink: 0;
}
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; filter: none; }
</style>
