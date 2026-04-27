# ADR 011: Estándar de README para Microservicios

## Estado

Aceptado

## Contexto

El workspace Digital Hospital está compuesto por múltiples microservicios con estructuras heterogéneas: algunos son servicios Python puros (estructura plana), mientras que otros incluyen tanto frontend como backend dentro del mismo directorio de microservicio (con subcarpeta `backend/`).

Hasta ahora no existía un estándar claro sobre:
- **Dónde colocar** el `README.md` del backend cuando el microservicio incluye frontend.
- **Qué información mínima** debe contener el README para que sea útil para otros desarrolladores y para agentes de IA.

Esto generaba READMEs inconsistentes: algunos sin endpoints documentados, otros sin variables de entorno, y ninguno con referencias explícitas a los schemas Pydantic ni a las dependencias inter-servicio.

## Decisión

Se adopta el estándar descrito en [`.agents/rules/MICROSERVICE_README.md`](../../.agents/rules/MICROSERVICE_README.md) con las siguientes reglas:

### Ubicación del README

| Estructura del microservicio | Ubicación del README |
|---|---|
| Servicio Python puro (estructura plana) | `<servicio>/README.md` |
| Microservicio fullstack (con subcarpeta `backend/`) | `<servicio>/backend/README.md` |

El README vive donde está el código Python, no se duplica en ambos niveles.

### Secciones obligatorias

Todos los README de microservicio deben incluir exactamente estas cinco secciones:

1. **Endpoints** — Tabla con método HTTP, ruta y descripción de cada endpoint expuesto.
2. **Schemas** — Referencias con rutas relativas a los archivos Pydantic que definen los cuerpos de request/response. No se reproducen los campos; solo se enlaza al archivo fuente.
3. **Setup** — Comandos mínimos para levantar el servicio localmente: `uv sync`, copia del `.env.example`, y comando `uvicorn` con el puerto correcto.
4. **Variables de entorno** — Tabla con cada variable requerida, un valor de ejemplo y su propósito. Las variables inter-servicio siguen el patrón `SERVICE_<NOMBRE>_URL`.
5. **Dependencias** — Tabla de microservicios que este servicio consume internamente, con la variable de entorno utilizada y el propósito de la llamada. Si no hay dependencias, se indica explícitamente: *"None. This service does not call other microservices."*

## Consecuencias

**Positivas**:
- Los agentes de IA pueden determinar los endpoints y contratos de un microservicio sin ejecutarlo ni navegar todo el árbol de archivos.
- La incorporación de nuevos desarrolladores requiere menos exploración: setup completo en un solo archivo.
- Las dependencias inter-servicio son explícitas y auditables, lo que facilita detectar ciclos o acoplamientos inesperados.
- Las referencias a schemas Pydantic como rutas relativas evitan documentación duplicada y el drift entre código y README.

**Negativas**:
- Mayor carga de mantenimiento: cada cambio de ruta, variable de entorno o dependencia inter-servicio requiere actualizar el README en el mismo PR.
- Los READMEs existentes deben ser actualizados para cumplir el estándar (deuda técnica de documentación).

## Microservicios afectados

| Microservicio | Tipo | README esperado |
|---|---|---|
| `api_core` | Plano | `api_core/README.md` |
| `api_middleware` | Plano | `api_middleware/README.md` |
| `app_catalogs` | Fullstack | `app_catalogs/backend/README.md` |
| `app_health_monitoring` | Fullstack | `app_health_monitoring/backend/README.md` |
| `app_logger_tracer` | Fullstack | `app_logger_tracer/backend/README.md` |
| `app_message_sender` | Plano | `app_message_sender/README.md` |
| `app_questionnaire` | Fullstack | `app_questionnaire/backend/README.md` |
| `dh_mfa` | Plano | `dh_mfa/README.md` |
| `dh_onboarding_back` | Plano | `dh_onboarding_back/README.md` |
| `dh_onboarding_front` | Frontend | No aplica (sin backend Python propio) |
