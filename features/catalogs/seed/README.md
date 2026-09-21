# Seed de catálogos

Datos **iniciales** de los catálogos: el **registro** y los **valores** de cada
catálogo.

- **Registro** → se siembra en Mongo (`dh_catalogs.catalogs`); ver
  [`../config/example.json`](../config/example.json).
- **Valores** → se siembran en el motor del catálogo (Postgres / ClickHouse /
  Mongo); aquí están los **gobernados/extensibles** (Postgres).

## Forma de un seed de valores

```jsonc
{ "value": "EMPLOYED", "label": "Empleado/a", "description": null,
  "status": "VALIDATED", "merged_into": null, "order": 0 }
```

- Shape canónico del **ítem**: `value`, `label`, `description`, `status`,
  `merged_into`, `order` (+ BaseModel: `uuid`, timestamps, auditoría). Diagrama:
  [`../CLASS.mmd`](../CLASS.mmd).
- **Seed** → `status = VALIDATED`, `merged_into = null`; `description` opcional;
  `order` = orden de presentación.
- **"Otro"** y **"Prefiere no decirlo"/"Ninguna"** **NO** son ítems: son
  *UI affordances*:
  - "Otro" dispara el **create** → ítem `PENDING`.
  - "Prefiere no decirlo"/"Ninguna" → `NULL` en el dominio (no guardan ítem).

## Archivos

| Catálogo | Archivo | Extensible (`governed`) |
|---|---|---|
| Ocupación | `occupation.json` | ✅ |
| Religión | `religion.json` | ✅ |
| Relación (tutor + emergencia) | `relationship.json` | ✅ |
| Género | `gender.json` | ✅ |
| Tipo de vivienda | `housing_type.json` | ✅ |

## Pendientes (mismo patrón)

`heating_fuel`, `work_shift`, `animal_type`, `allergy_category` — mismo formato, a
completar cuando se definan sus catálogos.

> Nota: los `value` se alinean con los enums del dominio (`EOccupationType`,
> `ERelationship`, `EGenderIdentity`) para facilitar la migración enum → catálogo;
> la alineación exacta se cierra en la fase de BD (hallazgos diferidos).
