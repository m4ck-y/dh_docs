# ADR 043: AHF como componente/servicio dedicado (fuera del motor de formularios)

## Estado
Aceptado

## Contexto

La sección **B — Antecedentes Heredofamiliares (AHF)** de la historia clínica
(`docs/diagrams/0_HISTORIA_CLINICA`, tab B) registra enfermedades de los
familiares del paciente. Su forma no es una lista plana de preguntas, sino una
**matriz familiar × enfermedad**: ~6 familiares (padre, madre, hijos —repetible—,
abuelos) × enfermedades agrupadas en 13 categorías con códigos **CIE-11**, más
"¿vive actualmente?" + causa de fallecimiento **por familiar**.

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

## Modelo de datos (resuelto)

- **Familiar** = una **`people.person`** (basta `first_name` + apellidos).
- **Relación / árbol** → schema **`relationships`**: **`family`** (arista
  **dirigida** progenitor→hijo) + **`partnership`** (pareja, simétrica). Base del
  futuro **grafo** (migración a Neo4j).
- **Enfermedades del familiar** → **`clinical_history.condition`** (la padece la
  `person`); **fallecimiento** → **`health_profile.death`** (`deceased_at`,
  `cause_code`/`cause_text`); el flag `condition.contributed_to_death` marca la
  causa.
- **AHF = agregado**: `relationships.family` (¿quiénes?) + `clinical_history.condition`
  del pariente (¿qué padecen?) — **sin** tablas propias (**`family_member`/
  `family_condition` quedan descartadas**).
- **"Otro"** de la fuente = **buscador del CIE-11 completo** (no texto libre, no
  grano).
- `form.cie11_code` **no aplica** (es metadata del `form`, no un catálogo de
  enfermedades).

> El endpoint de AHF **lee/compone** (no almacena). **Pendiente de diseño** (no
> bloquea AHF): `clinical_history.encounter` + `encounter_diagnosis` (consultas).

## Alternativas consideradas y descartadas

1. **Form con secciones por familiar** (6 fijas) o **repetible**, con
   `MULTIPLE_CHOICE` + "Otro" por familiar. Descartada: no expresa la matriz
   (6×~N checkboxes) y pierde las vistas de ADR 037.

## Consecuencias

**Positivas:**
- Semántica de matriz preservada; CIE-11 nativo; **grafo reutilizable** (árbol
  genealógico, migración a Neo4j).
- No infla el motor de formularios con una estructura que no es lineal.
- **Sin duplicación**: el familiar es una `person` y su clínica vive en el dominio.

**Negativas:**
- AHF no participa del ciclo `form`/`assignment`/`answer`/progreso; requiere **UI
  propia** y un endpoint **agregador**.
- El `mapper` (pregunta→columna) no aplica a AHF (no hay preguntas planas).

## Referencias
- Flujo fuente: `docs/diagrams/0_HISTORIA_CLINICA/flows/antecedentes_heredofamiliares.mmd`
- Prototipos UI: [ADR 037](037-family-conditions-ui-prototype.md),
  `features/clinical_history/proposals/family_condition/`
- Esquemas: `docs/db/postgres/relationships/` (`family`), `clinical_history/`
  (`condition`), `health_profile/` (`death`).
- Tracker: `docs/tasks/TASK-017-historia-clinica/planning/OPEN-QUESTIONS.md`
  (H1)
