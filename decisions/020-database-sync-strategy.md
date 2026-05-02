# ADR 020: Database Synchronization Strategy for Multi-Schema Monorepo

## Context
In our microservices architecture, we use a shared library (`dh_shared`) to define models across different PostgreSQL schemas (`auth`, `people`, `iam`, etc.). Many tables have cross-schema foreign keys (e.g., `auth.user` points to `people.person`). 

Using independent SQLAlchemy `DeclarativeBase` objects for each schema led to `NoReferencedTableError` because SQLAlchemy could not resolve foreign keys to tables not present in the current base's metadata. Additionally, manual schema creation in each microservice was redundant and error-prone.

## Decision
We will implement a centralized, shared metadata and synchronization strategy:

1.  **Shared Metadata**: All models in `dh_shared` must share the same `MetaData` object (`shared_metadata` in `dh_shared.base`). This ensures all tables are registered in a single registry, allowing SQLAlchemy to resolve cross-schema foreign keys.
2.  **Centralized Sync Utility**: Use the `sync_schemas(conn, schemas: list[str])` utility provided in `dh_shared.base`. 
    *   This function automatically creates the requested schemas.
    *   It detects and creates "dependency" schemas (schemas referenced via Foreign Keys).
    *   It filters the global metadata to only create/sync tables belonging to the specified `schemas`.
3.  **Model Registration**: Microservices must import the models they intend to sync **and** any models referenced via Foreign Keys within the `lifespan` context (or globally in `main.py`) to ensure they are loaded into the `shared_metadata`.

## Rationale
*   **Consistency**: Guarantees that foreign key constraints are correctly created across schemas.
*   **Developer Experience**: Simplifies the `lifespan` logic in microservices.
*   **Safety**: Prevents a microservice from accidentally creating tables it does not own (e.g., `dh_auth` should not create `iam.role`).

## Consequences
*   **Memory Footprint**: Loading many models into a single metadata object has a negligible memory cost.
*   **Startup Order**: While `sync_schemas` creates the schema structure, it's still recommended that the "owner" service of a schema starts first to ensure correct initialization and potential seeding.

## Implementation Details
Example usage in a microservice's `app/main.py`:

```python
from dh_shared.base import sync_schemas
from dh_shared.models.auth import AuthBase # Owner base
from dh_shared.models.people.person import Person # Referenced model

@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        # Syncs only tables in 'auth' schema, but resolves FKs to 'people'
        await sync_schemas(conn, ["auth"])
    yield
```
