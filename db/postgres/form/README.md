# Schema: Form

## Propósito

Esquema PostgreSQL para el **catálogo de cuestionarios** (encuestas y formularios
de salud): definición de los instrumentos (form, preguntas, opciones, secciones,
condiciones, scoring/interpretación) y, a futuro, el modelo de ejecución
(asignación, agendamiento, respuesta y respuestas individuales).

## Estado

En definición — diseño en curso.

## Diagramas

- **ERD (v1)**: [ERD_v1.mmd](./ERD_v1.mmd)

> Convención de naming `v1`: el sufijo `v1` se eliminará cuando el diseño alcance
> su forma definitiva ("absoluta").

## Fuente

- **`FormsFlow2.drawio`** — primer modelo de datos del catálogo (retomado),
  3 pestañas: `Página-1` (ERD de definición), `FORM_DETAIL-ERD-JSON` (JSON
  aplanado), `anwers` (ejecución + DDL SQL + endpoints). Conservado en
  `reference_projects/reference_questionnaire_v1_legacy/`.

El `ERD_v1.mmd` es la versión pulida derivada de esa fuente.

## Relaciones Externas

- **people**: las entidades de ejecución (asignación/respuesta) referencian
  `people.person`.
