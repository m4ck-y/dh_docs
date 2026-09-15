# Mappers

Mapeo de cada sección de la historia clínica a la base de datos (PostgreSQL).

- Convención de estado: 🟢 campo modelado · 🟡 entidad existe sin la columna · 🔴
  no existe (ver [ADR 032](../../../decisions/032-emoji-status-indicator-policy.md)).
- Cada sección produce `<seccion>.mapper.md`, hermano de su ficha en
  [`../sections/`](../sections/).

| Sección | Mapper | Estado |
|---|---|---|
| A - Registro | [`A_registro.mapper.md`](./A_registro.mapper.md) | ✅ |
| B - Antecedentes heredofamiliares | — | ⏳ pendiente |
| C - APNP | — | ⏳ pendiente |
| D - Antecedentes personales patológicos | — | ⏳ pendiente |
| E - Padecimiento actual | — | ⏳ pendiente |
