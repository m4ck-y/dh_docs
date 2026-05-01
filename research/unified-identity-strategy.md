# Investigación: Estrategia de Identidad Unificada y Solicitud de Roles

## Resumen
Esta investigación propone un cambio de paradigma en el proceso de registro de Digital Hospital. Actualmente, el sistema diferencia entre perfiles (Paciente/Médico) desde el paso 1. La propuesta sugiere que todos los usuarios sigan un flujo de **Onboarding Unificado** para validar su identidad base como "Persona", permitiendo la "Solicitud de Roles" (Escalamiento) de forma posterior y modular.

## Estado Actual (As-Is)
- **Onboarding Legacy**: Fuerza la selección de rol al inicio.
- **A. Registro (Clínico)**: Supone que el paciente es quien inicia el registro y luego pregunta por un tutor, lo cual es lógicamente inconsistente para menores de edad o personas incapacitadas.

## Propuesta: Identidad Primero, Rol Después (To-Be)
El flujo debe invertirse para garantizar la integridad de los datos y la gestión de dependencias:

1.  **Onboarding Universal**: 
    - Registro de cuenta (Email/Tel/Pass).
    - Verificación (OTP).
    - Datos Personales Básicos + CURP.
    - Carga de Identificación Base.
    - *Resultado*: El usuario existe como una entidad `Person` verificada, pero sin privilegios específicos (Base Role).

2.  **Solicitud de Roles (Role Escalation)**:
    - Desde la aplicación, el usuario puede elevar su perfil.
    
    ### Caso A: Tutor / Cuidador
    - El usuario solicita el rol de **Tutor**.
    - Proporciona documentos adicionales (si aplica).
    - Una vez aprobado, se habilita la opción: **"Gestionar personas bajo mi cuidado"**.
    - El Tutor registra a los dependientes (Pacientes). Esto resuelve el problema detectado en [A_REGISTRO.mmd](../historial_clinico/diagram/A_REGISTRO.mmd) al permitir que la persona legalmente responsable sea la que crea el expediente del dependiente.

    ### Caso B: Profesional de la Salud
    - El usuario solicita el rol de **Médico**.
    - Proporciona: Título profesional, Cédula, Especialidad.
    - Pasa a un flujo de validación administrativa específico para profesionales.

## Ventajas de este enfoque
- **Consistencia**: Todos los usuarios pasan por la misma validación de identidad robusta.
- **Flexibilidad**: Un mismo usuario (Persona) podría ser Tutor de su hijo y Paciente de un médico simultáneamente sin duplicar identidades.
- **Seguridad**: Se valida la identidad legal del tutor ANTES de que este proporcione datos sensibles de un menor.

## Archivos Relacionados
- [onboarding_legacy.mmd](../management/1_onboarding_legacy/onboarding_legacy.mmd)
- [A_REGISTRO.mmd](../historial_clinico/diagram/A_REGISTRO.mmd)
- [PROPOSAL_ROLE_ESCALATION_FLOW.mmd](../management/1_onboarding/PROPOSAL_ROLE_ESCALATION_FLOW.mmd) (En desarrollo)
