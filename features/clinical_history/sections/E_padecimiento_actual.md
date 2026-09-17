# E. PADECIMIENTO ACTUAL

> **Fuente:** `flows/padecimiento_actual.mmd` (drawio
> `0_DEMO_HISTORIA_CLINICA.drawio`, tab "E - PADECIMIENTO ACTUAL").
> **Modelado:** **form** (`key: padecimiento_actual`, `type: CLINICAL_HISTORY`,
> `expression: null`).

> **Artefacto:** [`bank/clinical_history/padecimiento_actual.json`](../../questionnaires/catalog/bank/clinical_history/padecimiento_actual.json)
> _(⏳ pendiente)_.

## Bloques de captura

Motivo → Caracterización del síntoma → Síntomas asociados → Impacto/acciones/estudios.

> **Divergencias de la fuente:**
> - El título interno del drawio dice **"B. PADECIMIENTO ACTUAL"** (aquí E).
> - **`20.0` y `21.0` "Antecedentes relacionados"** están **duplicados** en el
>   drawio; se unifican en `20.0`.

## Origen de las listas

| Campo | Origen |
|---|---|
| 9.0 Localización (selector corporal) | catálogo `body_site` |
| 22.1.1 Estudios previos | catálogo `study` |
| 6.0 Causa real o aparente (`6.8 Otro`) | catálogo (key por definir) |
| Resto (escalas, Sí/No) | **enum** |

## Motivo

- **2.0 Para comenzar, ¿qué le gustaría atender en este momento?**
  - 2.1 Presenta alguna molestia o síntoma
  - 2.2 Dar seguimiento a un problema de salud
  - 2.3 Cuidar su salud y prevenir problemas
    - 2.3.1 ¿Actualmente presenta alguna molestia o síntoma? (Sí/No)
  - 2.4 Realizar un chequeo general
- **3.0 Motivo de consulta** _(¿cuál es la principal molestia o síntoma?)_ — texto

## Caracterización del síntoma

- **4.0 Inicio del problema** — 4.1 Inició hoy · 4.2 Hace algunos días ·
  4.3 Hace semanas · 4.4 Hace meses · 4.5 Hace más tiempo
- **5.0 Forma de inicio** — 5.1 Repentina · 5.2 Gradual · 5.3 Aparece y
  desaparece · 5.4 No lo recuerda
- **6.0 Causa real o aparente**
  - 6.1 Actividad física o esfuerzo · 6.2 Estrés o emociones · 6.3 Golpe o
    lesión · 6.4 Contacto con sustancia o alimento · 6.5 Enfermedad previa ·
    6.6 Medicamento o tratamiento · 6.7 Ninguna · 6.8 Otro
- **7.0 Evolución** — 7.1 Ha mejorado · 7.2 Ha empeorado · 7.3 Igual ·
  7.4 Aparece y desaparece
- **9.0 Localización** _(¿en qué parte del cuerpo? selector corporal visual)_
- **10.0 Irradiación** _(¿se extiende a otra parte del cuerpo?)_
- **11.0 Tipo de molestia** _(¿cómo la describiría?)_
- **12.0 Intensidad** _(escala 0–10)_
- **13.0 Frecuencia** _(¿con qué frecuencia la presenta?)_
- **14.0 Duración** _(cuando aparece, ¿cuánto dura?)_
- **15.0 Factores que empeoran** _(¿algo que la empeore?)_
- **16.0 Factores que alivian** _(¿algo que la alivie?)_

## Síntomas asociados

- **17.0 ¿Ha presentado algún otro síntoma además de esta molestia?**
  - 17.0A ¿Estos síntomas acompañantes continúan actualmente? (17.1A Sí, todos /
    17.2A Algunos / 17.3A No)

## Impacto, acciones y estudios

- **18.0 Impacto funcional** _(¿ha afectado sus actividades diarias?)_
- **19.0 Acciones previas** _(¿ha realizado alguna acción para aliviar la molestia?)_
- **20.0 Antecedentes relacionados** _(¿había presentado esta molestia anteriormente?)_ ⚠️
- **22.0 Estudios previos**
  - 22.1 Sí → 22.1.1 Especifique (conectar con BD de estudios)
  - 22.2 No
- **23.0 Tratamiento previo**
  - 23.1 Medicamentos · 23.2 Atención médica · 23.3 Remedios caseros ·
    23.4 Terapias · 23.5 Ninguna
