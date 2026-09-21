# catalog

Schema de PostgreSQL para **catálogos gobernados** (vocabularios extensibles,
referenciados por FK). Dueño: `dh_catalogs`.

- **Una tabla por catálogo**, misma forma (`value` UNIQUE, `label`, `description`,
  `status`, `merged_into`, `order`) — el dominio los referencia por **FK tipada**;
  reevaluar si crecen a decenas. Tablas = entradas `POSTGRES` del
  [registro](../../features/catalogs/config/example.json); el `key` nombra la tabla.
- Los **masivos** (CP, CIE-11, Vademecum) → ClickHouse, no aquí.
- Registro/política/curaduría: [`features/catalogs/`](../../features/catalogs/) ·
  [ADR 044](../../decisions/044-catalogos-gobernados.md).

**Modelo:** [`erd.mmd`](./erd.mmd) · Pendiente: DDL (`COMMENT`s/índices) + FK del dominio.
