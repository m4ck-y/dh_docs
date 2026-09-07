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

## Diagrama de clases / modelo de documentos

Además del ERD relacional, se mantiene `CLASS_V2.mmd`: una representación
orientada a objetos/documentos del mismo dominio. Su propósito es mostrar cómo
se vería el catálogo de cuestionarios si se persiste en una base de datos NoSQL
(p. ej. MongoDB), donde `Form`, `Section`, `Question`, `Option`, `Conditional` y
`Url` se modelan como documentos/subdocumentos embebidos en lugar de tablas
normalizadas.

- Las relaciones de composición (`◆`) indican subdocumentos embebidos.
- Las relaciones de agregación/asociación (`◇`, `──>`) indican referencias a
  otros documentos.
- `CLASS_V2.mmd` no reemplaza a `ERD_v1.mmd`; son dos vistas del mismo modelo
  para dos tecnologías de persistencia distintas.

## Limitantes del modelo de documentos

Al usar un diseño orientado a documentos hay que tener en cuenta:

- **Límite de 16 MB por documento en MongoDB**: un cuestionario muy grande podría
  acercarse a este tope si se embeben todas las preguntas, opciones y metadatos
  en un solo documento. Para los instrumentos actuales (GDS-15, PHQ-9, etc.) no
  es un problema.
- **Embebido vs. referencia**: embeber es eficiente para lectura, pero dificulta
  reutilizar preguntas/opciones entre formularios. Si se necesita reutilización,
  conviene usar referencias a otra colección.
- **Duplicación de datos**: metadatos como categorías, referencias, duración
  estimada, grupos de edad, etc., pueden repetirse en cada documento si se
  embeben. Evaluar si vale la pena normalizarlos en colecciones aparte.
- **Ausencia de esquema rígido**: MongoDB no impone un esquema, por lo que
  `CLASS_V2.mmd` actúa como convenio de aplicación, no como restricción de la
  base de datos.

## Convenciones

- Cumple `.agents/rules/DOCUMENTATION_ERD.md` (relaciones → enums → entidades;
  tipos UPPERCASE; labels descriptivos) y
  `.agents/rules/MERMAID_ENUM_REPRESENTATION.md` (enums standalone con prefijo `E`).
- **BaseModel**: todas las tablas heredan `id` (Integer PK interno incremental),
  `uuid` (UUID externo), `created_at`, `updated_at`, `deleted_at`, `*_by_id_user`.
  Solo se anotan en el comentario del encabezado del ERD; no se listan como
  columnas (excepto `id`, mostrado por claridad).
- **FKs**: referencian el `id Integer` interno de la tabla destino (no el `uuid`).
- `EBiologicalSex` se comparte con `health_profile` (definido standalone en cada
  ERD, por convención Mermaid).
- **Excepción documentada**: las tablas puente N:N conservan `id` propio (no PK
  compuesta), a diferencia de la regla `PYTHON_INFRA_DB_BASE_MODEL.md` para N:N puras.

## Fuente

- **`FormsFlow2.drawio`** — primer modelo de datos del catálogo (retomado),
  3 pestañas: `Página-1` (ERD de definición), `FORM_DETAIL-ERD-JSON` (JSON
  aplanado), `anwers` (ejecución + DDL SQL + endpoints). Conservado en
  `reference_projects/reference_questionnaire_v1_legacy/`.

El `ERD_v1.mmd` es la versión pulida derivada de esa fuente.

## Relaciones Externas

- **people**: las entidades de ejecución (asignación/respuesta) referencian
  `people.person`.
