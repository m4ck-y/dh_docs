# Plan de Ejecucion — TASK-015: Persistencia FHIR PG + MongoDB

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
        FHIR_EP[GET/POST /fhir/{Resource}/{uuid}]
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
6. **Fallo silencioso**: si MongoDB falla, la operacion PG no se revierte.

## Flujo de Lectura

1. **Cliente externo / app** llama a `GET /fhir/Patient/{uuid}` via `api_middleware`.
2. **Middleware** lee directamente de MongoDB (documento FHIR pre-armado).
3. **App interna** sigue leyendo de PostgreSQL para logica de negocio.

## Estructura de Archivos

```
dh_shared/
└── src/dh_shared/
    └── schemas/shared/fhir/
        ├── resources/         # Pydantic schemas (ya implementados)
        │   ├── patient.py
        │   ├── organization.py
        │   └── practitioner.py
        └── documents/         # Beanie documents (nuevo)
            ├── __init__.py
            ├── patient_doc.py
            ├── organization_doc.py
            └── practitioner_doc.py

dh_shared/
└── src/dh_shared/
    └── mappings/              # Transformacion PG → FHIR (nuevo)
        ├── __init__.py
        ├── base.py            # MappingStrategy abstracta
        ├── patient.py         # Person → Patient
        ├── organization.py    # Company → Organization
        └── practitioner.py    # Person+Employee → Practitioner
```

## Patron de Documento Beanie

```python
from beanie import Document
from dh_shared.schemas.shared.fhir.resources.patient import Patient

class PatientDocument(Document):
    uuid: str              # mismo uuid que people.person
    resource_type: str = "Patient"
    resource: Patient      # FHIR Pydantic schema → serializa a JSON

    class Settings:
        name = "patients"
```

## Patron de Sync Hook

```python
from sqlalchemy import event

@event.listens_for(Session, "after_commit")
def sync_to_mongo(session):
    for obj in session.new | session.dirty:
        if isinstance(obj, Person):
            asyncio.ensure_future(
                sync_patient_to_mongo(obj.uuid, session)
            )
```

## Criterios de Aceptacion por Fase

Cada fase se considera completada cuando:

1. Mapping module con tests unitarios que cubren todos los campos.
2. Beanie document registrado en `init_beanie()` del servicio.
3. Sync hook funcional verificado con integracion.
4. Endpoint FHIR en `api_middleware` con Swagger documentado.
5. Reporte de avance en `docs/reports/` alineado a miercoles/viernes.
