# C. APNP (Antecedentes Personales No Patológicos)

> **Fuente:** `flows/apnp.mmd` (drawio `0_DEMO_HISTORIA_CLINICA.drawio`, tab
> "C - APNP"). **Modelado:** **form** (`key: apnp`, `type: CLINICAL_HISTORY`,
> `expression: null`).

> **Artefacto:** [`bank/clinical_history/apnp.json`](../../questionnaires/catalog/bank/clinical_history/apnp.json).

## Instrucciones (`form.instructions`)

> "A continuación, se realizarán algunas preguntas sobre hábitos y aspectos de la
> vida diaria que pueden influir en su estado de salud y bienestar."

Nodo **intro `1.0`** del `.mmd`; va en `form.instructions` (**no** como pregunta).

## Bloques de captura

Vivienda → Higiene → Trabajo → Actividad/alimentación → Sueño → Vacunas.

> **Divergencias de la fuente:**
> - Hay **dos nodos `1.0`** (la instrucción general y la pregunta de vivienda).
> - La numeración salta de `1.0` a `3.0` (falta el `2.0`).
> - `18.0 Cepillado` trae opciones redundantes (`18.7 "1 o 2 veces"` repite
>   `18.2`/`18.3`).

## Origen de las listas

| Campo | Origen |
|---|---|
| 1.0 Tipo de vivienda (1.7 "Otro") | catálogo `housing_type` |
| 12.0 Combustible (12.8 "Otro") | catálogo `heating_fuel` |
| 14.0A Tipo de animal (14.4A "Otro") | catálogo `animal_type` |
| 21.0 Turno (21.5 "Otro") | catálogo `work_shift` |
| Resto (Sí/No/No sabe, escalas, multiselección) | **enum** |

## Vivienda

- **1.0 ¿Qué tipo de vivienda tiene?** _(catálogo `housing_type`)_
  - 1.1 Casa independiente
  - 1.2 Dúplex / Tríplex
  - 1.3 Casa en hilera
  - 1.4 Departamento (1–3 pisos)
  - 1.5 Edificio alto (>3 pisos)
  - 1.6 Móvil / Tráiler
  - 1.7 Otro _(especificar)_
- **3.0 ¿Se usa como granja o rancho?** — Sí / No
- **4.0 Edad aproximada del edificio (años)** _(numérica)_
- **5.0 ¿Cuándo empezó a vivir aquí? (año)** _(numérica)_
- **6.0 ¿Cuántas personas viven en esta dirección?** — 1 / 2 / 3 / 4 / 5 o más
- **7.0 ¿Hay cochera cerrada?**
  - 7.1 Sí → 7.0A ¿Se estacionan vehículos en la cochera? (7.1A Sí / 7.2A No)
  - 7.2 No
- **8.0 ¿Hay dispositivos de gas en cuartos o cochera?** — Sí / No / No sabe
- **9.0 ¿Ha habido humedad o fugas en los últimos 12 meses?** — Sí / No / No sabe
- **10.0 ¿Huele frecuentemente a moho?** — Sí / No / No sabe
- **11.0 ¿Usa aire acondicionado?**
  - 11.1 Sí → 11.0A ¿Qué tipo? (11.1A Central / 11.2A Ventana/Pared / 11.3A Portátil)
  - 11.2 No
- **12.0 ¿Qué combustible usa para calefacción?** _(catálogo `heating_fuel`)_
  - 12.1 Gas de tubería · 12.2 Gas LP · 12.3 Electricidad · 12.4 Queroseno ·
    12.5 Carbón · 12.6 Madera · 12.7 Solar · 12.8 Otro · 12.9 Ninguno · 12.10 No sabe
- **13.0 ¿Tiene calefacción central con ductos?** — Sí / No
- **14.0 ¿Ha tenido animales dentro del hogar (últimos 12 meses)?**
  - 14.1 Sí → 14.0A ¿Qué tipo? (14.1A Perro / 14.2A Gato / 14.3A Animal pequeño
    peludo / 14.4A Otro / 14.5A No sabe) _(catálogo `animal_type`)_
  - 14.2 No

## Higiene

- **15.0 ¿Con qué frecuencia se baña?** — Más de una vez al día / A diario /
  Varias veces a la semana / Una vez a la semana o menos / Rara vez o casi nunca
- **16.0 ¿Con qué frecuencia cambia de ropa?** — Diario / 2–3 veces por semana /
  Menos de 2 veces por semana
- **17.0 ¿En cuáles situaciones acostumbra lavarse las manos? (seleccione todas)** _(MULTIPLE_CHOICE)_
  - 17.1 Antes de preparar alimentos
  - 17.2 Antes de comer o alimentar a otra persona
  - 17.3 Después de usar el baño
  - 17.4 Después de toser, estornudar o sonarse
  - 17.5 Cuando están visiblemente sucias
- **18.0 ¿Cuántas veces al día se cepilla los dientes?**
  - 18.1 No se cepilla · 18.2 1 vez · 18.3 2 veces · 18.4 Más de 2 ·
    18.5 Esporádicamente · 18.6 No aplica · 18.7 1 o 2 veces ⚠️ · 18.8 No sabe
- **19.0 ¿Usa hilo dental?** — No / Rara vez / 1–3 veces/semana / Diario
- **20.0 ¿Hace cuánto fue su última visita al dentista?**
  - 20.1 6 meses o menos · 20.2 6–12 meses · 20.3 1–2 años · 20.4 2–3 años ·
    20.5 3–5 años · 20.6 Más de 5 años · 20.7 Nunca ha ido

## Trabajo

- **21.0 ¿En qué horario o turno trabaja?** _(catálogo `work_shift`)_
  - 21.1 Diurno · 21.2 Vespertino · 21.3 Nocturno · 21.4 Rotativo
    (21.4A Con noches / 21.4B Sin noches) · 21.5 Otro
- **22.0 ¿Cuántas horas trabaja al día en promedio?** — 8 o menos / 9 a 12 / Más de 12
- **23.0 ¿Cuántos días a la semana trabaja?** _(numérica)_
- **24.0 ¿A cuáles riesgos laborales está expuesto? (seleccione todas)** _(MULTIPLE_CHOICE)_
  - 24.1 Químicos · 24.2 Biológicos · 24.3 Físicos · 24.4 Ergonómicos ·
    24.5 Psicosociales · 24.6 Seguridad/mecánicos

## Actividad física y alimentación

- **25.0 ¿Con qué frecuencia realiza actividad física?**
  - 25.1 Todos o casi todos los días · 25.2 Algunas veces por semana ·
    25.3 Ocasionalmente · 25.4 No realiza
- **26.0 ¿Cómo considera su alimentación actualmente?**
  - 26.1 Excelente · 26.2 Muy buena · 26.3 Buena · 26.4 Regular · 26.5 Mala

## Sueño

- **27.0 ¿Cómo considera la calidad de su sueño?** — Buena / Regular / Mala
- **28.0 ¿Cuántas horas duerme al día en promedio?**
  - 28.1 Menos de 5 · 28.2 Entre 5 y 6 · 28.3 Entre 7 y 9 · 28.4 Más de 9 ·
    28.5 Horario muy variable
- **28.0A ¿Con qué frecuencia ha usado medicamentos para dormir?**
  - 28.1A Nunca · 28.2A Una o dos veces · 28.3A Mensual · 28.4A Semanal

## Vacunas

- **29.0 En los últimos años, ¿ha recibido vacunas o refuerzos recomendados?**
  - Sí / No / No lo recuerda
- **30.0 ¿Cuenta con información o registro reciente de sus vacunas?** — Sí / No
