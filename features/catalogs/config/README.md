# Config de catálogos (registro)

**Registro motor-agnóstico** de los catálogos del sistema. Un documento por
catálogo; lo consulta `dh_catalogs` para resolver `config.catalog = "<key>"` y
**rutear** a su motor.

> El **modelo completo** (política, flujo y curaduría) está en el índice
> [`../README.md`](../README.md). Decisión: [ADR 044](../../../decisions/044-catalogos-gobernados.md).

## ¿Por qué en Mongo?

El registro **no** va en PostgreSQL (ni en ClickHouse), sino en **MongoDB**:

1. **Motor-agnóstico**: el registro describe catálogos que viven en *distintos*
   motores (`postgres`, `clickhouse`, `mongo`). No tiene sentido atarlo a uno de
   ellos (en PG "describiría" catálogos de ClickHouse/Mongo desde un motor
   ajeno). Mongo es un **store neutral**.
2. **Esquema flexible**: cada motor tiene su propio sub-objeto (`postgres` /
   `clickhouse` / `mongo`); Mongo admite esa variación **sin migraciones**.
3. **Dinámico**: agregar/editar un catálogo = insertar/actualizar **un
   documento**, sin `ALTER TABLE` ni deploy.
4. **Baja mutabilidad, alta lectura**: el registro se configura poco y se **lee
   mucho** (resolución de selectores); Mongo + cache encajan.
5. **Responsabilidad**: `dh_catalogs` ya es multi-motor; el registro es su
   **mapa de rutas**, natural como documento de configuración.

## Esquema

```jsonc
// Colección: dh_catalogs.catalogs
{
  "key": "occupation",                    // UNIQUE, estable (lo referencia config.catalog)
  "name": "Ocupación",
  "description": "Ocupaciones declaradas por el usuario.",

  "engine": "POSTGRES",                   // EStorageEngine: POSTGRES | CLICKHOUSE | MONGO
  "config": { "schema": "catalog", "table": "occupation" },

  "extensible": true,                     // ¿acepta "Otro" (el usuario agrega valores)?
  "governed": true                        // ¿requiere curaduría antes de ofrecerse?

  // BaseModel: uuid, created_at, updated_at, deleted_at, created_by, updated_by
}
```

### Forma de `config` según `engine`

| `engine` | `config` |
|---|---|
| `POSTGRES` | `{ schema, table }` |
| `CLICKHOUSE` | `{ database, table }` |
| `MONGO` | `{ database, collection, filter? }` |

- `config` se **valida** contra `engine` (unión discriminada en Pydantic).

## Ejemplo

[`example.json`](./example.json) — ocupación/religión (postgres), tipo de vivienda
(cerrado), código postal (clickhouse), intereses (mongo).

## Seed

El **registro** (`example.json`) también es **seed** (se siembra en Mongo); los
**valores iniciales** (`VALIDATED`) viven en [`../seed/`](../seed/).

## Seguridad

Sin credenciales ni `url_server` en el registro; las conexiones por motor viven
en la config / Secret Manager de `dh_catalogs`.
