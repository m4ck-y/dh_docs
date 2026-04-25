## Documentacion de Schemas y Tablas

---

## Schema: `public`

**Descripción:**

Contiene las entidades centrales, compartidas y de alto nivel que son reutilizadas por otros módulos del sistema. Incluye datos fundamentales como personas y empleados.

**Tablas principales:**

- `person`
- `employee`

---

## Schema: `person_data`

**Descripción:**

Almacena datos extendidos o complementarios asociados a una persona, manteniendo el núcleo `public.person` limpio y modular.

**Tablas principales:**

- `person_birth`
- `person_address`
- `person_document`

---

## Schema: `health_profile`

**Descripción:**

Agrupa atributos biológicos y clínicos estables del individuo, como sexo biológico, tipo de sangre, alergias crónicas y condiciones de salud de largo plazo.

**Tablas principales:**

- `biological_profile`
- `person_allergy`
- `chronic_condition`
- `vaccination_record`

---

## Schema: `health_monitoring`

**Descripción:**

Registra datos dinámicos o frecuentes, como signos vitales y mediciones de monitoreo continuo realizados en chequeos o mediante dispositivos conectados.

**Tablas principales:**

- `vital_measurement`
- `measurement_unit`
- `daily_checkup`

---

## Schema: `clinical_history`

**Descripción:**

Contiene el historial médico formal con trazabilidad temporal, incluyendo diagnósticos, internaciones, estudios médicos y planes de tratamiento.

**Tablas principales:**

- `diagnosis_record`
- `medical_study`
- `hospital_stay`
- `treatment_plan`

---

## Schema: `security`

**Descripción:**

Define el sistema de autenticación, autorización y control de acceso, con módulos, roles, permisos y sus relaciones.

**Tablas principales:**

- `role`
- `module`
- `permission`
- `role_permission`
- `user_role` *(relación entre usuarios y roles)*

---

## Schema: `account`

**Descripción:**

Gestiona cuentas de usuario y autenticación, separando la gestión de identidad de la lógica de seguridad.

**Tablas principales:**

- `user` (vinculada a `public.person`)
- `session` (sesiones activas o tokens)
- `password_reset` *(opcional)*
- `login_attempt` *(opcional para seguridad)*

---

# Tabla resumen con sugerencias de nombres y justificaciones

| Schema | Tabla original | Nombre sugerido | Motivo / Justificación |
| --- | --- | --- | --- |
| `public` | `person` | `person` | Central y ampliamente usada. |
|  | `employee` | `employee` | Directo y semántico. |
| `person_data` | `birth_info` | `person_birth` | Específico al nacimiento, evita ambigüedad. |
|  | `address` | `person_address` | Prefijo para claridad en relación a `person`. |
|  | `document` | `person_document` | Clarifica tipo y relación a persona. |
| `health_profile` | `health_info` | `biological_profile` | Más técnico y específico. |
|  | *(nuevo)* | `person_allergy` | Para alergias (relación uno a muchos). |
|  | *(nuevo)* | `chronic_condition` | Condiciones crónicas de salud. |
|  | *(nuevo)* | `vaccination_record` | Historial de vacunación. |
| `health_monitoring` | `measurement` | `vital_measurement` | Más claro y específico para signos vitales. |
|  | `unit` | `measurement_unit` | Aclara semántica de unidades. |
|  | *(nuevo)* | `daily_checkup` | Agrupación de mediciones por fecha. |
| `clinical_history` | *(nuevo)* | `diagnosis_record` | Más claro y formal que “diagnosis_history”. |
|  | *(nuevo)* | `medical_study` | Estudios médicos realizados. |
|  | *(nuevo)* | `hospital_stay` | Registro de internaciones. |
|  | *(nuevo)* | `treatment_plan` | Planes de tratamiento. |
| `security` | `roles` | `role` | Singular por convención. |
|  | `modules` | `module` | Singular y claro. |
|  | `permissions` | `permission` | Singular y específico. |
|  | `roles_permission` | `role_permission` | Tabla estándar para relaciones muchos a muchos. |
|  | *(nuevo)* | `user_role` | Relaciona usuarios con roles para asignación clara. |
| `account` | *(nuevo)* | `user` | Gestiona cuentas vinculadas a `person`. |
|  | *(nuevo)* | `session` | Controla sesiones activas y tokens. |
|  | *(nuevo, opcional)* | `password_reset` | Para recuperación de contraseña. |
|  | *(nuevo, opcional)* | `login_attempt` | Registro de intentos de inicio de sesión para seguridad. |

---

# Reglas de nomenclatura aplicadas

1. **Nombres en singular**: para mantener uniformidad y claridad.
2. **Prefijos para evitar ambigüedad**: especialmente en tablas relacionadas a entidades centrales.
3. **Uso de guion bajo en relaciones**: para tablas intermedias y claridad semántica.
4. **Evitar términos genéricos**: preferir nombres descriptivos y específicos.