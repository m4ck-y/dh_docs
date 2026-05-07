# storage

Schema de PostgreSQL para almacenamiento documental. Gestionado por `dh_storage`.

Gestiona documentos de identidad, medicos, laborales y empresariales: tipos, subtipos, archivos y estado de verificacion.

## Entidades

| Entidad | Descripcion |
|---|---|
| `document` | Documento conceptual con tipo, subtipo, fechas y estado de verificacion |
| `document_type` | Catalogo de tipos de documento |
| `document_subtype` | Catalogo de subtipos por tipo |
| `document_file` | Archivo fisico con side (FRONT, BACK, SINGLE, EXTRA), URL y metadata |

## Enums

| Enum | Valores |
|---|---|
| `EDocumentSide` | `FRONT`, `BACK`, `SINGLE`, `EXTRA` |
| `EVerificationStatus` | `PENDING`, `APPROVED`, `REJECTED` |

## Archivos

| Archivo | Descripcion |
|---|---|
| [erd.mmd](./erd.mmd) | Diagrama ERD del schema en Mermaid |
