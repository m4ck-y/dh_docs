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
- **"Otro"** es la única *UI affordance*: dispara el **create** → ítem `PENDING`.
- **"Prefiere no decirlo"** y **"Ninguna"** **sí son ítems** del catálogo
  (`status = VALIDATED`, con su `value`): el selector los necesita
  ([ADR 046](../../../decisions/046-opciones-pregunta.md) §6). El **dominio los
  mapea a `NULL`** — el centinela nunca se persiste, así que los `enum` de
  dominio **no** lo incluyen.

## Archivos

| Catálogo | Archivo | Extensible (`governed`) |
|---|---|---|
| Ocupación | `occupation.json` | ✅ |
| Religión | `religion.json` | ✅ |
| Relación (tutor + emergencia) | `relationship.json` | ✅ |
| Orientación sexual | `orientation.json` | ✅ |
| Género | `gender.json` | ✅ |
| Tipo de vivienda | `housing_type.json` | ✅ |
| Combustible de calefacción | `heating_fuel.json` | ✅ |
| Turno laboral | `work_shift.json` | ✅ |

## Pendientes (mismo patrón)

`animal_type`, `allergy_category` — mismo formato, a completar cuando se definan
sus catálogos.

> Nota: los `value` son los canónicos del dominio. Los enums de captura
> (`EOccupationType`, `ERelationship`, `EGenderIdentity`) se retiraron del ERD
> (ADR 044/049) y el dominio los referencia por FK al catálogo.
