<script lang="ts">
  import type { MedicalId } from '../../../lib/contracts/types';
  import { emergencySummary } from './summary';
  import qrcode from 'qrcode';

  let { medicalId }: { medicalId: MedicalId } = $props();

  let qrcodeSvg = $state('');

  $effect(() => {
    const summaryText = emergencySummary(medicalId);
    qrcode.toString(summaryText, { type: 'svg', margin: 1, width: 256 })
      .then(svg => {
        qrcodeSvg = svg;
      })
      .catch(err => {
        console.error('Failed to generate QR code', err);
      });
  });
</script>

<div class="qr-container">
  <p class="warning">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"></path><path d="M12 9v4"></path><path d="M12 17h.01"></path></svg>
    Cualquiera que escanee este código verá estos datos.
  </p>

  <div class="qr-code">
    {#if qrcodeSvg}
      {@html qrcodeSvg}
    {/if}
  </div>
</div>

<style>
  .qr-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 16px;
    margin-top: 16px;
  }

  .warning {
    color: var(--oh-danger);
    font-weight: 600;
    text-align: center;
    display: flex;
    align-items: center;
    gap: 8px;
    margin: 0;
  }

  .qr-code {
    background: #fff;
    padding: 16px;
    border-radius: var(--oh-radius);
    display: flex;
    justify-content: center;
    align-items: center;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  }

  :global(.qr-code svg) {
    display: block;
    max-width: 100%;
    height: auto;
  }
</style>
