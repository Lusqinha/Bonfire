<script setup>
import { usePage } from '@inertiajs/vue3'
const page = usePage()
const isLoggedIn = !!page.props.current_user
</script>

<template>
  <div class="landing">
    <header class="nav">
      <div class="nav-brand">
        <div class="brand-icon">📖</div>
        <span class="brand-name">Diário de Leitura</span>
      </div>
      <div class="nav-actions">
        <template v-if="isLoggedIn">
          <a href="/library" class="btn-accent">Ir para a biblioteca →</a>
        </template>
        <template v-else>
          <a href="/session/new" class="btn-ghost">Entrar</a>
          <a href="/registration/new" class="btn-accent">Criar conta</a>
        </template>
      </div>
    </header>

    <main>
      <!-- Hero -->
      <section class="hero">
        <h1 class="hero-title">Um lugar para<br /><em>acompanhar o que você lê</em></h1>
        <p class="hero-sub">
          Registre suas sessões de leitura, guarde anotações e mantenha sua biblioteca pessoal —
          sem planilhas, sem apps complicados, sem perder o fio da história.
        </p>
        <div class="hero-cta">
          <template v-if="isLoggedIn">
            <a href="/library" class="btn-accent btn-lg">Ir para a biblioteca →</a>
          </template>
          <template v-else>
            <a href="/registration/new" class="btn-accent btn-lg">Começar a usar</a>
            <a href="/session/new" class="btn-ghost-lg">Já tenho conta →</a>
          </template>
        </div>
      </section>

      <!-- Feature: Reading entries -->
      <section class="feature-section">
        <div class="feature-text">
          <div class="feature-label">Diário de leitura</div>
          <h2 class="feature-heading">Cada sessão tem seu registro</h2>
          <p class="feature-body">
            Ao terminar de ler, você anota até onde chegou e o que passou pela sua cabeça.
            Pode ser uma citação, uma dúvida, um pensamento solto. O importante é não perder.
          </p>
          <p class="feature-body">
            Com o tempo, você tem um histórico real da sua leitura — não só "li esse livro",
            mas como foi lê-lo, página por página.
          </p>
        </div>
        <div class="feature-demo">
          <div class="demo-entry">
            <div class="demo-entry-header">
              <div>
                <div class="demo-book-title">O Hobbit</div>
                <div class="demo-entry-meta">12 abr · 22:14 · Página 187</div>
              </div>
              <div class="demo-page-badge">p. 187</div>
            </div>
            <div class="demo-entry-body">
              A cena da conversa com Smaug é melhor do que eu lembrava. Bilbo improvisando
              respostas em enigmas enquanto tenta não revelar seu nome — há algo de muito
              humano nisso. O anonimato como proteção.
            </div>
          </div>
          <div class="demo-entry" style="opacity:0.5;transform:scale(0.97);transform-origin:top left">
            <div class="demo-entry-header">
              <div>
                <div class="demo-book-title">O Hobbit</div>
                <div class="demo-entry-meta">9 abr · 21:30 · Página 140</div>
              </div>
              <div class="demo-page-badge">p. 140</div>
            </div>
            <div class="demo-entry-body">
              Gollum apareceu e eu não esperava sentir tanta estranheza. A seção dos enigmas
              tem um ritmo diferente de tudo que veio antes...
            </div>
          </div>
        </div>
      </section>

      <!-- Feature: Library -->
      <section class="feature-section feature-section--reversed">
        <div class="feature-text">
          <div class="feature-label">Biblioteca</div>
          <h2 class="feature-heading">Seus livros, organizados do seu jeito</h2>
          <p class="feature-body">
            Três listas simples: o que você quer ler, o que está lendo agora, e o que já leu.
            Você busca um livro pelo título ou autor e as informações vêm prontas — capa, editora, número de páginas.
          </p>
          <p class="feature-body">
            Nada de cadastro manual demorado. Encontrou o livro, confirmou, está na sua biblioteca.
          </p>
        </div>
        <div class="feature-demo">
          <div class="demo-library">
            <div class="demo-lib-tabs">
              <span class="demo-tab active">Lendo (2)</span>
              <span class="demo-tab">Quero ler (8)</span>
              <span class="demo-tab">Já li (14)</span>
            </div>
            <div class="demo-books">
              <div class="demo-book-card">
                <div class="demo-book-cover" style="background:linear-gradient(135deg,#3d2008,#7a3a12)">🌍</div>
                <div class="demo-book-info">
                  <div class="demo-book-name">O Hobbit</div>
                  <div class="demo-book-author">J.R.R. Tolkien</div>
                  <div class="demo-progress-bar"><div class="demo-progress-fill" style="width:58%" /></div>
                  <div class="demo-progress-label">187 de 310 páginas</div>
                </div>
              </div>
              <div class="demo-book-card">
                <div class="demo-book-cover" style="background:linear-gradient(135deg,#12281a,#2d5a3d)">🧠</div>
                <div class="demo-book-info">
                  <div class="demo-book-name">Pensar, Depressa e Devagar</div>
                  <div class="demo-book-author">Daniel Kahneman</div>
                  <div class="demo-progress-bar"><div class="demo-progress-fill" style="width:23%" /></div>
                  <div class="demo-progress-label">112 de 489 páginas</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Feature: Notes -->
      <section class="feature-section">
        <div class="feature-text">
          <div class="feature-label">Notas</div>
          <h2 class="feature-heading">Guarde o que vale guardar</h2>
          <p class="feature-body">
            Às vezes você não quer registrar uma sessão de leitura — só quer salvar aquela
            frase que não dá pra deixar passar. Ou um trecho que você vai querer citar algum dia.
          </p>
          <p class="feature-body">
            As notas ficam dentro do livro, acessíveis quando você precisar revisitar.
          </p>
        </div>
        <div class="feature-demo">
          <div class="demo-notes">
            <div class="demo-note">
              <div class="demo-note-title">A ilusão do planejamento</div>
              <div class="demo-note-body">
                "Os seres humanos são incapazes de prever o futuro com precisão, mas
                são muito bons em criar histórias plausíveis sobre ele."
                <span style="color:var(--text-3)">— Kahneman, p. 251</span>
              </div>
              <div class="demo-note-meta">Pensar, Depressa e Devagar · 3 abr</div>
            </div>
            <div class="demo-note" style="opacity:0.55">
              <div class="demo-note-title">Sobre o tempo em Tolkien</div>
              <div class="demo-note-body">
                A Floresta de Mirkwood passa em quase nada no texto, mas parece longa
                demais de se ler. Sensação de tempo subjetivo transmitida pela escrita...
              </div>
              <div class="demo-note-meta">O Hobbit · 10 abr</div>
            </div>
          </div>
        </div>
      </section>

      <!-- Divider thought -->
      <section class="interlude">
        <blockquote class="interlude-quote">
          Ler sem anotar é como viajar sem câmera — você volta com memórias,
          mas os detalhes escorregam.
        </blockquote>
      </section>

      <!-- CTA -->
      <section class="cta-section">
        <div class="cta-inner">
          <h2 class="cta-title">Comece hoje, com os livros que você está lendo agora</h2>
          <p class="cta-sub">
            Não precisa migrar histórico nem organizar nada antes.
            Crie sua conta e registre a próxima sessão.
          </p>
          <template v-if="isLoggedIn">
            <a href="/library" class="btn-accent btn-lg">Ir para a biblioteca →</a>
          </template>
          <template v-else>
            <div class="cta-actions">
              <a href="/registration/new" class="btn-accent btn-lg">Criar conta</a>
              <a href="/session/new" class="btn-ghost-lg">Já tenho conta →</a>
            </div>
          </template>
        </div>
      </section>
    </main>

    <footer class="footer">
      <span>Diário de Leitura</span>
      <span class="footer-sep">·</span>
      <span>feito para leitores</span>
    </footer>
  </div>
