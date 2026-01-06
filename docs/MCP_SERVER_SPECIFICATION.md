# MCP Server Implementation Specification

**Issue:** #1 - [MCP] Implementar Servidor MCP en Rust
**Priority:** 🔴 HIGH
**Status:** 📋 Planning
**Estimated Effort:** 2-3 weeks

---

## Overview

Implementar un servidor **Model Context Protocol (MCP)** en Rust que exponga las capacidades médicas de OrionHealth a editores de código (Zed, VS Code) y agentes IA (Claude Desktop).

### What is MCP?

MCP (Model Context Protocol) es un protocolo estándar abierto que permite a las aplicaciones IA acceder a contexto externo de manera segura y estandarizada.

**Specification:** https://modelcontextprotocol.io/

---

## User Stories

### Primary User Story
> "Como desarrollador de agentes IA, quiero que OrionHealth exponga sus capacidades médicas vía MCP para integrarlas en editores/herramientas de desarrollo."

### Scenarios:

**Scenario 1: Zed Editor Integration**
```
Given: OrionHealth MCP server está corriendo
When: Usuario abre Zed Editor y escribe "busca registros de hipertensión"
Then: Zed invoca el tool search_medical_records()
And: OrionHealth retorna registros relevantes
And: Zed muestra resultados en el editor
```

**Scenario 2: Claude Desktop**
```
Given: Claude Desktop conectado a OrionHealth MCP
When: Usuario pregunta "resume mi salud del último mes"
Then: Claude invoca generate_health_summary(start_date, end_date)
And: OrionHealth genera resumen con LLM local/cloud
And: Claude presenta el resumen al usuario
```

**Scenario 3: Custom Agent**
```
Given: Agente personalizado se conecta vía MCP
When: Agente solicita add_medical_record(content, type)
Then: OrionHealth valida y almacena el registro
And: Retorna confirmación con ID del registro
```

---

## Technical Requirements

### 1. Protocol Implementation

**MCP Version:** 1.0 (latest stable)

**Transport:** Server-Sent Events (SSE) over HTTP

**Message Format:** JSON-RPC 2.0

**Authentication:** Token-based (Bearer)

### 2. Exposed Tools (Resources)

#### Tool 1: `search_medical_records`
**Purpose:** Buscar registros médicos con búsqueda inteligente

**Input Schema:**
```json
{
  "name": "search_medical_records",
  "description": "Busca registros médicos usando búsqueda semántica",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Texto de búsqueda (ej: 'hipertensión', 'glucosa alta')"
      },
      "date_range": {
        "type": "object",
        "properties": {
          "start": { "type": "string", "format": "date" },
          "end": { "type": "string", "format": "date" }
        }
      },
      "limit": {
        "type": "integer",
        "default": 10,
        "description": "Número máximo de resultados"
      }
    },
    "required": ["query"]
  }
}
```

**Output:**
```json
{
  "results": [
    {
      "id": "uuid",
      "content": "Consulta general - PA 140/90",
      "date": "2024-01-15",
      "type": "consultation",
      "relevance_score": 0.95
    }
  ],
  "total": 5,
  "strategy_used": "BM25"
}
```

---

#### Tool 2: `generate_health_summary`
**Purpose:** Generar resumen de salud para un período

**Input Schema:**
```json
{
  "name": "generate_health_summary",
  "description": "Genera un resumen de salud usando LLM local o cloud",
  "inputSchema": {
    "type": "object",
    "properties": {
      "start_date": { "type": "string", "format": "date" },
      "end_date": { "type": "string", "format": "date" },
      "type": {
        "type": "string",
        "enum": ["daily", "weekly", "monthly", "quarterly"],
        "default": "weekly"
      }
    },
    "required": ["start_date", "end_date"]
  }
}
```

**Output:**
```json
{
  "summary": "Resumen Semanal de Salud...",
  "period": "2024-01-01 to 2024-01-07",
  "records_count": 12,
  "llm_adapter_used": "Cloud",
  "insights": [
    "Presión arterial estable",
    "Glucosa dentro de rango normal"
  ]
}
```

