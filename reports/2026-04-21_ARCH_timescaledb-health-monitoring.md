**Proyecto o Apartado:** Health Monitoring

**Título de la actividad o tarea:** Implementación Estratégica de TimescaleDB para Series de Tiempo

**Descripción de la actividad o tarea:** 
En el sistema médico de la plataforma (`Health Monitoring`), se registran continuamente cientos o miles de datos biométricos diariamente por paciente: signos vitales, resultados de glucosa, peso, frecuencia cardíaca, entre otros. Al almacenar este colosal volumen de información utilizando los métodos tradicionales ("un historial clínico interminable" en una sola gran tabla), la base de datos eventualmente comienza a sufrir cuellos de botella severos. Si un doctor requiere consultar la tendencia de la presión arterial de un paciente durante los últimos tres años, el sistema se volvería inaceptablemente lento.

Para solucionar este desafío arquitectónico a futuro, se ha implementado la extensión **TimescaleDB** sobre la base de datos PostgreSQL existente. Funciona bajo el concepto de *Hypertables*: en lugar de guardar todos los registros del hospital en un solo contenedor gigante y difícil de mover, el motor de la base de datos automáticamente separa la información en "archiveros temporales" ocultos (carpetas o *chunks* por día, semana o mes), agrupando la información bajo el concepto de "Particionamiento de tiempo".

**Beneficios Estratégicos y Funcionales:**
1. **Velocidad Extrema en Gráficos y Dashboards**: Cuando la aplicación visual (Frontend) solicita mostrar un gráfico comparativo de la salud del paciente durante el último año, la respuesta de la base de datos es casi instantánea. Esto se debe a que el sistema sabe exactamente a qué partición específica ir (ej. los chunks de Enero a Diciembre) sin revisar ni leer la información médica del año pasado, un proceso conocido como *Data Skipping*.
2. **Alta Capacidad de Ingestión Continua**: Las bases de datos convencionales (como Postgres puro) usan índices "B-Tree" que se vuelven muy grandes y lentos a medida que crecen, afectando la inserción de nuevos datos. TimescaleDB permite que el sistema médico siga recibiendo lecturas continuas (ej. monitores IoT en camas de hospital) sin sufrir caídas en el rendimiento de escritura.
3. **Mantenimiento y Costos de Servidor Optimizados**: Facilita la configuración de "Políticas de Retención" donde el sistema comprime masivamente los datos históricos que rara vez se consultan o, si está bajo regulaciones específicas, elimina automáticamente los registros que pasen de ciertos años de antigüedad. Esto evita tener que contratar discos duros o servidores cada vez más grandes de forma infinita.

*Detalles Técnicos y de Código:*
Se documenta la estrategia de migración y adopción nativa de TimescaleDB para el manejo optimizado de "Time-Series Data" en el microservicio. Se tomó la decisión de mantener Postgres con la extensión TimescaleDB en lugar de adquirir una base de datos NoSQL externa, para así mantener compatibilidad total con el ORM y herramientas de respaldo actuales (ej. `pg_dump`).

El cambio central ocurre a nivel DDL (Data Definition Language). La tabla estándar `health.measurement` fue convertida a una *hypertable* usando la función nativa `create_hypertable()`.
Para que esto funcionara, la base de datos exigió dos cambios estructurales críticos:
- **Modificación de Llave Primaria (PK)**: El sistema cambió su identificador único de simplemente `(id)` a una llave compuesta de tiempo: `(id, event_at)`.
- **Migración a UTC Universal**: No es posible hacer analítica temporal global sin un estándar. Se ejecutó un script de migración masiva (`migration_timestamps_to_utc.sql`) que convirtió manualmente millones de columnas de tipo `timestamp without time zone` a `timestamp with time zone (timestamptz)`. La información se calibró primero asumiendo `America/Mexico_City` y luego se tradujo automáticamente al formato universal UTC. 

Finalmente, se ajustó el parámetro de partición `chunk_time_interval` a `INTERVAL '1 day'`, optimizando el rendimiento estadístico cuando el backend requiera usar funciones analíticas muy potentes en el código como `time_bucket('1 month', event_at)` para promediar signos vitales rápidamente.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):** 
- Verificación exitosa del particionamiento: La tabla interna `timescaledb_information.chunks` confirmó la correcta creación de sub-tablas automáticas bajo demanda.
- Ejecución de pruebas de rendimiento sobre las funciones de agrupación (`time_bucket`), devolviendo resultados de promedios mensuales y semanales sin saturar la memoria RAM.
- Verificación del contrato de la API: Las fechas solicitadas por los doctores o pacientes se devuelven ahora con estricto apego al estándar ISO-8601 UTC, evitando errores visuales de desplazamiento de horario en la interfaz web.
