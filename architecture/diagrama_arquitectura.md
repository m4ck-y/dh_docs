# Diagrama de Arquitectura Global - Hospital Digital

Este diagrama visualiza la interacción entre el Frontend, el Middleware, los microservicios de negocio y las capas transversales de observabilidad y mensajería del ecosistema.

```mermaid
graph TD
    User((Usuario / Frontend)) -->|Petición HTTPS| Middleware

    subgraph Gateway_Layer["Capa de Entrada (Gateway)"]
        Middleware["api_middleware
(Entry Point / JWT / Proxy)"]
    end

    subgraph Services_Layer["Capa de Microservicios (Negocio)"]
        Core["dh_core
(Identidad / Personas / IAM)"]
        Auth["dh_auth
(Autenticación / MFA / JWT)"]
        Onboarding["dh_onboarding
(Flujo de Registro / Orquestación)"]
        Questionnaire["dh_questionnaire
(FormFlow)"]
        Health["dh_health_monitoring
(Monitoreo Clínico)"]

        Onboarding -..->|Orquestación| Core
        Onboarding -..->|Orquestación| Auth
        Questionnaire -..->|Consulta Interna| Core
        Health -..->|Consulta Interna| Core
    end

    subgraph CrossCutting_Layer["Capa Transversal (Cross-cutting)"]
        Logger["dh_logger
(Observability Gateway)
Logs · Traces · Metrics · Events"]
        Messenger["dh_notify
(PulseCore · Messaging)
Email · SMS · WhatsApp"]
    end

    subgraph Storage_Layer["Capa de Datos (Persistence)"]
        Postgres[(PostgreSQL
Transaccional)]
        Mongo[(MongoDB
Leads / Logs / Configs)]
        Clickhouse[(ClickHouse
Fase 2 - Analítica / OLAP)]
        MemBuffer[("In-Memory Buffer
(Dev Phase)")]
    end

    subgraph External_Layer["Proveedores Externos"]
        SMTP["SMTP / Google Mail"]
        Twilio["Twilio (SMS / WhatsApp)"]
        SigNoz["SigNoz / OpenTelemetry
(Fase 3 - Futuro)"]
    end

    %% Gateway routing
    Middleware -->|Routing| Core
    Middleware -->|Auth & Login| Auth
    Middleware -->|Proxy Routing| Onboarding
    Middleware -->|Proxy Routing| Questionnaire
    Middleware -->|Proxy Routing| Health

    %% Business services → Observability
    Middleware -->|Telemetría| Logger
    Core -->|Telemetría| Logger
    Auth -->|Telemetría| Logger
    Onboarding -->|Telemetría| Logger
    Questionnaire -->|Telemetría| Logger
    Health -->|Telemetría| Logger

    %% Business services → Messaging
    Core -->|Despacho| Messenger
    Auth -->|OTP / Reset| Messenger
    Onboarding -->|Notificaciones| Messenger
    Questionnaire -->|Notificaciones| Messenger
    Health -->|Alertas Clínicas| Messenger

    %% Frontend → Observability (read-back)
    User -->|"GET /logs · /traces · /events"| Logger

    %% Data persistence
    Core --- Postgres
    Core --- Mongo
    Core --- Clickhouse
    Auth --- Postgres
    Questionnaire --- Postgres
    Health --- Postgres

    %% Logger persistence
    Logger --- MemBuffer
    Logger -.->|"Fase 3 (futuro)"| SigNoz

    %% Messenger providers
    Messenger --> SMTP
    Messenger --> Twilio

    %% Messenger → Logger (auditoría)
    Messenger -->|Audit Logs| Logger
```

## Descripción de Componentes

### Capa de Entrada (Gateway)
1. **api_middleware**: Único punto de entrada del ecosistema. Valida tokens JWT, aplica rate limiting y enruta el tráfico hacia los microservicios internos.

### Capa de Microservicios (Negocio)
2. **dh_core**: Centro de gravedad para datos compartidos (Personas, Cuentas, Seguridad, Identidad). Todos los servicios lo consultan para obtener contexto del usuario.
3. **dh_questionnaire**: Gestión de formularios clínicos y flujos dinámicos (FormFlow). Publica notificaciones de confirmación vía `dh_notify`.
4. **dh_health_monitoring**: Monitoreo clínico de signos vitales y alertas. Emite alertas críticas vía mensajería.

### Capa Transversal (Cross-cutting)
5. **dh_logger** *(Observability Gateway)*: Sistema centralizado de ingesta de telemetría. Recibe Logs, Traces, Metrics y Events desde **cualquier microservicio, desde el API Gateway o incluso directamente desde el Frontend**. Expone endpoints `GET` para que cualquier consumidor consulte el historial de trazas y eventos con filtros dot-notation (`{"metadata.user": "123"}`).
6. **dh_notify** *(PulseCore)*: Servicio de mensajería multi-canal con arquitectura de Providers intercambiables. Soporta Email (SMTP/Google), SMS y WhatsApp (Twilio). Registra toda actividad de despacho en `dh_logger` para auditoría completa sin acoplar el núcleo de negocio.

