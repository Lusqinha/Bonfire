<script setup>
import AppIcon from './AppIcon.vue'
defineEmits(['close'])

const groups = [
  { title: 'Navegação Global', items: [
    { desc: 'Abrir command palette / busca', keys: ['Ctrl', 'K'] },
    { desc: 'Ir para Biblioteca', keys: ['G', 'L'] },
    { desc: 'Ir para Início', keys: ['G', 'H'] },
    { desc: 'Atalhos de teclado', keys: ['?'] },
    { desc: 'Fechar modal / overlay', keys: ['Esc'] },
  ]},
  { title: 'Editor de Texto', items: [
    { desc: 'Negrito', keys: ['Ctrl', 'B'] },
    { desc: 'Itálico', keys: ['Ctrl', 'I'] },
    { desc: 'Salvar entrada', keys: ['Ctrl', 'Enter'] },
    { desc: 'Modo foco (sem distrações)', keys: ['Ctrl', 'Shift', 'F'] },
    { desc: 'Sair do modo foco', keys: ['Esc'] },
  ]},
  { title: 'Biblioteca', items: [
    { desc: 'Nova entrada de leitura', keys: ['N'] },
    { desc: 'Adicionar livro', keys: ['A'] },
    { desc: 'Alternar grid / lista', keys: ['V'] },
    { desc: 'Focar na busca', keys: ['/'] },
  ]},
]
</script>

<template>
  <div class="modal-overlay" @click="$emit('close')">
    <div class="modal" @click.stop>
      <div class="modal-header">
        <div class="modal-title">Atalhos de Teclado</div>
        <button @click="$emit('close')" style="color:var(--text-3)"><AppIcon name="x" :size="18" /></button>
      </div>
      <div class="modal-body">
        <div v-for="g in groups" :key="g.title" class="shortcut-group">
          <div class="shortcut-group-title">{{ g.title }}</div>
          <div v-for="item in g.items" :key="item.desc" class="shortcut-row">
            <span class="shortcut-desc">{{ item.desc }}</span>
            <span class="shortcut-keys">
              <span v-for="(k, i) in item.keys" :key="i" class="kbd">{{ k }}</span>
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed; inset: 0; z-index: 300;
  background: #00000060; backdrop-filter: blur(4px);
  display: flex; align-items: center; justify-content: center;
}
.modal {
  width: 520px; background: var(--bg-1);
  border: 1px solid var(--border-2); border-radius: var(--r-lg);
  box-shadow: var(--shadow); overflow: hidden;
}
.modal-header {
  padding: 20px 24px 16px; border-bottom: 1px solid var(--border);
  display: flex; align-items: center; justify-content: space-between;
}
.modal-title { font-family: var(--font-serif); font-size: 18px; }
.modal-body { padding: 20px 24px; max-height: 60vh; overflow-y: auto; }
.shortcut-group { margin-bottom: 20px; }
.shortcut-group-title { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.08em; color: var(--text-3); margin-bottom: 10px; }
.shortcut-row { display: flex; align-items: center; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid var(--border); }
.shortcut-row:last-child { border: none; }
.shortcut-desc { font-size: 13px; color: var(--text-2); }
.shortcut-keys { display: flex; gap: 4px; }
</style>
