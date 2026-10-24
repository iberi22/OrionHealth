<script lang="ts">
  import { onMount } from 'svelte';
  import QRCode from 'qrcode';
  import { getServices } from '../../../lib/contracts/services';

  let { onClose } = $props<{ onClose: () => void }>();

  const services = getServices();
  let inviteUrl = $state('');
  let qrCodeDataUrl = $state('');
  let loading = $state(true);

  onMount(async () => {
    loading = true;
    const ticket = await services.family.createInvite();
    inviteUrl = ticket.url;
    try {
      qrCodeDataUrl = await QRCode.toDataURL(inviteUrl, { width: 200, margin: 2 });
    } catch (e) {
      console.error(e);
    }
    loading = false;
  });

  function copyUrl() {
    navigator.clipboard.writeText(inviteUrl);
  }
</script>

<div class="dialog">
  <div class="dialog-content">
    <h2>Invitar miembro</h2>

    {#if loading}
      <p>Generando invitación...</p>
    {:else}
      <p>Muestra este código QR al familiar que deseas invitar, o envíale el enlace.</p>

      <div class="qr-container">
        {#if qrCodeDataUrl}
          <img src={qrCodeDataUrl} alt="Código QR de invitación" />
        {/if}
      </div>

      <div class="url-container">
        <input type="text" readonly value={inviteUrl} />
        <button aria-label="Copiar enlace" onclick={copyUrl}>Copiar</button>
      </div>
    {/if}

    <div class="dialog-actions">
      <button onclick={onClose}>Cerrar</button>
    </div>
  </div>
</div>

<style>
  .dialog {
    position: fixed;
    top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(0,0,0,0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 100;
  }
  .dialog-content {
    background: var(--oh-bg);
    padding: 2rem;
    border-radius: var(--oh-radius);
    max-width: 400px;
    width: 90%;
    text-align: center;
  }
  .qr-container {
    margin: 1.5rem 0;
    display: flex;
    justify-content: center;
  }
  .url-container {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 1.5rem;
  }
  input {
    flex: 1;
    padding: 0.5rem;
    border: 1px solid var(--oh-muted);
    border-radius: 4px;
    background: var(--oh-surface);
    color: var(--oh-text);
  }
  button {
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 4px;
    background: var(--oh-accent);
    color: white;
    cursor: pointer;
  }
  .dialog-actions {
    display: flex;
    justify-content: flex-end;
  }
</style>
