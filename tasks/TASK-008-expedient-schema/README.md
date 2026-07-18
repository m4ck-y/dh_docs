---
type: task
id: TASK-008
title: "Rediseño del Schema Expedient — document_file como tabla separada"
status: superseded
priority: medium
created: "2026-04-26"
started: null
completed: "2026-07-18"
tags: [expedient, postgres, schema, documents]
---

# TASK-008: Rediseño del Schema Expedient

> **Estado: SUPERSEDED**. El diseño de `document_file` se implementó en `dh_storage` (TASK-007) bajo el schema `storage`. El schema `expedient` ya no existe. Ver `docs/db/postgres/storage/erd.mmd` y `docs/tasks/TASK-007-dh-storage/`.

## Descripción

Actualizar el schema `expedient` en PostgreSQL para soportar múltiples archivos por documento (ej. frente + reverso de INE) mediante una tabla `document_file` separada. La columna `url_file` / `url_thumbnail` directamente en `document` no escala para este caso.

## Contexto

Decisión tomada el 2026-04-26. Ver análisis en `docs/ideas/documents_expedient/`. JSONB fue evaluado y descartado: los archivos tienen ciclo de vida propio (migración de storage, processing por archivo, reemplazo individual de sides), por lo que tabla relacional es la opción correcta.

## Objetivos (no aplicados — task superseded)

- ~~Actualizar `docs/db/postgres/expedient/erd.mmd` — agregar `document_file`, eliminar `url_file` y `url_thumbnail` de `document`.~~ El ERD se implementó en `docs/db/postgres/storage/erd.mmd`.
- ~~Crear ADR documentando la decisión (`document_file` relacional vs JSONB).~~ No requerido; la implementación en `dh_storage` cubre la decision.
- ~~Actualizar modelo SQLAlchemy `expedient.document` en `dh_onboarding`.~~ El modelo se movio a `dh_storage`.
- ~~Crear modelo SQLAlchemy `expedient.document_file`.~~ Creado como `storage.document_file` en `dh_storage`.
- ~~Actualizar el use case `upload_document_use_case.py` para persistir en `document_file`.~~ Migrado a `dh_storage`.
- ~~Actualizar `dh_onboarding` para soportar múltiples archivos en `POST /v1/onboarding/{id}/documents`.~~ `dh_onboarding` delega uploads a `dh_storage`.

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
- [Idea original](../../../docs/ideas/documents_expedient/)
- [ERD actual](../../db/postgres/storage/erd.mmd)
