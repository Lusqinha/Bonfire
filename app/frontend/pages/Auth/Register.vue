<script setup>
import { ref, computed } from 'vue'
import { router, usePage } from '@inertiajs/vue3'
import logoUrl from '../../assets/logo.png'

const page = usePage()
const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const loading = ref(false)

const errors = computed(() => page.props.errors || {})

function submit() {
  loading.value = true
  router.post('/conta', {
    email_address: email.value,
    password: password.value,
    password_confirmation: passwordConfirmation.value,
  }, {
    onFinish: () => { loading.value = false }
  })
}
</script>

<template>
  <div class="auth-wrap">
    <div class="auth-box">
      <a href="/" class="auth-back">← Início</a>
      <div class="auth-logo">
        <img :src="logoUrl" alt="Bonfire" class="auth-logo-img" />
        <div class="auth-title">Bonfire</div>
      </div>
      <div class="auth-sub">Comece a registrar suas leituras hoje</div>

      <div v-if="errors.base" class="auth-error">
        <span v-for="e in errors.base" :key="e">{{ e }}</span>
      </div>

      <form @submit.prevent="submit" class="auth-form">
        <div class="form-field">
          <label>E-mail</label>
          <input
            v-model="email" type="email" required
            autocomplete="email" placeholder="seu@email.com"
            :class="{ error: errors.email_address }"
          />
          <span v-if="errors.email_address" class="field-error">{{ errors.email_address.join(', ') }}</span>
        </div>
        <div class="form-field">
          <label>Senha</label>
          <input
            v-model="password" type="password" required
            autocomplete="new-password" placeholder="Mínimo 12 caracteres"
            :class="{ error: errors.password }"
          />
          <span v-if="errors.password" class="field-error">{{ errors.password.join(', ') }}</span>
        </div>
        <div class="form-field">
          <label>Confirmar senha</label>
          <input
            v-model="passwordConfirmation" type="password" required
            autocomplete="new-password" placeholder="Repita a senha"
            :class="{ error: errors.password_confirmation }"
          />
          <span v-if="errors.password_confirmation" class="field-error">{{ errors.password_confirmation.join(', ') }}</span>
        </div>
        <button type="submit" class="btn-primary" style="width:100%;justify-content:center;padding:12px" :disabled="loading">
          {{ loading ? 'Criando conta…' : 'Criar conta' }}
        </button>
      </form>

      <div class="auth-footer">
        Já tem conta? <a href="/sessao/nova" class="auth-link">Entrar</a>
      </div>
    </div>
  </div>
</template>

<style scoped>
.auth-wrap {
  height: 100%; overflow-y: auto; display: flex; align-items: center; justify-content: center;
  background: var(--bg); padding: 32px 16px;
}
.auth-box {
  width: 100%; max-width: 380px;
  background: var(--bg-1); border: 1px solid var(--border-2);
  border-radius: var(--r-lg); padding: 36px 32px; box-shadow: var(--shadow);
}
.auth-back {
  display: inline-block; font-size: 12px; color: var(--text-3);
  margin-bottom: 24px; transition: color 0.15s;
}
.auth-back:hover { color: var(--text-2); }
.auth-logo { display: flex; align-items: center; gap: 12px; margin-bottom: 6px; }
.auth-logo-img {
  width: 32px; height: 32px; object-fit: contain;
  filter: brightness(0) invert(1) sepia(1) saturate(3) hue-rotate(5deg) brightness(1.1);
}
.auth-title { font-family: var(--font-serif); font-size: 20px; font-weight: 600; }
.auth-sub { color: var(--text-3); font-size: 13px; margin-bottom: 28px; }
.auth-error {
  background: #e8706022; border: 1px solid #e8706044; border-radius: var(--r);
  padding: 10px 14px; font-size: 13px; color: var(--red); margin-bottom: 20px;
}
.auth-form { display: flex; flex-direction: column; gap: 16px; }
.form-field { display: flex; flex-direction: column; gap: 6px; }
.form-field label { font-size: 12px; color: var(--text-3); text-transform: uppercase; letter-spacing: 0.06em; }
.form-field input {
  background: var(--bg-2); border: 1px solid var(--border-2);
  border-radius: var(--r); padding: 10px 14px;
  font-size: 14px; color: var(--text); transition: border-color 0.15s;
}
.form-field input:focus { border-color: var(--accent-2); outline: none; }
.form-field input::placeholder { color: var(--text-3); }
.form-field input.error { border-color: var(--red); }
.field-error { font-size: 11px; color: var(--red); }
.auth-footer { text-align: center; font-size: 13px; color: var(--text-3); margin-top: 20px; }
.auth-link { color: var(--accent); }
.auth-link:hover { text-decoration: underline; }
</style>
