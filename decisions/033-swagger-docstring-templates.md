# ADR 033: Docstrings Swagger — Template y Placeholders para `FastAPI(description=__doc__)`

## Estado
Aceptado

## Contexto

Todo `FastAPI()` y `APIRouter()` acepta `description=__doc__` para poblar Swagger UI con Markdown. El proyecto ya tiene:
- **ADR 025** — cada microservicio debe tener test UI (`GET /`)
- **ADR 027** — sub-apps del middleware enlazan a la test UI del backend via `SERVICE_<NAME>_URL`
- **Rule `PYTHON_FASTAPI_DOCSTRINGS`** — routers usan `description=__doc__`

Pero no esta formalizado el **formato del docstring** — que secciones van, en que orden, ni que significa cada placeholder. Frontend y mobile leen esto como contrato.

## Decision

Dos templates obligatorios segun el tipo de servicio.

### Template A — Kernel / Gateway (FastAPI principal, no es sub-app)

```python
"""<Service Name> — <One-line purpose>.

## Overview

<1-2 parrafos describiendo responsabilidad. Mencionar esquemas DB que posee
si aplica. Mencionar si es stateless/proxy.>

## Services  ← solo si es gateway (api_middleware); si no, usar ## Endpoints

| Service | Status | Docs | Prefix |
|---------|--------|------|--------|
| Auth | RELEASED | [{root_path}/auth/docs]({root_path}/auth/docs) | `/auth` |
| IAM | RELEASED | [{root_path}/iam/docs]({root_path}/iam/docs) | `/iam` |
| ... | ... | ... | ... |

## Endpoints  ← si NO es gateway, listar grupos de endpoints

- <Verb> /path — <descripcion breve>

## Dependencies  ← opcional pero recomendado

- **PostgreSQL**: <schemas que usa>
- **<otro servicio>**: <que le pide>
"""
```

**Placeholders Template A:**

| Variable | Se reemplaza con | Ejemplo |
|---|---|---|
| `{root_path}` | `settings.ROOT_PATH.rstrip("/")` | `/api/middleware` |

---

### Template B — Sub-app / Mount proxy (api_middleware/app/microservices/*/app.py)

```python
"""<Service Name> — <One-line purpose>.

## Test UI

Preview: [{service_url}]({service_url})

## Overview

<1-2 parrafos de que hace el servicio real detras de este proxy.>

## Endpoints

- <Verb> /path — <descripcion breve>
- <Verb> /path — <descripcion breve>

## Backend

Proxies to: [{service_url}/docs]({service_url}/docs)
"""
```

**Placeholders Template B:**

| Variable | Se reemplaza con | Significado | Ejemplo |
|---|---|---|---|
| `{service_url}` | `settings.SERVICE_<NAME>_URL.rstrip("/")` | URL base del backend | `http://dh_auth:8081` |
| `[{service_url}]({service_url})` | Link renderizado en Swagger | Test UI del backend (ADR 025: `GET /`) | `[http://dh_auth:8081](http://dh_auth:8081)` |
| `[{service_url}/docs]({service_url}/docs)` | Link renderizado en Swagger | Swagger/OpenAPI del backend real | `[http://dh_auth:8081/docs](http://dh_auth:8081/docs)` |

---

### Implementacion

Todo docstring que use placeholders debe aplicar `.format()` ANTES de pasarlo a `FastAPI(description=...)`:

```python
# Template A — gateway
_DESC = __doc__.format(root_path=settings.ROOT_PATH.rstrip("/"))
app = FastAPI(description=_DESC, ...)

# Template B — sub-app (auth)
AUTH_URL = settings.SERVICE_AUTH_URL.rstrip("/")
_DESC = __doc__.format(service_url=AUTH_URL)
app = FastAPI(description=_DESC, ...)
```

---

### Ejemplo Template A — api_middleware (ya rellenado, sin placeholders)

```python
"""API Gateway - Central HTTP proxy for microservices.

## Overview

Stateless gateway that proxies requests to backend services.
Frontend points here instead of individual microservices.
No database — pure HTTP proxy.

## Services

| Service | Status | Docs | Prefix |
|---------|--------|------|--------|
| Auth | RELEASED | [/api/middleware/auth/docs](/api/middleware/auth/docs) | `/auth` |
| IAM | RELEASED | [/api/middleware/iam/docs](/api/middleware/iam/docs) | `/iam` |
| Core | RELEASED | [/api/middleware/core/docs](/api/middleware/core/docs) | `/core` |
| MFA | RELEASED | [/api/middleware/mfa/docs](/api/middleware/mfa/docs) | `/mfa` |
| Onboarding | RELEASED | [/api/middleware/onboarding/docs](/api/middleware/onboarding/docs) | `/onboarding` |
| Storage | RELEASED | [/api/middleware/storage/docs](/api/middleware/storage/docs) | `/storage` |
| Admin | RELEASED | [/api/middleware/admin/docs](/api/middleware/admin/docs) | `/admin` |

## Environment

Configure services with `SERVICE_<NAME>_URL` environment variables.
"""
```

---

### Ejemplo Template B — auth sub-app (ya rellenado, sin placeholders)

```python
"""Auth API - Authentication and user profile.

## Test UI

Preview: [http://dh_auth:8081](http://dh_auth:8081)

## Overview

Handles login, logout, token refresh, and enriched user profile (/me).
Uses HttpOnly cookies for stateless JWT. dh_auth is the only service
authorized to query IAM tables and issue tokens (ADR 015).

## Endpoints

- POST /login
- POST /refresh
- POST /logout
- GET /me

## Backend

Proxies to: [http://dh_auth:8081/docs](http://dh_auth:8081/docs)
"""
```

---

## Consecuencias

### Positivas
- Swagger del middleware es autodocumentado con links funcionales a test UI y Swagger del backend.
- Frontend/mobile ven la tabla de servicios sin leer codigo.
- Formato predecible para parseo automatico de CI o agentes.
- Dos links claros en cada sub-app: uno al sandbox visual (test UI), otro a la especificacion (Swagger backend).

### Negativas
- Mantener los docstrings actualizados cuando cambian endpoints o servicios.
- Mitigado porque la tabla de servicios ya esta en gateway.py y se actualiza junto con los mounts.

## Referencias

- [ADR 025: Static Test UI Standard](./025-static-test-ui-standard.md) — `GET /` test UI obligatoria en cada microservicio.
- [ADR 027: Enlace a Test UI desde Middleware](./027-middleware-test-ui-link.md) — `{service_url}` placeholder en sub-apps.
- [ADR 028: Contrato Duplicado de Schemas](./028-middleware-duplicate-schema-contract.md) — schemas y paths exactos.
- [Rule: PYTHON_FASTAPI_DOCSTRINGS](../.agents/rules/PYTHON_FASTAPI_DOCSTRINGS.md) — `description=__doc__`.
