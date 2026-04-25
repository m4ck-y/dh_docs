# ADR 004: Enfoque de Onboarding y Persistencia de Waitlist

## Estado
Aceptado

## Contexto
El sistema requiere un proceso de onboarding para convertir interesados (Waitlist) en usuarios activos. Existen dos enfoques principales: crear un schema de `onboarding` separado con datos temporales (Enfoque A), o utilizar la entidad `person` desde el inicio del proceso con estados de verificación (Enfoque B). Además, se requiere decidir el almacenamiento para la Waitlist.

## Decisión
Se han tomado las siguientes decisiones arquitectónicas:

1.  **Enfoque B (Person-first)**: Se opta por crear el registro en la tabla `people.person` de PostgreSQL en cuanto el aspirante inicia formalmente el onboarding.
    - El registro se creará con `verification_status = 'PENDING'`.
    - Esto permite reutilizar inmediatamente los schemas de `mfa` (para OTP), `expedient` (para documentos) y `people` (para datos demográficos) sin duplicar lógica o tablas.
    - Una vez finalizado y aprobado el proceso por un administrador, el status cambiará a `APPROVED`.

2.  **Waitlist en MongoDB**: La Waitlist (leads interesados) se mantendrá en **MongoDB**.
    - Dado que los datos de prospección pueden ser muy variables (fuentes de marketing, datos de contacto parciales, etc.), el esquema flexible de MongoDB es ideal.
    - Cuando un lead de la Waitlist es invitado o decide iniciar el onboarding, se gatilla la creación de la entidad `person` en PostgreSQL.

3.  **Segregación de Datos**: Todas las consultas del sistema que requieran "usuarios activos" o "personal del hospital" DEBEN filtrar explícitamente por `verification_status = 'APPROVED'`.

## Consecuencias
- **Positivas**: 
    - **Reutilización**: Máximo aprovechamiento de los schemas ya auditados (`people`, `auth`, `mfa`, `expedient`).
    - **Simplicidad**: Evita la complejidad de migrar datos de un schema de "applicant" temporal a los schemas finales.
    - **Flexibilidad**: MongoDB permite evolucionar los campos de la Waitlist sin migraciones de base de datos SQL.
- **Negativas**: 
    - **Polución de Datos**: La tabla `person` contendrá registros de procesos incompletos o rechazados.
    - **Complejidad de Query**: Requiere disciplina en el desarrollo para no incluir accidentalmente personas en estado `PENDING` en reportes o vistas operativas.
    - **Consistencia**: Requiere una integración entre el microservicio de Waitlist (Mongo) y el Core (Postgres).
