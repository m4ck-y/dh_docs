# Catálogos gobernados (PostgreSQL)

Capa **PostgreSQL** del feature `catalogs`: el **almacenamiento de los ítems** de
los vocabularios gobernados/extensibles (referenciados por FK desde el dominio,
ACID).

> El **registro**, la **política**, el **flujo** y la **curaduría** viven en el
> índice [`../README.md`](../README.md) y en [`../config/`](../config/). Aquí solo
> se documenta cómo se guardan los **ítems** en Postgres.

## Almacenamiento

En Postgres quedan solo las **tablas de ítems** (una por catálogo, misma forma) y
el enum de estado:

```sql
CREATE TYPE ECatalogStatus AS ENUM ('PENDING', 'VALIDATED', 'MERGED', 'REJECTED');

-- Una tabla por catálogo (misma forma). Ej.: religion, occupation, relationship, gender
CREATE TABLE religion (
    id SERIAL PRIMARY KEY,
    value VARCHAR(100) NOT NULL UNIQUE,         -- identificador estable (answer/FK)
    label VARCHAR(255) NOT NULL,                -- texto a mostrar
    description TEXT,
    status ECatalogStatus NOT NULL DEFAULT 'PENDING',
    merged_into INTEGER REFERENCES religion(id), -- canónico si status = MERGED
    "order" INTEGER NOT NULL DEFAULT 0
    -- BaseModel: uuid, created_at, updated_at, deleted_at, *_by_id_user
);
```

- Cada catálogo (`occupation`, `disease`, `religion`, …) es su **propia tabla** con la
  forma de arriba. El `key` del registro (`config/`) **nombra la tabla** (por convención).
- Shape canónico del ítem y diagrama: [`../CLASS.mmd`](../CLASS.mmd).

## Pendiente (fase de BD)

- **DDL** (`COMMENT`s/índices) — ERD ya en [`db/postgres/catalog/erd.mmd`](../../../db/postgres/catalog/erd.mmd).
- Decidir cómo el **dominio** referencia el ítem (FK por `value` compuesto, por
  id, `value` global único, o validación en app) — ver
  [ADR 044](../../../decisions/044-catalogos-gobernados.md).
