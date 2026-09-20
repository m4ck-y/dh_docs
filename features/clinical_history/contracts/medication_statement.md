# Contrato de Componente: Medicación Declarada (`medication_statement`)

Especificación del contrato de API, flujo de interfaz de usuario y persistencia para el registro de medicamentos declarados o consumidos por el paciente en la Historia Clínica.

> **Estándar clínico:** HL7 FHIR R5 — [`MedicationStatement`](https://hl7.org/fhir/R5/medicationstatement.html).  
> **Diferenciación clave:** Este contrato modela el **consumo reportado por la persona** (`MedicationStatement`), **no** el catálogo farmacéutico general ([`catalogs.medication`](../../catalogs/clickhouse/medication.md) en ClickHouse), ni una receta médica emitida por un facultativo ([`MedicationRequest`](https://hl7.org/fhir/R5/medicationrequest.html)).

---

## 1. Flujo en Frontend / UI

El componente de interfaz para la captura de medicamentos de la persona opera con un patrón de **autocompletado flexible con fallback libre**:

```mermaid
flowchart TD
    A["Usuario escribe en el buscador de medicamentos"] -->     B["Front consulta GET /v1/catalogs/medications?q={texto}"]
    B --> C{"¿El medicamento está en el catálogo?"}
    C -->|Sí| D["Usuario selecciona el ítem del catálogo\n(autocompleta nombre, código y sistema)"]
    C -->|No / Remedio casero / Desconocido| E["Usuario escribe el nombre libremente\n(ej. 'Té de manzanilla', 'Pastillas naturistas')"]
    D --> F["Completa posología (dosis, frecuencia, fechas, motivo)"]
    E --> F
    F --> G["Envía POST /v1/clinical-history/persons/{uuid_person}/medication-statements"]
    G --> H["Persiste en PostgreSQL: clinical_history.medication_statement"]
```

### Casos de Envío

#### Caso A: Medicamento encontrado en el catálogo (Vademécum / ClickHouse)
El frontend envía el código formal del sistema correspondiente:
```json
{
  "medication_code_system": "ATC",
  "medication_code": "N05AX08",
  "name": "Risperidona 2mg tableta",
  "instructions": "1 tableta cada 24 horas por la noche",
  "status": "ACTIVE",
  "start_date": "2024-01-15",
  "end_date": null,
  "adherence_code": "ALWAYS",
  "information_source": "PATIENT",
  "uuid_conditions": ["01918a24-1a3b-7f12-8822-b91c32fa0001"]
}
```

#### Caso B: Medicamento no catalogado, remedio o nombre desconocido
El frontend deja en `null` el sistema y código, pero envía el nombre en texto libre:
```json
{
  "medication_code_system": null,
  "medication_code": null,
  "name": "Gotas para dormir naturistas (etiqueta verde)",
  "instructions": "10 gotas en medio vaso de agua antes de acostarse",
  "status": "ACTIVE",
  "start_date": "2025-06-01",
  "end_date": null,
  "adherence_code": "SOMETIMES",
  "information_source": "PATIENT",
  "uuid_conditions": []
}
```

---

## 2. Endpoints de API (Contrato REST)

Cumple con las normas [ADR 010](../../../decisions/010-database-id-strategy.md) (IDs externos en UUID), [ADR 024](../../../decisions/024-endpoints-uuid-only.md) (rutas solo con UUID), [ADR 034](../../../decisions/034-entity-uuid-single-path.md) (entidad única en paths de sub-recursos) y [ADR 035](../../../decisions/035-api-path-no-trailing-slash.md) (sin trailing slash).

### 2.1 Listar medicamentos de la persona
* **Método**: `GET`
* **Ruta**: `/v1/clinical-history/persons/{uuid_person}/medication-statements`
* **Query Params**:
  * `status` (opcional): `ACTIVE` | `COMPLETED` | `STOPPED` | `ALL` (default: `ACTIVE`).
* **Respuesta (200 OK)**:
```json
[
  {
    "uuid": "01918a24-9b8c-7f12-9922-b91c32fa0099",
    "uuid_person": "01918a00-3321-7111-9988-bbccddeeff00",
    "medication_code_system": "ATC",
    "medication_code": "N05AX08",
    "name": "Risperidona 2mg tableta",
    "dosage": {
      "text": "1 tableta por la noche",
      "timing": {
        "frequency": 1,
        "period": 1,
        "period_unit": "d"
      }
    },
    "instructions": "1 tableta cada 24 horas por la noche",
    "status": "ACTIVE",
    "start_date": "2024-01-15",
    "end_date": null,
    "date_asserted": "2024-01-15T10:00:00Z",
    "adherence_code": "ALWAYS",
    "information_source": "PATIENT",
    "notes": null,
    "conditions": [
      {
        "uuid": "01918a24-1a3b-7f12-8822-b91c32fa0001",
        "name": "Trastorno bipolar",
        "cie11_code": "6A60"
      }
    ]
  }
]
```

### 2.2 Registrar nueva declaración de medicación
* **Método**: `POST`
* **Ruta**: `/v1/clinical-history/persons/{uuid_person}/medication-statements`
* **Body**: `MedicationStatementCreateRequest`
* **Respuesta (201 Created)**: `MedicationStatementResponse`

### 2.3 Actualizar o suspender medicación
* **Método**: `PATCH`
* **Ruta**: `/v1/clinical-history/medication-statements/{uuid_medication_statement}`
* **Body**: `MedicationStatementUpdateRequest` (campos opcionales para actualizar posología, adherencia, o pasar a `status: STOPPED` indicando `end_date`).
* **Respuesta (200 OK)**: `MedicationStatementResponse`

### 2.4 Descartar o eliminar (Error de captura)
* **Método**: `DELETE`
* **Ruta**: `/v1/clinical-history/medication-statements/{uuid_medication_statement}`
* **Efecto**: **Soft-delete** (`deleted_at`).
* **Respuesta (204 No Content)**

---

## 3. Modelo Físico (PostgreSQL)

> El **modelo** (columnas, tipos, FKs) vive en el **ERD**
> [`db/postgres/clinical_history/erd.mmd`](../../../db/postgres/clinical_history/erd.mmd)
> — convención del repo: *"el modelo vive en el ERD; no se mantienen DDL `.md`"*.
> Aquí solo se documenta el **significado/reglas** de cada campo.

### 3.1 `clinical_history.medication_statement`

| Campo | Tipo | Significado / regla |
|---|---|---|
| `id` | int (PK) | Interno (BaseModel). |
| `uuid` | UUID | Externo (ADR 010). Default en BD `gen_random_uuid()` (**v4**); los **seeds** se generan en **SQLAlchemy/Python** con la librería **v7** (`uuid6.uuid7()`). |
| `id_person` | FK `people.person` | Quién lo toma. |
| `medication_code_system` | varchar | Sistema del código (p. ej. `ATC`, `RXNORM`); `NULL` si es texto libre. |
| `medication_code` | varchar | Código en el catálogo (Vademecum); `NULL` si es texto libre. |
| `name` | text | Display del catálogo o nombre declarado. |
| `dosage` | jsonb | `Dosage[]` de FHIR. |
| `instructions` | text | Texto legible ("1 tableta cada 8 h"). |
| `status` | enum `EMedicationStatementStatus` | `ACTIVE` / `COMPLETED` / `STOPPED` / `ON_HOLD` — **desviación intencional** de FHIR R5 (ver nota). |
| `start_date` / `end_date` | date | Periodo (`effective`); `end_date` NULL = vigente. |
| `date_asserted` | timestamptz | Cuándo se reportó. |
| `adherence_code` | enum `EMedicationAdherence` | `ALWAYS` / `SOMETIMES` / `NEVER` / `UNKNOWN`. |
| `information_source` | enum `EInformationSource` | `PATIENT` / `RELATIVE` / `CLINICIAN`. |
| `notes` | text | — |
| *(BaseModel)* | | `created_at`, `updated_at`, `deleted_at`, auditoría. |

> **Desviación de FHIR R5 (`status`):** en FHIR, `MedicationStatement.status` es el
> ciclo de vida del **registro** (`recorded`/`entered-in-error`/`draft`). Aquí
> `status` = **estado clínico del tratamiento**. Es una **desviación intencional**,
> **pendiente de revisión posterior**. El registro capturado por error se maneja con
> **soft-delete** (`deleted_at`), no con un estado.

### 3.2 `clinical_history.medication_condition` (puente N:N)

| Campo | Tipo | Significado |
|---|---|---|
| `id` | int (PK) | Interno. |
| `uuid` | UUID | Externo (ADR 010). |
| `id_medication_statement` | FK | El medicamento. |
| `id_condition` | FK | La condición ("motivo"). |
| — | — | `UNIQUE (id_medication_statement, id_condition)`. |

---

## 4. Activador de Cuestionarios (Anexo D — Instrumento DAI-10)

En el flujo de cuestionarios psicométricos ([`activation/anexo_d.mmd`](../../../diagrams/0_HISTORIA_CLINICA/activation/anexo_d.mmd)), el inventario **DAI-10** (*Drug Attitude Inventory*) se habilita si el paciente consume **fármacos antipsicóticos**.

**Regla (funcional):** se habilita si la persona tiene un **medicamento `ACTIVE`** cuyo
código **ATC empieza con `N05A`** (Haloperidol, Risperidona, Olanzapina, Quetiapina,
Aripiprazol, Clozapina, Clorpromazina, Flufenazina). Si el medicamento se eligió del
catálogo (ClickHouse) con ATC `N05A%`, el sistema activa el DAI-10 sin intervención
manual.

> **Sintaxis AST:** **por definir** — depende de la decisión **H4** sobre cómo el AST
> lee el dominio: **(a)** entidad `medication_statement` (con selector) vs **(b)**
> propiedad-arreglo de `person` (`person.medications`). Ver
> [`OPEN-QUESTIONS.md`](../../../tasks/TASK-017-historia-clinica/planning/OPEN-QUESTIONS.md)
> (H4) y [`expressions/operands.md`](../../questionnaires/expressions/operands.md).
> **No** se fija aquí una estructura JSON no estándar.
