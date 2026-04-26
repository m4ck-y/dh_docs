# Documentación de Schemas Pydantic

## Objetivo

Todos los schemas Pydantic deben incluir documentación clara mediante `Field` y `examples` para garantizar que los equipos de front-end y móvil comprendan la estructura de datos sin necesidad de consultar el código fuente.

## Directrices

### 1. Usar `Field` con descripción

Cada campo de un schema debe incluir una descripción que explique su propósito:

```python
from pydantic import BaseModel, Field

class PacienteSchema(BaseModel):
    nombre: str = Field(..., description="Nombre completo del paciente")
    fecha_nacimiento: date = Field(..., description="Fecha de nacimiento en formato YYYY-MM-DD")
    genero: str = Field(..., description="Género del paciente: 'M' | 'F' | 'Otro'")
```

### 2. Incluir examples

Los examples permiten a los consumidores de la API ver valores concretos:

```python
class PacienteSchema(BaseModel):
    nombre: str = Field(..., description="Nombre completo del paciente", examples=["Juan Pérez"])
    fecha_nacimiento: date = Field(..., description="Fecha de nacimiento", examples=["1990-05-15"])
```

### 3. Patrón recomendado

Combinar descripción y examples en cada campo:

```python
from pydantic import BaseModel, Field
from datetime import date
from typing import Optional

class PacienteCreateSchema(BaseModel):
    nombre: str = Field(
        ...,
        description="Nombre completo del paciente",
        examples=["Juan Pérez"]
    )
    fecha_nacimiento: date = Field(
        ...,
        description="Fecha de nacimiento en formato YYYY-MM-DD",
        examples=["1990-05-15"]
    )
    email: Optional[str] = Field(
        None,
        description="Correo electrónico válido del paciente",
        examples=["juan.perez@example.com"]
    )
```

## Aplicación

- **En servicios propios** (dh_onboarding_back, etc.): siempre incluir Field con description y examples
- **En api_middleware**: si los schemas se redefinen allí, también deben incluir la documentación completa

La documentación en api_middleware es independiente pero debe mantener coherencia con los schemas originales.