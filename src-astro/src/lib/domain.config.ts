export const domainConfig = {
  appId: 'orionhealth-web',
  appName: 'orionhealth-web',
  instanceId: 'default',
  entities: [
    {
        name: "record",
        label: "Record",
        fields: [
            "name",
            "status"
        ],
        xavierKind: "record"
    },
    {
        name: "medication",
        label: "Medication",
        fields: [
            "name",
            "status"
        ],
        xavierKind: "medication"
    },
    {
        name: "appointment",
        label: "Appointment",
        fields: [
            "name",
            "status"
        ],
        xavierKind: "appointment"
    },
    {
        name: "vitals",
        label: "Vitals",
        fields: [
            "name",
            "status"
        ],
        xavierKind: "vitals"
    },
    {
        name: "emergency",
        label: "Emergency",
        fields: [
            "name",
            "status"
        ],
        xavierKind: "emergency"
    },
    {
        name: "allergy",
        label: "Allergy",
        fields: [
            "name",
            "status"
        ],
        xavierKind: "allergy"
    }
],
  aui: {
    enabled: true,
    allowAgentTheme: true,
  },
  // pay-per-use 5% + mesh-only gratis: 1 camion = 100 camiones mismo precio (solo consumo R2/D1/AI)
  // mesh-only: 0$ (datos P2P Yjs replicados en otros nodos gara-g sin Cloudflare)
  // payg: infra 100% + AI*1.10 + 5% handling, sin fee por vehiculo/entidad
  billing: {
    tier: 'payg' as const, // 'free' | 'mesh-only' | 'payg' | 'payg-managed'
    mode: 'swal-managed' as const, // 'mesh-only' | 'self-managed' | 'swal-managed'
  },
} as const;
export type DomainConfig = typeof domainConfig;
