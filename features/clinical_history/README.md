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
| [`contracts/`](./contracts/) | Contratos de API/dominio para los componentes de dominio (ej. [`medication_statement.md`](./contracts/medication_statement.md)). |
| [`proposals/`](./proposals/) | Prototipos de UI (propuestas, no diseño final). |

**Mapeo a dominio:** el feature [`../mapper/`](../mapper/) vincula **preguntas de
`form`** con propiedades de dominio. Los **componentes** (A/B/D) **no** pasan por el
mapper: su contrato (componente → dominio) se documenta en [`contracts/`](./contracts/)
(ej. [`medication_statement`](./contracts/medication_statement.md)). El resto de endpoints
responsables está en definición (ver [`sections/README.md`](./sections/README.md)).

> **Desviación FHIR (medicación):** `clinical_history.medication_statement.status` usa un
> **estado clínico** (`ACTIVE`/`COMPLETED`/`STOPPED`/`ON_HOLD`), **no** el
> `MedicationStatement.status` de FHIR R5 (`recorded`/`entered-in-error`/`draft`).
> **Pendiente de revisión posterior** — ver
> [`contracts/medication_statement.md`](./contracts/medication_statement.md).

**Fuente de los flujos:** `docs/diagrams/0_HISTORIA_CLINICA/` (drawio + `flows/`
`.mmd` + `activation/` con los anexos).

## Secciones

| # | Sección | Ficha | Vínculos (mapper) |
|---|---|---|---|
| A | Registro | componente de dominio ([ADR 045](../../decisions/045-historia-clinica-componentes-vs-formularios.md)) — spec en [`sections/A_registro.md`](./sections/A_registro.md) | ⏳ (componente → dominio pendiente) |
| B | Antecedentes heredofamiliares | componente propio ([ADR 043](../../decisions/043-ahf-componente-dedicado.md)) — spec en [`sections/B_ahf.md`](./sections/B_ahf.md) | — |
| C | APNP | [`sections/C_apnp.md`](./sections/C_apnp.md) | ⏳ |
| D | Antecedentes personales patológicos | híbrido ([ADR 045](../../decisions/045-historia-clinica-componentes-vs-formularios.md)) — spec en [`sections/D_antecedentes_pp.md`](./sections/D_antecedentes_pp.md) | ⏳ |
| E | Padecimiento actual | [`sections/E_padecimiento_actual.md`](./sections/E_padecimiento_actual.md) | ⏳ |

> **Bloqueos**: **D** es **híbrido** (ficha lista; **H2** y **H5** cerrados); sus
> **componentes** se **inyectan** por el front. **A** y **B** son **componentes de
> dominio** (ADR 045 / ADR 043), con modelado pendiente. **C** tiene banco
> (`bank/clinical_history/apnp.json`); **D** banco del `form`
> (`antecedentes_pp.json`); **E** ficha lista (banco diferido).

## Clasificación por bloque

Qué parte de cada sección es **endpoint/componente**, **form** (cuestionario) o
**catálogo** (ver ADR 045 / ADR 046). Las celdas `¿?` son decisiones
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
| **E — Padecimiento** | motivo + caracterización del síntoma | ¿? | ✅ | body, studies | decidir `Encounter`/`Condition` |

> Las preguntas de elección son **enum** (`list_options.items`) o **catálogo**
> (`list_options.catalog.key`). El **motor** y la **política** del catálogo los
> define el **registro** ([`../catalogs/`](../catalogs/)); la ficha solo apunta al
> `key`. Regla:
> [`sections/README.md`](./sections/README.md#enum-o-catálogo).

## Anexos de activación (C/D)

Los tabs **ANEXO C** ([`activation/anexo_c.mmd`](../../diagrams/0_HISTORIA_CLINICA/activation/anexo_c.mmd))
y **ANEXO D** ([`activation/anexo_d.mmd`](../../diagrams/0_HISTORIA_CLINICA/activation/anexo_d.mmd))
del drawio (`docs/diagrams/0_HISTORIA_CLINICA/`) son **reglas de activación**
(*respuesta de la HC → cuestionario habilitado*), **no** secciones del expediente.
**Viven en el `form.condition` del instrumento** que se habilita (mecanismo
[ADR 039](../../decisions/039-condicion-visibilidad-ast.md): *"el formulario se
habilita si…"*); representación con el selector `uuid` y evaluación por `person`
([ADR 047](../../decisions/047-contexto-evaluacion-expresiones.md)). Ver
[H4](../../tasks/TASK-017-historia-clinica/planning/OPEN-QUESTIONS.md) — queda
abierto solo para **enfermedades/medicamentos** (entidades de dominio).

Su **nomenclatura no coincide** con las secciones reales: usan "Formulario A/B/C"
donde `B` = *Padecimiento actual* (nuestra **E**) y `C` = *Antecedentes personales
patológicos* (nuestra **D**).

### Reconciliación (a revisar/validar)

| Anexo | Sección real |
|---|---|
| `A.1.0` (tutor) | **A** — Registro (`1.0`) |
| `A.1.2.13` (edad) | **A** — edad |
| `B.2.0` (motivo / `2.1–2.4`) | **E** — Padecimiento |
| `C.1.1` (mental) | **D** — categoría **`2.4`** (mente/emociones) |
| `C.2.1.*` (enfermedades) · `C.2.2.1.1.1` (medicamentos) · `C.3.0/4.0/5.0` (tabaco/alcohol/drogas) | **D** |
| `j-2.0` (Nutrición) | *fuera de la HC* (formulario de Nutrición) |

> Mapa **provisional**: hay que **revisarlo/validarlo** contra el drawio.

### Gaps / divergencias de la fuente

- La categoría **`2.4 Mente, emociones y aprendizaje`** de **D** **no incluye**
  varias condiciones que el anexo **sí** activa. **Se agregaron temporalmente** para
  que esos activadores funcionen:

  | Condición | Instrumento (anexo) |
  |---|---|
  | Estrés | PSS |
  | Estrés postraumático | DTS |
  | Fobia social | SPIN |
  | Alexitimia | TAS-20 |

- El anexo **se contradice**: depresión en `2.1.8` (Anexo C) vs `2.1.6` (Anexo D).
- El bloque `1.0/1.1 MENTAL` del anexo **se mapea a la categoría `2.4`** (no se
  agrega un `1.0`).

### Activadores por fuente

| Activador | Fuente |
|---|---|
| `A.1.0` (tutor) · `A.1.2.13` (edad) | **dominio** (`care.person_responsible`, `people.birth`) |
| `C.2.1.*` (enfermedades) · medicamentos | **dominio** (`clinical_history.condition`, …) |
| `C.3.0/4.0/5.0` (tabaco/alcohol/drogas) · `B.2.0` (motivo) | **`answer`** (respuestas de D/E) |
| `j-2.0` (Nutrición) | fuera de la HC |

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
- El mapeo a dominio **pregunta → columna** vive en el feature
  [`../mapper/`](../mapper/) (contrato en `mapper/README.md`); aplica **solo a
  `form`**. Los **componentes** (A/B/D) documentan su contrato **componente →
  dominio** aparte (pendiente; ver [`sections/README.md`](./sections/README.md)).
- Contenido en español; carpetas y nombres de archivo en inglés `snake_case`.
