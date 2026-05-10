# TASK-007: Microservicio de Storage (dh_storage)

## Descripcion

Microservicio dueno de la abstraccion de storage del ecosistema. Gestiona el ciclo de vida completo de archivos: fotos de perfil, documentos de identidad, expedientes clinicos, y documentos empresariales. Storage en disco local (GCS/AWS futuro via abstraccion swappable).

`dh_storage` es el unico punto de entrada para cualquier upload/download de archivos en el ecosistema. Escribe en `people.photo` (fotos) y `storage.*` (documentos).

## Objetivos

- [x] Modelos SQLAlchemy en `dh_shared` (DocumentType, DocumentSubtype, Document, DocumentFile + EDocumentSide, Photo)
- [x] ERD en `docs/db/postgres/storage/erd.mmd`
- [x] Seeder de catalogos (`seed_storage_catalogs`)
- [ ] Crear servicio `dh_storage` con Screaming Architecture
- [ ] Endpoint upload document (multipart: file + uuid_person + uuid_document_type + uuid_document_subtype + side)
- [ ] Endpoint upload person photo (multipart: file + uuid_person, genera 3 tamanos)
- [ ] Endpoint download file by file UUID
- [ ] Endpoint list document metadata per person
- [ ] Endpoint get photo metadata per person
- [ ] Endpoint soft-delete document (cascade a document_file)
- [ ] Endpoint delete photo
- [ ] Storage en disco con estructura de carpetas estandarizada
- [ ] Migrar `upload_document_use_case.py` de `dh_onboarding` a `dh_storage`
- [ ] Duplicar schemas en `api_middleware` (ADR 028)
- [ ] Static test UI en `dh_storage`

## Enlaces Rapidos

- [Endpoints](planning/endpoints.md)
- [Estructura de archivos](planning/estructura_archivos.md)
- [Arquitectura](planning/arquitectura.mmd)
- [Registro de Progreso](progress/)
