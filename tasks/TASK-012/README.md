---
type: task
id: TASK-012
title: "Orquestador de Seeders Global (System Seeder)"
status: backlog
priority: medium
created: "2026-04-26"
started: null
completed: null
tags: ["seeder", "orchestration", "integration", "dev-tools"]
---

# TASK-012: Orquestador de Seeders Global (System Seeder)

## 📝 Descripción
Desarrollar una herramienta centralizada (script o micro-repositorio) encargada de poblar el ecosistema completo de Digital Hospital. A diferencia de los seeders locales, este orquestador no toca la base de datos directamente; utiliza las APIs públicas/internas de cada microservicio.

## 🔑 Estrategia: Orquestación vía API
El seeder garantiza que los datos sean coherentes a través de los microservicios siguiendo un orden lógico de creación y respetando las reglas de negocio (validaciones, hashing, etc.).

### Orden de Ejecución Sugerido:
1. **`api_core`**: Crear registros de `Person`.
2. **`dh_organizations`**: Crear `Industry`, `Company` y `Location`.
3. **`dh_auth`**: Crear `AuthUser` vinculados a las personas creadas.
4. **`dh_iam`**: Crear `Tenants` para las compañías y asignar `Memberships` con roles a los usuarios.

## 🎯 Objetivos
- [ ] Crear estructura base de scripts (Python/HTTPX).
- [ ] **Módulo Core**: Seed de personas básicas (Médicos, Pacientes, Admins).
- [ ] **Módulo Org**: Seed de la estructura hospitalaria base.
- [ ] **Módulo Auth/IAM**: Creación de credenciales y asignación de permisos multi-tenancy.
- [ ] **Validación de Integridad**: Verificación de que tras el seeding, el login sea funcional para todos los perfiles creados.

## 🔗 Enlaces Rápidos
- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/)
- [Artefactos](artifacts/)
