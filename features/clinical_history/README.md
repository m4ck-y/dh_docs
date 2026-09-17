# Historia clínica

Especificaciones de la **historia clínica** del Hospital Digital. Se compone de
**formularios** (secciones C, D, E — motor de [`../questionnaires/`](../questionnaires/),
`form.type = CLINICAL_HISTORY`) y **componentes/endpoints de dominio** (A, B),
según el criterio de [ADR 045](../../decisions/045-historia-clinica-componentes-vs-formularios.md).

**Estado:** En definición (A = componente de dominio; AHF = componente propio,
modelado pendiente).

**Depende de:** [`questionnaires/`](../questionnaires/) — motor, schema (`form`,
`question`, `section`, `answer`, `assignment`) y banco
(`catalog/bank/clinical_history/`).

## Estructura

| Carpeta | Contenido |
|---|---|
| [`sections/`](./sections/) | Una ficha por sección del expediente (estructura del `form` **o** del componente: preguntas/opciones/subrutas). |
| [`proposals/`](./proposals/) | Prototipos de UI (propuestas, no diseño final). |

**Mapeo a dominio:** los vínculos pregunta → propiedad de dominio viven en el
feature [`../mapper/`](../mapper/) (vista en
[`../mapper/views/clinical_history/`](../mapper/views/clinical_history/)).

**Fuente de los flujos:** `docs/diagrams/0_HISTORIA_CLINICA/` (drawio + `flows/`
`.mmd` + `activation/` con los anexos).

## Secciones

| # | Sección | Ficha | Vínculos (mapper) |
|---|---|---|---|
| A | Registro | componente de dominio ([ADR 045](../../decisions/045-historia-clinica-componentes-vs-formularios.md)) — spec en [`sections/A_registro.md`](./sections/A_registro.md) | [contrato dominio](../mapper/views/clinical_history/A_registro.md) |
| B | Antecedentes heredofamiliares | componente propio ([ADR 043](../../decisions/043-ahf-componente-dedicado.md)) — spec en [`sections/B_ahf.md`](./sections/B_ahf.md) | — |
| C | APNP | [`sections/C_apnp.md`](./sections/C_apnp.md) | ⏳ |
| D | Antecedentes personales patológicos | híbrido ([ADR 045](../../decisions/045-historia-clinica-componentes-vs-formularios.md)) — spec en [`sections/D_antecedentes_pp.md`](./sections/D_antecedentes_pp.md) | ⏳ |
| E | Padecimiento actual | [`sections/E_padecimiento_actual.md`](./sections/E_padecimiento_actual.md) | ⏳ |

> **Bloqueos**: **D** es **híbrido** (ficha lista; **H2 cerrado** = registros 1:N →
> componentes); sus **componentes** tienen composición pendiente (**H5**). **A** y
> **B** son **componentes de dominio** (ADR 045 / ADR 043), con modelado pendiente.
> **C** tiene banco (`bank/clinical_history/apnp.json`); **D** banco del `form`
> (`antecedentes_pp.json`); **E** ficha lista (banco diferido).

## Clasificación por bloque

Qué parte de cada sección es **endpoint/componente**, **form** (cuestionario) o
**catálogo gobernado** (ver ADR 045 / ADR 046). Las celdas `¿?` son decisiones
abiertas (ver
[`OPEN-QUESTIONS.md`](../../tasks/TASK-017-historia-clinica/planning/OPEN-QUESTIONS.md)).

| Cuestionario / sección | Bloque | Endpoint (componente) | Form (answers) | Catálogo(s) | Decisión / Notas |
|---|---|---|---|---|---|
| **A — Registro** | perfil (tutor, domicilio, contacto) | ✅ | — | religión, ocupación, relación, género | ADR 045 |
| **B — AHF** | matriz familiar × enfermedad | ✅ | — | disease, disease_category | ADR 043 |
| **C — APNP** (`apnp`) | vivienda / higiene / trabajo / actividad / sueño / vacunas | — | ✅ | housing_type, fuel_type, animal_type, work_shift | form |
| **D — Antec. PP** | tabaco / alcohol / drogas / donación | — | ✅ | — | form |
| **D — Antec. PP** | alergias | ✅ | — | — | `AllergyIntolerance` |
| **D — Antec. PP** | cirugías / lesiones / transfusiones | ✅ | — | — | `Procedure` (H2) |
| **D — Antec. PP** | hospitalizaciones | ✅ | — | — | `Encounter` (H2) |
| **D — Antec. PP** | enfermedades `2.0` | ✅ | — | disease | componente `Condition` (1:N) |
| **E — Padecimiento** | motivo + caracterización del síntoma | ¿? | ✅ | body, studies | decidir `Encounter`/`Condition` (H3) |

## Propuestas UI

- [`proposals/family_condition/`](./proposals/family_condition/): prototipos de
  **Antecedentes Heredofamiliares (AHF)**. **Prototipo de propuesta, no el
  diseño final.** Ver [ADR 037](../../decisions/037-family-conditions-ui-prototype.md).

## Convención

- **Cadena de verdad**: `drawio → .mmd → ficha → artefacto` (`bank JSON` para un
  `form`; contrato de dominio para un componente). La ficha es **derivada** y
  debe **reconciliarse** con el `.mmd` antes de crear el artefacto; las
  divergencias intencionales y los TODO de la fuente se anotan (ver
  [`sections/README.md`](./sections/README.md)).
- Cada sección produce una ficha `<seccion>.md` en `sections/`.
- El mapeo a dominio (campo → entidad/columna) vive en el feature
  [`../mapper/`](../mapper/): contrato en `mapper/README.md` y vista legible en
  `mapper/views/<dominio>/`.
- Contenido en español; carpetas y nombres de archivo en inglés `snake_case`.
