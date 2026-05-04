# ADR 027: API Middleware — Enlace a Test UI de Cada Microservicio

## Estado
Aceptado

## Contexto

El `api_middleware` agrupa sub-apps FastAPI por microservicio, cada una con su propio Swagger en `/docs`. Sin embargo:

- La test UI retro (ADR 025) existe en cada microservicio backend (`GET /`), no en el middleware.
- El middleware no replica las test UIs porque seria redundante, dificil de mantener y no escala con nuevos servicios.
- Los desarrolladores que navegan el Swagger del middleware necesitan una forma rapida de saltar a la test UI real del microservicio.

## Decision

Cada sub-app de `api_middleware` **debe incluir en su docstring** un enlace a la URL raiz del microservicio backend (test UI), usando la variable de entorno `SERVICE_<NAME>_URL`.

### Formato del docstring

```python
"""Auth API - Authentication and user profile.

## Test UI

Preview: [{service_url}]({service_url})

## Overview

Handles login, logout, silent refresh, and enriched user profile (/me).
...
"""
```

El placeholder `{service_url}` se reemplaza con el valor de `settings.SERVICE_AUTH_URL` formateado via `__doc__.format(service_url=...)`.

### Implementacion

En cada `app/microservices/<name>/app.py`:

```python
from app.settings import settings

SERVICE_URL = settings.SERVICE_NAME_URL.rstrip("/")
_DESC = __doc__.replace("{service_url}", SERVICE_URL) if SERVICE_URL else __doc__

def create_app() -> FastAPI:
    app = FastAPI(
        title="...",
        description=_DESC,
        ...
    )
```

**Nota**: Se usa `.replace()` en lugar de `.format()` porque los docstrings pueden contener llaves `{settings.SERVICE_...}` de otras variables que no deben ser formateadas.

### Reglas

1. **Enlace condicional**: Si `SERVICE_<NAME>_URL` esta vacio (no configurado), no se muestra el enlace. El docstring se usa tal cual sin formato.
2. **Formato Markdown**: El enlace usa sintaxis de Markdown `[texto](url)` para ser clickeable en Swagger UI.
3. **Texto descriptivo**: Usar `Test UI` o `Preview` como texto del enlace.
4. **Todas las sub-apps**: Aplica a todas las sub-apps del middleware (auth, iam, core, mfa, onboarding, etc.)
5. **Redireccion directa**: Al hacer click, el navegador abre una nueva pestana a la raiz del microservicio, donde se sirve la test UI (ADR 025).

### Ejemplo de visualizacion en Swagger

```
Auth API - Authentication and user profile.

## Test UI

Preview: [http://127.0.0.1:8080](http://127.0.0.1:8080)

## Overview

Handles login, logout, silent refresh...
```

## Consecuencias

- **Positivas**:
    - Navegacion fluida entre Swagger del middleware y test UI del microservicio.
    - Sin duplicacion de HTML/CSS/JS en el middleware.
    - El enlace se actualiza automaticamente con la variable de entorno.
    - Documentacion centralizada y auditable.
- **Negativas**:
    - Requiere que la variable de entorno este correctamente configurada.
    - Si no esta configurada, el enlace no aparece (no hay fallback).

## Referencias

- [ADR 025: Static Test UI Standard](./025-static-test-ui-standard.md) — Cada microservicio sirve test UI en `GET /`.
- [ADR 022: ENDPOINTS.md](./022-mandatory-endpoints-documentation.md) — Documentacion obligatoria de endpoints.