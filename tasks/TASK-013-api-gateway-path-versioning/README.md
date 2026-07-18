---
type: task
id: TASK-013
title: "API Gateway Path Versioning — Root Path y API Prefix"
status: backlog
priority: high
created: "2026-05-06"
started: null
completed: null
tags: ["api_gateway", "routing", "versioning", "deployment"]
---

# TASK-013: API Gateway Path Versioning — Root Path y API Prefix

##  Descripción

Establecer una convención unificada de rutas para el API Gateway (`api_middleware`) que incluya:
1. **ROOT_PATH** — Prefijo base del gateway: `/api/middleware`
2. **Mount points** — Cada microservicio se monta en `/{ROOT_PATH}/{service_name}/`
3. **Versioning** — Cada microservicio maneja su propio prefijo `/v1` internamente (ya lo tienen)

**Valores por defecto (siempre)**:
- `ROOT_PATH = "/api/middleware"`
- CORS = `*`

Los servicios ya definen `router = APIRouter(prefix="/v1")`, por lo que la ruta completa queda:
```
/api/middleware/auth/v1/login
/api/middleware/iam/v1/permissions
/api/middleware/core/v1/people
```

## Objetivos

### api_middleware (Gateway)
- [ ] Agregar `ROOT_PATH: str = "/api/middleware"` a `api_middleware/app/settings/env.py`
- [ ] Actualizar `api_middleware/.env.example` con `ROOT_PATH=/api/middleware`
- [ ] Modificar `api_middleware/app/gateway.py` para construir mounts: `app.mount(f"{ROOT}/{service_name}", create_service())`
- [ ] Validar que Swagger refleje rutas con prefijo (ej: `/api/middleware/auth/v1/docs`)

### Microservicios Individuales (12 servicios)
Para cada servicio (`dh_auth`, `dh_iam`, `dh_core`, `dh_mfa`, `dh_onboarding`, `dh_health_monitoring`, `dh_storage`, `dh_admin`, `dh_organizations`, `dh_catalogs`, `dh_notify`, `dh_logger`):
- [ ] Agregar `ROOT_PATH: str = "/"` y `CORS_ORIGINS: list[str] = ["*"]` a `app/settings/env.py`
- [ ] Actualizar `.env.example` con `ROOT_PATH=/` y `CORS_ORIGINS=["*"]`
- [ ] Verificar que `app/main.py` tenga `CORSMiddleware` usando `settings.CORS_ORIGINS`
- [ ] Validar que el servicio opere correctamente con `ROOT_PATH="/"` (no afecta routers internos)

## Enlaces Rápidos

- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/)
- [Artefactos](artifacts/)

---

## Especificación de Rutas

### Estructura Final

```
/{ROOT_PATH}/{service_name}/v1/...
```

**Ejemplo con valores por defecto**:
```
/api/middleware/auth/v1/login
/api/middleware/iam/v1/roles
/api/middleware/core/v1/people
/api/middleware/organizations/v1/companies
```

**Nota**: El prefijo `/v1` lo define cada microservicio internamente (ya existe en sus routers). El gateway solo monta el servicio en `/{ROOT_PATH}/{service_name}/`.

---

##  Configuration Matrix

| Servicio | Gateway Mount Path | ROOT_PATH (default) | CORS (default) | Prioridad |
|----------|-------------------|---------------------|----------------|-----------|
| `dh_auth` | `/api/middleware/auth` | `/api/auth` | `["*"]` |  Alta |
| `dh_iam` | `/api/middleware/iam` | `/api/iam` | `["*"]` |  Alta |
| `dh_core` | `/api/middleware/core` | `/api/core` | `["*"]` |  Alta |
| `dh_mfa` | `/api/middleware/mfa` | `/api/mfa` | `["*"]` |  Media |
| `dh_onboarding` | `/api/middleware/onboarding` | `/api/onboarding` | `["*"]` |  Media |
| `dh_health_monitoring` | `/api/middleware/health_monitoring` | `/api/health_monitoring` | `["*"]` |  Media |
| `dh_storage` | `/api/middleware/storage` | `/api/storage` | `["*"]` |  Media |
| `dh_admin` | `/api/middleware/admin` | `/api/admin` | `["*"]` |  Baja |
| `dh_organizations` | `/api/middleware/organizations` | `/api/organizations` | `["*"]` |  Alta (Pendiente) |
| `dh_catalogs` | `/api/middleware/catalogs` | `/api/catalogs` | `["*"]` |  Media (Pendiente) |
| `dh_notify` | `/api/middleware/notify` | `/api/notify` | `["*"]` |  Baja (Testing) |
| `dh_logger` | `/api/middleware/logger` | `/api/logger` | `["*"]` |  Baja (Testing) |
| `api_middleware` (gateway) | N/A | `/api/middleware` | `["*"]` |  Alta |