---

#### Tool 3: `add_medical_record`
**Purpose:** Agregar nuevo registro médico

**Input Schema:**
```json
{
  "name": "add_medical_record",
  "description": "Agrega un nuevo registro médico a la base de datos",
  "inputSchema": {
    "type": "object",
    "properties": {
      "content": {
        "type": "string",
        "description": "Contenido del registro médico"
      },
      "type": {
        "type": "string",
        "enum": ["consultation", "lab_result", "medication", "vital_signs"],
        "description": "Tipo de registro"
      },
      "date": {
        "type": "string",
        "format": "date-time",
        "description": "Fecha del registro (ISO 8601)"
      },
      "metadata": {
        "type": "object",
        "description": "Metadatos adicionales (opcional)"
      }
    },
    "required": ["content", "type"]
  }
}
```

**Output:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "created",
  "embedding_generated": true
}
```

---

#### Tool 4: `get_vital_trends`
**Purpose:** Obtener tendencias de signos vitales

**Input Schema:**
```json
{
  "name": "get_vital_trends",
  "description": "Obtiene tendencias de un signo vital específico",
  "inputSchema": {
    "type": "object",
    "properties": {
      "vital_type": {
        "type": "string",
        "enum": ["blood_pressure", "glucose", "weight", "heart_rate", "temperature"],
        "description": "Tipo de signo vital"
      },
      "period": {
        "type": "string",
        "enum": ["week", "month", "quarter", "year"],
        "default": "month"
      }
    },
    "required": ["vital_type"]
  }
}
```

**Output:**
```json
{
  "vital_type": "blood_pressure",
  "period": "month",
  "data_points": [
    { "date": "2024-01-01", "systolic": 120, "diastolic": 80 },
    { "date": "2024-01-08", "systolic": 125, "diastolic": 82 }
  ],
  "trend": "stable",
  "average": { "systolic": 122, "diastolic": 81 }
}
```

---

### 3. Architecture

```
┌─────────────────────────────────────────┐
│  MCP Client (Zed, Claude Desktop)       │
└────────────┬────────────────────────────┘
             │ JSON-RPC 2.0 over SSE
             │
┌────────────▼────────────────────────────┐
│  MCP Server (Rust - axum HTTP)          │
│  ┌─────────────────────────────────┐    │
│  │ Authentication Middleware       │    │
│  │ (Bearer Token)                  │    │
│  └────────────┬────────────────────┘    │
│               │                          │
│  ┌────────────▼────────────────────┐    │
│  │ JSON-RPC Handler                │    │
│  │ (method dispatch)               │    │
│  └────────────┬────────────────────┘    │
│               │                          │
│  ┌────────────▼────────────────────┐    │
│  │ Tool Registry                   │    │
│  │  - search_medical_records       │    │
│  │  - generate_health_summary      │    │
│  │  - add_medical_record           │    │
│  │  - get_vital_trends             │    │
│  └────────────┬────────────────────┘    │
└───────────────┼─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│  OrionHealth Core (existing modules)    │
│  ┌────────────────────────────────┐     │
│  │ Search Service (search.rs)     │     │
│  │ Health Service (health.rs)     │     │
│  │ Vector Store (vector_store.rs) │     │
│  │ Database (database.rs)         │     │
│  │ Smart LLM Manager (llm/)       │     │
│  └────────────────────────────────┘     │
└─────────────────────────────────────────┘
```

---

### 4. File Structure

```
orionhealth/rust/src/
├── mcp/
│   ├── mod.rs                    # Module exports
│   ├── server.rs                 # MCP server setup (axum)
│   ├── protocol.rs               # JSON-RPC 2.0 types
│   ├── auth.rs                   # Token authentication
│   ├── tools/
│   │   ├── mod.rs                # Tool registry
│   │   ├── search.rs             # search_medical_records
│   │   ├── summary.rs            # generate_health_summary
│   │   ├── records.rs            # add_medical_record
│   │   └── vitals.rs             # get_vital_trends
│   └── sse.rs                    # Server-Sent Events transport
└── lib.rs                        # Add: pub mod mcp;
```

---

### 5. Dependencies (Cargo.toml)

```toml
[dependencies]
# Existing dependencies...

