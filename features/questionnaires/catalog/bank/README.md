# Banco de instrumentos (`bank/`)

Instancias reales del catálogo: la **definición** de cada instrumento (y de la
historia clínica) como documento JSON, lista para el mock del frontend y para la
persistencia (PostgreSQL relacional o vista documental MongoDB).

El **modelo** (ERD, `CLASS`, `../../schema.sql`, `../../expressions/`) vive un
nivel arriba; este directorio solo contiene **datos**.

## Estructura

| Ruta | Contenido |
|---|---|
| `categories.json` | Vocabulario controlado de categorías de bienestar (`key` + `name`). |
| `population.json` | Vocabulario controlado de poblaciones objetivo (`name`). |
| `instruments/` | Un `.json` + un `.md` por instrumento psicométrico (`kind: INSTRUMENT`). |
| `clinical_history/` | Un `.json` + un `.md` por formulario clínico (`kind: CLINICAL_HISTORY`). |

- **Plano**: la categoría (mental/físico/social) **no** es carpeta; vive en
  `list_categories[]`. Un instrumento puede pertenecer a varias (p. ej. CRAFFT:
  `wellbeing_physical` + `wellbeing_social`), sin duplicar el archivo.
- **Vocabularios controlados**: `list_categories` usa `categories.json` y
  `list_population` usa `population.json`.
- **Rangos** (`list_age_groups`, `estimated_duration`): forma
  `{ name, min, max, unit }`. `name` = **etiqueta legible** de la fuente (UI);
  `min`/`max` = valor numérico; `unit` = `EUnit` (`YEAR`, `MONTH`, `MINUTE`, ...).
  No se usa `description` para etiquetas.
- **Enums sin bank**: los campos cuyo valor viene de un **enum del DDL**
  (`EUnit`, `EQuestionType`, `EAssignmentStatus`, `EBiologicalSex`, `EUrlType`)
  **no** tienen archivo de vocabulario; su fuente es `schema.sql`.
- **`question.text` nullable**: hay instrumentos cuyos ítems **no tienen
  enunciado** (ej. **CDI**, formato "elige la frase"). En ese caso `text` va en
  `null`, el contexto en `form.instructions`, y se muestran **solo las opciones**.
- **`population` = grupo objetivo NO etario** (contexto/condición clínica). Las
  etiquetas que solo describen edad **no** van aquí: se expresan en
  `list_age_groups`. Excluidas por eso: `Adultos` (IPAQ, ya `18–65`) y
  `Pacientes geriátricos` (GDS, ya `>60`).
- **Fuente humana** de cada instrumento: `docs/diagrams/<dominio>/flows/<key>.mmd`
  (+ `reviews/<key>-review.md`).

## Inventario

| key | `kind` | ítems | categoría(s) | expresión |
|---|---|---|---|---|
| `phq-9` | INSTRUMENT | 9 | bienestar mental | scoring + evaluation |
| `hads` | INSTRUMENT | 14 | bienestar mental | subscales (A/D) |
| `gds` | INSTRUMENT | 15 | bienestar mental | scoring + evaluation |
| `cdi` | INSTRUMENT | 27 | bienestar mental | scoring + evaluation (`text: null`) |
| `gad-7` | INSTRUMENT | 7 | bienestar mental | scoring + evaluation |
| `pss` | INSTRUMENT | 14 | bienestar mental | scoring (sin evaluación) |
| `crafft` | INSTRUMENT | 9 | bienestar físico + social | scoring + evaluation (`list_sections` A/B + `condition`) |
| `ipaq` | INSTRUMENT | 7 | bienestar físico | scoring (METs) + evaluation (Alto/Moderado/Bajo) |

## Convención de un instrumento

- `key` del instrumento = nombre del archivo (`phq-9.json`, `crafft.json`).
- Cada instrumento tiene **dos archivos**: `<key>.json` (definición canónica) y
  `<key>.md` (lectura humana, formato legacy `PHQ9.md`).
