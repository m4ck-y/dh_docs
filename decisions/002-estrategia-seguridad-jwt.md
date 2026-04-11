# ADR 002: Estrategia de Seguridad JWT (Identity Propagation)

## Estado
Aceptado

## Contexto
En un ecosistema de microservicios, existen varias formas de manejar la autenticación. Necesitamos decidir si la validación del token JWT se realiza únicamente en el punto de entrada (Gateway) o en cada microservicio individualmente. Dado que el sistema maneja datos hospitalarios sensibles, la seguridad es una prioridad máxima.

## Decisión
Se ha decidido implementar la **Opción B: Validación Global mediante Propagación de Identidad**.

1.  **api_middleware**: Realizará la primera validación. Si el token es inválido, rechazará la petición inmediatamente. Si es válido, pasará el token original (sin modificar) en el encabezado `Authorization` a los microservicios.
2.  **Microservicios (`app_*`, `api_core`)**: Cada servicio volverá a validar el token JWT utilizando la clave pública/secreto compartido antes de procesar cualquier lógica de negocio.

## Consecuencias
- **Positivas**: 
    - **Arquitectura Zero-Trust**: La seguridad no depende únicamente del perímetro (Gateway). Cada servicio es responsable de su propia seguridad.
    - **Cumplimiento Normativo**: Alineado con estándares de salud (HIPAA/GDPR) para la protección de datos sensibles.
    - **Trazabilidad**: Cada microservicio tiene acceso directo a la identidad del usuario a través del token.
- **Negativas**: 
    - **Ligero Overhead**: Se repite la validación criptográfica en cada salto, aunque el impacto es despreciable dada la eficiencia de las librerías actuales.
    - **Gestión de Claves**: Todos los servicios deben tener acceso a las claves de validación.