# MCP Server
axum = "0.7"                        # HTTP framework
tower = "0.4"                       # Middleware
tower-http = { version = "0.5", features = ["cors", "trace"] }
tokio-stream = "0.1"                # SSE streaming
serde_json = "1.0"                  # Already exists
uuid = { version = "1.11", features = ["v4"] }  # Already exists

# Optional: If using official MCP SDK (if available)
# mcp-sdk = "0.1"  # Check crates.io
```

---

## Implementation Plan

### Phase 1: Protocol Layer (Week 1)

**Tasks:**
1. [ ] Create `mcp/protocol.rs` with JSON-RPC 2.0 types
2. [ ] Implement `JsonRpcRequest`, `JsonRpcResponse`, `JsonRpcError`
3. [ ] Create `mcp/server.rs` with axum HTTP server
4. [ ] Implement SSE transport in `mcp/sse.rs`
5. [ ] Add authentication middleware in `mcp/auth.rs`
6. [ ] Unit tests for protocol serialization

**Deliverable:** Basic MCP server that responds to ping

---

### Phase 2: Tool Implementation (Week 2)

**Tasks:**
1. [ ] Create tool registry in `mcp/tools/mod.rs`
2. [ ] Implement `search_medical_records` tool
3. [ ] Implement `generate_health_summary` tool
4. [ ] Implement `add_medical_record` tool
5. [ ] Implement `get_vital_trends` tool
6. [ ] Integration tests for each tool

**Deliverable:** All 4 tools functional and tested

---

### Phase 3: Integration & Testing (Week 3)

**Tasks:**
1. [ ] Connect MCP server to OrionHealth core
2. [ ] End-to-end tests with real database
3. [ ] Performance benchmarks (latency, throughput)
4. [ ] Zed Editor configuration file
5. [ ] Documentation and examples
6. [ ] Security audit (token handling, CORS)

**Deliverable:** Production-ready MCP server

---

## Testing Strategy

### Unit Tests
```rust
#[tokio::test]
async fn test_jsonrpc_request_parsing() {
    let json = r#"{"jsonrpc":"2.0","method":"search","id":1}"#;
    let req: JsonRpcRequest = serde_json::from_str(json).unwrap();
    assert_eq!(req.method, "search");
}
```

### Integration Tests
```rust
#[tokio::test]
async fn test_search_tool_integration() {
    let app = create_test_app().await;
    let response = app
        .oneshot(Request::builder()
            .uri("/mcp")
            .method("POST")
            .header("Authorization", "Bearer test-token")
            .body(json!({
                "jsonrpc": "2.0",
                "method": "tools/call",
                "params": {
                    "name": "search_medical_records",
                    "arguments": { "query": "hipertensión" }
                },
                "id": 1
            }))
            .unwrap())
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
}
```

### End-to-End Tests (with Zed)
```bash
# Manual test with Zed Editor
1. Start MCP server: cargo run --bin orionhealth-mcp
2. Configure Zed: ~/.config/zed/settings.json
3. Open Zed and trigger MCP tool
4. Verify response in editor
```

---

## Configuration

### Server Configuration (orionhealth-mcp.toml)
```toml
[server]
host = "127.0.0.1"
port = 8765
log_level = "info"

[auth]
token = "generated-random-token-here"  # Or read from env
token_expiry_days = 7

[cors]
allowed_origins = ["http://localhost:*"]

