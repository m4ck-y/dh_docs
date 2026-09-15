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
- **Fuente humana** de cada instrumento: `docs/diagrams/<dominio>/flows/<key>.mmd`
  (+ `reviews/<key>-review.md`).

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
  "estimated_duration": { "min_minutes": 5, "max_minutes": 10, "description": "..." },
  "target_age_group": { "name": "...", "min_age": 18, "max_age": 99 },
  "target_sex": null,
  "list_references": [],
  "list_questions": [ /* ... */ ]
}
```

## Derivación

```
docs/diagrams/<dominio>/flows/<key>.mmd      (drawio -> mmd)
        + reviews/<key>-review.md            (tabla Puntuacion | Interpretacion)
        -> bank/instruments|clinical_history/<key>.json   (definicion)
        -> ../../expressions/                (scoring / evaluation)
```

## Pendientes

- Convertir los `.mmd` de `docs/diagrams/` a `<key>.json`.
- Completar `categories.json` con el vocabulario (columna `LS` del
  `docs/diagrams/catalog/instruments.csv`).
- Definir el/los formulario(s) de historia clínica (`clinical_history/`).
