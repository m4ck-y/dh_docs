# expedient

Schema de PostgreSQL para el expediente documental de personas.

Gestiona documentos de identificación y archivos adjuntos: tipos de documento, categorías y estado de verificación.

## Entidades

| Entidad | Descripción |
|---|---|
| `document` | Documento de una persona con URL, tipo, fechas de emisión/vencimiento y estado de verificación |
| `document_type` | Catálogo de tipos de documento (ej. INE, pasaporte, acta de nacimiento) |
| `document_category` | Categorías de documento (ej. Identificación, Educación, Médico, Laboral, Fiscal) |

## Enums

| Enum | Valores |
|---|---|
| `EVerificationStatus` | `PENDING`, `APPROVED`, `REJECTED` |

## Archivos

| Archivo | Descripción |
|---|---|
| [erd.mmd](./erd.mmd) | Diagrama ERD del schema en Mermaid |
