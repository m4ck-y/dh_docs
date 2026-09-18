# Store de bindings (mapper)

Store donde vivirán los **bindings** que resuelve el runner (prefill y
write-through). **Estado: propuesta** — el **schema definitivo está por
evaluarse**.

## Store propuesto

- **Motor:** MongoDB (motor-agnóstico, editable sin migración, para UI admin).
- **DB:** `dh_mapper`.
- **Colección:** **pendiente de decidir** entre las dos propuestas de
  [`../examples/`](../examples/):
  - `bindings` — **un documento por binding** (`binding.example.jsonc`).
  - `forms` — **un documento por form** con `list_bindings[]`
    (`form.example.jsonc`).

## Contrato del binding

Ver las propuestas en [`../examples/`](../examples/) y el alcance/casos de uso en
[`../README.md`](../README.md) y [`../uses_cases/README.md`](../uses_cases/README.md).

Hoy el binding propuesto tiene:

| Campo | Descripción |
|---|---|
| `key` | Id lógico estable y único. |
| `domain` | Agrupación (`clinical_history` / `questionnaires`). |
| `source` | `{ form_key, question_key, question_uuid? }`. |
| `target` | `{ engine, config, property, match_on? }`. |
| `operation` | `{ read, write, mode }` (`UPSERT`/`APPEND`/`REPLACE`). |
| `transform` | `null` o transformación a definir. |
| `conflict` | `KEEP_EXISTING` / `OVERWRITE` / `FLAG`. |
| `enabled` | Conectar/desconectar. |

## Pendiente

- **Definir el schema definitivo** (campos finales, enums, índices/unicidad,
  validaciones).
- Definir `transform` (`SPLIT` / `MAP` / `EXPRESSION`; `COMBINE` diferido).
- Implementar la colección Mongo + seed.
