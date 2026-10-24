<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import { navigate } from '../routes';

  const services = getServices();

  // We should read actual settings from somewhere if they exist, but for now
  // let's try reading from localStorage or default values.
  let autoLockMinutes = $state(5);
  let theme = $state('system');
  let lang = $state('es');

  // init from localStorage where possible
  try {
    const savedTheme = localStorage.getItem('oh-theme');
    if (savedTheme) theme = savedTheme;

    const params = new URLSearchParams(window.location.search);
    const savedLang = params.get('lang');
    if (savedLang) lang = savedLang;
  } catch (e) {
    // ignore
  }

  function handleAutoLockChange(e: Event) {
    const min = parseInt((e.target as HTMLSelectElement).value, 10);
    autoLockMinutes = min;
    services.vault.setAutoLockMinutes(min);
  }

  function handleThemeChange(e: Event) {
    const t = (e.target as HTMLSelectElement).value;
    theme = t;
    try {
      localStorage.setItem('oh-theme', t);
      if (t === 'dark') {
        document.documentElement.setAttribute('data-theme', 'dark');
      } else if (t === 'light') {
        document.documentElement.removeAttribute('data-theme');
      } else {
        // system
        if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
           document.documentElement.setAttribute('data-theme', 'dark');
        } else {
           document.documentElement.removeAttribute('data-theme');
        }
      }
    } catch(e) {}
  }

  function handleLangChange(e: Event) {
    const l = (e.target as HTMLSelectElement).value;
    lang = l;

    // Spec says reuse `?lang=` if src/i18n/ui.ts exists, otherwise local state.
    // We update URL params to be safe, which keeps local state too.
    try {
      const url = new URL(window.location.href);
      url.searchParams.set('lang', l);
      window.history.replaceState({}, '', url.toString());
    } catch(e) {}
  }

  function lockNow() {
    services.vault.lock();
    navigate('/app/lock');
  }

  function openOnboarding() {
    navigate('/app/onboarding');
  }
</script>

<section data-testid="area-settings" class="settings-area">
  <header>
    <h1>Ajustes</h1>
  </header>

  <div class="settings-group">
    <h2>Seguridad</h2>
    <div class="setting-item">
      <label for="autolock">Bloqueo automático</label>
      <select id="autolock" value={autoLockMinutes} onchange={handleAutoLockChange}>
        <option value={1}>1 minuto</option>
        <option value={5}>5 minutos</option>
        <option value={15}>15 minutos</option>
      </select>
    </div>

    <div class="setting-item">
      <button class="danger-btn" onclick={lockNow}>Bloquear ahora</button>
    </div>
  </div>

  <div class="settings-group">
    <h2>Apariencia</h2>
    <div class="setting-item">
      <label for="theme">Tema</label>
      <select id="theme" value={theme} onchange={handleThemeChange}>
        <option value="system">Sistema</option>
        <option value="light">Claro</option>
        <option value="dark">Oscuro</option>
      </select>
    </div>
    <div class="setting-item">
      <label for="lang">Idioma</label>
      <select id="lang" value={lang} onchange={handleLangChange}>
        <option value="es">Español</option>
        <option value="en">English</option>
      </select>
    </div>
  </div>

  <div class="settings-group">
    <h2>Acerca de</h2>
    <div class="setting-item">
      <button class="secondary-btn" onclick={openOnboarding}>Cómo funciona</button>
    </div>
    <div class="setting-item about-text">
      <p>OrionHealth v1.0.0</p>
      <p>Tus datos son tuyos. Encriptados de extremo a extremo.</p>
    </div>
  </div>
</section>

<style>
  .settings-area {
    padding: 16px;
    max-width: 600px;
    margin: 0 auto;
    color: var(--oh-text);
  }
  header {
    margin-bottom: 24px;
  }
  h1 {
    margin: 0;
  }
  .settings-group {
    background-color: var(--oh-surface);
    border-radius: var(--oh-radius);
    padding: 16px;
    margin-bottom: 24px;
  }
  .settings-group h2 {
    margin: 0 0 16px 0;
    font-size: 1.2em;
    color: var(--oh-muted);
  }
  .setting-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
  }
  .setting-item:last-child {
    margin-bottom: 0;
  }
  label {
    font-weight: 500;
  }
  select {
    padding: 8px 12px;
    border-radius: var(--oh-radius);
    border: 1px solid var(--oh-muted);
    background-color: var(--oh-bg);
    color: var(--oh-text);
    font-size: 1rem;
  }
  button {
    padding: 10px 16px;
    border: none;
    border-radius: var(--oh-radius);
    cursor: pointer;
    font-weight: 500;
    font-size: 1rem;
    width: 100%;
    text-align: center;
  }
  .danger-btn {
    background-color: var(--oh-danger);
    color: white;
  }
  .secondary-btn {
    background-color: var(--oh-secondary);
    color: white;
  }
  .about-text {
    flex-direction: column;
    align-items: flex-start;
    color: var(--oh-muted);
    font-size: 0.9em;
    gap: 4px;
  }
  .about-text p {
    margin: 0;
  }
</style>
