# IHCE Gateway Backend

Este backend actúa como un gateway seguro para la Historia Clínica Electrónica Interoperable (IHCE) de Colombia, permitiendo la autenticación vía OAuth 2.0 y la consulta de recursos FHIR R4.

## Características

- **OAuth 2.0 Flow**: Implementación completa del flujo de autorización contra el servidor de identidad de IHCE.
- **FHIR R4 Client**: Cliente optimizado para interactuar con APIs de salud basadas en el estándar FHIR R4.
- **RDA Parser**: Extracción y simplificación del Resumen Digital de Atención (RDA).
- **Seguridad**: Encriptación de tokens (AES-256-CBC) en reposo.
- **Cumplimiento**: Alineado con la Resolución 1888 de 2025 y la Guía FHIR Core Colombia.

## Estructura del Proyecto

```
backend/
├── src/
│   ├── auth/           # Lógica de OAuth y Criptografía
│   ├── fhir/           # Cliente FHIR y Parsers
│   └── server.js       # Servidor Express y Rutas
├── .env.example        # Variables de entorno
└── package.json        # Dependencias
```

## Configuración

1. Clonar el repositorio y navegar a `backend/`
2. Instalar dependencias: `npm install`
3. Copiar `.env.example` a `.env` y configurar las credenciales de IHCE.
4. Iniciar el servidor: `npm run dev`

## Endpoints

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/auth/ihce/login` | Inicia el flujo OAuth 2.0 |
| GET | `/api/auth/ihce/callback` | Callback de OAuth, intercambia código por token |
| GET | `/api/fhir/patient/:id` | Obtiene el recurso FHIR Patient por ID |
| GET | `/api/fhir/rda` | Obtiene el Resumen Digital de Atención (RDA) del paciente |

## Guías de Referencia

- [FHIR Core Colombia](https://co.fhir.guide/core/)
- [Resolución 1888 de 2025](https://www.minsalud.gov.co/Paginas/Resolucion-1888-de-2025.aspx)
