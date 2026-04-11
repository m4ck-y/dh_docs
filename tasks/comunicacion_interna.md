# Guía de Comunicación Interna (Microservicios)

Este documento define cómo los microservicios (`app_*`) deben interactuar con el núcleo central (`api_core`) y cómo se maneja el tráfico externo.

## 1. Flujo de Peticiones Externas

1.  **Origen**: Aplicación Móvil, Web o Frontend.
2.  **Destino**: `api_middleware`.
3.  **Proceso**:
    - El middleware valida el token JWT contra `api_core` (o de forma autónoma si tiene la clave pública).
    - El middleware redirige la petición al microservicio correspondiente (ej. `app_questionnaire`).

## 2. Comunicación Interna (Service-to-Service)

Cuando un microservicio como `app_questionnaire` necesita datos que residen en `api_core`, debe realizar una petición interna.

### Reglas de Oro:
- **No acceso directo a DB**: Un microservicio NUNCA debe leer directamente la base de datos de otro. Siempre debe usar la API interna.
- **Protocolo**: Se recomienda el uso de peticiones REST internas o un cliente HTTP asíncrono (como `httpx`).

### Ejemplo de flujo (Obtención de datos de Persona):
1.  `app_questionnaire` recibe una petición para un formulario.
2.  `app_questionnaire` realiza una petición `GET` interna a `api_core/person/{id}`.
3.  `api_core` responde con el objeto JSON de la persona.
4.  `app_questionnaire` procesa la lógica y responde al middleware.

## 3. Seguridad Interna

- **Tokens de Servicio**: Las peticiones entre microservicios deben incluir un encabezado de autorización especial o realizarse a través de una red privada (Docker Network) que no esté expuesta al exterior.
- **API Core**: Ha sido designado como el "Single Source of Truth" para Identidades y Personas. No debe exponer endpoints CRUD de personas directamente al exterior a menos que sea a través del middleware con los permisos adecuados.

## 4. Implementación Sugerida

Se recomienda crear una clase `CoreAPIClient` en la carpeta `shared/` de cada microservicio para abstraer las llamadas a `api_core`.