**Nota**: El `ROOT_PATH` del servicio se usa solo cuando corre independiente (subdominio directo). Detrás del gateway, el path lo controla el gateway mediante `app.mount()`.

---

## Ejemplo de Configuración Completa

### api_middleware/.env (Docker)

```bash
# Docker Compose / Kubernetes inyecciona HOST/PORT via environment
ROOT_PATH=/api/middleware
SERVICE_AUTH_URL=http://dh_auth:8081
SERVICE_IAM_URL=http://dh_iam:8082
SERVICE_CORE_URL=http://dh_core:8083
SERVICE_MFA_URL=http://dh_mfa:8084
SERVICE_ONBOARDING_URL=http://dh_onboarding:8085
SERVICE_HEALTH_MONITORING_URL=http://dh_health_monitoring:8086
SERVICE_STORAGE_URL=http://dh_storage:8087
SERVICE_ADMIN_URL=http://dh_admin:8088
SERVICE_ORGANIZATIONS_URL=http://dh_organizations:8089
SERVICE_CATALOGS_URL=http://dh_catalogs:8090
SERVICE_NOTIFY_URL=http://dh_notify:8091
SERVICE_LOGGER_URL=http://dh_logger:8092
```

**Nota**: `HOST` y `PORT` son gestionados por Docker (expose + container_name). Las URLs de servicios usan nombres de contenedor DNS interno.

---

### dh_auth/.env (Docker)

```bash
DATABASE_URL=postgresql+asyncpg://...
JWT_SECRET=...
ROOT_PATH=/api/auth  # ← Usado cuando corre independiente (subdominio)
CORS_ORIGINS=["*"]    # ← Ajustar en producción
```

**Docker** maneja `HOST=0.0.0.0` y `PORT=8081` via `docker-compose.yml` o Kubernetes manifest.

---

### dh_core/.env (Docker)

```bash
DATABASE_URL=postgresql+asyncpg://...
ROOT_PATH=/api/core
CORS_ORIGINS=["*"]
```

---

### gateway.py (api_middleware/app/gateway.py)

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.settings import settings

app = FastAPI(title="API Gateway", ...)

# CORS — ajustar en producción
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

ROOT = settings.ROOT_PATH.rstrip("/")  # "/api/middleware"

# Montar cada servicio en /{ROOT}/{service_name}/
app.mount(f"{ROOT}/auth", create_auth())
app.mount(f"{ROOT}/iam", create_iam())
app.mount(f"{ROOT}/core", create_core())
app.mount(f"{ROOT}/mfa", create_mfa())
app.mount(f"{ROOT}/onboarding", create_onboarding())
app.mount(f"{ROOT}/health_monitoring", create_health_monitoring())
app.mount(f"{ROOT}/storage", create_storage())
app.mount(f"{ROOT}/admin", create_admin())
app.mount(f"{ROOT}/organizations", create_organizations())
app.mount(f"{ROOT}/catalogs", create_catalogs())
app.mount(f"{ROOT}/notify", create_notify())
app.mount(f"{ROOT}/logger", create_logger())
```

**Resultado** (Docker network):
- Gateway Swagger: `http://localhost:8000/api/middleware/docs` (puerto mapeado docker → host)
- Auth endpoints: `http://localhost:8000/api/middleware/auth/v1/login`
- Core endpoints: `http://localhost:8000/api/middleware/core/v1/people`

**Nota**: En Docker, los `SERVICE_*_URL` usan nombres de contenedor (ej: `http://dh_auth:8081`) como DNS interno.
