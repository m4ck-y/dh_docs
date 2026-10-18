# ADR 049: Referencia a catálogos y a tablas de otro servicio — `id` en la misma BD, `key` cuando cruza motor

## Estado
Aceptado (2026-10-18)

## Contexto

El [ADR 044](044-catalogos-gobernados.md) define que el `value` de un catálogo
gobernado es el *"identificador estable (respuesta + FK de dominio)"*, pero **no
precisa cómo se almacena la referencia** en la tabla de dominio. Los ERDs
existentes mezclan dos formas:

| Forma | Ejemplo |
|---|---|
| `id_*` → Integer con FK real | `auth.user.id_person` → `people.person.id` |
| `key_*` → String, sin constraint | `people.address.key_state` · `sociocultural_identity.key_religion` |

Además, la [matriz de acceso](../db/service_database_access_matrix.md) se
contradice: su **principio 3** pide *"FK cross-service con `id` Integer con
constraint real — misma instancia PostgreSQL"*, mientras que su **regla
cross-service** pide *"`person_uuid UUID` sin FK constraint"*.

Y los catálogos **no viven en un solo motor** ([ADR 003](003-estrategia-multi-base-de-datos.md),
reparto del ADR 044): los gobernados/extensibles en **PostgreSQL**, los masivos
(código postal, CIE-11, vademécum) en **ClickHouse**, los documentales en
**MongoDB**. En los tres, el único identificador común es el `value`.

## Decisión

La forma de la referencia se decide **por dónde vive el destino**:

| Destino | Forma | Constraint |
|---|---|---|
| **Misma base de datos / motor** (incluye los catálogos gobernados en PostgreSQL) | **`id_*` Integer** → el `id` de la tabla | FK real |
| **Otro motor o servidor** (catálogos masivos en ClickHouse, etc.) | **`key_*` String** → el `value` del catálogo o el `key` de la tabla | sin constraint |

Reglas complementarias:

- La **API y los DTO** siempre exponen el `value` (catálogos) o el `uuid`
  (entidades) — nunca el `id` ([ADR 017](017-referencias-cross-service.md)). El
  mapeo `value → id` vive en el repositorio.
- El **seed** inserta por `value`; la referencia se resuelve al cargar. No se
  fijan ids.
- Al **fusionar** duplicados (`merged_into`, ADR 044) la curaduría reescribe las
  referencias al `id` canónico; hacia afuera se sigue viendo el `value`.
- Un vocabulario **con "Otro/Especifique"** es siempre **catálogo** (tabla); los
  campos **sin "Otro"** son **opciones estáticas** — sin tabla y sin `enum` de
  BD (ADR 044).

## Consecuencias

- Se gana integridad donde es posible (misma BD) sin renunciar a los catálogos
  que viven en otro motor.
- Las columnas `key_*` que apuntan a catálogos **gobernados en PostgreSQL**
  (`key_religion`, `key_gender`) migran a `id_*` con FK real; las que apuntan a
  catálogos **masivos** (`key_state`, `key_municipality`, `key_colony`,
  `key_country`, `key_nationality`) se mantienen como `key_*`.
- Queda **enmendado** el texto del ADR 044: el `value` es el identificador de la
  respuesta y del dominio **hacia afuera**; en la base puede guardarse como `id`.
- Resuelve la contradicción de la matriz de acceso: el principio 3 aplica
  **dentro de la misma instancia**; entre servicios/motores rige la referencia
  por identificador natural.
- Pendiente: alinear la longitud de las `key_*` (`String(20)`) con la del `value`
  del catálogo (`String(100)`).

## Referencias

- [ADR 044 — Catálogos con gobernanza](044-catalogos-gobernados.md)
- [ADR 017 — Referencias Cross-Service](017-referencias-cross-service.md)
- [ADR 003 — Estrategia Multi-Base de Datos](003-estrategia-multi-base-de-datos.md)
- [Matriz de acceso servicios ↔ schemas](../db/service_database_access_matrix.md)
