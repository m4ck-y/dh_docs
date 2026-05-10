# ADR 035: API Path Format — Sin Trailing Slash

## Context

Los microservicios del ecosistema Digital Hospital definen rutas de API de forma inconsistente: algunos usan `"/"` como path de lista/creación (`@router.get("/")`, `@router.post("/")`) y otros usan `""` (`@router.get("")`, `@router.post("")`).

FastAPI trata ambos casos de forma distinta:
- `"/"` — solo responde a la ruta **con** trailing slash (`GET /v1/people/`)
- `""` — solo responde a la ruta **sin** trailing slash (`GET /v1/people`)

Esta inconsistencia causa errores 404 cuando el cliente (frontend o api_middleware) llama sin trailing slash pero el backend solo responde con él, o viceversa.

## Decisión

**Todos los endpoints del ecosistema NO deben tener trailing slash.**

| Incorrecto | Correcto |
|---|---|
| `@router.get("/")` | `@router.get("")` |
| `@router.post("/")` | `@router.post("")` |
| `APIRouter(prefix="/v1/")` | `APIRouter(prefix="/v1")` |

### Reglas

1. **Routers**: El `prefix` de `APIRouter` nunca debe terminar en `/`.
2. **Endpoints de lista/creación**: Usar `""` en vez de `"/"` para paths sin segmento adicional.
3. **Sub-recursos**: Usar `"/{uuid_person}/addresses"` — barra inicial, sin barra final.
4. **Proxy paths (api_middleware)**: Los paths enviados via `request()` al backend deben coincidir exactamente con la ruta del backend, sin trailing slash.
5. **Validación automática**: Todo PR debe verificar que ningún decorador `@router.<method>` use `"/"` o que termine en `/`.

### Excepciones

- La ruta raíz del servicio (`@app.get("/")`) para health check o UI puede usar `"/"` ya que representa la raíz del servicio, no un recurso.

## Consecuencias

- **Positivas**: Elimina errores 404 por mismatch de trailing slash. Unifica el comportamiento entre servicios.
- **Negativas**: Clientes legacy que llamen con trailing slash obtendrán 404 (FastAPI no hace redirect automático de `"/"` a `""`).
- **Migración**: Se corrigieron los endpoints existentes en `api_middleware` (`people.py`, `waitlist.py`) que usaban `"/"`.

## Referencias

- [ADR 009](009-api-response-format.md) — Formato de respuesta estándar
- [FastAPI Routing — Trailing Slash](https://fastapi.tiangolo.com/tutorial/path-params/)