</template>

<style scoped>
.landing {
  height: 100%; overflow-y: auto; overflow-x: hidden;
  background: var(--bg);
}

/* Nav */
.nav {
  display: flex; align-items: center; justify-content: space-between;
  padding: 20px 48px; border-bottom: 1px solid var(--border);
  position: sticky; top: 0; z-index: 10;
  background: var(--bg);
}
.nav-brand { display: flex; align-items: center; gap: 10px; }
.brand-icon {
  width: 30px; height: 30px; background: var(--accent); border-radius: 7px;
  display: flex; align-items: center; justify-content: center; font-size: 15px;
}
.brand-name { font-family: var(--font-serif); font-size: 17px; font-weight: 600; }
.nav-actions { display: flex; align-items: center; gap: 12px; }
.btn-ghost {
  padding: 7px 14px; border-radius: var(--r); font-size: 13px;
  color: var(--text-2); transition: color 0.15s;
}
.btn-ghost:hover { color: var(--text); }
.btn-accent {
  display: inline-flex; align-items: center;
  padding: 8px 18px; border-radius: var(--r);
  background: var(--accent); color: #1a1208;
  font-weight: 600; font-size: 13px; transition: filter 0.15s;
}
.btn-accent:hover { filter: brightness(1.1); }

/* Hero */
.hero {
  text-align: center;
  padding: 100px 32px 72px;
  max-width: 680px; margin: 0 auto;
}
.hero-title {
  font-family: var(--font-serif); font-size: 52px; font-weight: 600;
  line-height: 1.15; margin-bottom: 22px; color: var(--text);
}
.hero-title em { color: var(--accent); font-style: normal; }
.hero-sub {
  font-size: 17px; color: var(--text-2); line-height: 1.75;
  margin-bottom: 40px;
}
.hero-cta { display: flex; align-items: center; justify-content: center; gap: 20px; flex-wrap: wrap; }
.btn-lg { padding: 13px 26px; font-size: 14px; }
.btn-ghost-lg { font-size: 14px; color: var(--text-2); transition: color 0.15s; }
.btn-ghost-lg:hover { color: var(--text); }

