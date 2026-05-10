# ADR 030: Inicializacion Centralizada de Schemas via `init_schemas`

## Estado
Aceptado

## Contexto

Anteriormente cada microservicio usaba `sync_schemas(conn, schemas: list[str])` para crear solo las tablas de los schemas que le pertenecian. Esto generaba dos problemas:

1. **Orden de arranque forzoso**: si un servicio creaba una tabla con FK a otra que no existia aun (ej. `auth.user` referencia `people.person`), el `create_all` fallaba porque `sync_schemas` solo creaba schemas dependientes como vacios, no sus tablas.
2. **Configuracion fragil de enums**: los `Enum` types de SQLAlchemy se creaban sin schema explicito, requiriendo `search_path` en el engine o dependiendo de que otro servicio los creara primero en `public`.

## Decision

Se reemplaza `sync_schemas(conn, schemas)` por `init_schemas(conn)` en `dh_shared/base.py`. La nueva funcion:

```python
ALL_SCHEMAS = [
    "people", "expedient", "auth", "iam", "org",
    "health_profile", "mfa", "relationships",
]

async def init_schemas(conn):
    from sqlalchemy import text

    # 1. Crear todos los schemas
    for schema in ALL_SCHEMAS:
        await conn.execute(text(f"CREATE SCHEMA IF NOT EXISTS {schema}"))

    # 2. Crear todas las tablas (SQLAlchemy resuelve FKs circulares)
    await conn.run_sync(shared_metadata.create_all)
```

### Principios

1. **Fase 1 — Schemas**: se crean los 8 schemas con `CREATE SCHEMA IF NOT EXISTS`. Idempotente.
2. **Fase 2 — Tablas**: `shared_metadata.create_all()` con `checkfirst=True`. SQLAlchemy resuelve FKs circulares entre schemas (ej. `people.personal_identifier` ↔ `expedient.document`) porque ve todas las tablas en una sola pasada.
3. **Sin parametros**: cada microservicio simplemente llama `await init_schemas(conn)` sin pasar listas de schemas.
4. **Sin orden de arranque**: el primer servicio que arranca crea todo. Los demas hacen skip porque las tablas ya existen (`checkfirst`).

### Uso en microservicios

```python
# dh_core, dh_auth, dh_iam, dh_onboarding, dh_admin, dh_storage
from dh_shared.base import init_schemas

@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await init_schemas(conn)
    yield
    await engine.dispose()
```

### Registro de modelos

`dh_shared/__init__.py` importa todos los modelos (`from dh_shared.models import (...)`), lo que los registra en `shared_metadata`. Cualquier `from dh_shared...` en un microservicio dispara este registro antes de que `init_schemas` se ejecute.

## Consecuencias

- **Positivas**:
    - Cero configuracion — sin `search_path`, sin listas de schemas, sin orden de arranque.
    - Idempotente — ejecutar N veces produce el mismo resultado.
    - FKs circulares entre schemas resueltas por SQLAlchemy nativamente.
    - Enum types creados correctamente en el mismo `shared_metadata.create_all`.
- **Negativas**:
    - El primer servicio que arranca crea TODAS las tablas, incluso las de schemas que no son suyos. Esto es aceptable porque `checkfirst=True` las salta en servicios subsecuentes y `CREATE SCHEMA IF NOT EXISTS` es inofensivo.
    - `dh_shared/__init__.py` debe importar todos los modelos — ya lo hace.

## Referencias

- [ADR 010: Estrategia de IDs en Base de Datos](./010-database-id-strategy.md) — `BaseModelMixin` con `id` + `uuid`.
- [ADR 017: Referencias Cross-Service](./017-referencias-cross-service.md) — FKs cross-schema con constraints reales.
- [ADR 020: Estrategia de Sync de Base de Datos](./020-database-sync-strategy.md) — `sync_schemas` original (reemplazado).
- [ADR 023: Unified SQLAlchemy Registry](./023-unified-sqlalchemy-registry.md) — `shared_metadata` y `shared_registry`.