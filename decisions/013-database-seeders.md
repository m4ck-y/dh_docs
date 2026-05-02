# ADR 013: Estrategia de Seeders para Datos de Catálogo

## Estado
Aceptado

## Contexto

Algunos esquemas de la base de datos requieren datos de catálogo para funcionar correctamente desde el primer arranque del servicio — por ejemplo, `expedient.document_type` y `expedient.document_subtype`. Sin estos registros, los endpoints que dependan de ellos fallarán con FK violations o `404 Not Found`.

Se necesita una estrategia que:
- Inserte los datos de catálogo automáticamente al arrancar el servicio.
- No duplique registros si el servicio se reinicia.
- No requiera comandos manuales ni scripts externos.
- Sea predecible y auditable.

## Decisión

Los seeders de catálogo se implementan como funciones `async` en `app/shared/database/seeders.py` y se invocan desde el `lifespan` de FastAPI, **después de `Base.metadata.create_all`**.

### Estructura

```
app/
  shared/
    database/
      postgres.py       ← engine, Base, AsyncSessionLocal
      seeders.py        ← funciones de seeding (una por dominio)
  main.py               ← lifespan: create_all → seed → mongo init
```

### Patrón obligatorio: guard de tabla vacía

Antes de insertar, verificar que la tabla tiene `0` registros. Si tiene datos, salir sin hacer nada. La verificación se hace sobre la tabla raíz del dominio que se va a sembrar.

```python
count = await session.scalar(select(func.count()).select_from(MyModel))
if count > 0:
    return
```

### Orden de inserción con flush intermedio

Cuando los datos a sembrar tienen FK entre sí (tipo → subtipo), insertar el nivel padre primero, hacer `flush()` para obtener los IDs enteros generados, luego insertar los hijos con esos IDs.

```python
parent = ParentModel(name="Tipo A")
session.add(parent)
await session.flush()  # genera parent.id sin commit

session.add(ChildModel(name="Subtipo A1", id_parent=parent.id))
await session.commit()
```

### Invocación en lifespan

```python
@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    await seed_expedient_catalogs()  # después de create_all, antes de mongo init

    # MongoDB init...
    yield
```

## Reglas

- Un seeder por dominio de catálogo — no mezclar dominios en una misma función.
- El guard de tabla vacía es obligatorio — nunca insertar sin verificar primero.
- **Uso de Logger Tracer**: Los seeders **nunca** deben usar `print()`. Deben usar `ServiceLogger` para reportar el inicio, salto (skip) y éxito de la operación hacia VitalTrace.
- **Utilidades de `dh_shared`**: Si el seeder requiere hashear contraseñas (ej. usuario admin inicial) o usar enums, debe importar estas utilidades de `dh_shared` para garantizar la consistencia en todo el monorepo.
- Usar `flush()` entre niveles de FK, no múltiples `commit()`.
- Un solo `commit()` al final de cada función seeder.
- Los seeders son **idempotentes** — ejecutarlos N veces produce el mismo estado que ejecutarlos una vez.
- Los seeders solo cubren **datos de catálogo estáticos** — nunca datos de negocio dinámicos.

## Consecuencias

- **Positivas**:
    - El servicio arranca funcionalmente en un entorno limpio sin intervención manual.
    - Idempotente — reinicios y redeploys no generan duplicados ni errores.
    - El catálogo vive junto al código que lo necesita — es fácil de mantener y revisar.
- **Negativas**:
    - Agregar una entrada al catálogo requiere un redeploy (no es configurable en caliente).
    - Si el catálogo crece mucho, la lógica de seeding puede volverse lenta al arranque.
