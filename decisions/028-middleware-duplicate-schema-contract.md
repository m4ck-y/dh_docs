# ADR 028: API Middleware — Contrato Duplicado de Schemas y Endpoints

## Estado
Aceptado

## Contexto

El `api_middleware` expone endpoints explicitos para cada microservicio del ecosistema. Segun la politica establecida en AGENTS.md:

> El `api_middleware` actua como el contrato estricto (interfaz) entre el frontend y los backends.

Esto implica que los schemas Pydantic y los routers deben duplicarse en el middleware en lugar de usar proxies catch-all. La duplicacion genera friccion de mantenimiento:

- Schemas y DTOs pueden divergir del original.
- Los docstrings de funciones y schemas pueden perderse en la copia.
- Las rutas pueden renombrarse accidentalmente (ej. `refresh` → `silent-refresh`).
- Los tipos de datos pueden debilitarse (ej. `datetime` → `str`, `EmailStr` → `str`).

## Decision

Todo endpoint y schema en el `api_middleware` **debe ser una replica exacta** del microservicio original en cuanto a:

### 1. Paths de endpoints

Las rutas en el middleware deben coincidir **exactamente** con las del microservicio original. El prefijo de version (`/v1/...`) y el nombre del recurso deben ser identicos.

| Original | Middleware | Correcto? |
|---|---|---|
| `POST /v1/auth/refresh` | `POST /v1/auth/refresh` | Si |
| `POST /v1/auth/refresh` | `POST /v1/auth/silent-refresh` | No |

### 2. Pydantic Schemas

Cada schema en `app/microservices/<service>/domain/` debe ser una copia funcionalmente identica del DTO original:

- **Nombres de campos**: Exactamente iguales (incluyendo convencion `uuid_` / `id_`).
- **Tipos**: Identicos (ej. `UUID`, `datetime`, `EmailStr`, `date`, enums).
- **Validadores**: `min_length`, `max_length`, `field_validator`, etc. deben replicarse.
- **Documentacion**: `Field(description=...)` y `examples=[...]` deben mantenerse completos.
- **Valores por defecto**: `Field(None)` para opcionales, `Field(...)` para requeridos.

### 3. Docstrings de funciones

Cada funcion endpoint en el middleware debe incluir el docstring del endpoint original. Esto asegura que Swagger UI en el middleware muestre la misma documentacion que el microservicio.

### 4. Documentacion de sub-app

Cada `app.py` debe documentar los endpoints que expone y enlazar a la test UI del microservicio (ADR 027).

## Regla nemotecnica

> El middleware es un **espejo documentado** del microservicio. Si el original cambia, el middleware debe reflejarlo.

## Verificacion

Para auditar el cumplimiento, comparar contra el original:

1. **Paths**: Comparar `router.py` del original contra `routes/*.py` del middleware.
2. **Schemas**: Comparar los DTOs — mismo `__fields__`, mismos tipos, mismas descripciones.
3. **Docstrings**: Cada funcion endpoint en el middleware debe tener docstring no vacio.
4. **Field quality**: Ningun campo en los DTOs del middleware debe ser "bare type" sin `Field(...)`.

## Consecuencias

- **Positivas**:
    - Swagger del middleware es documentacion completa y autonoma.
    - Frontend y mobile pueden confiar en el middleware como fuente unica de verdad del contrato API.
    - Facilita onboarding de nuevos desarrolladores al tener toda la API visible en un solo lugar.
- **Negativas**:
    - Mantenimiento duplicado. Cada cambio en un DTO original requiere actualizar el middleware.
    - Riesgo de divergencia si no se mantiene disciplina.
    - Mayor cantidad de codigo en el middleware (~200-400 lineas por sub-app).

## Referencias

- [ADR 010: Estrategia de IDs en Base de Datos](./010-database-id-strategy.md) — Convencion de naming `uuid_` / `id_`.
- [ADR 024: Endpoints API con UUIDs](./024-endpoints-uuid-only.md) — Solo UUIDs en API publica.
- [ADR 025: Static Test UI Standard](./025-static-test-ui-standard.md) — Test UI en cada microservicio.
- [ADR 027: Enlace a Test UI desde Middleware](./027-middleware-test-ui-link.md) — Docstring con link a test UI.
- AGENTS.md — Politica de contrato estricto del middleware.
