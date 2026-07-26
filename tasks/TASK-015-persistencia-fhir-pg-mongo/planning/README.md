# Plan de Ejecucion — TASK-015: Persistencia FHIR PG + MongoDB

## Decision de Arquitectura: Hibrido PostgreSQL + MongoDB

### Alternativas evaluadas (y por que se descartaron)

| Enfoque | Verdicto | Razon |
|---|---|---|
| **Restructurar PostgreSQL a FHIR** | Descartado | ~68 tablas normalizadas. Migracion masiva, fragil ante cambios de version FHIR. El modelo relacional actual esta optimizado para logica transaccional (auth, IAM, multi-tenancy). |
| **JSONB en tablas existentes** | Descartado | Modelo hibrido con boundary difuso entre relacional y JSON. Queries complejas sobre JSONB mas lentas. No resuelve el nesting profundo de FHIR. |
| **JSONB en tabla `fhir_resource` unica** | Descartado | Mas limpio que la opcion anterior, pero fuerza a usar una sola tabla para todos los recursos. No aprovecha MongoDB (ya presente en el stack). |
| **PostgreSQL relacional + MongoDB documental** | **Seleccionado** | Sin reestructurar tablas existentes. MongoDB ya en el stack (ADR 003). UUID dual ya implementado (ADR 010). Schemas Pydantic FHIR ya validan el JSON. Cada BD optimizada para su proposito. |

### Vinculacion con ADRs existentes

| ADR | Relevancia para TASK-015 |
|---|---|
| [003 — Polyglot Persistence](../../decisions/003-estrategia-multi-base-de-datos.md) | Autoriza MongoDB como motor documental. PostgreSQL para transaccional, MongoDB para flexible/documental. |
| [005 — MongoDB Driver + Lifespan](../../decisions/005-mongodb-driver-and-fastapi-lifespan.md) | Define `pymongo.AsyncMongoClient` via Beanie. Inicializacion en FastAPI `lifespan`. |
| [010 — Database ID Strategy](../../decisions/010-database-id-strategy.md) | UUID dual (integer PK interno + UUID expuesto). El UUID es el link natural PG ↔ MongoDB. |
| [036 — FHIR R5 Adoption](../../decisions/036-fhir-r5-adoption.md) | Schemas Pydantic en `dh_shared`. **Deja sin decidir la persistencia fisica — TASK-015 cierra esa brecha.** |

### Orden de fases: RBAC first

Se evaluaron dos ordenamientos:

| Orden | Justificacion |
|---|---|
| **Domain-first** (Patient → Practitioner → Organization → RBAC) | Mas tangible, arranca con el recurso mas valioso |
| **RBAC-first** (RBAC → Organization → Patient → Practitioner) | **Seleccionado**. Seguridad ante todo: sin roles/permisos funcionales no se deben exponer datos clinicos. El IAM ya existe en PostgreSQL — solo requiere seed y verificacion. Organization se hace primero porque no depende de personas. |

---

## Arquitectura General

```mermaid
flowchart LR
    subgraph PostgreSQL
        PG[people.person<br/>org.company<br/>org.employee]
    end

    subgraph MongoDB
        M_Patient[ patients ]
        M_Org[ organizations ]
        M_Pract[ practitioners ]
    end

    subgraph "Sync Service"
        MAP[mapping module<br/>PG entity → FHIR JSON]
        SYNC[post-commit hook<br/>CRUD → MongoDB write]
    end

    subgraph "API Layer"
        MIDDLE[api_middleware]
        FHIR_EP[GET /fhir/{Resource}/{uuid}]
    end

    PG -->|on_after_commit| MAP
    MAP -->|Pydantic validation| SYNC
    SYNC -->|upsert by uuid| M_Patient
    SYNC -->|upsert by uuid| M_Org
    SYNC -->|upsert by uuid| M_Pract
    MIDDLE -->|read| M_Patient
    MIDDLE -->|read| M_Org
    MIDDLE -->|read| M_Pract
    FHIR_EP --> MIDDLE
```

