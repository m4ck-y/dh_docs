# Catálogo: `medication` (Medicamentos — Vademecum)

> **Estado: PROPUESTA.** Fuente (Vademecum), **columnas finales** y pipeline de
> **sync** por definir. **No consolidado** — las columnas de abajo son propuestas.

## Registro

```jsonc
{ "key": "medication", "name": "Medicamentos (Vademecum)",
  "description": "Catálogo masivo de medicamentos (Vademecum).",
  "engine": "CLICKHOUSE", "config": { "database": "catalogs", "table": "medication" },
  "extensible": false, "governed": false }
```

## Columnas (propuesta)

| Columna | Tipo | Nota |
|---|---|---|
| `code_system` | varchar | sistema del código (`ATC` / `SNOMED` / `RXNORM` / nacional) |
| `code` | varchar | código del medicamento en ese sistema |
| `name` | text | nombre (genérico/comercial) |
| `form` | varchar | forma farmacéutica |
| `strength` | varchar | concentración |
| `atc` | varchar | código **ATC** (p. ej. `N05A` = antipsicóticos) |
| `group` | varchar | grupo terapéutico (legible) |

> **Identificador**: `code_system` + `code` (equivale a un `CodeableConcept` de FHIR;
> `Medication.code` tiene binding **Example** → cualquier sistema, ver FHIR).
> ⚠️ Si `code_system = "ATC"`, la columna `atc` es **redundante** (el clasificador
> DAI-10 usaría `code`/`N05A`); si el `code` es un código **nacional/comercial**,
> `atc` se **conserva** para clasificar.

## Uso

- Lo referencia **`clinical_history.medication_statement.medication_code`** (ver contrato en [`features/clinical_history/contracts/medication_statement.md`](../../clinical_history/contracts/medication_statement.md)).
- **Búsqueda / Autocomplete en UI**: consumido vía `GET /api/catalogs/medications?q={query}` contra ClickHouse (servicio `dh_catalogs`).
- El clasificador (`atc`/`group`) habilita el activador **DAI-10**
  (antipsicóticos) — ver `features/clinical_history/README.md` (anexos C/D) y el contrato de medicación.

## Fuente / sync (pendiente)

- **Origen**: **Vademecum** (por definir: versión, licencia, formato).
- **Pipeline** → ClickHouse (por definir).

## ERD (físico)

[`db/click_house/catalogs/erd.mmd`](../../../db/click_house/catalogs/erd.mmd)

## Referencias

- Feature: [`../README.md`](../README.md) · [`./README.md`](./README.md)
- Esquema físico: [`doc/db/click_house`](../../../db/click_house/)
- Decisión: [ADR 044](../../../decisions/044-catalogos-gobernados.md) · ADR 003