- Textos del formulario:
  - `description` = **técnica** (qué es / qué evalúa). Para profesionales.
  - `instructions` = **llenado** (cómo responder). Para el paciente. Nullable.
  - **amigable** (presentación) = solo en el `<key>.md`; **no** se modela.
- Carpetas y `key`/slugs en inglés; `name`/`text`/`description` en español.
- `kind`: `INSTRUMENT` | `CLINICAL_HISTORY`.
- `id` (uuid/string) estable, para que `expression`/`condition` puedan referenciar.
- Un form usa `list_questions` **XOR** `list_sections` (ver ADR 038).
- `expression` (envelope AST) y `condition` (AST) según `../../expressions/`.

## Plantilla

```jsonc
{
  "id": "uuid-form-<key>",
  "key": "<key>",
  "kind": "INSTRUMENT",
  "name": "...",
  "description": "...",
  "instructions": null,
  "verified": false,
  "condition": null,
  "expression": { /* definitions? / scoring? / evaluation? / subscales? */ },
  "list_categories": [ { "key": "wellbeing_mental", "name": "Bienestar mental" } ],
  "list_evaluation_topics": [ { "key": "...", "name": "..." } ],
  "list_cie11_codes": [ { "code": "6A7" } ],
  "list_population": [ { "name": "..." } ],
  "estimated_duration": { "name": "≤10 minutos", "min": 5, "max": 10, "unit": "MINUTE" },
  "list_age_groups": [ { "name": "≥18 años", "min": 18, "max": 99, "unit": "YEAR" } ],
  "target_sex": null,
  "list_references": [],
  "list_questions": [ /* ... */ ]
}
```

## Derivación

```
docs/diagrams/catalog/instruments.csv    (metadata: nombre, descripción, edad, tiempo, CIE-11, LS, población)
        + docs/diagrams/<dominio>/flows/<key>.mmd   (preguntas y opciones; drawio -> mmd)
        + reviews/<key>-review.md                    (tabla Puntuacion | Interpretacion)
        -> bank/instruments|clinical_history/<key>.json   (definicion canonica)
        -> bank/instruments|clinical_history/<key>.md     (lectura para usuario final)
        -> ../../expressions/                        (scoring / evaluation)
```

## Pendientes

- Convertir los `.mmd` de `docs/diagrams/` a `<key>.json`.
- Completar `categories.json` con el vocabulario (columna `LS` del
  `docs/diagrams/catalog/instruments.csv`).
- Definir el/los formulario(s) de historia clínica (`clinical_history/`).

## Decisiones y dudas

**Decisiones de llenado del banco** (registradas en
[`TASK-016`](../../../../tasks/TASK-016-catalogo-cuestionarios/planning/pendientes.md)):

- **C12** `description` (técnica) vs `instructions` (llenado); amigable solo en `.md`.
- **C13** `list_population` (N:N).
- **C14** prefijo `list_` en colecciones.
- **C16** rangos `{name, min, max, unit}` + `EUnit`.
- **C17** `question.text` nullable (ítems sin enunciado, ej. CDI).

**Dudas abiertas** (a resolver en el futuro):

- **`question.config`** ¿también lleva `unit`? (C16).
- **`target_*`** (`target_sex`, `list_age_groups`, `list_population`) ¿deberían ir
  dentro de `condition`? (C15).
- **IPAQ**: el drawio **no** define categorías; Alto/Moderado/Bajo vienen del AST
  estándar (nota en `ipaq.md`). Además, `TIMER` sin límites.
- **CRAFFT**: el nombre del CSV es "CARLOS (CRAFFT)"; los ítems **F** (truncado) y
  **T** (duplicado) venían rotos en el drawio (corregidos desde el legacy; nota en
  `crafft.md`).
- **CDI**: ítem 25 invertido respecto al estándar (nota en `cdi.md`).
- **"No sabe / no está seguro"** se representa como **`null`** (sin respuesta),
  no como opción.
