# ADR 045: Historia clínica — componentes/endpoints de dominio vs formularios

## Estado
Aceptado

## Contexto

La historia clínica (secciones A–E) se planteó como formularios estructurales
(`form.type = CLINICAL_HISTORY`) reutilizando el motor de cuestionarios. Pero no
todas las secciones son cuestionarios:

- **A (Registro)** captura el perfil de la persona (nombre, nacimiento,
  domicilio/teléfonos/correos, tutor, contacto de emergencia) con **cardinalidad
  1:N** en el dominio (`people.address/phone/email`, `care.person_responsible`,
  `people.emergency_contact`).
- **B (AHF)** es una **matriz** familiar × enfermedad (ya decidido componente en
  [ADR 043](043-ahf-componente-dedicado.md)).
- **D (Antecedentes PP)** contiene **registros clínicos** (cirugías, lesiones,
  hospitalizaciones) que son recursos de dominio.

Un `form` (lista lineal de preguntas + `answer` por evento) no representa bien
matrices, registros repetibles ni el perfil multi-valor.

## Decisión

Clasificar **cada sección** de la HC según su naturaleza, usando **form** o
**componente/endpoint de dominio**:

| Sección | Modelado | Recurso FHIR / dominio |
|---|---|---|
| A — Registro | **Componente** (perfil, CRUD 1:N) | `Patient` + `RelatedPerson` (`people`/`care`) |
| B — AHF | **Componente** (matriz) | `FamilyMemberHistory` (ADR 043) |
| C — APNP | **Form** (hábitos) | `Questionnaire`/`QuestionnaireResponse` |
| D — Antec. PP | **Híbrido**: form (preguntas planas) + componentes (registros) | `Condition`/`AllergyIntolerance`/`Procedure`/`Encounter` |
| E — Padecimiento actual | **Form** | `Questionnaire`/`QuestionnaireResponse` |

### Criterio

| Es un **form** si… | Es un **componente** si… |
|---|---|
| Lista lineal de preguntas con opciones | Matriz, registros repetibles o perfil con entidad de dominio propia |
| Captura por evento (`assignment`/`answer`) | Dato persistente de la persona (CRUD, precarga) |
| Sin cardinalidad propia (1 respuesta por pregunta) | Cardinalidad **1:N / N:N** en el dominio |

### Secciones híbridas (D)

Una sección puede ser **híbrida**: `form` (preguntas planas) **+** componentes de
dominio (registros). En ese caso:

- El **`form`** del banco (`bank/clinical_history/`) incluye **solo las preguntas
  nativas**; los **componentes** (registros) **no** se modelan en el `form`.
- El **frontend compone** la sección: renderiza el `form` e **inyecta** los
  componentes en su punto del orden de la sección.
- El front reconoce la sección híbrida **por el `key` (o `id`) del `form`**
  (registro en el front: `key → componentes + orden`), **sin** agregar campos al
  `form` ni cambiar su shape.

Ver pendiente de composición: `OPEN-QUESTIONS.md` (H5).

## Consecuencias

**Positivas:**
- Cada sección se modela donde encaja; se evita forzar matrices/perfiles a
  preguntas lineales.
- Alinea con FHIR R5 ([ADR 036](036-fhir-r5-adoption.md)) y la persistencia
  híbrida (TASK-015).

**Negativas:**
- La HC es heterogénea: el `form` cubre solo C/E (y el form de D); los
  componentes requieren endpoints/UI propios y no participan del progreso del
  motor.

**Aplicación:**
- El banco `bank/clinical_history/` guarda **solo forms** (C/E, form de D); A/B
  no tienen banco.
- El `mapper` (pregunta→columna) aplica a **forms**; para **componentes** el
  contrato es **componente→dominio** (vista legible en `mapper/views/`).
- Los "Otro/Especifique" de ambos usan **catálogos gobernados**
  ([ADR 044](044-catalogos-gobernados.md)).

## Referencias
- Componente AHF: [ADR 043](043-ahf-componente-dedicado.md)
- FHIR R5: [ADR 036](036-fhir-r5-adoption.md)
- Catálogos: [ADR 044](044-catalogos-gobernados.md)
- Secciones: `features/clinical_history/sections/`
