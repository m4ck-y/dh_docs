# API Endpoints: dh_storage

Base path: `/v1/storage`

## Document Upload

| Method | Path | Description | Body |
|--------|------|-------------|------|
| POST | `/people/{uuid_person}/documents` | Upload a document with its file(s) | multipart/form-data |

**Form fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `file` | binary | yes | The file to upload |
| `uuid_document_type` | UUID | yes | Document type UUID |
| `uuid_document_subtype` | UUID | yes | Document subtype UUID |
| `side` | EDocumentSide | no | FRONT, BACK, SINGLE, EXTRA. Default: SINGLE |

**Response:** `ApiResponseSingle[DocumentResponseDTO]` — 201 Created

**DB effects:** Creates or finds `storage.document` + inserts `storage.document_file`. Writes file to disk.

## Document Metadata per Owner

| Method | Path | Description |
|--------|------|-------------|
| GET | `/people/{uuid_person}/documents` | List all document metadata for a person |

**Query params:** `?page=1&limit=50`

**Response:** `ApiResponsePaginated[DocumentResponseDTO]`

**Future scopes:** `/companies/{uuid_company}/documents` (when dh_organizations exists).

## File Download

| Method | Path | Description |
|--------|------|-------------|
| GET | `/files/{uuid_file}` | Download a single file by file UUID |

**Response:** Binary file with `Content-Disposition: inline` and correct `Content-Type`.

## Soft-Delete Document

| Method | Path | Description |
|--------|------|-------------|
| DELETE | `/people/{uuid_person}/documents/{uuid_document}` | Soft-delete a document and all its files |

**Response:** 204 No Content

**DB effects:** Sets `deleted_at` on `storage.document` and all related `storage.document_file` rows.

## Catalog Config (read-only)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/config/document-types` | List all document types |
| GET | `/config/document-types/{uuid_type}/subtypes` | List subtypes for a document type |

**Response:** `ApiResponseSingle` or `ApiResponsePaginated`

## Ownership Contract

- `dh_storage` es el **unico punto de entrada** para upload/download de archivos en el ecosistema.
- `dh_storage` escribe en `storage.*` (documentos) y `people.photo` (fotos de perfil).
- `dh_onboarding` llama a `dh_storage` via HTTP para subir documentos.
- `dh_core` llama a `dh_storage` via HTTP para fotos de perfil.
- Ningun otro microservicio escribe archivos a disco ni inserta en `storage.*` o `people.photo`.
- Cuando el storage migre a GCS/AWS, solo `dh_storage` cambia.
