# API Endpoints: dh_expedient

## Config

|Método|Path|Descripción|DB|
|------|-----|------------|--|
|GET|/v1/expedient/config/categories|Lista categorías|PostgreSQL|
|GET|/v1/expedient/config/categories/{category}/subtypes|Lista subtypes por categoría|PostgreSQL|
|GET|/v1/expedient/config/validation|Lista validación|MongoDB|

## Documentos

|Método|Path|Descripción|Auth|
|------|-----|------------|----|
|POST|/v1/expedient/documents|Subir documento|User|
|GET|/v1/expedient/documents/{id}|Obtener metadata|PostgreSQL|
|GET|/v1/expedient/documents/{id}/download|Descargar archivo|-|
|GET|/v1/expedient/documents?owner_id={id}|Listar documentos|User|
|DELETE|/v1/expedient/documents/{id}|Eliminar documento|User|

## Review (Admin)

|Método|Path|Descripción|
|------|-----|------------|
|PATCH|/v1/expedient/documents/{id}/review|Revisar documento (status, notas)|

## Notas

- `/config/categories` retorna de `document_category` en PostgreSQL
- `/config/validation` retorna de MongoDB `document_type_config`
- El endpoint de upload valida contra MongoDB pero guarda en PostgreSQL