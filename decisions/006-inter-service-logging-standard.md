# ADR 006: Estándar de Logging Inter-Servicio hacia VitalTrace

## Estado
Aceptado

## Contexto

El ecosistema Digital Hospital está compuesto por múltiples microservicios, frontend y apps móviles. Sin un estándar de observabilidad, cada cliente implementa su propio mecanismo de logging. `logger_tracer_service` (VitalTrace) es el hub centralizado. Esta decisión define cómo todos los clientes deben integrarse con él.

## Decisión

Se adopta el patrón de **logger dual** para microservicios backend:

1. **Logger local**: Python `logging` estándar — capturado por stdout / GCP Cloud Logging.
2. **Logger remoto**: `httpx` asíncrono hacia VitalTrace — observabilidad centralizada.

Reglas transversales a todos los clientes:
- **Prohibición de `print`**: El uso de la función `print()` está estrictamente prohibido en código de producción. Toda salida de información debe realizarse a través del `ServiceLogger` para garantizar que sea capturada por VitalTrace y stdlib.
- **Logger failures**: Los fallos del logger nunca afectan al servicio — si `logger_tracer_service` es inaccesible, solo genera un warning local (stdlib), nunca una excepción.
- **Configuración**: `SERVICE_LOGGER_TRACER_URL` vacío deshabilita el forwarding sin error.
- **Dependencias**: Dependencia requerida en microservicios: `httpx` (`uv add httpx`).
- **Entorno**: `ENVIRONMENT` debe estar configurado en cada servicio (`development`, `staging`, `production`).

---

## Schemas de VitalTrace

### LogLevel (enum)
```
"DEBUG" | "INFO" | "WARNING" | "ERROR" | "FATAL"
```

### `POST /v1/logs/` — LogEntry
```json
{
  "level": "INFO",
  "event": "waitlist.duplicate",
  "message": "Email already registered",
  "service": "dh_onboarding_back",
  "environment": "production",
  "metadata": { "email": "user@example.com" }
}
```
| Campo | Requerido | Descripción |
|---|---|---|
| `level` | ✅ | Enum: `DEBUG`, `INFO`, `WARNING`, `ERROR`, `FATAL` |
| `event` | ✅ | Nombre corto del evento: `user.login`, `waitlist.register` |
| `message` | ✅ | Descripción detallada |
| `service` | ✅ | Nombre del servicio emisor |
| `environment` | ✅ | `development`, `staging`, `production` |
| `trace_id` | ❌ | ID de trace distribuido (opcional) |
| `user` | ❌ | `{ id, name, ip_address }` |
| `http` | ❌ | `{ method, route, status_code, user_agent, ip }` |
| `metadata` | ❌ | Dict arbitrario con contexto adicional |

### `POST /v1/events/` — EventEntry
```json
{
  "event": "lead_registered",
  "service": "dh_onboarding_back",
  "session_id": "system",
  "metadata": { "email": "user@example.com", "source": "landing_page" }
}
```
| Campo | Requerido | Descripción |
|---|---|---|
| `event` | ✅ | Identificador del evento: `lead_registered`, `onboarding_completed` |
| `service` | ✅ | Nombre del servicio emisor |
| `session_id` | ✅ | ID de sesión. En backend sin sesión usar `"system"` |
| `user_id` | ❌ | ID del usuario involucrado |
| `page` | ❌ | Vista o URL donde ocurrió el evento |
| `metadata` | ❌ | Dict arbitrario con contexto adicional |

### `POST /v1/metrics/` — MetricEntry
```json
{
  "name": "onboarding_duration_ms",
  "value": 1250.0,
  "type": "gauge",
  "service": "dh_onboarding_back",
  "labels": { "step": "otp_verify" },
  "metadata": {}
}
```
| Campo | Requerido | Descripción |
|---|---|---|
| `name` | ✅ | Nombre estandarizado: `http_requests_total`, `duration_ms` |
| `value` | ✅ | Valor numérico |
| `service` | ✅ | Nombre del servicio emisor |
| `type` | ❌ | Enum: `counter`, `gauge`, `histogram` |
| `labels` | ❌ | Dict `str→str` para agrupar (sin IDs únicos — usar `metadata` para eso) |
| `metadata` | ❌ | Dict arbitrario (acepta IDs únicos) |

---

## Implementación: Microservicio Python (Backend)

