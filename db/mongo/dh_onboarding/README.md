# dh_onboarding

Base documental del servicio `dh_onboarding`: los **leads** interesados antes de
que inicien el onboarding formal (ciclo de vida, invitación y conversión).

| Colección | Clase | Qué guarda |
|---|---|---|
| `waitlist` | `WaitlistLead` | el lead: contacto, estado del ciclo de vida e invitación |

- Diagrama: [CLASS.mmd](./CLASS.mmd) — 1 colección + 3 subdocumentos embebidos
  (`metadata`, `timestamps`, `onboarding`) + 1 enum (`EWaitlistStatus`).
- Ejemplo de registro: [waitlist.jsonc](./waitlist.jsonc) — el lead en estado
  `ACTIVE`, con los campos de la invitación y la conversión en `null`.
- Flujo (estados, transiciones, invitación, conversión): doc del servicio
  `backend/dh_onboarding/docs/WAITLIST_LIFECYCLE.md`.
- Código: `backend/dh_onboarding/app/contexts/waitlist/domain/models/waitlist_lead.py`.

## Pendientes

| # | Punto | Estado |
|---|---|---|
| 1 | `source` — vocabulario sin cerrar (ADR 044): **enum de texto** o **catálogo** si lleva "Otro"; hoy `Optional[str]` libre | 🔴 por decidir |
| 2 | `onboarding.invite_token` — se guarda **en claro**; propuesto hash SHA-256 (precedente `dh_mfa`) + índice por hash | 🔴 por decidir |
| 3 | Índices `status`, `timestamps.created_at`, `onboarding.invite_token` — documentados pero **no implementados** (no hay `IndexModel`) | 🔴 pendiente |
| 4 | Conversión (`CONVERTED`): `converted_at` y `uuid_person_postgres` reservados; falta el endpoint que los escribe | 🔴 pendiente |
