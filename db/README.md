# db

Documentación de las bases de datos del sistema.

Cada subcarpeta corresponde a un motor de base de datos distinto.

## Motores

| Carpeta | Motor | Descripción |
|---|---|---|
| [postgres/](./postgres/) | PostgreSQL | Base de datos relacional principal — datos demográficos, expediente, relaciones de cuidado |
| [mongo/](./mongo/) | MongoDB | Pendiente de diseño |
| [click_house/](./click_house/) | ClickHouse | Pendiente de diseño — orientado a analítica y eventos |

## Estándares Transversales

- **[Matriz de Acceso Servicios-Schemas](./service_database_access_matrix.md)**: Define la propiedad y permisos de cada servicio sobre la persistencia.
- **[Estándar de Fechas y Horas — UTC](../decisions/008-datetime-utc-standard.md)**: Todos los timestamps deben almacenarse en UTC. Aplica a PostgreSQL (`DateTime(timezone=True)`), MongoDB (datetimes timezone-aware) y Pydantic (`datetime.now(timezone.utc)`).