```python
# app/shared/utils/logger.py
import logging
import httpx
from datetime import datetime, timezone
from typing import Any
from app.settings.config import settings

_stdlib = logging.getLogger(__name__)


async def _push(endpoint: str, payload: dict) -> None:
    if not settings.SERVICE_LOGGER_TRACER_URL:
        return
    try:
        async with httpx.AsyncClient(timeout=2.0) as client:
            await client.post(
                f"{settings.SERVICE_LOGGER_TRACER_URL}/v1/{endpoint}/",
                json=payload,
            )
    except Exception as e:
        _stdlib.warning("logger_tracer_service unreachable — log lost locally: %s", e)


class ServiceLogger:
    def __init__(self, service: str) -> None:
        self._service = service

    async def info(self, message: str, event: str = "app.log", **ctx: Any) -> None:
        _stdlib.info(f"[{event}] {message}")
        await _push("logs", {"level": ELogLevel.INFO, "event": event, "message": message,
                              "service": self._service, "environment": settings.ENVIRONMENT, "metadata": ctx})

    async def warning(self, message: str, event: str = "app.warning", **ctx: Any) -> None:
        _stdlib.warning(f"[{event}] {message}")
        await _push("logs", {"level": ELogLevel.WARNING, "event": event, "message": message,
                              "service": self._service, "environment": settings.ENVIRONMENT, "metadata": ctx})

    async def error(self, message: str, event: str = "app.error", **ctx: Any) -> None:
        _stdlib.error(f"[{event}] {message}")
        await _push("logs", {"level": ELogLevel.ERROR, "event": event, "message": message,
                              "service": self._service, "environment": settings.ENVIRONMENT, "metadata": ctx})

    async def event(self, event_name: str, session_id: str = "system", **ctx: Any) -> None:
        _stdlib.info(f"[EVENT] {event_name}")
        await _push("events", {"event": event_name, "service": self._service,
                                "session_id": session_id, "metadata": ctx})

    async def metric(self, name: str, value: float, metric_type: str = "counter",
                     labels: dict | None = None, **ctx: Any) -> None:
        _stdlib.info(f"[METRIC] {name}={value}")
        await _push("metrics", {"name": name, "value": value, "type": metric_type,
                                 "service": self._service, "labels": labels or {}, "metadata": ctx})


logger = ServiceLogger(service="<nombre_del_servicio>")
```

### Variables de entorno requeridas

| Variable | Valores válidos | Descripción |
|---|---|---|
| `ENVIRONMENT` | `development` / `staging` / `production` | Campo requerido por VitalTrace en cada log. Permite filtrar y separar los logs por entorno en el dashboard de observabilidad. Sin este valor el endpoint `/v1/logs/` responde 422. |
| `SERVICE_LOGGER_TRACER_URL` | URL base del servicio | URL de VitalTrace. Si está vacío, el logger omite el forwarding sin error. |

```env
# Deployment environment. Required by VitalTrace for every log entry.
# Values: development | staging | production
ENVIRONMENT=production

# URL of the VitalTrace observability service (logger_tracer_service)
SERVICE_LOGGER_TRACER_URL=https://dh-logger-tracer-967885369144.europe-west1.run.app
```

### Uso
```python
from app.shared.utils.logger import logger

await logger.info("Lead registrado", event="waitlist.register", email=email)
await logger.warning("Email duplicado", event="waitlist.duplicate", email=email)
await logger.error("Fallo al conectar con api_core", event="core.connection_error")
await logger.event("lead_registered", session_id="system", email=email, source=source)
await logger.metric("onboarding_duration_ms", value=1250.0, metric_type="gauge")
```

---

## Implementación: Frontend (JavaScript / TypeScript)

```typescript
const VITALTRACE_URL = process.env.NEXT_PUBLIC_LOGGER_URL;
const SERVICE = "dh_onboarding_front";

async function pushLog(level: string, event: string, message: string, metadata = {}) {
  if (!VITALTRACE_URL) return;
  fetch(`${VITALTRACE_URL}/v1/logs/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ level, event, message, service: SERVICE,
                           environment: process.env.NODE_ENV, metadata }),
  }).catch(() => {}); // silencioso
}

async function pushEvent(event: string, sessionId: string, metadata = {}) {
  if (!VITALTRACE_URL) return;
  fetch(`${VITALTRACE_URL}/v1/events/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ event, service: SERVICE, session_id: sessionId, metadata }),
  }).catch(() => {});
}

// Uso
pushLog("info", "onboarding.step_completed", "Paso 1 completado", { step: "personal_info" });
pushEvent("onboarding_step_1_completed", sessionStorage.getItem("session_id") ?? "unknown");
```

> El `session_id` en frontend debe ser un identificador de sesión del usuario (localStorage/sessionStorage).

---

## Implementación: Mobile (iOS / Android / Flutter)

```dart
// Flutter
import 'package:http/http.dart' as http;
import 'dart:convert';

const _baseUrl = String.fromEnvironment('VITALTRACE_URL');
const _service = 'dh_mobile';

Future<void> logEvent(String eventName, {String sessionId = 'unknown', Map<String, dynamic> metadata = const {}}) async {
  if (_baseUrl.isEmpty) return;
  try {
    await http.post(
      Uri.parse('$_baseUrl/v1/events/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'event': eventName,
        'service': _service,
        'session_id': sessionId,
        'metadata': metadata,
      }),
    ).timeout(const Duration(seconds: 2));
  } catch (_) {}
}

// Uso
logEvent('onboarding_completed', sessionId: currentSessionId, metadata: {'person_id': personId});
```

---

## Consecuencias

- **Positivas**:
    - Observabilidad centralizada con schema consistente entre todos los clientes.
    - Falla silenciosa — VitalTrace inaccesible no afecta ningún servicio.
    - Patrón replicable en cualquier microservicio nuevo.
- **Negativas**:
    - Microservicios Python requieren `httpx` como dependencia.
    - Una llamada HTTP por operación (mitigable con `/v1/batch` en iteraciones futuras).
    - `session_id` requerido en eventos — backend usa `"system"` como convención.
