# planning — TASK-017

- Feature: [`features/clinical_history/`](../../../features/clinical_history/README.md).
- Secciones A-E: fuente en `docs/diagrams/0_HISTORIA_CLINICA/flows/*.mmd`.
- Modelo: reutiliza [`schema.sql`](../../../features/questionnaires/schema.sql)
  (`form.type = CLINICAL_HISTORY`), no define tablas propias.
- Vínculos a dominio: feature [`mapper`](../../../features/mapper/README.md).
- **Decisiones abiertas / stoppers**: [`OPEN-QUESTIONS.md`](./OPEN-QUESTIONS.md)
  (H1 AHF, H4 anexos; **H2** y **H3** cerrados; **H5** composición híbrida).
