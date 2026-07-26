# Preguntas de diseno no resueltas — TASK-015

Este documento captura las decisiones arquitectonicas que deben resolverse **antes** de escribir codigo. Cada pregunta presenta alternativas viables y su trade-off principal.

---

## 1. Schema de documento Beanie en MongoDB

**Contexto**: Los Pydantic schemas FHIR (`Patient`, `Organization`, `Practitioner`) ya existen en `dh_shared`. Al guardarlos en MongoDB via Beanie, el schema del documento define *como* se almacenan.

### Alternativa A: Campo unico embebido (`resource: Patient`)

```python
class PatientDocument(Document):
    uuid: str              # indexed, unique
    resource: Patient      # FHIR Pydantic → serializa a JSON directo
    updated_at: datetime
```

**Trade-off**: 
- (+) Simple, el Pydantic model es la fuente unica de verdad
- (+) FHIR changes = solo actualizar Pydantic, no el documento Beanie
- (-) Queries FHIR como `GET /Patient?identifier=xxx` requieren Mongo index sobre campo anidado `resource.identifier[0].value`

### Alternativa B: Campos aplanados para queries + `resource` para FHIR completo

```python
class PatientDocument(Document):
    uuid: str
    resource: Patient
    # Campos indexados duplicados
    identifier_system: str | None
    identifier_value: str | None
    name_family: str | None
    gender: str | None
    birth_date: date | None
    active: bool
```

**Trade-off**:
- (+) Queries FHIR eficientes con indices simples
- (-) Duplicacion de datos, riesgo de desincronizacion entre `resource` y campos aplanados

### Pregunta pendiente
¿Alternativa A (simplicidad) o Alternativa B (eficiencia en queries FHIR)?

---

## 2. Referencias entre recursos FHIR en MongoDB

**Contexto**: FHIR usa `Reference` objects. Ej: `Patient.generalPractitioner = Reference[Practitioner]` con `reference: "Practitioner/{uuid}"`. En MongoDB no hay FK constraints.

### Alternativa A: String reference + resolucion en codigo

Guardar el `Reference` tal cual como string: `"Practitioner/{uuid}"`. Al leer un Patient, si se necesita el Practitioner completo, hacer un segundo query a MongoDB.

**Trade-off**:
- (+) Simple, sin joins en BD
- (-) N+1 queries si se necesita resolver muchas referencias

### Alternativa B: $lookup en aggregation pipeline

Usar `$lookup` de MongoDB para resolver la referencia en una sola query.

**Trade-off**:
- (+) Una sola query
- (-) Mas complejo de mantener

### Alternativa C: Embed parcial (solo los campos comunes como `display`)

Embedar `{"reference": "Practitioner/uuid", "display": "Dr. Smith"}`. Si el display cambia en el Practitioner, se desincroniza.

**Trade-off**:
- (+) 0 queries extra para mostrar el nombre
- (-) Riesgo de desincronizacion

### Pregunta pendiente
¿Como se resuelven las referencias? ¿Second query (A), $lookup (B), o embed parcial (C)?

---

## 3. Patron de sync: PostgreSQL → MongoDB

**Contexto**: SQLAlchemy `after_commit` es sincrono. MongoDB via Beanie requiere `async/await`. No se puede `await` dentro de un hook sincrono.

### Alternativa A: cola en memoria + worker async (por sesion)

```python
# Hook sincrono: solo encola
@event.listens_for(Session, "after_commit")
def enqueue_sync(session):
    for obj in session.new:
        sync_queue.append(obj.uuid)

# Worker async (FastAPI lifespan / BackgroundTasks)
async def process_sync_queue():
    while True:
        uuid_val = sync_queue.pop()
        await sync_to_mongo(uuid_val)
```

**Trade-off**:
- (+) Sin dependencias externas
- (-) Se pierde si el proceso muere

### Alternativa B: FastAPI BackgroundTasks

En el endpoint que hace commit, agregar un BackgroundTask que ejecute el sync despues de la respuesta HTTP.

**Trade-off**:
- (+) Nativo de FastAPI, simple
- (-) Solo funciona para escrituras via API, no para tareas batch/seeder

### Alternativa C: Event bus (RabbitMQ / NATS / Redis Streams)

Emitir evento `person.created` con el UUID. Un consumer async lo procesa y escribe en MongoDB.

**Trade-off**:
- (+) Robusto, persistente, escalable
- (-) Infraestructura adicional no presente en el stack actual

### Pregunta pendiente
¿Alternativa A (cola en memoria), B (BackgroundTasks), o C (event bus)?

---

## 4. Diseno de colecciones MongoDB

### Alternativa A: Una coleccion por recurso FHIR
```
patients/
organizations/
practitioners/
```

### Alternativa B: Coleccion unica generica
```
fhir_resources/  (con campo resourceType)
```

### Pregunta pendiente
¿Alternativa A (coleccion por recurso, alineado con FHIR) o Alternativa B (coleccion unica, mas flexible)?

---

## 5. Indexacion para busquedas FHIR

**Escenario**: Un cliente FHIR llama `GET /fhir/Patient?identifier=http://example.com/fhir/NSS|12345`.

### Campos candidatos a indexar
- `uuid` (indice unico, obligatorio)
- `identifiers.system` + `identifiers.value` (compuesto, para busqueda por identifier)
- `name[0].family` (busqueda por apellido)
- `gender` (filtro demografico)
- `birthDate` (filtro por fecha)
- `active` (filtro comun)

### Pregunta pendiente
¿Que campos se indexan en la Fase 0? Mínimo: `uuid` + `identifiers`. ¿Que mas es critico para la primera iteracion?

---

## 6. Tolerancia a fallos en el sync

**Contexto**: AGENTS.md y ADR 006 establecen que los fallos de observabilidad (logger) deben ser silenciosos. ¿Aplica el mismo principio al sync FHIR?

### Alternativa A: Log silencioso (mismo que logger)
Si MongoDB falla, loggear warning y continuar. El documento se sincronizara en la siguiente escritura.

### Alternativa B: Retry con backoff
Reintentar N veces con exponential backoff antes de rendirse.

### Alternativa C: Dead letter queue
Guardar UUIDs fallidos en una cola persistente para reprocesamiento manual/automatico.

### Pregunta pendiente
¿Mismo principio que logger (fail silent, A), retry (B), o dead letter queue (C)?

---

## 7. Scope concreto de Fase 0 y Fase 1

### Fase 0 — Infraestructura base
¿Que archivos exactamente se crean y en que directorios?

Propuesta pendiente de validacion:
```
dh_shared/src/dh_shared/
├── schemas/shared/fhir/documents/     # Beanie documents
│   ├── __init__.py
│   ├── patient_doc.py
│   ├── organization_doc.py
│   └── practitioner_doc.py
└── mappings/                           # PG → FHIR transformers
    ├── __init__.py
    ├── base.py
    ├── patient.py
    ├── organization.py
    └── practitioner.py
```

### Fase 1 — RBAC + Admin
¿Que seed de admin se necesita? ¿Tablas especificas de IAM a poblar?

### Pregunta pendiente
Confirmar estructura de archivos y que tablas se seedean en RBAC.
