# ADR 043: AHF como componente/servicio dedicado (fuera del motor de formularios)

## Estado
Aceptado

## Contexto

La sección **B — Antecedentes Heredofamiliares (AHF)** de la historia clínica
(`docs/diagrams/0_HISTORIA_CLINICA`, tab B) registra enfermedades de los
familiares del paciente. Su forma no es una lista plana de preguntas, sino una
**matriz familiar × enfermedad**: ~6 familiares (padre, madre, hijos —repetible—,
abuelos) × ~60 enfermedades agrupadas en 13 categorías con códigos **CIE-11**,
más "¿vive actualmente?" + causa de fallecimiento **por familiar** y "Otro"
texto libre por celda.

Los prototipos UI ([ADR 037](037-family-conditions-ui-prototype.md),
`features/clinical_history/proposals/family_condition/`) ya confirmaron esta
naturaleza matricial (vistas matrix/árbol/lista, "¿Vive?" elevado al ámbito del
familiar, "Otro" con clave compuesta).

El contrato `form` (TASK-016) modela formularios como listas lineales de
preguntas (`question` + `option` + `condition` + `expression`). No expresa una
matriz de dos ejes sin degenerar en cientos de preguntas si/no.

## Decisión

**AHF no se modela como `form.section`.** Es un **componente/servicio dedicado**
(captura tipo family-tree) con su **propio endpoint**, fuera de `form`/`answer`:

- El frontend lo presenta como una **sección de la HC** (tras el Registro A),
  pero a nivel de modelo **no** es `form.section`.
- Sus datos son **de dominio de la persona** (`id_person`), persistentes y
  precargables (no respuestas inmutables de un `assignment`).

**El modelado de sus entidades queda pendiente** en esta fase:
`family_member`, `family_condition` y el catálogo `disease`/`disease_category`
(+ su endpoint). Sub-decisiones abiertas: schema de destino (`family_history` vs
`health_profile`), reuso de CIE-11 (`form.cie11_code`) y grano de "Otro"
(por categoría vs por enfermedad).

## Alternativas consideradas y descartadas

1. **Form con secciones por familiar** (6 fijas) o **repetible**, con
   `MULTIPLE_CHOICE` + "Otro" por familiar. Descartada: no expresa la matriz
   (6×~60 checkboxes), dificulta "Otro" por celda y pierde las vistas de ADR 037.

## Consecuencias

**Positivas:**
- Semántica de matriz preservada; CIE-11 nativo; reutilizable para árbol
  genealógico y reportes.
- No infla el motor de formularios con una estructura que no es lineal.

**Negativas:**
- AHF no participa del ciclo `form`/`assignment`/`answer`/progreso; requiere
  persistencia y UI propias.
- El `mapper` (pregunta→columna) no aplica a AHF (no hay preguntas planas).

## Referencias
- Flujo fuente: `docs/diagrams/0_HISTORIA_CLINICA/flows/antecedentes_heredofamiliares.mmd`
- Prototipos UI: [ADR 037](037-family-conditions-ui-prototype.md),
  `features/clinical_history/proposals/family_condition/`
- Tracker: `docs/tasks/TASK-017-historia-clinica/planning/OPEN-QUESTIONS.md`
  (H1)
