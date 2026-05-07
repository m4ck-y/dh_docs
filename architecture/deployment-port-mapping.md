# Deployment Port Mapping — Digital Hospital

## Architecture Layers

### L1 Public Gateway (Externo — Único punto de entrada)

| Servicio | Root Path | Puerto | Acceso | Estado |
|----------|-----------|--------|--------|--------|
| `api_middleware` | `/` | **8000** | Frontend/Mobile only | Activo |

**Nota**: Este es el **único** servicio expuesto a Internet. Frontend web y móvil apuntan únicamente a `https://<domain>:8000` (o平衡ador). Todos los demás servicios corren en red privada.

---

### L2 Backend Services (Interno — NO expuestos directo)

| Servicio | Root Path | Puerto | `SERVICE_*_URL` Var | Estado |
|----------|-----------|--------|---------------------|--------|
| `dh_auth` | `/auth` | **8081** | `SERVICE_AUTH_URL` | Activo |
| `dh_iam` | `/iam` | **8082** | `SERVICE_IAM_URL` | Activo |
| `dh_core` | `/core` | **8083** | `SERVICE_CORE_URL` | Activo |
| `dh_mfa` | `/mfa` | **8084** | `SERVICE_MFA_URL` | Activo |
| `dh_onboarding_back` | `/onboarding` | **8085** | `SERVICE_ONBOARDING_URL` | Activo |
| `dh_health_monitoring` | `/health_monitoring` | **8086** | `SERVICE_HEALTH_MONITORING_URL` | Activo |
| `dh_storage` | `/storage` | **8087** | `SERVICE_STORAGE_URL` | Activo |
| `dh_admin` | `/admin` | **8088** | N/A (admin only) | Activo |
| `dh_organizations` | `/organizations` | **8089** | `SERVICE_ORGANIZATIONS_URL` | ⏳ Pendiente |
| `dh_catalogs` | `/catalogs` | **8090** | `SERVICE_CATALOGS_URL` | ⏳ Pendiente |
| `app_message_sender` (PulseCore) | `/message_sender` | **8091** | `SERVICE_MESSAGE_SENDER_URL` | Testing |
| `app_logger_tracer` (VitalTrace) | `/logger_tracer` | **8092** | `SERVICE_LOGGER_TRACER_URL` | Testing |

---

### L3 Reserved Range (Futuros servicios / réplicas)

| Rango | Propósito |
|-------|-----------|
| 8093-8200 | Microservicios adicionales (ej: `dh_questionnaire`, `dh_billing`, etc.) |
| 8201-8300 | Réplicas de servicios críticos (escalado horizontal) |
| 8301-8400 | Staging / pre-producción |
| 8401-8500 | Herramientas de desarrollo (seeds, migraciones, admin tools) |

---

## Network & Firewall Rules

```yaml
# firewall Rules
public_inbound:
  - port: 8000
    service: api_middleware
    source: "0.0.0.0/0"  # Internet

internal_only:
  - ports: 8081-8092
    service: backend_services
    source: "10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16"  # Solo red privada
    note: "Ningún puerto backend debe estar expuesto a Internet"

database:
  - port: 5432
    service: PostgreSQL
    source: "10.0.0.0/8"  # Solo red privada
  - port: 27017
    service: MongoDB
    source: "10.0.0.0/8"
```

---

## API Gateway Routing (api_middleware)

El `api_middleware` monta cada servicio como sub-app:

```python
# gateway.py — app.mount()
app.mount("/auth", create_auth())                    # → http://localhost:8081
app.mount("/iam", create_iam())                      # → http://localhost:8082
app.mount("/core", create_core())                    # → http://localhost:8083
app.mount("/mfa", create_mfa())                      # → http://localhost:8084
app.mount("/onboarding", create_onboarding())        # → http://localhost:8085
app.mount("/health_monitoring", create_health_monitoring())  # → http://localhost:8086
app.mount("/storage", create_storage())              # → http://localhost:8087
app.mount("/admin", create_admin())                  # → http://localhost:8088
app.mount("/organizations", create_organizations())  # → http://localhost:8089
app.mount("/catalogs", create_catalogs())            # → http://localhost:8090
app.mount("/message_sender", create_message_sender())# → http://localhost:8091
app.mount("/logger_tracer", create_logger_tracer())  # → http://localhost:8092
```

---

## Environment Variables Pattern

Cada servicio define su puerto y URL targets:

```bash
# api_middleware/.env (L1 Gateway)
PORT=8000
SERVICE_AUTH_URL=http://localhost:8081
SERVICE_IAM_URL=http://localhost:8082
SERVICE_CORE_URL=http://localhost:8083
...

# dh_auth/.env (L2 Service)
PORT=8081
# (No necesita KNOW otros servicios a menos que los llame)
```

**Regla**: `SERVICE_<SERVICE_NAME>_URL` — nombre en MAYÚSCULAS, guion bajo, sin prefijos `dh_` o `app_`.

---

## Deployment Checklist

- [ ] **VPS Firewall**: Solo puerto 8000 abierto al público
- [ ] **Docker Compose / systemd**: Cada serviciousa su puerto asignado
- [ ] **.env files**: Todos los servicios tienen su `SERVICE_*_URL` apuntando al puerto correcto
- [ ] **api_middleware gateway.py**: Montados todos los sub-apps con `app.mount()`
- [ ] **Monitoring**: Alertas en puertos 8081-8092 (acceso solo interno)
- [ ] **Load Balancer** (futuro):平衡ador apunta solo a `api_middleware:8000` en multiples réplicas

---

## Cambios vs. Estado Actual

| Servicio | Puerto Actual | Puerto Propuesto | Acción |
|----------|---------------|------------------|--------|
| `dh_admin` | 8050 (→) | **8088** | Cambiar a rango 8081-8092 |
| `dh_storage` | 8060 (→) | **8087** | Cambiar a rango 8081-8092 |
| `api_middleware` | 8000 | **8000** | Sin cambio |

**Motivo**: Uniformizar rango 8081-8092 para todos los microservicios backend. El puerto 8000 reservado exclusivamente para el gateway.

---

## Referencias

- [docs/STATUS.md](../STATUS.md) — Estado general del proyecto
- [docs/ARCHITECTURE_OVERVIEW.md](./ARCHITECTURE_OVERVIEW.md) — Matriz de propiedad de datos
- [api_middleware/AGENTS.md](../../api_middleware/AGENTS.md) — Patrones del gateway
