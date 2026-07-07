**Proyecto o Apartado:** Core Domain / dh_shared / FHIR Organization

**Título de la actividad o tarea:** Inicio de la Investigación del Recurso Organization (FHIR)

**Descripción de la actividad o tarea:**
Para continuar con la adopción progresiva del estándar FHIR en la plataforma de **Digital Hospital**, se ha dado inicio formal a la etapa de investigación y exploración del recurso **Organization** (Organización). Este componente es crucial para modelar las entidades jurídicas y operativas que interactúan en el ecosistema de salud, tales como hospitales corporativos, clínicas locales, laboratorios de análisis, departamentos gubernamentales e instituciones de seguros. El objetivo principal es analizar sus dependencias lógicas, el manejo de catálogos y sistemas de codificación locales (como la clave CLUES en México), y cómo este recurso se relaciona estructuralmente con otros componentes de datos del ecosistema.

**Beneficios Estratégicos y Funcionales:**
1. **Modelado Jerárquico de Unidades Médicas**: FHIR permite relacionar organizaciones de forma recursiva (organización padre e hijas), facilitando la representación de un gran corporativo hospitalario que cuenta con múltiples clínicas geográficas.
2. **Asociación de Recursos de Salud**: Servirá como pilar central de referencia para vincular pacientes (médicos o clínicas a cargo de su expediente), personal médico (`Practitioner`) y ubicaciones físicas (`Location`).
3. **Estandarización de Identificadores Institucionales**: Permite estructurar sistemas de identificación flexibles que admitan de forma nativa registros gubernamentales locales sin romper el formato estándar de intercambio.

*Detalles Técnicos y de Código:*
Se ha comenzado a explorar la especificación oficial de FHIR para definir los campos requeridos en el nuevo esquema de Pydantic:
- **Identificadores**: Configuración de sistemas de identificación múltiple (ej. RFC, CLUES, identificadores internos de seguro).
- **Tipos de Organización**: Clasificación mediante el sistema de códigos FHIR `organization-type` (ej. clin, dept, ins, pay, govt).
- **Contactos y Telecomunicaciones**: Puntos de contacto dedicados para el personal administrativo o de emergencias de la organización.
- **Relaciones con el Recurso `Location`**: Mapeo preliminar de cómo vincular una entidad administrativa con sus locaciones físicas y salas de hospitalización.

**Estado de la actividad o tarea:** En desarrollo

**Avances de la actividad (si lo requiere):**
- Revisión de la especificación técnica oficial del recurso `Organization` de HL7 FHIR v4.3.0.
- Definición de dependencias lógicas en el esquema relacional actual (`org.Company` y `org.Location` en la librería `dh_shared`).
- Diseño preliminar de los tipos de datos comunes que serán compartidos con otros esquemas de interoperabilidad.