/* Feature sections */
.feature-section {
  display: grid; grid-template-columns: 1fr 1fr;
  gap: 64px; align-items: center;
  max-width: 1040px; margin: 0 auto;
  padding: 80px 48px;
  border-top: 1px solid var(--border);
}
.feature-section--reversed { direction: rtl; }
.feature-section--reversed > * { direction: ltr; }
.feature-label {
  font-size: 11px; text-transform: uppercase; letter-spacing: 0.1em;
  color: var(--accent); font-weight: 600; margin-bottom: 12px;
}
.feature-heading {
  font-family: var(--font-serif); font-size: 28px; font-weight: 600;
  line-height: 1.25; margin-bottom: 20px; color: var(--text);
}
.feature-body {
  font-size: 14px; color: var(--text-2); line-height: 1.8;
  margin-bottom: 14px;
}
.feature-body:last-child { margin-bottom: 0; }

/* Demo: reading entry */
.demo-entry {
  background: var(--bg-1); border: 1px solid var(--border);
  border-radius: var(--r-lg); padding: 20px;
  margin-bottom: 10px;
}
.demo-entry-header {
  display: flex; align-items: flex-start; justify-content: space-between;
  gap: 12px; margin-bottom: 12px;
}
.demo-book-title { font-family: var(--font-serif); font-size: 13px; font-weight: 600; color: var(--text); }
.demo-entry-meta { font-size: 11px; color: var(--text-3); margin-top: 3px; }
.demo-page-badge {
  font-size: 11px; font-weight: 600; color: var(--accent);
  background: var(--accent-dim); padding: 3px 8px; border-radius: 20px;
  white-space: nowrap; flex-shrink: 0;
}
.demo-entry-body {
  font-size: 13px; color: var(--text-2); line-height: 1.7;
  font-family: var(--font-serif);
}

