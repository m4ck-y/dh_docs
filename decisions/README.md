# Registro de Decisiones Tecticas (Decisions)

Esta seccion contiene el registro oficial de las decisiones arquitectonicas del proyecto Digital Hospital.

## Estandar
Cada decision tecnica importante debe documentarse siguiendo el formato de **ADR (Architecture Decision Record)** para que el equipo entienda el "porque" de la estructura actual.

## Indice de Decisiones
- **[001: Estructura de Documentacion](001-estructura-documentacion.md)**
- **[002: Estrategia de Seguridad JWT](002-estrategia-seguridad-jwt.md)**
- **[003: Estrategia Multi-Base de Datos](003-estrategia-multi-base-de-datos.md)**
- **[004: Enfoque de Onboarding y Persistencia de Waitlist](004-onboarding-approach-and-waitlist-storage.md)**
- **[005: Driver de MongoDB y Patron de Inicializacion FastAPI](005-mongodb-driver-and-fastapi-lifespan.md)**
- **[006: Estandar de Logging Inter-Servicio hacia VitalTrace](006-inter-service-logging-standard.md)**
- **[007: Documentacion de Schemas Pydantic](007-pydantic-schemas-documentation.md)**
- **[008: Estandar de Fechas y Horas — UTC en Todo el Sistema](008-datetime-utc-standard.md)**
- **[009: Formato Estandar de Respuesta de API](009-api-response-format.md)**
- **[010: Estrategia de Identificadores en Base de Datos](010-database-id-strategy.md)**
- **[011: Estandar de README en Microservicios](011-microservice-readme-standard.md)**
- **[012: SQLAlchemy Echo Debug](012-sqlalchemy-echo-debug.md)**
- **[013: Seeders de Base de Datos](013-database-seeders.md)**
- **[014: Estandar de Hashing de Contrasenas](014-estandar-hashing-contrasenas.md)**
- **[015: Estrategia de Autorizacion Stateless via JWT](015-estrategia-autorizacion-stateless.md)**
- **[016: Tipos de Membresia y Contextos de Usuario](016-tipos-de-membresia-y-contexto-de-usuario.md)**
- **[017: Referencias Cross-Service](017-referencias-cross-service.md)**
- **[018: Migracion de User de People a Auth](018-migracion-user-people-a-auth.md)**
- **[019: Silent Refresh at Gateway Level](019-silent-refresh-gateway-level.md)**
- **[019b: Validacion de Duplicados en Onboarding](019-validacion-duplicados-onboarding.md)**
- **[020: Database Sync Strategy (Reemplazado por ADR 030)](020-database-sync-strategy.md)**
- **[022: ENDPOINTS.md Obligatorio](022-mandatory-endpoints-documentation.md)**
- **[023: Unified SQLAlchemy Registry](023-unified-sqlalchemy-registry.md)**
- **[024: Endpoints API con UUIDs](024-endpoints-uuid-only.md)**
- **[025: Static Test UI Standard](025-static-test-ui-standard.md)**
- **[026: Resolucion Local del id Interno](026-local-id-resolution.md)**
- **[027: Middleware — Enlace a Test UI](027-middleware-test-ui-link.md)**
- **[028: Middleware — Contrato Duplicado](028-middleware-duplicate-schema-contract.md)**
- **[029: Sub-objetos en DTOs](029-dto-subobjects-naming.md)**
- **[030: init_schemas — Inicializacion Centralizada](030-init-schemas.md)**
- **[031: Configuracion Baseline para Microservicios](031-microservice-baseline-config.md)**
- **[032: Politica de Emojis como Indicadores de Estado](032-emoji-status-indicator-policy.md)**
- **[033: Docstrings Swagger — Templates y Placeholders](033-swagger-docstring-templates.md)**
- **[034: UUID de Entidad en Rutas de PATCH/DELETE/GET-single](034-entity-uuid-single-path.md)**
- **[035: Rutas API sin Slash Final](035-api-path-no-trailing-slash.md)**
- **[036: Adopción FHIR R5](036-fhir-r5-adoption.md)**
- **[037: Prototipos UI de Antecedentes Familiares](037-family-conditions-ui-prototype.md)**

---
*Para crear una nueva decision, utiliza la plantilla `_template.md` (proximamente).*