# TASK-007: Microservicio de Gestión de Documentos

## 📝 Descripción

Microservicio evolutivo para gestión de documentos (identidad, médicos, seguridad social) con almacenamiento swappable (disk → GCS) y validación configurable vía MongoDB.

## 🎯 Objetivos

- [ ] Implementar storage abstraction (disk/GCS swappable)
- [ ] Crear modelo MongoDB para mappings de tipo documento, extensiones y peso máximo
- [ ] Endpoints CRUD para upload/download/list/delete documentos
- [ ] Integrar con dh_onboarding_back para flujo de onboarding

## 🔗 Enlaces Rápidos

- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/)
- [Artefactos](artifacts/)