/* Demo: library */
.demo-library {
  background: var(--bg-1); border: 1px solid var(--border);
  border-radius: var(--r-lg); overflow: hidden;
}
.demo-lib-tabs {
  display: flex; gap: 0; border-bottom: 1px solid var(--border);
  padding: 0 16px;
}
.demo-tab {
  padding: 12px 14px; font-size: 12px; color: var(--text-3);
  border-bottom: 2px solid transparent; cursor: default;
}
.demo-tab.active { color: var(--accent); border-bottom-color: var(--accent); }
.demo-books { padding: 16px; display: flex; flex-direction: column; gap: 12px; }
.demo-book-card { display: flex; align-items: center; gap: 14px; }
.demo-book-cover {
  width: 44px; height: 62px; border-radius: 4px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  font-size: 22px;
}
.demo-book-info { flex: 1; min-width: 0; }
.demo-book-name { font-family: var(--font-serif); font-size: 13px; font-weight: 600; color: var(--text); }
.demo-book-author { font-size: 11px; color: var(--text-3); margin-bottom: 8px; }
.demo-progress-bar { height: 3px; background: var(--bg-3); border-radius: 2px; margin-bottom: 4px; }
.demo-progress-fill { height: 100%; background: var(--accent); border-radius: 2px; }
.demo-progress-label { font-size: 10px; color: var(--text-3); }

/* Demo: notes */
.demo-notes { display: flex; flex-direction: column; gap: 10px; }
.demo-note {
  background: var(--bg-1); border: 1px solid var(--border);
  border-radius: var(--r-lg); padding: 18px 20px;
}
.demo-note-title {
  font-family: var(--font-serif); font-size: 14px; font-weight: 600;
  color: var(--text); margin-bottom: 8px;
}
.demo-note-body {
  font-size: 13px; color: var(--text-2); line-height: 1.65;
  font-family: var(--font-serif); margin-bottom: 12px;
}
.demo-note-meta { font-size: 11px; color: var(--text-3); }

/* Interlude */
.interlude {
  border-top: 1px solid var(--border);
  padding: 72px 48px; text-align: center;
}
.interlude-quote {
  font-family: var(--font-serif); font-size: 22px; font-style: italic;
  color: var(--text-2); max-width: 600px; margin: 0 auto;
  line-height: 1.6; font-weight: 400;
}

/* CTA */
.cta-section {
  border-top: 1px solid var(--border);
  background: var(--bg-1); padding: 80px 32px;
}
.cta-inner { max-width: 560px; margin: 0 auto; text-align: center; }
.cta-title {
  font-family: var(--font-serif); font-size: 30px; font-weight: 600;
  line-height: 1.3; margin-bottom: 14px;
}
.cta-sub {
  font-size: 15px; color: var(--text-2); line-height: 1.7; margin-bottom: 32px;
}
.cta-actions { display: flex; align-items: center; justify-content: center; gap: 20px; flex-wrap: wrap; }

/* Footer */
.footer {
  display: flex; align-items: center; justify-content: center; gap: 10px;
  padding: 24px; border-top: 1px solid var(--border);
  font-size: 13px; color: var(--text-3);
}
.footer-sep { opacity: 0.4; }

/* Responsive */
@media (max-width: 768px) {
  .nav { padding: 16px 20px; }
  .hero { padding: 64px 24px 48px; }
  .hero-title { font-size: 36px; }
  .hero-sub { font-size: 15px; }
  .feature-section {
    grid-template-columns: 1fr;
    padding: 48px 24px;
    gap: 36px;
  }
  .feature-section--reversed { direction: ltr; }
  .interlude { padding: 48px 24px; }
  .interlude-quote { font-size: 18px; }
}
</style>