## Flujo de Escritura

1. **App escribe en PostgreSQL** (modelo relacional existente, sin cambios).
2. **Post-commit hook** (SQLAlchemy `after_commit` event) dispara el sync.
3. **Mapping module** carga entidades relacionadas, construye FHIR Pydantic object.
4. **Validacion Pydantic** confirma que el FHIR JSON cumple el schema.
5. **Beanie upsert** escribe el documento en MongoDB.
6. **Tolerancia a fallos**: si MongoDB falla, loggear warning. La operacion PG no se revierte. (Ver OPEN-QUESTIONS.md item 6).

## Flujo de Lectura

1. **Cliente externo / app** llama a `GET /fhir/Patient/{uuid}` via `api_middleware`.
2. **Middleware** lee directamente de MongoDB (documento FHIR pre-armado).
3. **App interna** sigue leyendo de PostgreSQL para logica de negocio.

---

## Diseno de Schemas (PENDIENTE)

Las decisiones sobre schema Beanie, indexacion, referencias y patron de sync estan documentadas como preguntas abiertas en:

→ **[OPEN-QUESTIONS.md](OPEN-QUESTIONS.md)**

Cada pregunta tiene 2-3 alternativas viables con trade-offs. Deben resolverse **antes** de escribir codigo.

---

## Estructura de Archivos Propuesta

```
dh_shared/
└── src/dh_shared/
    ├── schemas/shared/fhir/
    │   ├── resources/         # Pydantic schemas (ya implementados)
    │   │   ├── patient.py
    │   │   ├── organization.py
    │   │   └── practitioner.py
    │   └── documents/         # Beanie documents (nuevo — Fase 0)
    │       ├── __init__.py
    │       ├── patient_doc.py
    │       ├── organization_doc.py
    │       └── practitioner_doc.py
    └── mappings/              # Transformacion PG → FHIR (nuevo — Fase 0)
        ├── __init__.py
        ├── base.py            # MappingStrategy abstracta
        ├── patient.py         # Person → Patient
        ├── organization.py    # Company → Organization
        └── practitioner.py    # Person+Employee → Practitioner
```

## Patron de Documento Beanie (ilustrativo)

```python
from beanie import Document
from dh_shared.schemas.shared.fhir.resources.patient import Patient

class PatientDocument(Document):
    uuid: str              # mismo uuid que people.person (ADR 010)
    resource_type: str = "Patient"
    resource: Patient      # FHIR Pydantic schema → serializa a JSON

    class Settings:
        name = "patients"
```

> **Nota**: El schema final depende de las decisiones en OPEN-QUESTIONS.md (item 1: campo unico vs aplanado).

---

## Criterios de Aceptacion por Fase

Cada fase se considera completada cuando:

1. Mapping module con tests unitarios que cubren todos los campos FHIR mapeados.
2. Beanie document registrado en `init_beanie()` del servicio correspondiente.
3. Sync hook funcional verificado con prueba de integracion (write PG → aparece en Mongo).
4. Endpoint FHIR en `api_middleware` con schema Pydantic duplicado y router explicito (regla AGENTS.md).
5. Reporte de avance en `docs/reports/` alineado a miercoles/viernes.

---

## Enlaces

- [Preguntas de diseno pendientes](OPEN-QUESTIONS.md)
- [TASK-015 README](../README.md)
- [ADR 003: Polyglot Persistence](../../decisions/003-estrategia-multi-base-de-datos.md)
- [ADR 005: MongoDB Driver](../../decisions/005-mongodb-driver-and-fastapi-lifespan.md)
- [ADR 010: ID Strategy](../../decisions/010-database-id-strategy.md)
- [ADR 036: FHIR R5 Adoption](../../decisions/036-fhir-r5-adoption.md)
