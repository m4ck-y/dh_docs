**Proyecto o Apartado:** Core Domain / dh_shared / FHIR Patient

**Título de la actividad o tarea:** Investigación e Implementación del Esquema Pydantic para el Recurso Patient (FHIR)

**Descripción de la actividad o tarea:**
Como primer paso práctico para la adopción del estándar FHIR en la capa de comunicación y persistencia del ecosistema, se inició el análisis a bajo nivel e implementación en Python del recurso **Patient** (Paciente). El objetivo principal de esta actividad es construir los esquemas de validación de Pydantic que sirvan como base para los endpoints de la API, comprender a fondo sus relaciones internas y dependencias de tipos de datos, y alinear este estándar internacional con las tablas relacionales existentes en la base de datos de la plataforma.

**Beneficios Estratégicos y Funcionales:**
1. **Validación Estricta de Restricciones Clínicas**: FHIR exige que el campo `contact` de un paciente tenga datos de contacto válidos o una referencia a una organización. Al implementar esta validación en Python, se evitan errores de datos huérfanos o incompletos antes de guardarlos.
2. **Estructura Demográfica Universal**: Se da soporte a estructuras complejas como múltiples nombres (`HumanName`), direcciones físicas (`Address`), contactos de emergencia (`PatientContact`) e idiomas de comunicación preferidos (`PatientCommunication`), logrando un perfil clínico sumamente rico y estándar.
3. **Paso Previo al Desarrollo de las APIs**: Contar con los esquemas de datos validados y probados en la librería central (`dh_shared`) reduce considerablemente la complejidad y el tiempo de codificación al momento de construir los endpoints REST en `dh_core` y otros microservicios.

*Detalles Técnicos y de Código:*
Se ha programado formalmente la estructura de validación en Python dentro de `dh_shared` (`dh_shared/src/dh_shared/schemas/shared/fhir/resources/patient.py`). Los componentes críticos implementados incluyen:
- **`Patient`**: Clase principal (`BaseModel`) que expone los atributos estandarizados de FHIR como `resourceType`, `identifier`, `active`, `name` (lista de `HumanName`), `telecom` (lista de `ContactPoint`), `gender` (Enum `AdministrativeGender`), `birthDate`, `deceased[x]`, `address`, `contact`, `communication`, y enlaces a otros expedientes (`link`).
- **`PatientContact`**: Modelo para contactos de emergencia o tutores legales. Se implementó una regla de validación de restricciones personalizada mediante `@model_validator(mode="after")` para asegurar que el contacto cuente por lo menos con información personal (nombre, telecomunicación, dirección) o, en su defecto, una referencia a una organización responsable.
- **`PatientCommunication`**: Modelo que especifica las preferencias lingüísticas del paciente para garantizar una comunicación comprensible durante la consulta médica.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Escritura y depuración del archivo de esquemas de pacientes (`patient.py`) y sus tipos de datos relacionados (Attachment, CodeableConcept, HumanName, Period, Reference).
- Implementación de pruebas de validación automatizadas para verificar que las restricciones de FHIR (como las llaves de contacto obligatorias) lancen las excepciones correctas (`ValueError`) cuando los datos estén mal formados.
- Planificación del mapeo de estos esquemas hacia los modelos relacionales de la base de datos PostgreSQL, preparando la transición para la posterior implementación de las APIs CRUD en los microservicios.
