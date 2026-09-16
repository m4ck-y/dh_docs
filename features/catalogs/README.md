# Catálogos (feature)

Módulo de **catálogos / vocabularios controlados** del sistema: valores de
referencia que se ofrecen en selectores de formularios (cuestionarios e historia
clínica) y que, en algunos casos, **el usuario puede extender** ("Otro /
Especifique").

**Estado:** Propuesta (decisión en
[ADR 044](../../decisions/044-catalogos-gobernados.md); modelado de BD diferido).

**Usado por:** `questionnaires` y `clinical_history` (referencian los catálogos
con `config.catalog`).

## Estructura

| Carpeta | Motor | Contenido |
|---|---|---|
| [`config/`](./config/) | MongoDB | **Registro** de catálogos (motor-agnóstico). |
| [`postgres/`](./postgres/) | PostgreSQL | Catálogos **gobernados/extensibles** (tablas de ítems: una por catálogo). |
| [`clickhouse/`](./clickhouse/) | ClickHouse (columnar) | Catálogos **masivos** de baja mutabilidad (código postal, CIE-11, salud). |
| [`seed/`](./seed/) | — | **Valores iniciales** (`VALIDATED`) de los catálogos gobernados/extensibles. |

## Tipos y motores ([ADR 003](../../decisions/003-estrategia-multi-base-de-datos.md))

| Tipo | Motor | Ejemplos |
|---|---|---|
| **Gobernado / extensible** (referenciado por FK, ACID) | PostgreSQL (`catalog`) | religión, relación, ocupación, género |
| **Masivo de baja mutabilidad** (lectura/análisis) | ClickHouse (columnar) | código postal, CIE-11, catálogos de salud |
| **Documental / esquema flexible** | MongoDB | registro del catálogo (`config/`); ítems documentales (pendiente) |

El **dueño** de todos es el microservicio **`dh_catalogs`** (multi-motor).

## Modelo

**Registro motor-agnóstico** (en Mongo) + **ítems** con shape canónico, viviendo
en el motor indicado. Diagrama de clases: [`CLASS.mmd`](./CLASS.mmd).

### Registro — [`config/`](./config/)
```jsonc
{ "key": "occupation", "name": "Ocupación", "description": "…",
  "engine": "POSTGRES", "config": { "schema": "catalog", "table": "occupation" },
  "extensible": true, "governed": true }
```
- `key` — nombre del catálogo (lo referencia `config.catalog`).
- `engine` — `EStorageEngine` (`POSTGRES | CLICKHOUSE | MONGO`).
- `config` — forma según `engine`:
  - `POSTGRES` → `schema` + `table`
  - `CLICKHOUSE` → `database` + `table`
  - `MONGO` → `database` + `collection` (+ `filter`)

### Ítem — shape canónico
```jsonc
{ "value": "EMPLOYED", "label": "Empleado/a", "description": null,
  "status": "VALIDATED", "merged_into": null, "order": 0 }
```
- `value` — identificador estable (respuesta + FK de dominio).
- `status` — `ECatalogStatus`.
- Vive en el motor del catálogo: tabla (PG), tabla (ClickHouse) o colección (Mongo).

### Estado — `ECatalogStatus`
| Estado | Significado |
|---|---|
| `PENDING` | Creado por un usuario ("Especifique"); en cola de curaduría |
| `VALIDATED` | Canónico (sembrado o promovido); se ofrece en el selector |
| `MERGED` | Desduplicado: apunta al canónico (`merged_into`); no se lista |
| `REJECTED` | Descartado por curaduría; no se lista |

Sembrado/curado → `VALIDATED`; creado por usuario → `PENDING`.

### Política (`extensible` × `governed`)
| `extensible` | `governed` | Comportamiento |
|---|---|---|
| `false` | — | cerrado (solo `VALIDATED`, sin "Otro") |
| `true` | `true` | "Otro" → `PENDING`; se ofrece tras curaduría |
| `true` | `false` | "Otro" → disponible al instante |

### Flujo de captura ("Otro → Especifique")
```
selector (catálogo)
  ├─ elige un ítem VALIDATED (o PENDING propio)  → guarda el `value` del ítem
  └─ elige "Otro" y escribe                        → create-request a dh_catalogs
        → crea un ítem PENDING → guarda el `value` del nuevo ítem
```
- El front no guarda texto suelto: crea el ítem y referencia su `value`.
- "Otro" y "Prefiere no decirlo"/"Ninguna" **no** son ítems (son affordances de UI).

### Curaduría y desduplicación
- Revisar `PENDING`.
- **Desduplicar** (mismo significado, distinto texto) → `status = MERGED` +
  `merged_into = <canónico>`; las respuestas que apuntaban al ítem fusionado se
  **resuelven al canónico**.
- Promover a `VALIDATED` o descartar con `REJECTED`.

## Convención de nombres

- `config/` — registro (Mongo) · `postgres/` — ítems gobernados ·
  `clickhouse/` — ítems masivos · `seed/` — valores iniciales.
- `CLASS.mmd` — vista lógica motor-agnóstica.
- `config/example.json` — ejemplo del registro; `seed/<key>.json` — valores de un
  catálogo (`key` = nombre de archivo).

## Archivos

```
catalogs/
├── README.md            # índice (modelo, política, flujo, pendientes)
├── CLASS.mmd            # vista lógica motor-agnóstica
├── config/              # registro (Mongo)
│   ├── README.md
│   └── example.json
├── postgres/            # ítems gobernados (tablas)
│   └── README.md
├── clickhouse/          # ítems masivos (columnar)
│   └── README.md
└── seed/                # valores iniciales (VALIDATED)
    ├── README.md
    ├── occupation.json
    ├── religion.json
    ├── relationship.json
    └── gender.json
```

## Pendientes

- Modelar los **schemas por motor** (PG + ClickHouse) — diferido a la fase de BD.
- Definir **C20** (TASK-016): opciones respaldadas por catálogo + flujo de create
  en el modelo de pregunta.
- Crear el microservicio **`dh_catalogs`** (multi-motor): endpoints list / create /
  validate / merge.
- Decidir el **criterio** de qué vocabularios migran a catálogo (no todos los "Otro").

## Referencias

- Decisión: [ADR 044](../../decisions/044-catalogos-gobernados.md)
- Estrategia de motores: [ADR 003](../../decisions/003-estrategia-multi-base-de-datos.md)
- Regla: `.agents/rules/CATALOGS_GOVERNANCE.md`
- Persistencia (diferida): `docs/db/postgres/catalog/`, `docs/db/click_house/`
