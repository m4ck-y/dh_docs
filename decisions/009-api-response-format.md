# ADR 009: Formato Estándar de Respuesta de API

## Estado
Aceptado

## Contexto

Sin un formato de respuesta unificado, cada endpoint devuelve estructuras distintas — algunos devuelven el recurso directo, otros un dict, otros con envoltorios distintos. Esto obliga al frontend y al móvil a manejar casos especiales por endpoint y dificulta la creación de interceptores HTTP genéricos.

## Decisión

Todos los endpoints del ecosistema Digital Hospital deben envolver sus respuestas en uno de los dos formatos estándar definidos a continuación.

---

## Formatos

### `ApiResponseSingle[T]`

Para: `POST` (crear), `GET /{id}` (detalle), `PUT`, `PATCH`.

```json
{
  "status_code": 201,
  "internal_code": 0,
  "message": "Lead registrado exitosamente.",
  "data": {
    "id": "64f1a2b3c4d5e6f7a8b9c0d1",
    "email": "juan@example.com",
    "status": "ACTIVE"
  }
}
```

### `ApiResponsePaginated[T]`

Para: `GET /recursos` (colecciones).

```json
{
  "status_code": 200,
  "internal_code": null,
  "message": "Datos recuperados exitosamente.",
  "data": [
    { "id": "...", "email": "..." }
  ],
  "pagination": {
    "page": 1,
    "limit": 100,
    "total": 450,
    "pages": 5
  }
}
```

### Diccionario de campos

| Campo | Tipo | Descripción |
|---|---|---|
| `status_code` | `int` | Código HTTP de la respuesta (200, 201, etc.) |
| `internal_code` | `int \| null` | Código interno de negocio para tipar flujos o errores específicos |
| `message` | `str \| null` | Mensaje legible sobre el resultado de la operación |
| `data` | `T \| T[]` | El recurso o lista de recursos retornados |
| `pagination.page` | `int` | Página actual |
| `pagination.limit` | `int` | Máximo de registros por página |
| `pagination.total` | `int` | Total absoluto de registros en BD |
| `pagination.pages` | `int` | `ceil(total / limit)` |

---

## Implementación Python (FastAPI + Pydantic)

El modelo vive en `app/shared/schemas/responses.py` de cada microservicio.

```python
from pydantic import BaseModel, Field
from typing import Generic, TypeVar, List, Optional

T = TypeVar("T")

class PaginationResponse(BaseModel):
    page: int = Field(..., examples=[1])
    limit: int = Field(..., examples=[100])
    total: int = Field(..., examples=[450])
    pages: int = Field(..., examples=[5])

class ApiResponseBase(BaseModel):
    status_code: int = Field(..., examples=[200])
    internal_code: Optional[int] = Field(None, examples=[0])
    message: Optional[str] = Field(None, examples=["Operation successful."])

class ApiResponseSingle(ApiResponseBase, Generic[T]):
    data: Optional[T] = Field(None)

class ApiResponsePaginated(ApiResponseBase, Generic[T]):
    data: List[T] = Field(...)
    pagination: PaginationResponse = Field(...)
```

### Uso en router

```python
from app.shared.schemas.responses import ApiResponseSingle
from fastapi import APIRouter, status

@router.post("", response_model=ApiResponseSingle[LeadResponseDTO], status_code=status.HTTP_201_CREATED)
async def register_lead(payload: RegisterLeadDTO):
    lead = await RegisterLeadUseCase().execute(payload)
    return ApiResponseSingle(
        status_code=status.HTTP_201_CREATED,
        message="Lead registered successfully.",
        data=lead,
    )
```

---

## Formato de Error

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "No se encontró el recurso solicitado.",
    "details": { "resource": "waitlist", "email": "juan@example.com" }
  }
}
```

---

## Consecuencias

- **Positivas**:
    - El frontend y móvil pueden crear un interceptor HTTP genérico que siempre lea `response.data`.
    - Paginación estandarizada — no hay que negociar el contrato por endpoint.
    - Swagger muestra estructura consistente en todos los servicios.
- **Negativas**:
    - Requiere actualizar endpoints existentes que ya retornan el recurso desnudo.
    - Clientes deben leer `.data` en lugar del objeto directo.
