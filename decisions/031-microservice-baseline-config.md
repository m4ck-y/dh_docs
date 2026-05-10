# ADR 031: Configuracion Baseline para Microservicios

## Estado
Aceptado

## Contexto

Todo microservicio nuevo en el ecosistema Digital Hospital debe arrancar con una configuracion minima y autocontenida. Actualmente existen dos patrones de arranque heredados:

1. Servicios sin `root_path` — Swagger no refleja la ruta real detras del gateway.
2. Servicios sin `CORSMiddleware` — fallan si el frontend o el gateway llaman desde otro origen.

El task TASK-013 establece la convencion de versionado de rutas en el gateway (`/{ROOT_PATH}/{service_name}/v1/...`), pero no formaliza que **cada microservicio debe cumplir con una configuracion base que garantice compatibilidad con el gateway y operabilidad standalone**.

## Decision

Todo microservicio del ecosistema Digital Hospital **debe incluir** como minimo las siguientes variables de configuracion y el middleware CORS al momento de su creacion. Esta configuracion es el **baseline no negociable** para cualquier nuevo servicio.

### 1. Variables de configuracion obligatorias (`app/settings/config.py`)

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "Digital Hospital - <Service Name>"
    VERSION: str = "1.0.0"
    ENVIRONMENT: str = "development"

    ROOT_PATH: str = "/api/<service_name>"
    CORS_ORIGINS: list[str] = ["*"]

    # ... dominio especifico ...

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
    )

settings = Settings()
```

| Variable | Tipo | Default | Proposito |
|---|---|---|---|
| `PROJECT_NAME` | `str` | `"Digital Hospital - <Name>"` | Titulo en Swagger UI y logs |
| `VERSION` | `str` | `"1.0.0"` | Version semantica del servicio |
| `ENVIRONMENT` | `str` | `"development"` | Entorno (development, staging, production). Enviado a VitalTrace. |
| `ROOT_PATH` | `str` | `"/api/<service_name>"` | Path raiz cuando corre standalone. Detras del gateway lo controla `app.mount()`. |
| `CORS_ORIGINS` | `list[str]` | `["*"]` | Origenes permitidos para CORS. `["*"]` en desarrollo. Restringir en produccion. |

### 2. `CORSMiddleware` obligatorio en `app/main.py`

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.settings.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    lifespan=lifespan,
    root_path=settings.ROOT_PATH,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

Reglas:
- `app.add_middleware(CORSMiddleware, ...)` **siempre** se ejecuta despues de `app = FastAPI(...)` y **antes** de cualquier `app.include_router(...)` o `app.mount(...)`.
- `allow_origins` usa `settings.CORS_ORIGINS`, nunca un hardcode.
- `root_path` en `FastAPI(...)` usa `settings.ROOT_PATH`.

### 3. Archivo `.env.example` obligatorio

```bash
PROJECT_NAME="Digital Hospital - <Service Name>"
VERSION="1.0.0"
ENVIRONMENT=development

ROOT_PATH="/api/<service_name>"
CORS_ORIGINS='["*"]'

# ... dominio especifico ...
```

Cada servicio publica su `.env.example` con valores por defecto funcionales para desarrollo local.

### 4. Matriz de ROOT_PATH por servicio

| Servicio | ROOT_PATH | Gateway Mount |
|---|---|---|
| `api_middleware` | `/api/middleware` | N/A (es el gateway) |
| `dh_auth` | `/api/auth` | `/api/middleware/auth` |
| `dh_iam` | `/api/iam` | `/api/middleware/iam` |
| `dh_core` | `/api/core` | `/api/middleware/core` |
| `dh_mfa` | `/api/mfa` | `/api/middleware/mfa` |
| `dh_onboarding` | `/api/onboarding` | `/api/middleware/onboarding` |
| `dh_storage` | `/api/storage` | `/api/middleware/storage` |
| `dh_admin` | `/api/admin` | `/api/middleware/admin` |
| `dh_logger` | `/api/logger` | `/api/middleware/logger` |
| `dh_notify` | `/api/notify` | `/api/middleware/notify` |
| `dh_organizations` (pendiente) | `/api/organizations` | `/api/middleware/organizations` |
| `dh_catalogs` (pendiente) | `/api/catalogs` | `/api/middleware/catalogs` |

La ruta completa final es: `/{ROOT_PATH}/{service_name}/v1/{endpoint}`.

### 5. Checklist para nuevo microservicio

Al crear un microservicio desde cero, verificar:

- [ ] `app/settings/config.py` contiene `ROOT_PATH` y `CORS_ORIGINS`
- [ ] `.env.example` contiene `ROOT_PATH` y `CORS_ORIGINS`
- [ ] `app/main.py` tiene `CORSMiddleware` con `settings.CORS_ORIGINS`
- [ ] `app/main.py` pasa `root_path=settings.ROOT_PATH` a `FastAPI()`
- [ ] `ROOT_PATH` en `.env.example` coincide con la matriz de este ADR
- [ ] El README del servicio lista `ROOT_PATH` y `CORS_ORIGINS` en `env_vars`
- [ ] La test UI (`GET /`) funciona tanto standalone como detras del gateway

## Consecuencias

### Positivas
- **Consistencia garantizada**: todo microservicio arranca con CORS funcional y rutas correctas.
- **Onboarding rapido**: checklist explicito elimina ambiguedad al crear servicios nuevos.
- **Operabilidad dual**: misma configuracion funciona standalone (`/`) y detras del gateway (`/api/<name>`).
- **Swagger correcto**: `root_path` asegura que `/docs` y `/redoc` reflejen rutas reales en ambos modos.

### Negativas
- **Boilerplate**: ~10 lineas adicionales en cada `config.py` y `main.py`. Mitigable con templates de scaffolding.

## Referencias

- [TASK-013: API Gateway Path Versioning](../tasks/TASK-013-api-gateway-path-versioning/README.md) — origen del requerimiento.
- [ADR 025: Static Test UI Standard](./025-static-test-ui-standard.md) — `GET /` con UI retro terminal.
- [ADR 028: Middleware — Contrato Duplicado](./028-middleware-duplicate-schema-contract.md) — schemas duplicados en el gateway.
- [ADR 011: Microservice README Standard](./011-microservice-readme-standard.md) — variables de entorno documentadas.
- `.agents/rules/MICROSERVICE_README.md` — regla de README para microservicios.