### Capa de Datos (Multi-DB)
- **PostgreSQL**: Motor principal para datos transaccionales y relacionales.
- **MongoDB**: Almacenamiento documental para catálogos con estructuras dinámicas.
- **ClickHouse**: Motor OLAP para analítica masiva de baja mutabilidad y eventos.
- **In-Memory Buffer**: Buffer temporal de desarrollo para `dh_logger` (Fase 1). Se reemplazará por RabbitMQ + SigNoz en Fases 2-3.

### Proveedores Externos
- **SMTP / Google Mail**: Proveedor de email transaccional para `dh_notify`.
- **Twilio**: Proveedor para SMS y WhatsApp.
- **SigNoz / OpenTelemetry**: Backend de observabilidad real (Fase 3 del roadmap de `dh_logger`).

## Decisiones Arquitectónicas Clave

| Decisión | Justificación |
| :--- | :--- |
| `dh_logger` como capa transversal universal | Desacoplar la generación de telemetría del almacenamiento. Cualquier cliente (backend o frontend) puede ingestar y consultar señales. |
| `dh_notify` con Provider Pattern | Intercambiar proveedores de mensajería (SMTP → SendGrid, Twilio → AWS SNS) sin tocar la lógica de negocio de ningún microservicio. |
| `dh_notify` → `dh_logger` para auditoría | Cada mensaje enviado queda registrado como `Event` en el Observability Gateway, dando trazabilidad completa sin código de auditoría duplicado. |
| Frontend con acceso directo a `dh_logger` | Permite que el dashboard de observabilidad (`frontend/index.html`) consulte logs y trazas en tiempo real sin pasar por el Gateway, reduciendo latencia en herramientas de diagnóstico internas. |

---

## Diagrama 2 — Flujo de Secuencia (Ciclo de Vida de un Request)

Muestra el recorrido completo de una acción clínica típica a través del ecosistema, incluyendo la telemetría y la notificación como efectos secundarios.

```mermaid
sequenceDiagram
    actor User as Usuario / Frontend
    participant GW as api_middleware
    participant Core as dh_core
    participant SVC as dh_questionnaire
    participant MSG as dh_notify
    participant LOG as dh_logger

    User->>GW: POST /v1/questionnaire/submit
    GW->>GW: Valida JWT
    GW->>LOG: POST /v1/traces (span: gateway.auth)
    GW->>Core: GET /users/{id} (contexto de identidad)
    Core-->>GW: UserContext { id, name, role }
    GW->>LOG: POST /v1/logs (info: identity resolved)

    GW->>SVC: POST /submit (proxied + UserContext)
    SVC->>SVC: Valida formulario clínico
    SVC->>Core: POST /audit (registro clínico)

    SVC->>MSG: POST /waitlist/send-confirmation
    MSG->>MSG: Renderiza template HTML (Jinja2)
    MSG-->>User: Email de confirmación enviado
    MSG->>LOG: POST /v1/events (event: email.sent)

    SVC->>LOG: POST /v1/traces (span: questionnaire.submit, status: ok)
    SVC-->>GW: 201 Created
    GW-->>User: 201 Created

    Note over User,LOG: El Frontend puede consultar telemetría directamente
    User->>LOG: GET /v1/logs?query={"metadata.user":"123"}
    LOG-->>User: ApiResponsePaginated[LogEntry]
```

---

## Diagrama 3 — Vista de Capas Horizontal (Layer Architecture)

Presenta la arquitectura como capas horizontales independientes, ideal para visualizar la separación de responsabilidades y los límites entre dominios.

```mermaid
graph LR
    subgraph Clients["Clientes"]
        Browser["Web Browser
(Dashboard UI)"]
        ExtAPI["Sistemas Externos"]
    end

    subgraph Gateway["API Gateway"]
        MW["api_middleware
JWT · Rate Limit · Proxy"]
    end

    subgraph Business["Microservicios de Negocio"]
        direction TB
        CORE["dh_core
Identidad · Auth"]
        QUEST["dh_questionnaire
FormFlow Clínico"]
        HEALTH["dh_health_monitoring
Monitoreo"]
    end

    subgraph CrossCutting["Servicios Transversales"]
        direction TB
        LOGGER["dh_logger
Logs · Traces · Metrics · Events"]
        MSGSENDER["dh_notify
Email · SMS · WhatsApp"]
    end

    subgraph Data["Persistencia"]
        direction TB
        PG[("PostgreSQL")]
        MONGO[("MongoDB")]
        CH[("ClickHouse")]
        MEM[("In-Memory Buffer")]
    end

    subgraph External["Proveedores Externos"]
        direction TB
        SMTP["SMTP / Google"]
        TWILIO["Twilio"]
        SIGNOZ["SigNoz / OTel
Fase 3"]
    end

    Clients -->|HTTPS| Gateway
    Gateway -->|Routing| Business
    Business -->|Telemetría| CrossCutting
    Gateway -->|Telemetría| CrossCutting
    Clients -->|"GET /logs /events"| LOGGER

    Business --> Data
    CrossCutting --> Data
    MSGSENDER --> External
    LOGGER -.->|Fase 3| SIGNOZ
```
