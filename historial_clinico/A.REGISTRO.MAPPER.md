# A. REGISTRO — Mapper DB

> **Convención:**
> - 🟢 `schema.entidad.columna` — campo ya modelado en la DB
> - 🟡 `schema.entidad` — entidad existe pero falta columna específica
> - 🔴 — no existe en la DB aún

---

## 1.0 ¿Requiere apoyo de tutor o responsable? _(pregunta condicional)_

🟢 `care.person_responsible` — la existencia de un registro implica "sí requiere tutor"

---

## Ruta 1.1 — Sí (con tutor/responsable)

> _"A continuación, ingrese los datos del tutor o responsable."_

### Datos del tutor / responsable

El tutor es una `person` en la DB. Sus datos se recogen igual que los del usuario.

- **1.1.1 Nombre completo** _(Apellido Paterno, Apellido Materno, Nombre(s))_
  - 🟢 `people.person.first_name`
  - 🟢 `people.person.last_name`
  - 🟢 `people.person.second_last_name`

- **1.1.2 Parentesco** _(condicional)_
  - 1.1.2.1 Madre → 🟢 `care.person_responsible.type_relationship` = `MOTHER`
  - 1.1.2.2 Padre → 🟢 `care.person_responsible.type_relationship` = `FATHER`
  - 1.1.2.3 Cuidador(a) → 🟢 `care.person_responsible.type_relationship` = `CAREGIVER`
  - 1.1.2.4 Tutor legal → 🟢 `care.person_responsible.type_relationship` = `LEGAL_GUARDIAN`
  - 1.1.2.6 Otro → 🟢 `care.person_responsible.type_relationship` = `OTHER`
    - 1.1.2.6.1 _Especifique_ → 🟢 `care.person_responsible.other_relationship`

- **1.1.3 ¿Cuál es su relación en el cuidado y vida diaria del paciente?** _(condicional)_
  - 1.1.3.1 Vive con el usuario y participa en su cuidado → 🟢 `care.person_responsible.care_role` = `LIVES_WITH_AND_CARES`
  - 1.1.3.2 Participa en su cuidado, pero no vive con él/ella → 🟢 `care.person_responsible.care_role` = `CARES_NOT_LIVING_WITH`
  - 1.1.3.3 Sólo brinda apoyo administrativo o legal → 🟢 `care.person_responsible.care_role` = `ADMINISTRATIVE_SUPPORT_ONLY`

---

> _"A continuación, comparta algunos datos generales que nos ayudarán a conocer mejor su entorno."_

### Datos del usuario (recopilados por el tutor)

