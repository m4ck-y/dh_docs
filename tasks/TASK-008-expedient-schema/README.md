---
type: task
id: TASK-008
title: "Rediseño del Schema Expedient — document_file como tabla separada"
status: backlog
priority: medium
created: "2026-04-26"
started: null
completed: null
tags: [expedient, postgres, schema, documents]
---

# TASK-008: Rediseño del Schema Expedient

## Descripción

Actualizar el schema `expedient` en PostgreSQL para soportar múltiples archivos por documento (ej. frente + reverso de INE) mediante una tabla `document_file` separada. La columna `url_file` / `url_thumbnail` directamente en `document` no escala para este caso.

## Contexto

Decisión tomada el 2026-04-26. Ver análisis en `docs/ideas/documents_expedient/`. JSONB fue evaluado y descartado: los archivos tienen ciclo de vida propio (migración de storage, processing por archivo, reemplazo individual de sides), por lo que tabla relacional es la opción correcta.

## Objetivos

- [ ] Actualizar `docs/db/postgres/expedient/erd.mmd` — agregar `document_file`, eliminar `url_file` y `url_thumbnail` de `document`.
- [ ] Crear ADR documentando la decisión (`document_file` relacional vs JSONB).
- [ ] Actualizar modelo SQLAlchemy `expedient.document` en `dh_onboarding_back`.
- [ ] Crear modelo SQLAlchemy `expedient.document_file`.
- [ ] Actualizar el use case `upload_document_use_case.py` para persistir en `document_file`.
- [ ] Actualizar `dh_onboarding_back` para soportar múltiples archivos en `POST /v1/onboarding/{id}/documents`.

## Estructura de `document_file`

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | |
| `id_document` | Integer FK | → `expedient.document` |
| `side` | Enum | `FRONT`, `BACK`, `SINGLE`, `EXTRA` |
| `url` | String | URL en storage (disk o GCS) |
| `mime_type` | String | `image/jpeg`, `application/pdf`, etc. |
| `size_bytes` | BigInt | Tamaño del archivo |
| `created_at` | Timestamp | |

## Dependencias

- TASK-007 (gestión de documentos / storage abstraction) — esta tarea define el schema que TASK-007 usará.

## Enlaces Rápidos

- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/README.md)
- [Artefactos](artifacts/)
- [Idea original](../../../ideas/documents_expedient/)
- [ERD actual](../../db/postgres/expedient/erd.mmd)
