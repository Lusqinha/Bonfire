<script setup>
import { ref } from 'vue'
import { router, usePage } from '@inertiajs/vue3'
import logoUrl from '../../assets/logo.png'

const page = usePage()
const email = ref('')
const password = ref('')
const loading = ref(false)

function submit() {
  loading.value = true
  router.post('/session', { email_address: email.value, password: password.value }, {
    onFinish: () => { loading.value = false }
  })
}
</script>

<template>
  <div class="login-wrap">
    <div class="login-box">
      <div class="login-logo">
        <img :src="logoUrl" alt="Bonfire" class="login-logo-img" />
        <div class="login-title">Bonfire</div>
      </div>
      <div class="login-sub">Seu registro pessoal de leituras</div>

      <div v-if="$page.props.flash?.alert" class="login-error">
        {{ $page.props.flash.alert }}
      </div>

      <form @submit.prevent="submit" class="login-form">
        <div class="form-field">
          <label>E-mail</label>
          <input v-model="email" type="email" required autocomplete="email" placeholder="seu@email.com" />
        </div>
        <div class="form-field">
          <label>Senha</label>
          <input v-model="password" type="password" required autocomplete="current-password" placeholder="••••••••" />
        </div>
        <button type="submit" class="btn-primary" style="width:100%;justify-content:center" :disabled="loading">
          {{ loading ? 'Entrando…' : 'Entrar' }}
        </button>
      </form>

      <div class="login-footer">
        Novo aqui? <a href="/registration/new" class="login-link">Criar conta</a>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-wrap {
  height: 100vh; display: flex; align-items: center; justify-content: center;
  background: var(--bg);
}
.login-box {
  width: 360px; background: var(--bg-1); border: 1px solid var(--border-2);
  border-radius: var(--r-lg); padding: 40px 32px; box-shadow: var(--shadow);
}
.login-logo { display: flex; align-items: center; gap: 12px; margin-bottom: 6px; }
.login-logo-img {
  width: 32px; height: 32px; object-fit: contain;
  filter: brightness(0) invert(1) sepia(1) saturate(3) hue-rotate(5deg) brightness(1.1);
}
.login-title { font-family: var(--font-serif); font-size: 20px; font-weight: 600; }
.login-sub { color: var(--text-3); font-size: 13px; margin-bottom: 28px; }
.login-error {
  background: #e8706022; border: 1px solid #e8706044; border-radius: var(--r);
  padding: 10px 14px; font-size: 13px; color: var(--red); margin-bottom: 20px;
}
.login-form { display: flex; flex-direction: column; gap: 16px; }
.form-field { display: flex; flex-direction: column; gap: 6px; }
.form-field label { font-size: 12px; color: var(--text-3); text-transform: uppercase; letter-spacing: 0.06em; }
.form-field input {
  background: var(--bg-2); border: 1px solid var(--border-2);
  border-radius: var(--r); padding: 10px 14px;
  font-size: 14px; color: var(--text); transition: border-color 0.15s;
}
.form-field input:focus { border-color: var(--accent-2); outline: none; }
.form-field input::placeholder { color: var(--text-3); }
.btn-primary:disabled { opacity: 0.7; cursor: not-allowed; }
.login-footer { text-align: center; font-size: 13px; color: var(--text-3); margin-top: 20px; }
.login-link { color: var(--accent); }
.login-link:hover { text-decoration: underline; }
</style>
