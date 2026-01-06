# MCP Server Implementation - Setup Instructions

## 📁 Directory Structure Required

The MCP server requires the following directory structure to be created:

```
orionhealth/rust/src/
└── mcp/
    ├── mod.rs
    ├── protocol.rs
    ├── server.rs
    ├── auth.rs
    ├── sse.rs
    └── tools/
        ├── mod.rs
        ├── search.rs
        ├── summary.rs
        ├── records.rs
        └── vitals.rs
```

## 🚀 Quick Setup (Run this command)

### Windows (PowerShell):
```powershell
# Navigate to project root
cd e:\scripts-python\orionhealth

# Create directories
New-Item -ItemType Directory -Path "rust\src\mcp\tools" -Force

# Verify
Get-ChildItem "rust\src\mcp" -Recurse
```

### Windows (CMD):
```cmd
cd /d e:\scripts-python\orionhealth
mkdir rust\src\mcp\tools
dir rust\src\mcp
```

### Linux/macOS:
```bash
cd /path/to/orionhealth
mkdir -p rust/src/mcp/tools
ls -la rust/src/mcp
```

## 📝 Files to Create

After creating the directories, the following files need to be created with the implementation provided in the specification.

### 1. `rust/src/mcp/mod.rs`
Module exports and re-exports

### 2. `rust/src/mcp/protocol.rs`
JSON-RPC 2.0 protocol types (327 lines - READY)

### 3. `rust/src/mcp/auth.rs`
Token-based authentication middleware

### 4. `rust/src/mcp/sse.rs`
Server-Sent Events transport

### 5. `rust/src/mcp/server.rs`
Axum HTTP server setup

### 6. `rust/src/mcp/tools/mod.rs`
Tool registry and dispatcher

### 7. `rust/src/mcp/tools/search.rs`
Search medical records tool

### 8. `rust/src/mcp/tools/summary.rs`
Generate health summary tool

### 9. `rust/src/mcp/tools/records.rs`
Add medical record tool

### 10. `rust/src/mcp/tools/vitals.rs`
Get vital trends tool

## 🔧 Dependencies Added

The following dependencies have been added to `Cargo.toml`:

```toml
# MCP Server
axum = "0.7"
tower = "0.4"
tower-http = { version = "0.5", features = ["cors", "trace"] }
tokio-stream = "0.1"
```

## ✅ Status

- [x] Dependencies added to Cargo.toml
- [ ] Directory structure created (MANUAL STEP REQUIRED)
- [x] Protocol types implemented (ready to copy)
- [ ] Auth middleware (pending)
- [ ] SSE transport (pending)
- [ ] Server setup (pending)
- [ ] Tools implementation (pending)

## 📋 Next Steps

1. **Create the directory structure** using one of the commands above
2. **Copy protocol.rs implementation** from MCP_PROTOCOL_IMPLEMENTATION.md
3. **Continue with auth.rs** (authentication middleware)
4. **Implement SSE transport** in sse.rs
5. **Setup Axum server** in server.rs
6. **Implement tools** in tools/ directory

## 🆘 Troubleshooting

### Issue: "Parent directory does not exist"
**Solution:** Run the directory creation command first before attempting to create files.

### Issue: "Permission denied"
**Solution:** Run terminal as Administrator (Windows) or use `sudo` (Linux/macOS).

### Issue: "Path not found"
**Solution:** Verify you're in the correct project directory (`orionhealth/`).

---

**Created:** 2026-01-06
**Status:** Waiting for manual directory creation
**Next Action:** Execute directory creation command, then proceed with file implementation
