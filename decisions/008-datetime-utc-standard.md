# ADR 008: Estándar de Fechas y Horas — UTC en Todo el Sistema

## Estado
Aceptado

## Contexto

Un sistema hospitalario multi-servicio con base en distintos timezones (servidores en Cloud Run europe-west1, usuarios en México) necesita una convención estricta para el manejo de fechas. Sin un estándar, los timestamps almacenados en PostgreSQL y MongoDB pueden quedar en hora local o sin información de zona horaria, lo que produce datos inconsistentes y errores difíciles de diagnosticar.

## Decisión

**Todas las fechas y horas del sistema se almacenan y procesan en UTC.** La conversión a hora local es responsabilidad exclusiva del cliente (frontend / móvil) en el momento de mostrar la información al usuario.

---

## Reglas por Capa

### Python / Pydantic

```python
from datetime import datetime, timezone

# ✅ Correcto
datetime.now(timezone.utc)

# ❌ Prohibido — deprecated en Python 3.12+
datetime.utcnow()
```

Los campos `datetime` en modelos Pydantic deben usar `default_factory`:

```python
from pydantic import BaseModel, Field
from datetime import datetime, timezone

class MyModel(BaseModel):
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    deleted_at: Optional[datetime] = None  # None = no eliminado (soft delete)
```

### PostgreSQL / SQLAlchemy

Usar siempre `DateTime(timezone=True)`. Sin timezone el motor almacena hora local del servidor.

```python
from sqlalchemy import Column, DateTime
from sqlalchemy.sql import func

class MyModel(Base):
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
    deleted_at = Column(DateTime(timezone=True), nullable=True)  # soft delete
```

### MongoDB / Beanie

MongoDB almacena internamente en UTC. Solo asegurarse de pasar datetimes timezone-aware desde Python:

```python
from beanie import Document
from pydantic import Field
from datetime import datetime, timezone

class MyDocument(Document):
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
```

---

## Convención de Naming

| Campo | Tipo | Descripción |
|---|---|---|
| `created_at` | `datetime` (UTC) | Fecha de creación del registro |
| `updated_at` | `datetime` (UTC) | Última modificación |
| `deleted_at` | `Optional[datetime]` (UTC) | Soft delete — `None` significa activo |
| `expires_at` | `Optional[datetime]` (UTC) | Para tokens, invitaciones, etc. |
| `invited_at` | `Optional[datetime]` (UTC) | Fecha de invitación (waitlist) |
| `converted_at` | `Optional[datetime]` (UTC) | Fecha de conversión de lead |

Nunca usar: `createdAt`, `created_date`, `fecha_creacion`, `timestamp_creation`.

---

## Formato en Respuestas de API

Las APIs deben serializar datetimes en **ISO 8601 con sufijo Z** (UTC explícito):

```
2026-04-26T03:41:28.385627Z
```

FastAPI + Pydantic serializa `datetime` timezone-aware automáticamente en este formato. No se requiere configuración adicional.

---

## Consecuencias

- **Positivas**:
    - Timestamps consistentes entre PostgreSQL, MongoDB y logs.
    - Sin ambigüedad al correlacionar eventos entre microservicios.
    - El frontend / móvil convierte a hora local según el timezone del usuario.
- **Negativas**:
    - Los desarrolladores deben recordar convertir a hora local al mostrar datos en UI.
    - Consultas SQL que filtren por rango de fechas deben considerar el offset del usuario.
