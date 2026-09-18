# Store de bindings (mapper)

Store donde viven los **bindings** que resuelve el runner (prefill y
write-through). CRUD gestionado por el microservicio **`dh_bindings`**.

## Store

- **Motor:** MongoDB.
- **DB:** `dh_bindings`.
- **Colección:** **`bindings`** — un documento por binding.
- **Shape canónico:** `binding.example.jsonc` (en `examples/`; ver índice del feature).

## Índices

| Nombre | Campos | Tipo | Propósito |
|---|---|---|---|
| `uq_form_question` | `(source.form, source.question)` | unique | 1 binding por pregunta |
| `ix_form_enabled_ops` | `(source.form, enabled, target.operations)` | non-unique | batch UC2 (prefill / write-through) |

## Cómo correr el seed

```bash
mongosh < features/mapper/store/seeder.js
```

El seed es **idempotente**: re-ejecutar no duplica (upsert por `source.form` + `source.question`).
