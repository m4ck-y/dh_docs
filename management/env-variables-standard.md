# Estándar de Variables de Entorno

Guía de referencia para todas las variables de entorno del ecosistema Digital Hospital. Define la nomenclatura obligatoria para servicios nuevos e identifica inconsistencias en servicios existentes.

---

## Categorías y Convenciones

### 1. Identidad del Servicio

Presentes en todos los microservicios.

| Variable | Valores válidos | Descripción |
|---|---|---|
| `ENVIRONMENT` | `development` / `staging` / `production` | Entorno de despliegue. Campo requerido por VitalTrace en cada log. Sin él, `/v1/logs/` responde 422. |
| `PROJECT_NAME` | string | Nombre descriptivo del servicio. |
| `VERSION` | `1.0.0` | Versión semántica. |
| `DEBUG` | `True` / `False` | Solo para servicios que lo soporten. No exponer en producción. |

---

### 2. Descubrimiento de Servicios (Inter-Service URLs)

Todo URL hacia otro microservicio **debe** seguir el patrón `SERVICE_<NOMBRE>_URL`.

| Variable | Ejemplo | Descripción |
|---|---|---|
| `SERVICE_<NOMBRE>_URL` | `http://localhost:8000` | URL base del microservicio destino. Default: string vacío para degradación silenciosa. |

**Servicios del ecosistema:**

| Variable | Servicio |
|---|---|
| `SERVICE_CORE_URL` | `api_core` — entidades base (Person, IAM, etc.) |
| `SERVICE_AUTH_URL` | `app_auth` — autenticación y tokens |
| `SERVICE_LOGGER_TRACER_URL` | `app_logger_tracer` (VitalTrace) — observabilidad |
| `SERVICE_MESSAGE_SENDER_URL` | `app_message_sender` (PulseCore) — notificaciones |
| `SERVICE_HEALTH_MONITORING_URL` | `app_health_monitoring` — signos vitales |
| `SERVICE_WAITLIST_URL` | *(eliminado)* — la waitlist es un módulo interno de `dh_onboarding_back` |

> Nunca hardcodear URLs en el código fuente. Ver `AGENTS.md`.

---

### 3. Base de Datos — MongoDB

Estándar definido en [ADR 005](../decisions/005-mongodb-driver-and-fastapi-lifespan.md).

| Variable | Ejemplo | Descripción |
|---|---|---|
| `MONGO_URL` | `mongodb://localhost:27017` | Connection string completa. Incluye usuario/contraseña si aplica. |
| `MONGO_DB_NAME` | `dh_onboarding` | Nombre de la base de datos dentro del servidor. |
| `MONGO_COLLECTION_<X>` | `waitlist` | Nombre de una colección específica. Permite cambiarla sin tocar código. |

**Ejemplo completo:**
```env
MONGO_URL=mongodb://user:pass@localhost:27017
MONGO_DB_NAME=dh_onboarding
MONGO_COLLECTION_WAITLIST=waitlist
```

**Atlas (producción):**
```env
MONGO_URL=mongodb+srv://user:pass@cluster.mongodb.net/?retryWrites=true&w=majority
MONGO_DB_NAME=dh_onboarding
```

> **Inconsistencia conocida:** `app_logger_tracer` usa `MONGO_DB` en lugar de `MONGO_DB_NAME` y divide la conexión en campos separados (`MONGO_USER`, `MONGO_HOST`, etc.). Pendiente de migrar al estándar.

---

### 4. Base de Datos — PostgreSQL

| Variable | Ejemplo | Descripción |
|---|---|---|
| `POSTGRES_URL` | `postgresql+asyncpg://user:pass@localhost:5432/db` | Connection string completa. Formato SQLAlchemy async. |

**Ejemplo completo:**
```env
POSTGRES_URL=postgresql+asyncpg://admin:secret@localhost:5432/dh_core
```

> **Inconsistencia conocida:** `api_core` usa campos separados (`POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB_NAME`) en lugar de un connection string único. Pendiente de migrar.

---

### 5. Seguridad / JWT

| Variable | Ejemplo | Descripción |
|---|---|---|
| `SECRET_KEY` | string aleatorio | Clave secreta para firma de tokens JWT. Nunca commitear. |
| `JWT_ALGORITHM` | `HS256` | Algoritmo de firma. |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `60` | Tiempo de vida del access token. |

> **Inconsistencia conocida:** `dh_onboarding_back` usa `ALGORITHM` en lugar de `JWT_ALGORITHM`. Pendiente de normalizar.

---

### 6. Observabilidad

| Variable | Ejemplo | Descripción |
|---|---|---|
| `LOG_LEVEL` | `INFO` | Nivel mínimo del logger local de Python. Valores: `DEBUG` / `INFO` / `WARNING` / `ERROR`. |
| `SERVICE_LOGGER_TRACER_URL` | URL de VitalTrace | Cubierto en la categoría de Service URLs. |
| `ENVIRONMENT` | `production` | Cubierto en Identidad del Servicio. |

---

## Estado por Servicio

| Variable | `api_core` | `dh_onboarding_back` | `api_middleware` | `app_logger_tracer` |
|---|---|---|---|---|
| `ENVIRONMENT` | ✅ | ✅ | ✅ | ❌ pendiente |
| `MONGO_URL` | ⚠️ usa campos separados | ✅ | — | ⚠️ usa campos separados |
| `MONGO_DB_NAME` | ✅ | ✅ | — | ⚠️ usa `MONGO_DB` |
| `POSTGRES_URL` | ⚠️ usa campos separados | — | — | — |
| `SERVICE_LOGGER_TRACER_URL` | ❌ pendiente | ✅ | ✅ | — |
| `JWT_ALGORITHM` | ✅ | ⚠️ usa `ALGORITHM` | — | — |

---

## Resumen de Inconsistencias Pendientes

| Servicio | Pendiente |
|---|---|
| `api_core` | Migrar a `POSTGRES_URL` y `MONGO_URL` únicos; agregar `SERVICE_LOGGER_TRACER_URL` |
| `app_logger_tracer` | Migrar a `MONGO_URL` + `MONGO_DB_NAME`; agregar `ENVIRONMENT` |
| `dh_onboarding_back` | Renombrar `ALGORITHM` → `JWT_ALGORITHM` |
