# ADR 029: Sub-objetos en DTOs — Agrupacion Semantica y Reglas de Naming

## Estado
Aceptado

## Contexto

Los DTOs de entrada (`Create*DTO`) tienden a crecer con campos planos que mezclan atributos de multiples tablas relacionadas. Por ejemplo, `CreatePersonDTO` contiene campos de `Person`, `Email`, `Phone`, `Birth`, `LegalInfo` y `PersonalIdentifier` todos al mismo nivel. Esto produce:

1. **Ambiguedad de pertenencia**: no es evidente a que tabla/entidad pertenece cada campo sin leer el use case.
2. **Naming inconsistente**: algunos campos planos se parecen pero no siguen el mismo patron (`phone_code` + `phone_number` vs `email` solo).
3. **Dificultad de mantenimiento**: al agregar un campo nuevo a una entidad relacionada (ej. `type_phone`), no hay un lugar natural para colocarlo sin romper la estructura.

## Decision

Los DTOs que persisten datos en multiples tablas deben usar **sub-objetos** que agrupen campos pertenecientes a una misma entidad/tabla de base de datos. Cada sub-objeto representa exactamente una tabla.

### Regla de Naming

**Los campos dentro de un sub-objeto NO deben repetir el nombre de la propiedad padre.** El contexto ya lo provee el nombre del sub-objeto.

```python
# Correcto — el contexto del padre elimina la redundancia
class PhoneInputDTO(BaseModel):
    code: str       # no phone_code
    number: str     # no phone_number
    type: EPhoneType  # no type_phone

class BirthInputDTO(BaseModel):
    date: date          # no birth_date
    key_country: str    # no key_birth_country
    key_state: str      # no key_birth_state

# Incorrecto — redundancia
class PhoneInputDTO(BaseModel):
    phone_code: str       # phone.phone_code — redundante
    phone_number: str     # phone.phone_number — redundante
    type_phone: EPhoneType  # phone.type_phone — redundante
```

### Nombrado del campo email

El sub-objeto `email` usa `address` como nombre del campo que contiene la direccion de correo, no `mail` ni `email`:

```python
class EmailInputDTO(BaseModel):
    address: EmailStr   # email.address — "email address" es el termino estandar
    type: EEmailType
```

### Excepcion: campos unicos

Si una entidad relacionada solo aporta **un unico campo**, se mantiene plano en el DTO padre. Crear un sub-objeto para un solo campo es overengineering.

```python
class CreatePersonDTO(BaseModel):
    key_nationality: Optional[str] = None  # LegalInfo solo tiene este campo — se queda plano
```

### Contrato canonico

El DTO padre `CreatePersonDTO` queda asi:

```python
class EmailInputDTO(BaseModel):
    address: EmailStr
    type: EEmailType = Field(default=EEmailType.PERSONAL)

class PhoneInputDTO(BaseModel):
    code: str
    number: str
    type: EPhoneType = Field(default=EPhoneType.MOBILE)

class BirthInputDTO(BaseModel):
    date: date
    key_country: str
    key_state: Optional[str] = None

class CreatePersonDTO(BaseModel):
    email: EmailInputDTO
    phone: PhoneInputDTO
    first_name: str                      # Person — se queda plano (campos directos de la tabla Person)
    last_name: str
    second_last_name: Optional[str] = None
    birth: BirthInputDTO
    type_gender: Optional[str] = None
    key_nationality: Optional[str] = None  # LegalInfo — 1 solo campo, se queda plano
    personal_identifier: Optional[PersonalIdentifierInputDTO] = None
```

Ejemplo JSON:
```json
{
  "email":      {"address": "juan@example.com", "type": "PERSONAL"},
  "phone":      {"code": "+52", "number": "5512345678", "type": "MOBILE"},
  "first_name": "Juan",
  "last_name":  "Perez",
  "birth":      {"date": "1990-05-15", "key_country": "MX", "key_state": "CMX"},
  "personal_identifier": {"type": "NATIONAL_ID", "value": "PEGJ900515HJCRRC09"}
}
```

### Criterio para decidir sub-objeto vs plano

| Condicion | Decision |
|-----------|----------|
| La entidad relacionada tiene >= 2 campos | Sub-objeto |
| La entidad relacionada tiene 1 solo campo | Plano en el padre |
| Los campos son atributos directos de la tabla principal (no FK) | Plano en el padre |

## Aplicacion

Este patron aplica a:
- DTOs de creacion que persisten en multiples tablas (`CreatePersonDTO`, futuros `CreateCompanyDTO`, etc.)
- Schemas duplicados en `api_middleware` (ADR 028 — contrato espejo)

No aplica a:
- DTOs de respuesta (los Response DTOs ya son especificos por entidad)
- DTOs de endpoints que operan sobre una sola entidad (`CreateAddressDTO`, `CreatePhoneDTO` para endpoints individuales)

## Consecuencias

- **Positivas**:
    - Mapping directo entre DTO y tablas de base de datos — legible sin leer el use case.
    - Nombres de campos mas cortos y sin redundancia (`phone.code` vs `phone_code`).
    - Facil de extender: agregar un campo a `PhoneInputDTO` no afecta el shape del DTO padre.
    - Consistente con el patron ya aplicado en `PersonalIdentifierInputDTO`.
- **Negativas**:
    - El JSON de request gana un nivel de anidacion — ligeramente mas verboso.
    - Requiere actualizar schemas duplicados en `api_middleware` (ADR 028).

## Referencias

- [ADR 010: Estrategia de IDs en Base de Datos](./010-database-id-strategy.md) — Define `BaseModelMixin` con entidades por tabla.
- [ADR 024: Endpoints API con UUIDs](./024-endpoints-uuid-only.md) — Solo UUIDs en API publica.
- [ADR 028: API Middleware — Contrato Duplicado](./028-middleware-duplicate-schema-contract.md) — Schemas replicados en middleware.
