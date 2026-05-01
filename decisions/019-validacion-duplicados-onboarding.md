# ADR 019: Validación de Duplicados en Onboarding

**Estado**: Aceptado  
**Fecha**: 2026-04-26  
**Contexto**: Prevención de registros duplicados en el flujo de onboarding

## Contexto

Durante el proceso de onboarding, existía la posibilidad de crear registros duplicados si un usuario intentaba registrarse múltiples veces con el mismo email o CURP. Esto podía generar:

1. **Duplicación de personas** en `dh_core`
2. **Conflictos de integridad** en constraints únicos (email, CURP)
3. **Inconsistencias de datos** entre servicios
4. **Problemas de autenticación** por usuarios duplicados

## Decisión

**Implementar validación de duplicados antes de crear nuevos registros** en el flujo de onboarding.

### Nuevos Endpoints en `dh_core`

```http
GET /v1/people/persons/check-exists?email={email}&curp={curp}
GET /v1/people/persons/by-email/{email}
GET /v1/people/persons/by-curp/{curp}
```

**Respuesta estándar** (`ApiResponseSingle[PersonExistsResponseDTO]`):
```json
{
  "status_code": 200,
  "message": "Person existence check completed",
  "data": {
    "exists": true,
    "person_uuid": "550e8400-e29b-41d4-a716-446655440000",
    "person_id": 123
  }
}
```

### Nuevo Flujo de Onboarding

1. **Validar existencia**: Verificar si persona existe por email/CURP
2. **Si existe sin usuario**: Crear solo `AuthUser` vinculado a persona existente
3. **Si existe con usuario**: Retornar error 409 (Conflict)
4. **Si no existe**: Crear persona + usuario (flujo original)

### Implementación Técnica

**Use Case**: `CheckPersonExistsUseCase`
- `by_email(email)`: Busca por email en tabla `Email`
- `by_curp(curp)`: Busca por CURP en tabla `PersonalIdentifier`  
- `by_email_or_curp(email, curp)`: Busca por cualquiera de los dos

**Validación en Onboarding**:
```python
# Check if person already exists
existing_person = await core.check_person_exists(email=dto.email, curp=dto.curp)
if existing_person["data"]["exists"]:
    # Handle existing person logic
else:
    # Create new person + auth user
```

## Consecuencias

### Positivas
- **Prevención de duplicados**: Elimina registros duplicados por email/CURP
- **Integridad de datos**: Mantiene consistencia entre servicios
- **Experiencia de usuario**: Mensajes claros sobre cuentas existentes
- **Reutilización**: Permite completar onboarding de personas pre-existentes

### Negativas
- **Complejidad adicional**: Más validaciones en el flujo de onboarding
- **Latencia**: Llamada adicional a `dh_core` antes de crear registros
- **Dependencia**: Mayor acoplamiento entre `dh_onboarding_back` y `dh_core`

### Casos de Uso Cubiertos

1. **Usuario nuevo**: Email y CURP no existen → Crear persona + usuario
2. **Persona existente sin usuario**: Existe persona pero no `AuthUser` → Crear solo usuario
3. **Usuario existente**: Persona y usuario existen → Error 409 con mensaje claro
4. **Validación parcial**: Solo email o solo CURP proporcionado → Validar disponible

## Implementación

1. ✅ Crear endpoints de validación en `dh_core`
2. ✅ Implementar `CheckPersonExistsUseCase`
3. ✅ Agregar `PersonExistsResponseDTO`
4. ✅ Actualizar cliente HTTP en `dh_onboarding_back`
5. ✅ Modificar flujo de `SavePersonalInfoUseCase`
6. 🔄 Agregar endpoints al `api_middleware` (contrato)
7. 🔄 Pruebas de integración

## Referencias

- [ADR 018: Migración User de People a Auth](018-migracion-user-people-a-auth.md)
- [AGENTS.md: API Middleware Contract](../AGENTS.md#api-middleware-contract)
- [STATUS.md: Estado del Proyecto](../STATUS.md)