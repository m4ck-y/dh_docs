# relationships

Schema de PostgreSQL para **vínculos entre personas**: legales, sociales y de
cuidado.

Cada tabla es **un tipo de arista** entre dos `people.person` — **dirigida** o
**simétrica** — y es la base para el futuro **grafo** (migración a Neo4j).

## Convención: dirección por tabla

| Tipo de arista | Dirección |
|---|---|
| Parentesco / filiación | **Dirigida** (`progenitor → hijo`) |
| Pareja | **Simétrica** (A ↔ B) |
| Cuidado / responsabilidad | **Dirigida** (`dependiente → responsable`) |
| Amistad | **Simétrica** |
| Seguir | **Dirigida** (A sigue a B) |

## Entidades

| Entidad | Semántica | Dirección | Neo4j | Estado |
|---|---|---|---|---|
| `person_responsible` | Tutor / cuidador de un dependiente | Dirigida | `:RESPONSIBLE_FOR` | ✅ |
| `family` | Filiación (progenitor ↔ hijo) | Dirigida | `:PARENT_OF` | nueva |
| `partnership` | Pareja (esposo/a, concubinato) | Simétrica | `:SPOUSE_OF` | nueva |
| `friendship` | Amistad | Simétrica | `:FRIEND_OF` | diferible |
| `follow` | Seguir a otra persona | Dirigida | `:FOLLOWS` | diferible |

> **Nota de nombre:** la arista de pareja se llama `partnership` (no `union`)
> porque `UNION` es **palabra reservada** de SQL y obligaría a citarla siempre.

## Enums

| Enum | Valores | Usado por |
|---|---|---|
| `ERelationship` | `MOTHER`, `FATHER`, `CAREGIVER`, `LEGAL_GUARDIAN`, `OTHER` | `person_responsible` |
| `ECareRole` | `LIVES_WITH_AND_CARES`, `CARES_NOT_LIVING_WITH`, `ADMINISTRATIVE_SUPPORT_ONLY` | `person_responsible` |
| `EEconomicDependence` | `YES`, `PARTIALLY`, `NO` | `person_responsible` |
| `EParentageKind` | `BIOLOGICAL`, `ADOPTIVE`, `FOSTER`, `STEP` | `family` |
| `EUnionType` | `SPOUSE`, `PARTNER`, `DIVORCED` | `partnership` |

## Notas

- **Nodos = `people.person`**; estas tablas son **aristas**. La migración a Neo4j
  mapea cada tabla a un **label** de relación.
- **Simétricas** (`partnership`, `friendship`): guardar **una sola vez** con orden
  canónico (`*_id` menor primero) para no duplicar.
- **Dirigidas** (`family`, `person_responsible`, `follow`): el primer `*_id` es el
  **origen** y el segundo el **destino**.
- Sobre `person_responsible`: hoy mezcla **relación** (`type`) con
  **cuidado** (`care_role`, `economic_dependence`); a futuro podría derivarse la
  relación desde `family`/`partnership` (ver *Pendientes*).

## Archivos

| Archivo | Descripción |
|---|---|
| [erd.mmd](./erd.mmd) | **ERD — fuente del modelo** (entidades + enums) |

> El modelo del schema **vive en el ERD** (`.mmd`); no se mantienen DDL `.md` por
> tabla.

## Pendientes

- `friendship`, `follow` (aristas sociales) — **diferidas**.
- Vínculos legales/financieros (`power_of_attorney`, `insurance_links`) — futuros.
- Alinear el **nombre del schema** (`relationships` vs `care`) en el índice
  [`../README.md`](../README.md).
- Unificar el enum de relación con `people.emergency_contact`
  (`ERelationshipContact`) — hoy hay dos.
- Tablas de **cuidado** (`care_plan`, `care_visit`, …) que listaba el README
  previo **no** pertenecen a este schema (son dominio `care`).
