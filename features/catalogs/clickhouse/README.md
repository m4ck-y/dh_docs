# Catálogos masivos (ClickHouse)

Capa **ClickHouse** (columnar) del feature `catalogs`: catálogos **masivos y de
baja mutabilidad**, orientados a **lectura/análisis** desde los selectores. Dueño:
microservicio **`dh_catalogs`** (multi-motor).

> Ver el índice del feature: [`../README.md`](../README.md) y
> [ADR 003](../../../decisions/003-estrategia-multi-base-de-datos.md).

## Qué catálogos van aquí

| Catálogo | Notas |
|---|---|
| **Código postal** | volumétrico (país → estado → municipio → colonia → CP) |
| **CIE-11** | clasificación de enfermedades (masiva, estándar) |
| **Catálogos de salud** | medicamentos, estudios, etc. (masivos) |

## Características

- **Columnar**: lecturas masivas y rápidas (autocomplete/búsqueda de CP, CIE, etc.).
- **Baja mutabilidad**: se actualizan por **seed/sincronización** desde una
  fuente, no por escritura del usuario.
- **Solo lectura** para el front (los selectores consultan); la escritura de
  "Otro" **no** aplica aquí (eso es la capa **PostgreSQL gobernada**).

## Contraste con PostgreSQL (gobernada)

| | PostgreSQL (`catalog`) | ClickHouse |
|---|---|---|
| Mutabilidad | alta (usuario crea "Otro") | baja (seed/sync) |
| Gobernanza | `PENDING`/`VALIDATED`/… | no aplica |
| Volumen | acotado | masivo |
| Uso | selectores extensibles + FK | búsqueda/autocomplete masivo |

## Estado

**Pendiente de diseño.** Referencia actual: `docs/db/click_house/` (TODO:
"catálogos de código postal").

## Pendientes

- Definir el **schema** (tablas/columnas) y el **pipeline de seed/sync** hacia
  ClickHouse (fuente → ClickHouse).
- Definir los **endpoints de consulta** (búsqueda/autocomplete) en `dh_catalogs`.
