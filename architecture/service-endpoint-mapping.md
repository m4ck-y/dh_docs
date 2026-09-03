# Service Endpoint Mapping — Digital Hospital

## Definición de Rutas y Puertos

Cada microservicio tiene un **ROOT_PATH por defecto** que se usa cuando corre de forma independiente (subdominio directo). Detrás del gateway, el path lo maneja el API Gateway.

| Servicio | Puerto | Gateway Mount Path | ROOT_PATH (default) | CORS (default) | Estado |
|----------|--------|-------------------|---------------------|----------------|--------|
| `api_middleware` (gateway) | 8080 | N/A | `/api/middleware` | `["*"]` | Activo |
| `dh_auth` | 8081 | `/api/middleware/auth` | `/api/auth` | `["*"]` | Activo |
| `dh_iam` | 8082 | `/api/middleware/iam` | `/api/iam` | `["*"]` | Activo |
| `dh_core` | 8083 | `/api/middleware/core` | `/api/core` | `["*"]` | Activo |
| `dh_mfa` | 8084 | `/api/middleware/mfa` | `/api/mfa` | `["*"]` | Activo |
| `dh_onboarding` | 8085 | `/api/middleware/onboarding` | `/api/onboarding` | `["*"]` | Activo |
| `dh_health_monitoring` | 8086 | `/api/middleware/health_monitoring` | `/api/health_monitoring` | `["*"]` | Activo |
| `dh_storage` | 8087 | `/api/middleware/storage` | `/api/storage` | `["*"]` | Activo |
| `dh_admin` | 8088 | `/api/middleware/admin` | `/api/admin` | `["*"]` | Activo |
| `dh_organizations` | 8089 | `/api/middleware/organizations` | `/api/organizations` | `["*"]` | ⏳ Pendiente |
| `dh_catalogs` | 8090 | `/api/middleware/catalogs` | `/api/catalogs` | `["*"]` | ⏳ Pendiente |
| `dh_notify` | 8091 | `/api/middleware/notify` | `/api/notify` | `["*"]` | Testing |
| `dh_logger` | 8092 | `/api/middleware/logger` | `/api/logger` | `["*"]` | Testing |

## Estructura de URLs

### Vía Gateway (recomendado)

```
http://<host>:8000/api/middleware/{service_name}/v1/...
```

Ejemplos:
- Auth login: `http://localhost:8000/api/middleware/auth/v1/login`
- Core person: `http://localhost:8000/api/middleware/core/v1/people`
- IAM roles: `http://localhost:8000/api/middleware/iam/v1/roles`

### Independiente (subdominio directo)

```
http://{service_name}.tudominio.com/api/{service_name}/v1/...
```

Ejemplo (cuando cada servicio tiene su propio subdominio):
- Auth: `https://auth.tudominio.com/api/auth/v1/login`
- Core: `https://core.tudominio.com/api/core/v1/people`

## Configuración por Servicio

Cada servicio debe definir en su `app/settings/env.py`:

```python
class Settings(BaseSettings):
    # ... settings existentes (DB, JWT, etc.)
    ROOT_PATH: str = "/api/{service_name}"  # Cambiar según despliegue
    CORS_ORIGINS: list[str] = ["*"]  # Ajustar en producción
```

Y en su `.env`:

```bash
ROOT_PATH=/api/{service_name}
CORS_ORIGINS=["*"]
```

## Network & Firewall

- **Público**: Solo puerto 8000 (api_middleware gateway)
- **Interno**: Puertos 8081-8092 solo accesibles desde red privada
- **CORS**: Default `*` — ajustar por entorno (dev/staging/prod)

## Referencias

- [Deployment Port Mapping](../architecture/deployment-port-mapping.md)
- [API Gateway docs](../../backend/api_middleware/docs/)
- [STATUS](../../docs/STATUS.md)
