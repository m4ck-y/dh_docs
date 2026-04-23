**Proyecto o Apartado:** Base de Datos PostgreSQL / Historial Clínico

**Título de la actividad o tarea:** Modelado y Mapeo del Schema para la Sección "A. Registro" del Historial Clínico

**Descripción de la actividad o tarea:**
El historial clínico es el núcleo de cualquier plataforma hospitalaria. Antes de construir formularios o flujos de captura, se requiere garantizar que cada dato que un paciente o su tutor proporcione al registrarse tenga un destino claro y estructurado en la base de datos. Sin este mapeo previo, los equipos de desarrollo suelen generar columnas redundantes, datos sin tipado o estructuras difíciles de consultar a futuro.

Se llevó a cabo el análisis completo de la primera sección del historial clínico ("A. Registro"), extraída del diagrama de flujo original en draw.io. Dicha sección abarca dos rutas: el registro mediado por un tutor o responsable, y el registro directo del usuario. Para cada campo del formulario se identificó la entidad, columna y valor exacto en la base de datos PostgreSQL donde debe persistirse la información.

**Beneficios Estratégicos y Funcionales:**
1. **Trazabilidad total del formulario**: Cada pregunta, opción y campo de texto libre del formulario queda vinculado a su correspondiente `schema.entidad.columna`, eliminando ambigüedad en el desarrollo del backend.
2. **Estandarización con enums**: Las respuestas de opción múltiple se modelaron como enums tipados en lugar de strings libres, garantizando integridad referencial y facilitando filtros, reportes y analítica clínica.
3. **Soporte de privacidad**: Se estableció la convención de `NULL` para la opción "Prefiere no decirlo" en todos los campos sensibles (sexo biológico, religión, estado civil, ingresos, escolaridad), permitiendo capturar la preferencia del usuario sin forzar un valor.
4. **Convención de campos libres**: Para opciones del tipo "Otro — Especifique", se adoptó el patrón `{campo}_other` (`relationship_other`, `occupation_other`, `religion_other`) de forma uniforme en todos los schemas afectados.

*Detalles Técnicos:*

Se crearon y modificaron entidades en cuatro schemas de PostgreSQL:

**Schema `health_profile` (nuevo):**
- Se introdujo la entidad `biological_profile` (relación 1:1 con `person`) con el enum `EBiologicalSex` (`HOMBRE`, `MUJER`, `INTERSEXUAL`), separando explícitamente el concepto de sexo biológico al nacer de la identidad de género ya existente en `people.person.type_gender`.
- Se incorporaron entidades para el perfil clínico estable: `person_allergy`, `chronic_condition` y `vaccination_record`.

**Schema `people`:**
- `sociocultural_identity`: Se agregó la columna `religion_other String(100)` para capturar la descripción libre cuando la religión seleccionada es "Otra".
- `profile`: Se reemplazó el campo `occupation String` (texto libre sin estructura) por `occupation_type Enum(EOccupationType)` y se agregó `occupation_other String(100)`. Se incorporaron también `education_level Enum(EEducationLevel)` e `income_range Enum(EIncomeRange)`.
- `legal_info`: Se migró `type_civil_status String` a `civil_status Enum(ECivilStatus)`.
- `emergency_contact`: Se agregó el valor `CAREGIVER` al enum `ERelationshipContact` y la columna `relationship_other String(100)`.

**Nuevos enums en `people`:**
- `EOccupationType`: `EMPLOYED`, `SELF_EMPLOYED`, `FREELANCE`, `HOMEMAKER`, `UNEMPLOYED`, `RETIRED`, `OTHER`, `PREFERS_NOT_TO_SAY`
- `ECivilStatus`: `SINGLE`, `MARRIED`, `COMMON_LAW`, `SEPARATED`, `DIVORCED`, `WIDOWED`, `PREFERS_NOT_TO_SAY`
- `EEducationLevel`: `NO_STUDIES`, `PRIMARY`, `SECONDARY`, `HIGH_SCHOOL`, `UNIVERSITY`, `POSTGRADUATE`, `PREFERS_NOT_TO_SAY`
- `EIncomeRange`: `NO_INCOME`, `UNDER_5000`, `FROM_5000_TO_9999`, `FROM_10000_TO_19999`, `FROM_20000_TO_39999`, `FROM_40000`, `PREFERS_NOT_TO_SAY`

**Schema `care`:**
- `person_responsible`: Se agregó `economic_dependence Enum(EEconomicDependence)` (`YES`, `PARTIALLY`, `NO`) para registrar si el usuario depende económicamente del tutor. Se renombró `other_relationship` a `relationship_other` para consistencia con la convención `{campo}_other`.

**Documentación generada:**
Se estableció la convención de que cada sección del historial clínico produce dos archivos: `<SECCIÓN>.md` (estructura del formulario) y `<SECCIÓN>.MAPPER.md` (mapeo a la DB). Los archivos `historial_clinico/A.REGISTRO.md` y `historial_clinico/A.REGISTRO.MAPPER.md` quedan como referencia base para las secciones posteriores.

**Estado de la actividad o tarea:** En desarrollo

**Avances de la actividad (si lo requiere):**
- Modelado de datos y diseño de schema completado: todos los campos de la sección "A. Registro" cuentan con entidad, columna y valor mapeados.
- Mapeo completo de los 40+ campos — sin campos 🔴 sin modelar al cierre de esta fase.
- Gap único pendiente: catálogo `catalog.religion` sin poblar — los campos `key_religion` de `sociocultural_identity` permanecen en 🟡 hasta que dicho catálogo sea definido.
- Convenciones establecidas y documentadas en `historial_clinico/README.md` para uso en secciones futuras del historial clínico.

**Siguientes pasos:**
- Implementación de endpoints REST para la captura y persistencia de los datos de la sección "A. Registro".
- Modelado y mapeo de las secciones restantes del historial clínico.
