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
| `name` | Etiqueta legible (opcional). |
| `source` | `{ form, question }` (keys estables). |
| `target` | `{ engine, schema, table, property }` — propiedad **1:1**. |
| `read` | Prefill (UC2): solo si la pregunta está vacía. |
| `write` | Write-through (UC1): solo si fue respondida; la respuesta manda. |
| `enabled` | Conectar/desconectar. |

> **1:N** (varios registros, p. ej. `people.address`): **no** es mapper → es
> **componente** (ADR 045). Si algún día se requiere, se agrega `target.match_on`.

## Pendiente

- **Definir el schema definitivo** (campos finales, enums, índices/unicidad,
  validaciones).
- Definir `transform` (`SPLIT` / `MAP` / `EXPRESSION`; `COMBINE` diferido).
- Implementar la colección Mongo + seed.
