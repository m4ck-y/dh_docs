# ADR 016: Tipos de Membresía y Contextos de Usuario

## Estado
Aceptado

## Contexto
El sistema debe soportar dos tipos principales de usuarios:
1. **Usuarios Profesionales/Internos**: Médicos y personal administrativo que trabajan para una organización específica.
2. **Usuarios Externos/Pacientes**: Personas que acceden al sistema de forma global o a través de un portal de pacientes, sin estar vinculados laboralmente a un hospital específico.

Se requiere definir cómo se estructuran estos registros utilizando el esquema de multi-tenancy.

## Decisión
Implementar un modelo de membresías diferenciado basado en el `ETenantType` definido en el esquema IAM.

### 1. Usuario con Contexto de Empresa (COMPANY)
- **Vínculo**: `person` -> `membership` -> `tenant (type: COMPANY)`.
- **Naturaleza**: Representa a un **Empleado**.
- **Requerimientos**: 
    - Debe tener roles asignados dentro de ese tenant específico (ej: Médico, Recepcionista).
    - Suele tener un registro espejo en la tabla `organizations.employee` para datos de nómina, horario y cargo laboral (`personal_type`).
- **Uso**: Acceso a backoffice, gestión de pacientes, facturación hospitalaria.

### 2. Usuario con Contexto de Sistema (SYSTEM)
- **Vínculo**: `person` -> `membership` -> `tenant (type: SYSTEM)`.
- **Naturaleza**: Representa a un **Paciente o Usuario Público**.
- **Requerimientos**: 
    - Roles básicos globales (ej: Paciente, Usuario Registrado).
    - No requiere registro en la tabla `employee`.
- **Uso**: Portal del paciente, consulta de resultados, agendamiento de citas global.

### 3. Modelo Híbrido (Multi-membresía)
El sistema permitirá que una misma persona física tenga múltiples membresías simultáneamente.

## Jerarquía de Relaciones y Cardinalidad
Para garantizar la flexibilidad total, el sistema opera bajo los siguientes niveles:

1. **Multi-compañía (Nivel Organizacional)**: Una `person` puede estar vinculada a N `tenants` diferentes (B2B Multi-tenancy).
2. **Multi-membresía (Nivel de Acceso)**: Cada vínculo entre una persona y una compañía es una `membership` independiente. Al loguearse, el usuario elige una membresía activa, lo que define su contexto de datos.
3. **Multi-rol (Nivel de Permisos)**: Dentro de una misma `membership`, un usuario puede tener N `roles` asignados. El sistema debe **agregar (sumar)** todos los permisos de esos roles en el token JWT.

*Ejemplo*: El Dr. García (Persona) entra a Hospital Central (Compañía) con su membresía de empleado, la cual tiene los roles de "Médico" y "Jefe de Área" (Multi-rol). Al mismo tiempo, tiene otra membresía en el sistema global como "Paciente".

## Propiedad de Datos (Data Ownership)
Para evitar la duplicidad de lógica y asegurar la integridad, se define la siguiente propiedad exclusiva:

- **Microservicio `dh_auth`**: Dueño exclusivo de la tabla `AuthUser` (credenciales, contraseñas, tokens). Ningún otro servicio puede escribir directamente en esta tabla.
- **Microservicio `api_core`**: Dueño exclusivo de la tabla `Person` (perfil humano: nombre, fecha de nacimiento, género). Cualquier registro de persona (vía onboarding o administrativo) debe pasar por sus APIs.

## Consecuencias

### Positivas:
- **Flexibilidad Total**: No hay necesidad de duplicar datos de la persona si cambia de rol o de hospital.
- **Seguridad Granular**: El middleware puede filtrar accesos basándose en el tipo de tenant presente en el JWT.
- **Claridad de Dominio**: Separa claramente la identidad (`person`) de la función laboral (`employee`) y del acceso (`membership`).

### Negativas:
- **Complejidad en el Login**: El sistema de autenticación (`dh_auth`) debe permitir al usuario elegir su "contexto activo" si tiene múltiples membresías válidas.
