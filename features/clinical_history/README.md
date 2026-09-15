# Historia clínica

Especificaciones de la **historia clínica** del Hospital Digital. Se compone de
formularios estructurales (secciones A-E) que se modelan y almacenan con el
mismo motor/catálogo de formularios del módulo
[`../questionnaires/`](../questionnaires/) (`form.kind = CLINICAL_HISTORY`).

**Estado:** En definición (sección A modelada; AHF con propuesta de UI).

**Depende de:** [`questionnaires/`](../questionnaires/) — motor, schema (`form`,
`question`, `section`, `answer`, `assignment`) y banco
(`catalog/bank/clinical_history/`).

## Estructura

| Carpeta | Contenido |
|---|---|
| [`sections/`](./sections/) | Una ficha por sección del expediente (estructura del formulario: preguntas, opciones, subrutas). |
| [`proposals/`](./proposals/) | Prototipos de UI (propuestas, no diseño final). |

**Mapeo a dominio:** los vínculos pregunta → propiedad de dominio viven en el
feature [`../mapper/`](../mapper/) (vista en
[`../mapper/views/clinical_history/`](../mapper/views/clinical_history/)).

**Fuente de los flujos:** `docs/diagrams/0_HISTORIA_CLINICA/` (drawio + `flows/`
`.mmd` + `activation/` con los anexos).

## Secciones

| # | Sección | Ficha | Vínculos (mapper) |
|---|---|---|---|
| A | Registro | [`sections/A_registro.md`](./sections/A_registro.md) | [`views/clinical_history/A_registro.md`](../mapper/views/clinical_history/A_registro.md) |
| B | Antecedentes heredofamiliares | ⏳ | ⏳ |
| C | APNP | ⏳ | ⏳ |
| D | Antecedentes personales patológicos | ⏳ | ⏳ |
| E | Padecimiento actual | ⏳ | ⏳ |

## Propuestas UI

- [`proposals/family_condition/`](./proposals/family_condition/): prototipos de
  **Antecedentes Heredofamiliares (AHF)**. **Prototipo de propuesta, no el
  diseño final.** Ver [ADR 037](../../decisions/037-family-conditions-ui-prototype.md).

## Convención

- Cada sección produce una ficha `<seccion>.md` en `sections/`.
- El mapeo a dominio (pregunta → entidad/columna) vive en el feature
  [`../mapper/`](../mapper/): contrato en `mapper/README.md` y vista legible en
  `mapper/views/<dominio>/`.
- Contenido en español; carpetas y nombres de archivo en inglés `snake_case`.
