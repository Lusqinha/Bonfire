import '../assets/app.css'
import { createApp, h } from 'vue'
import { createInertiaApp } from '@inertiajs/vue3'

createInertiaApp({
  resolve: name => {
    const pages = import.meta.glob('../pages/**/*.vue', { eager: true })
    const page = pages[`../pages/${name}.vue`]
    if (!page) throw new Error(`Page not found: ${name}`)
    return page
  },
  setup({ el, App, props, plugin }) {
    createApp({ render: () => h(App, props) })
      .use(plugin)
      .mount(el)
  },
}).catch(e => {
  console.error('[Inertia] Failed to initialize:', e)
  document.body.innerHTML = `<pre style="color:red;padding:20px">${e.message}\n${e.stack}</pre>`
})
