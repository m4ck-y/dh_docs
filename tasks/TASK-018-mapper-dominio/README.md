---
type: task
id: TASK-018
title: "Mapper de dominio: prefill y write-through"
status: backlog
priority: medium
created: "2026-09-15"
started: null
completed: null
tags: ["mapper", "mongodb", "dominio", "bindings", "prefill"]
---

# TASK-018: Mapper de dominio — prefill y write-through

## Descripción

Implementar el feature transversal `mapper`: vincular preguntas (cuestionarios e
historia clínica) con propiedades del dominio físico (`people`,
`health_profile`, `care`, ...) para **prefill** (leer si ya existe) y
**write-through** (persistir al enviar), con su store y su UI administrativa.

## Objetivos

- [ ] Contrato de binding estable (por `form_key`/`question_key`) y validación.
- [ ] Store en Mongo (`docs/db/mongo/mapper/`).
- [ ] `read` / prefill en el runner.
- [ ] `write` / write-through (upsert en dominio) al enviar.
- [ ] Política de conflicto y transformaciones.
- [ ] UI administrativa (conectar/desconectar vínculos).

## Enlaces rápidos

- [Plan de ejecución](planning/README.md)
- [Registro de progreso](progress/)
- [Artefactos](artifacts/)
- [Feature](../../features/mapper/README.md)
- [Ejemplo de binding](../../features/mapper/examples/binding.example.jsonc)
