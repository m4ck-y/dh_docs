# ADR 012: SQLAlchemy Echo derivado de `ENVIRONMENT`

## Estado
Aceptado

## Contexto

Durante el desarrollo es necesario observar el SQL que SQLAlchemy genera y ejecuta — creación de tablas, queries, inserts — para verificar que el ORM construye las sentencias correctas. SQLAlchemy expone el parámetro `echo` en `create_async_engine`.

En producción y staging, `echo=True` genera ruido excesivo en logs, puede exponer queries con datos sensibles y degrada el rendimiento.

## Decisión

El valor de `echo` se deriva directamente de la variable `ENVIRONMENT` ya existente. No se crea una variable adicional.

```python
engine = create_async_engine(settings.POSTGRES_URL, echo=settings.ENVIRONMENT == "development")
```

| `ENVIRONMENT` | `echo` |
|---|---|
| `development` | `True` |
| `staging` | `False` |
| `production` | `False` |

## Consecuencias

- **Positivas**:
    - Sin variable extra — el comportamiento se infiere del contexto de ejecución.
    - El desarrollador no necesita recordar activar ni desactivar nada.
    - Staging y producción son silenciosos por construcción.
- **Negativas**:
    - No es posible desactivar echo en development sin cambiar `ENVIRONMENT`.
    - Si se necesita development silencioso (ej. tests de carga local), hay que cambiar `ENVIRONMENT=staging` temporalmente.