- **1.1.4 Domicilio actual** _(Calle, Manzana/Lote o # Ext., # Int., Unidad, Colonia, Ciudad, Entidad, CP.)_
  - 🟢 `people.address.address` — calle + número
  - 🟢 `people.address.address_complement` — # int., unidad
  - 🟢 `people.address.key_colony` → catálogo colonia
  - 🟢 `people.address.key_municipality` → catálogo municipio/ciudad
  - 🟢 `people.address.key_state` → catálogo entidad federativa
  - 🟢 `people.address.key_country` → catálogo país
  - 🟢 `people.address.postal_code`
  - 🟢 `people.address.type_address` = `HOME`

- **1.1.5 Fecha de nacimiento** _(dd, mmm, aaaa)_
  - 🟢 `people.birth.birth_date`

- **1.1.6 Lugar de nacimiento** _(Ciudad, Edo)_
  - 🟢 `people.birth.key_state_birth`
  - 🟢 `people.birth.key_birth_country`

- **1.1.7 Teléfono fijo**
  - 🟢 `people.phone.code` + `people.phone.number` con `type_phone` = `HOME`

- **1.1.8 Celular**
  - 🟢 `people.phone.code` + `people.phone.number` con `type_phone` = `MOBILE`

- **1.1.9 Correo electrónico**
  - 🟢 `people.email.email` con `type_email` = `PERSONAL`

- **1.1.10 Sexo al nacer** _(condicional)_
  - 1.1.10.1 Femenino → 🟡 `people.person` — `EGenderIdentity` tiene `FEMENINO` pero es identidad de género, no sexo biológico al nacer
  - 1.1.10.2 Masculino → 🟡 `people.person` — misma situación
  - 1.1.10.3 Intersexual → 🟡 `people.person` — `EGenderIdentity` tiene `INTERSEXUAL`
  - 1.1.10.4 Prefiere no decirlo → 🔴 — no hay opción explícita de "prefiere no decirlo" en el enum

  > ⚠️ El campo `people.person.type_gender` modela identidad de género (`EGenderIdentity`), no sexo al nacer. Se necesita una columna separada `sex_at_birth` o un enum dedicado.

- **1.1.11 Edad**
  - 🟢 calculada desde `people.birth.birth_date` (no se almacena)

- **1.1.12 Religión** _(condicional)_
  - 1.1.12.1 Católica → 🟡 `people.sociocultural_identity.key_religion` — existe la FK al catálogo
  - 1.1.12.2 Cristiana → 🟡 `people.sociocultural_identity.key_religion`
  - 1.1.12.3 Otra religión → 🟡 `people.sociocultural_identity.key_religion`
    - 1.1.12.3.1 _Especifique_ → 🔴 — no hay campo de texto libre para religión personalizada
  - 1.1.12.4 Ninguna → 🟡 `people.sociocultural_identity.key_religion` — depende del catálogo
  - 1.1.12.5 Prefiere no decirlo → 🔴 — no modelado

- **1.1.13 Escolaridad**
  - 1.1.13.1 Sin estudios → 🔴
  - 1.1.13.2 Educación primaria → 🔴
  - 1.1.13.3 Educación secundaria → 🔴
  - 1.1.13.4 Educación media superior → 🔴
  - 1.1.13.5 Educación superior → 🔴
  - 1.1.13.6 Posgrado → 🔴
  - 1.1.13.6 Prefiere no decirlo → 🔴

  > ⚠️ No existe entidad/columna de escolaridad en ningún schema.

- **1.1.14 Estado civil** _(condicional)_
  - 1.1.14.1 Soltero/a → 🟡 `people.legal_info.type_civil_status` — columna existe como `String`, sin enum definido
  - 1.1.14.2 Casado/a → 🟡 `people.legal_info.type_civil_status`
  - 1.1.14.3 Unión libre / convivencia → 🟡 `people.legal_info.type_civil_status`
  - 1.1.14.4 Separado/a → 🟡 `people.legal_info.type_civil_status`
  - 1.1.14.5 Divorciado/a → 🟡 `people.legal_info.type_civil_status`
  - 1.1.14.6 Viudo/a → 🟡 `people.legal_info.type_civil_status`
  - 1.1.14.7 Prefiere no decirlo → 🔴 — `type_civil_status` es `String` libre, sin enum que lo contemple

- **1.1.17 ¿El usuario depende económicamente de usted?**
  - 1.1.17.1 Sí → 🔴
  - 1.1.17.2 Parcialmente → 🔴
  - 1.1.17.3 No → 🔴

  > ⚠️ No existe campo de dependencia económica en `care.person_responsible` ni en otro schema.

- **1.1.15 Ocupación**
  - 1.1.15.1 Empleado/a → 🟡 `people.profile.occupation` — campo texto libre, sin enum de categorías
  - 1.1.15.2–1.1.15.8 (resto de opciones) → 🟡 `people.profile.occupation` — mismo campo, pero sin enum de categorías estandarizadas

- **1.1.16 Ingresos**
  - 1.1.16.1 Sin ingresos → 🔴
  - 1.1.16.2 < $5,000 → 🔴
  - 1.1.16.3 $5,000 – $9,999 → 🔴
  - 1.1.16.4 $10,000 – $19,999 → 🔴
  - 1.1.16.5 $20,000 – $39,999 → 🔴
  - 1.1.16.6 ≥ $40,000 → 🔴
  - 1.1.16.7 Prefiere no decirlo → 🔴

  > ⚠️ No existe ningún campo de ingresos en la DB.

---

## Ruta 1.2 — No (sin tutor)

_(El usuario llena sus propios datos. Mismos campos y mapeos que los de la sección 1.1, aplicados directamente a la `person` del usuario.)_

---

## Datos generales del usuario _(persona en seguimiento)_

- **1.2.1 Nombre completo**
  - 🟢 `people.person.first_name`
  - 🟢 `people.person.last_name`
  - 🟢 `people.person.second_last_name`

- **1.2.2 Domicilio actual**
  - 🟢 `people.address.*` (ver desglose en 1.1.4)

- **1.2.3 Fecha de nacimiento**
  - 🟢 `people.birth.birth_date`

- **1.2.4 Lugar de nacimiento**
  - 🟢 `people.birth.key_state_birth`
  - 🟢 `people.birth.key_birth_country`

- **1.2.5 Teléfono fijo**
  - 🟢 `people.phone` con `type_phone` = `HOME`

- **1.2.6 Celular**
  - 🟢 `people.phone` con `type_phone` = `MOBILE`

- **1.2.7 Correo electrónico**
  - 🟢 `people.email.email` con `type_email` = `PERSONAL`

### Contacto de emergencia _(opcional)_

- **1.2.8B Nombre completo del contacto**
  - 🟢 `people.emergency_contact.first_name`
  - 🟢 `people.emergency_contact.last_name`

- **1.2.9 Parentesco** _(condicional)_
  - 1.2.9.1 Madre → 🟡 `people.emergency_contact.relationship_type` — `ERelationshipContact` tiene `PARENT`, no diferencia madre/padre
  - 1.2.9.2 Padre → 🟡 `people.emergency_contact.relationship_type` = `PARENT`
  - 1.2.9.3 Pareja → 🟢 `people.emergency_contact.relationship_type` = `SPOUSE`
  - 1.2.9.4 Hermano(a) → 🟢 `people.emergency_contact.relationship_type` = `SIBLING`
  - 1.2.9.5 Hijo(a) → 🟢 `people.emergency_contact.relationship_type` = `CHILD`
  - 1.2.9.6 Amigo(a) → 🟢 `people.emergency_contact.relationship_type` = `FRIEND`
  - 1.2.9.7 Cuidador(a) → 🔴 — `ERelationshipContact` no tiene `CAREGIVER`
  - 1.2.9.4 Otro → 🟢 `people.emergency_contact.relationship_type` = `OTHER`
    - 1.2.9.1.1 _Especifique_ → 🔴 — `emergency_contact` no tiene campo de texto libre para relación personalizada

- **1.2.10 Teléfono principal del contacto**
  - 🟢 `people.emergency_contact.phone_number`

### Más datos del usuario

- **1.2.11 Sexo al nacer**
  - 🟡 `people.person.type_gender` — misma situación que 1.1.10 (ver nota)

- **1.2.13 Edad**
  - 🟢 calculada desde `people.birth.birth_date`

- **1.2.14 Religión**
  - 🟡 `people.sociocultural_identity.key_religion` (ver nota en 1.1.12)

- **1.2.16 Estado civil**
  - 🟡 `people.legal_info.type_civil_status` (ver nota en 1.1.14)

---

## Resumen de gaps 🔴

| Campo | Schema sugerido | Nota |
|---|---|---|
| Sexo al nacer (vs. identidad de género) | `people.person` | Agregar `sex_at_birth` con enum dedicado |
| Escolaridad | `people` | Nueva entidad/columna `education_level` |
| Ingresos | `people` | Nueva columna `income_range` en `profile` o `sociocultural_identity` |
| Dependencia económica | `care.person_responsible` | Agregar `economic_dependency` enum (FULL, PARTIAL, NONE) |
| Religión: texto libre / "prefiere no decirlo" | `people.sociocultural_identity` | Agregar `religion_other` texto libre + valor en catálogo |
| Cuidador(a) como parentesco de emergencia | `people.emergency_contact` | Agregar `CAREGIVER` a `ERelationshipContact` |
| Texto libre parentesco de emergencia | `people.emergency_contact` | Agregar columna `other_relationship` |
| "Prefiere no decirlo" en edo. civil | `people.legal_info` | Definir enum `ECivilStatus` con esa opción |