[tools]
# Enable/disable specific tools
search_enabled = true
summary_enabled = true
add_record_enabled = true
vitals_enabled = true
```

### Zed Editor Configuration (~/.config/zed/settings.json)
```json
{
  "context_servers": {
    "orionhealth": {
      "command": "orionhealth-mcp",
      "args": ["--config", "~/.orionhealth/mcp.toml"],
      "env": {
        "ORIONHEALTH_TOKEN": "${ORIONHEALTH_TOKEN}"
      }
    }
  }
}
```

---

## Security Considerations

### Authentication
- ✅ Bearer token required for all requests
- ✅ Token rotation every 7 days
- ✅ Tokens stored securely (never in code)

### Data Privacy
- ⚠️ Medical data exposed via network (localhost only by default)
- ✅ CORS restricted to localhost
- ✅ No logging of sensitive medical content

### Rate Limiting
- Implement rate limiting: 100 requests/minute per token
- Prevent abuse of cloud LLM API

---

## Performance Targets

| Metric | Target | Rationale |
|--------|--------|-----------|
| Tool invocation latency | < 100ms | Excludes LLM generation |
| Search response time | < 50ms | Database query + ranking |
| Summary generation | < 5s | Includes LLM inference |
| Concurrent connections | 10 | Single-user desktop app |
| SSE message throughput | 100 msg/s | Real-time updates |

---

## Monitoring & Logging

### Structured Logging (tracing)
```rust
use tracing::{info, warn, error};

#[tracing::instrument]
async fn handle_tool_call(tool_name: &str, params: Value) -> Result<Value> {
    info!("Tool invoked: {}", tool_name);
    // ...
    Ok(result)
}
```

### Metrics to Track
- Tool invocation count (per tool)
- Average response time
- Error rate (by error type)
- LLM adapter usage (local vs cloud)

---

## Documentation Deliverables

1. **`docs/MCP_SERVER_GUIDE.md`**
   - Installation instructions
   - Configuration reference
   - Tool API documentation
   - Troubleshooting

2. **`docs/ZED_INTEGRATION.md`**
   - Zed Editor setup
   - Example workflows
   - Keyboard shortcuts
   - Video tutorial (screencast)

3. **`examples/mcp_client_test.rs`**
   - Programmatic MCP client
   - Test all tools
   - Demonstration code

---

## Definition of Done

### Functional Requirements
- [ ] All 4 tools implemented and working
- [ ] SSE transport functional
- [ ] Token authentication enforced
- [ ] CORS configured correctly
- [ ] Error handling comprehensive

### Non-Functional Requirements
- [ ] Tool latency < 100ms (excluding LLM)
- [ ] 100% uptime during single-user session
- [ ] Memory leak free (valgrind/ASAN)
- [ ] Zero security vulnerabilities (cargo audit)

### Documentation
- [ ] User guide published
- [ ] API reference complete
- [ ] Zed integration guide with video
- [ ] Example code provided

### Testing
- [ ] 10+ unit tests (protocol layer)
- [ ] 4 integration tests (one per tool)
- [ ] End-to-end test with Zed Editor
- [ ] Performance benchmarks documented

---

## Risks & Mitigations

### Risk 1: MCP Spec Changes
**Mitigation:** Pin to MCP version 1.0, monitor spec updates

### Risk 2: SSE Browser Compatibility
**Mitigation:** Use standard SSE format, test with multiple clients

### Risk 3: Token Security
**Mitigation:** Never log tokens, use env vars, implement rotation

### Risk 4: Performance Bottleneck
**Mitigation:** Profile with `cargo flamegraph`, optimize hot paths

---

## Success Metrics

### Adoption
- ✅ At least 1 successful Zed Editor integration
- ✅ Documentation rated 4/5+ by test users

### Performance
- ✅ 95th percentile tool latency < 200ms
- ✅ Zero crashes in 48-hour stress test

### Quality
- ✅ Code coverage > 80%
- ✅ Zero critical security issues
- ✅ Passes all integration tests

---

## References

- **MCP Specification:** https://modelcontextprotocol.io/
- **Zed MCP Guide:** https://zed.dev/docs/extensions/context-servers
- **JSON-RPC 2.0 Spec:** https://www.jsonrpc.org/specification
- **axum Documentation:** https://docs.rs/axum/latest/axum/
- **SSE Spec:** https://html.spec.whatwg.org/multipage/server-sent-events.html

---

**Prepared by:** GitHub Copilot (Claude Sonnet 4.5)
**Date:** 2026-01-06
**Status:** 📋 Specification Complete - Ready for Implementation
**Next Action:** Begin Phase 1 (Protocol Layer)
