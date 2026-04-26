# Matriz de Acceso: Servicios y Schemas de Datos

Este documento define la propiedad y los permisos de acceso de cada microservicio sobre los diferentes schemas y bases de datos del ecosistema.

## Principios de Acceso
1.  **Propiedad (Owner)**: Solo un microservicio debe ser el dueño (escritura/migraciones) de un schema específico.
2.  **Acceso Indirecto**: Los servicios deben preferir consultar datos a través de APIs de otros servicios en lugar de acceso directo a la DB (desacoplamiento).
3.  **Solo Lectura (Read-Only)**: En casos excepcionales de alto rendimiento, se permite acceso de solo lectura a schemas ajenos.

## Matriz de Persistencia Relacional (PostgreSQL)

| Servicio | Schema | Acceso | Notas |
|:---------|:-------|:------:|:------|
| `api_core` | `people` | **Owner** | Datos demográficos y perfiles centrales. |
| `app_auth` | `auth` | **Owner** | Credenciales, sesiones y dispositivos (Extraído). |
| `api_core` | `iam` | **Owner** | Roles, membresías y permisos. |
| `app_auth` | `mfa` | **Owner** | Factores y desafíos multi-factor (Extraído). |
| `app_questionnaire` | `expedient` | **Owner** | Documentos e identificadores clínicos. |
| `app_health_monitoring` | `health_profile` | **Owner** | Perfiles biológicos y monitoreo. |

## Matriz de Persistencia No Relacional (MongoDB / ClickHouse)

| Servicio | Motor | Base de Datos / Colección | Acceso | Notas |
|:---------|:------|:--------------------------|:------:|:------|
| `app_waitlist` | Mongo | `waitlist` | **Owner** | Leads y prospección. |
| `api_core` | Mongo | `audit_logs` | **Owner** | Logs de auditoría de identidad. |
| `app_logger_tracer` | Mongo | `telemetry_events` | **Owner** | Almacenamiento inicial de logs. |
| `app_logger_tracer` | ClickHouse | `telemetry_analytics` | **Owner** | Analítica de logs y trazabilidad. |
| `app_logger_tracer` | Mongo | `service_configs` | **Owner** | Configuraciones dinámicas de tracing. |

## Interdependencias Críticas

| Origen | Destino | Tipo | Razón |
|:-------|:--------|:----:|:------|
| `app_waitlist` | `api_core` | API | Promoción de lead a `person` (Postgres). |
| `app_questionnaire` | `api_core` | API | Validación de identidad del paciente. |
| `api_middleware` | `api_core` | API | Validación de JWT y permisos de ruta. |
| `Cualquier Servicio` | `app_logger_tracer` | API | Envío de telemetría y logs. |

## Dependencias por Flujo de Negocio (Vista de Procesos)

Esta vista muestra como microservicios de orquestacion (como Onboarding) interactuan con multiples dominios para completar un proceso.

| Microservicio | Proceso | Schemas Relacionados | Entidades Clave | Interaccion |
|:--------------|:--------|:---------------------|:----------------|:------------|
| `app_onboarding` | **Registro de Usuario** | `people`, `auth`, `mfa`, `expedient` | `person`, `user`, `otp_challenge`, `document` | Orquestacion (vía API) |
| `app_questionnaire` | **Llenado de Formulario** | `people`, `expedient` | `person`, `document`, `identifier` | Consulta y Escritura |
| `app_waitlist` | **Captura de Leads** | `mongo.waitlist`, `people` | `waitlist`, `person` | Conversion (Mongo -> Postgres) |

---
*Este documento debe actualizarse cada vez que se cree un nuevo microservicio o se añada un nuevo schema de datos.*
