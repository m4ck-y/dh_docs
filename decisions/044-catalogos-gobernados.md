# ADR 044: Catálogos con gobernanza (vocabularios controlados extensibles)

## Estado
Aceptado

## Contexto

Varios campos de formularios (cuestionarios y historia clínica) terminan en la
opción **"Otro → Especifique"**: el usuario escribe un valor libre que no está en
las opciones precargadas (p. ej. parentesco, religión, ocupación, género). Dos
problemas:

1. Si se guarda como **texto libre** (columna `*_other`), varios usuarios pueden
   escribir **lo mismo con distinto texto** ("Ing. de software", "Ingeniero de
   Software", "programador") → el valor no es **reutilizable** ni **analizable**.
2. Si se modela como **enum**, no es **extensible**: cada valor nuevo exige un
   cambio de código/migración.

Los vocabularios de este tipo son **catálogos** (tablas de referencia). El
schema `catalog` ya está declarado como catálogos globales del sistema y su
dueño es el microservicio **`dh_catalogs`** (`ARCHITECTURE_OVERVIEW.md`), pero
hoy está **pendiente de modelar** (`docs/db/postgres/catalog/README.md`).

## Decisión

Adoptar **catálogos con gobernanza**: cada vocabulario controlado es una **tabla**
de `catalog`, con un **estado de validación** y un flujo de **creación por el
usuario** seguido de **curaduría**.

### 1. Entidad de catálogo

Cada vocabulario (relación, religión, ocupación, género, colonia, municipio,
etc.) es una tabla de `catalog`:

```
{ id, key, name, status, created_by, merged_into?, …BaseModel }
```

- **`status`** — enum **`ECatalogStatus`**:
  | Estado | Significado |
  |---|---|
  | `PENDING` | Creado por un usuario ("Especifique"); en cola de curaduría |
  | `VALIDATED` | Canónico (sembrado o promovido por curaduría); se ofrece en el selector |
  | `MERGED` | Desduplicado: apunta al canónico (`merged_into`); no se lista |
  | `REJECTED` | Descartado por curaduría (spam/inválido); no se lista |
- **`merged_into`** — referencia al ítem canónico cuando el ítem fue fusionado.
- Las opciones **sembradas/curradas** nacen como `VALIDATED`; las creadas por un
  usuario nacen como `PENDING`.

> `ECatalogStatus` es **distinto** de `EVerificationStatus` (verificación de
> identidad en `people`): aquí es el ciclo de vida de un término de catálogo.

### 2. Flujo de captura ("Otro → Especifique")

```
front (selector del catálogo)
  ├─ elige un ítem VALIDATED (o PENDING propio)  → guarda el id del ítem
  └─ elige "Otro" y escribe                        → envía un create-request
                                                      (schema create de la entidad)
        └─ dh_catalogs (API) crea el ítem con status=PENDING
              └─ la respuesta referencia el id del nuevo ítem
```

- El **front no envía el texto suelto**: envía un **objeto de creación**
  (`SchemaCreateRequest`) al endpoint de `dh_catalogs`.
- La **respuesta (answer) referencia el `id` del ítem** de catálogo (no el texto).
- Se mantiene trazabilidad: `created_by` del ítem.

### 3. Curaduría y desduplicación

- Un proceso (manual o asistido, posterior) revisa los `PENDING`.
- **Desduplicación**: fusionar `PENDING` hacia el canónico marcando
  `status = MERGED` + `merged_into = <canónico>`; las respuestas que apuntaban al
  ítem fusionado se **resuelven al canónico** (reportes/consultas).
- Promover a `VALIDATED`, o descartar con `REJECTED`.

### Alcance

Aplica a **todos** los campos "Otro/Especifique" (cuestionarios y HC): p. ej. en
la sección A de la HC — `tutor_relationship`, `religion`, `occupation`, `gender`,
`emergency_relationship`. Los campos **sin** "Otro" (escolaridad, estado civil,
sexo al nacer, etc.) siguen siendo **enum** estáticos.

## Alternativas consideradas y descartadas

1. **Texto libre (`*_other`)**. Descartada: duplica valores con distinto texto,
   no reutilizable ni consultable.
2. **Enum estático**. Descartada: no es extensible sin migración/código.
3. **Catálogo sin estado** (todo visible al instante). Descartada: sin
   curaduría, el selector se llena de duplicados y ruido.

## Consecuencias

**Positivas:**
- Vocabularios **reutilizables, consultables y curables**; desduplicación
  controlada.
- Extensible por el usuario **sin migración** y **sin ensuciar** el selector.

**Negativas:**
- Requiere el microservicio **`dh_catalogs`** (modelar schema `catalog` + endpoints)
  y un **proceso de curaduría**.
- La captura es más compleja que un texto libre (create-request + referencia).

## Referencias
- Owner: `docs/ARCHITECTURE_OVERVIEW.md` (`dh_catalogs` → schema `catalog`).
- Schema pendiente: `docs/db/postgres/catalog/README.md`.
- Impacto en el modelo de pregunta: pendiente **C20** (TASK-016) — opciones
  respaldadas por catálogo + flujo de create.
- Aplicación en la HC: `docs/features/clinical_history/sections/A_registro.md`.
