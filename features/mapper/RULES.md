# RULES — Mapper

Reglas normativas y compactas. Contexto/problema en [`README.md`](./README.md);
casos en [`uses_cases/`](./uses_cases/README.md).

## Direccionalidad
- `answer` = **snapshot histórico inmutable**: no se reescribe por cambios
  externos ni por re-contestación (re-contestar = nueva `assignment`).
- Escritura **en una sola vía**: `answer → dominio` (write-through).
  **No** hay sync inverso (`dominio → answer`).
- Prefill (`dominio → pregunta`) es **lectura para UX**; **no** toca el `answer`.

## Binding
- Vincula **una pregunta de un `form`** ↔ **una propiedad 1:1** de dominio.
- `target.operations` ⊆ `{READ, WRITE}`; `[]` inválido.
  `READ` = prefill · `WRITE` = guardar.
- Es **cableado estático**: no guarda valores ni estado (el valor vive en la columna).

## Conflictos (fijos, sin campo)
- **Prefill**: solo si la pregunta está vacía (el dominio **no** pisa lo ya contestado).
- **Write**: si el dominio ya tiene valor, la **respuesta lo sobrescribe**.

## Destino y escritura
- Solo propiedades **1:1**. Lo **1:N** (varios registros) es componente (ADR 045).
- FK `id_person`; la persona se identifica por `person.uuid`.
- Upsert `INSERT … ON CONFLICT (id_person) DO UPDATE` → requiere
  `UNIQUE(id_person)` en la tabla 1:1.
- `answer` y dominio se escriben en la **misma transacción**.

## Divergencia
- `answer` y dominio **pueden divergir** (p. ej. corrección externa).
- Auditoría/histórico → `answer`; operación actual → dominio.

## Alcance
- Solo **preguntas de un `form`**.
- **No** es mapper: catálogos (`list_options.catalog`), activadores
  (`form.condition`), scoring (`expression`).
- Componentes (A/B/D) **no** pasan por el mapper (endpoint propio).
