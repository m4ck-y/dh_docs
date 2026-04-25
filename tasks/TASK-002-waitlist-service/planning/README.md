# Plan de Ejecución - TASK-002

## Arquitectura
- **Base de Datos**: MongoDB.
- **Comunicación**: REST API.
- **Integración**: Conexión con el Core API para la promoción de leads (futuro).

## Pasos de Implementacion

### Fase 1: Infraestructura y Modelo
- [ ] Configurar la conexión a MongoDB en el microservicio.
- [ ] Definir el modelo de datos (Pydantic) para la colección `waitlist`.
- [ ] Implementar el repositorio de persistencia.

### Fase 2: Endpoints Públicos
- [ ] `POST /api/v1/waitlist`: Registro de leads desde landing pages.
- [ ] `GET /api/v1/waitlist/check/{email}`: Verificar si un email ya está registrado.

### Fase 3: Endpoints de Administración
- [ ] `GET /api/v1/admin/waitlist`: Listar leads con filtros (status, source).
- [ ] `POST /api/v1/admin/waitlist/{email}/invite`: Generar token y cambiar status a `INVITED`.

### Fase 4: Seguridad y Validación
- [ ] Implementar validación de emails únicos.
- [ ] Asegurar que los tokens de invitación tengan expiración y sean seguros.

## Plan de Pruebas
- [ ] Unit tests para el repositorio de Mongo.
- [ ] Integration tests para los endpoints de registro e invitación.
- [ ] Prueba de carga ligera para el endpoint de registro.
