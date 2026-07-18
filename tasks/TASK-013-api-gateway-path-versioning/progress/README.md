# Progreso

Registro de progreso del TASK-013: API Gateway Path Versioning.

## Estado

**Backlog** — sin progreso registrado.

## Nota

Los servicios ya operan con `ROOT_PATH=/` y `APIRouter(prefix="/v1")`. El gateway monta cada servicio en `/{ROOT_PATH}/{service_name}/`.
