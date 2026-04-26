# ADR 005: Driver de MongoDB y Patrón de Inicialización en FastAPI

## Estado
Aceptado

## Contexto

Beanie 2.x (versión estándar del ecosistema Digital Hospital) depende directamente de `pymongo 4.9+`, que incluye `AsyncMongoClient` de forma nativa. El uso de `motor` como driver de conexión era el estándar anterior, pero:

1. `motor` ya no es una dependencia necesaria cuando se usa `beanie>=2.1.0`.
2. `motor 3.7+` presenta incompatibilidades con Beanie 2.1.0 que requieren un monkeypatch manual sobre `AsyncIOMotorClient`.
3. FastAPI deprecó `@app.on_event("startup"/"shutdown")` en favor del patrón `lifespan`.

## Decisión

Se adoptan los siguientes estándares para todos los servicios nuevos y futuros refactors:

1. **Driver**: Usar `pymongo.AsyncMongoClient`. No declarar `motor` como dependencia en ningún servicio.

2. **Inicialización**: Inicializar Beanie exclusivamente dentro del `lifespan` de FastAPI. El uso de `@app.on_event` está prohibido.

3. **Variables de entorno**: Usar la convención `MONGO_URL` (connection string completa) y `MONGO_DB_NAME` (nombre de la base de datos) en todos los microservicios.

## Consecuencias

- **Positivas**:
    - Eliminación de `motor` como dependencia explícita y su monkeypatch asociado.
    - Conexión MongoDB correctamente enlazada al ciclo de vida de la aplicación (apertura en startup, cierre en shutdown).
    - Nomenclatura de variables de entorno consistente entre todos los servicios.
- **Negativas**:
    - `app_logger_tracer` (servicio existente) usa `motor` y `@app.on_event`. Deberá migrarse en una tarea futura.

## Referencia de Implementación

Ver regla técnica: `.agents/rules/PYTHON_INFRA_MONGO_BEANIE.md`
