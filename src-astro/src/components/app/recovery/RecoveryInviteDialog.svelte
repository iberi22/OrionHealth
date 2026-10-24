<script lang="ts">
  import { onMount } from 'svelte';
  import QRCode from 'qrcode';
  
  let {
    inviteUrl = '',
    memberName = '',
    onClose
  } = $props<{
    inviteUrl: string;
    memberName: string;
    onClose: () => void;
  }>();

  let qrCodeDataUrl = $state('');

  onMount(async () => {
    if (inviteUrl) {
      try {
        qrCodeDataUrl = await QRCode.toDataURL(inviteUrl, { margin: 1, width: 250 });
      } catch (err) {
        console.error(err);
      }
    }
  });
</script>

<div class="overlay" onclick={onClose}>
  <div class="dialog" onclick={(e) => e.stopPropagation()}>
    <h2>Invitación de recuperación para {memberName}</h2>
    <p>Comparte este enlace o pide al miembro que escanee el código QR con su nuevo dispositivo.</p>
    
    <div class="qr-container">
      {#if qrCodeDataUrl}
        <img src={qrCodeDataUrl} alt="QR Code" />
      {:else}
        <p>Generando QR...</p>
      {/if}
    </div>
    
    <div class="url-container">
      <input class="recovery-invite-url" type="text" readonly value={inviteUrl} aria-label="Enlace de recuperación" />
      <button class="copy-btn" onclick={() => navigator.clipboard.writeText(inviteUrl)}>Copiar</button>
    </div>
    
    <div class="actions">
      <button class="primary" onclick={onClose}>Cerrar</button>
    </div>
  </div>
</div>

<style>
  .overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }
  .dialog {
    background: var(--oh-surface, #fff);
    padding: 2rem;
    border-radius: var(--oh-radius, 8px);
    max-width: 400px;
    width: 90%;
    color: var(--oh-text, #333);
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  }
  h2 {
    margin-top: 0;
    font-size: 1.2rem;
  }
  .qr-container {
    display: flex;
    justify-content: center;
    margin: 1.5rem 0;
  }
  .url-container {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 1.5rem;
  }
  input {
    flex: 1;
    padding: 0.5rem;
    border: 1px solid var(--oh-muted, #ccc);
    border-radius: var(--oh-radius, 4px);
    background: var(--oh-bg, #f9f9f9);
    color: var(--oh-text, #333);
  }
  .actions {
    display: flex;
    justify-content: flex-end;
  }
  button {
    padding: 0.5rem 1rem;
    border: none;
    border-radius: var(--oh-radius, 4px);
    cursor: pointer;
    font: inherit;
  }
  button.primary {
    background: var(--oh-accent, #007bff);
    color: #fff;
  }
  button.copy-btn {
    background: var(--oh-secondary, #6c757d);
    color: #fff;
  }
</style>
