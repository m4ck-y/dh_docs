# signup (feature)

Flujo de **autorregistro**: desde la creación de la cuenta hasta el perfil de la
persona en el sistema. Lo implementa el micro-frontend `dh_frontend_signup` y lo
orquesta `dh_onboarding` (crea la `person` en `dh_core`).

**Estado:** 🟡 parcial — el front está implementado; la orquestación del backend
(alta de cuenta + perfil + aceptación) está 🔴 pendiente.

**Diccionario de datos:** [map.md](./map.md) — qué captura cada paso y **dónde se
guarda** (`schema.tabla.columna`).

## Flujo

```
1. Cuenta            correo · contraseña · acepta términos        → auth + dh_legal
2. Verificación      código OTP al destino                        → dh_mfa
3. Perfil (wizard)   Datos personales → Domicilio →
                     Información complementaria → Contacto de emergencia
4. Verifica tus datos  revisión (editar cualquier paso)
5. Envío             alta de la persona y su perfil               → dh_core
```

- Los títulos de los pasos son los del front (`REGISTER_TEXTS.wizardSteps`), y hay
  **dos variantes**: el usuario crea su propio perfil (*main*) o un tutor crea el
  perfil de la persona en seguimiento (*associated*), que agrega `parentesco` y
  `viveContigo`.
- El paso *Datos personales* arranca con el **CURP**: el front prellena nombre,
  fecha de nacimiento y sexo desde ahí (`domain/curp.ts`) — el backend no debe
  confiar en esa derivación.

## Qué escribe cada bloque

| Bloque | Escribe en |
|---|---|
| Cuenta (correo, contraseña) | `auth.user` |
| Verificación OTP | `dh_mfa.otp_challenges` |
| Aceptación de términos | `dh_legal.legal_acceptances` ([ADR 050](../../decisions/050-contenido-legal-en-mongodb.md)) |
| Perfil (los 4 pasos) | `people.*` · `health_profile.biological_profile` · `relationships.person_responsible` |

Los catálogos (`gender`, `religion`, `orientation`, `occupation`, `relationship`)
se referencian como `id_*` (FK dentro de PostgreSQL) y los geográficos como
`key_*` (cruzan motor) — [ADR 049](../../decisions/049-referencia-catalogos-id-vs-key.md).

> 🔴 **Pendiente**: la columna **servicio objetivo** por destino (hoy se deduce del
> [mapa de propiedad](../../ARCHITECTURE_OVERVIEW.md): `dh_core` → `people`/`health_profile`/`relationships`,
> `dh_auth` → `auth`, `dh_mfa` → `dh_mfa`, `dh_legal` → `dh_legal`).

## Nota — historia clínica

> El **registro** de la historia clínica
> ([`clinical_history/sections/A_registro.md`](../clinical_history/sections/A_registro.md))
> es documentación **aparte**: tiene su propio formato y estructura (numeración
> clínica `1.x`, fuente drawio), no este diccionario. Lo que comparte con el signup
> es el **destino**: cuando un campo de la HC apunta al mismo `schema.tabla.columna`
> que ya se llenó acá, **se reutiliza** y no se vuelve a capturar.
>
> - **Se reutilizan** (mismo destino, ya llenado acá): nombre, fecha y lugar de
>   nacimiento, sexo al nacer, género, orientación, religión, estado civil,
>   escolaridad, ocupación, domicilio y teléfonos — ya en `people.*` y
>   `health_profile.biological_profile`.
> - **No se reutilizan — no existe destino** (siguen siendo captura de la HC):
>   dependientes (`1.2.19`) y grupo étnico (`G2`) — de este último el modelo solo
>   tiene la bandera `self_considers_indigenous` y el idioma, no el grupo.
> - **Existe destino pero no coincide** — ingresos (`1.2.18`): hay columna
>   (`people.profile.income_range`), pero `EIncomeRange` está en **rangos de $** y la
>   HC pregunta por **suficiencia** → desalineado 🔴.

## Pendientes

| # | Punto | Estado |
|---|---|---|
| 1 | Orquestación del alta (cuenta + perfil + aceptación) en `dh_onboarding` | 🔴 |
| 2 | Los **7 gaps** del mapa (sin destino, duplicidades, desalineados) | 🔴 ver [map.md](./map.md#gaps) |
| 3 | Columna **servicio objetivo** por destino | 🔴 |
| 4 | **Reutilización con la HC**: resolver por `schema.tabla.columna` (que el componente de la HC lea el perfil en vez de volver a preguntar) | 🔴 |
| 5 | `payload` de ejemplo del paso *Verifica tus datos* (`example.jsonc`) | 🔴 opcional |
| 6 | **Backend/front del contacto de emergencia** y demás derivas del modelo: ver [Pendientes de implementación](./map.md#pendientes-de-implementación) | 🔴 |

## Referencias

- Contrato del front: `frontend/dh_frontend_signup/src/domain/schemas.ts` · `constants.ts`
- Destinos: [`db/postgres/people/`](../../db/postgres/people/erd.mmd) · [`health_profile/`](../../db/postgres/health_profile/erd.mmd) · [`relationships/`](../../db/postgres/relationships/erd.mmd) · [`auth/`](../../db/postgres/auth/ERD.mmd)
- [ADR 044 — Catálogos con gobernanza](../../decisions/044-catalogos-gobernados.md) · [ADR 049 — `id` vs `key`](../../decisions/049-referencia-catalogos-id-vs-key.md) · [ADR 050 — Legal en MongoDB](../../decisions/050-contenido-legal-en-mongodb.md)
- [Feature legal](../legal/README.md) (aceptación de términos)
