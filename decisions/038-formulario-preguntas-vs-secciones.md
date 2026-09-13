# ADR 038: Formulario — Preguntas Directas XOR Secciones y Contrato `list_sections`

## Estado
Aceptado

## Contexto

El catálogo de cuestionarios (`features/questionnaires/`) modela la composición de
un formulario en dos capas: persistencia (`schema.sql`, `catalog/ERD.mmd`) y
contrato de payload (`catalog/example.jsonc`, contrato `Instrument` del motor).

Durante la consolidación del modelo se decidió incorporar al contrato el campo
`list_sections` (presente en la referencia `app_questionnaire`, siempre como `[]`).
Al hacerlo se detectó una **contradicción interna**: el modelo físico permitía que
un formulario tuviera simultáneamente preguntas directas (`questions_form`) y
secciones (`section` + `questions_section`), y varios artefactos lo afirmaban
explícitamente:

- `schema.sql`: la pregunta "se vincula a un formulario mediante `questions_form` o
  a una sección mediante `questions_section`" (el "o" describía el origen, no la
  exclusividad por formulario).
- `ERD.mmd`: `form` declaraba **ambas** relaciones `||--o{ section` y
  `||--o{ questions_form`.
- `CLASS.mmd`: `Form` declaraba `Section[] sections` **y** `Question[] questions`.
- `catalog/example.jsonc`: un mismo payload traía 4 preguntas directas en
  `list_questions` **y** una sección en `list_sections` con su propia pregunta.
- `catalog/README.md` §7: la pregunta podía aparecer en el Form A en posición 1 y
  en el Form B en posición 7 (reutilización a nivel de pregunta).

La referencia `app_questionnaire` no impone exclusividad; su `list_sections` está
siempre vacío y carece de forma poblada. Por tanto, la forma canónica no podía
copiarse de la referencia: debía salir del ERD del proyecto.

## Decisión

### Exclusividad: preguntas directas XOR secciones

Un formulario se compone de **preguntas directas** (`list_questions`) **o** de
**secciones** (`list_sections`) que agrupan sus propias preguntas. **Nunca ambas.**

- `list_sections` es el **espejo del ERD** en el payload: `form ||--o{ section`
  (exclusivo con `questions_form`), y `section ||--o{ questions_section`.
- La exclusividad es una **regla de aplicación** (validación Pydantic + `COMMENT`
  en el DDL). **No** se materializa con constraint de BD: PostgreSQL no permite un
  `CHECK` XOR entre tablas, y añadir triggers se descartó por costo de mantenimiento.
  Consecuencia explícita: el DDL **no garantiza** la invariante; la capa de
  aplicación es la responsable de rechazar la mezcla.

### Regla de orden (sin cambios)

El orden vive donde vive la relación:

| Elemento | Dónde vive su `order` | Por qué |
|---|---|---|
| `option` | En `option` (entidad propia) | Pertenece a una única pregunta; no se comparte. |
| `section` | En `section` (entidad propia) | Pertenece a un único formulario. |
| `question` | En `questions_form` / `questions_section` | Es un átomo reutilizable: su posición depende del contexto. |

En la vista documental (`CLASS.mmd`) la relación se embebe, por lo que
`Question.order` sí vive en el subdocumento.

### Forma del contrato

```ts
interface Section {
  id: number;                 // uuid externo en el modelo relacional
  key?: string;
  name?: string;
  description?: string;
  order: number;              // section.order (vive en la entidad)
  list_questions: Question[]; // embebidas, con su order propio en la sección
}

interface Instrument {
  // ...
  list_questions: Question[];   // preguntas directas
  list_sections?: Section[];    // secciones (exclusivo con list_questions)
  // ...
}
```

### Campos de metadata: `list_references` y `list_sections` rescatados

En el mismo pase se cierran dos brechas del contrato `Instrument`:

| Campo | Forma | Nota |
|---|---|---|
| `list_references` | `{ id?, url_reference?, name?, notes?, url_thumbnail?, type_media? }[]` | Forma real observada en `PHQ9.json` e `IA_DEVELOPMENT.json`; el README §5 estaba incompleto (solo 3 campos). |
| `list_sections` | `Section[]` | Espejo del ERD; no `unknown[]`. |

### Inconsistencia corregida: `target_sex`

`target_sex` **no era una brecha real**: el `example.jsonc` ya lo modelaba como
objeto `{ type_biological_sex, id }` (espejo de la tabla `target_sex` y del enum
`EBiologicalSex`), mientras el contrato documentado (`catalog/README.md` §5) lo
declaraba erróneamente como `null | string` y marcado como gap — contradiciendo
también el `null` de la referencia. Se corrigió el README §5 para concordar con
el ejemplo y el ERD; no se introdujo estructura nueva.

## Consecuencias

**Positivas:**
- El contrato del payload queda alineado con el ERD, eliminando la contradicción.
- La forma de `list_sections` sale del modelo propio (ERD) y no de un `[]` sin
  estructura de la referencia.
- La regla de orden (`order` en la relación; en la entidad solo si es exclusiva)
  queda confirmada y consistente entre ERD y vista documental.
- Se corrigió la contradicción interna de `target_sex` (ejemplo vs README).

**Negativas:**
- La exclusividad **no está garantizada por la BD**: depende de validación de
  aplicación (Pydantic). Un insert directo en SQL podría violarla.
- Contradice la referencia `app_questionnaire`, que no es excluyente; cualquier
  importación futura desde esa referencia debe normalizarse a este contrato.
- El motor del frontend aún no ramifica entre `list_questions` y `list_sections`
  (pendiente D12 en `TODO/cuestionarios.md`); el contrato se define antes que la
  implementación, según la fase actual de definición de schemas.

## Referencias
- Modelo y decisiones de capa: `docs/features/questionnaires/catalog/README.md`
- Persistencia: `docs/features/questionnaires/schema.sql` y `catalog/ERD.mmd`
- Vista documental: `docs/features/questionnaires/catalog/CLASS.mmd`
- Contrato de ejemplo: `docs/features/questionnaires/catalog/example.jsonc`
- Referencia de modelado: `other_projects/app_questionnaire/backend/docs/cuestionarios/`
- Pendientes relacionados: `docs/TODO/cuestionarios.md` (C8, D12)
