# IPAQ

**Nombre:** Cuestionario Internacional de Actividad Física

**¿Qué evalúa?:** Actividad física

**Grupo etario:** 18 - 65 años

**Referencia:** [El Cuestionario Internacional de Actividad Física (IPAQ)](https://www.elsevier.es/es-revista-revista-iberoamericana-fisioterapia-kinesiologia-176-articulo-el-cuestionario-internacional-actividad-fisica--13107139) · [IPAQ scoring protocol](https://r2d2.kumc.edu/ADC/Protocols/IPAQ/IPAQ_scoring_protocol.pdf)

**Tiempo aplicativo:** 7 minutos

**Número de ítems:** 7

**CIE-11:** QE20

**Categoría:** Bienestar físico

---

## Instrucciones

Definiciones: actividad moderada = incremento moderado en respiración, frecuencia cardíaca y sudoración ≥10 min; actividad vigorosa = incremento mayor, ≥10 min.

---

## Preguntas

1. Durante los últimos 7 días, ¿cuántos días realizó usted actividades físicas vigorosas como levantar objetos pesados, excavar, aeróbicos o pedalear rápido en bicicleta? (días/semana)
2. ¿Cuánto tiempo en total usualmente le tomó realizar actividades físicas vigorosas en uno de esos días que las realizó? (horas/minutos; "no sabe" = sin respuesta)
3. Durante los últimos 7 días, ¿cuántos días hizo usted actividades físicas moderadas tal como cargar objetos livianos, pedalear en bicicleta a paso regular, o jugar dobles de tenis? No incluya caminatas. (días/semana)
4. Usualmente, ¿cuánto tiempo dedica usted en uno de esos días haciendo actividades físicas moderadas? (horas/minutos; "no sabe" = sin respuesta)
5. Durante los últimos 7 días, ¿cuántos días caminó usted por al menos 10 minutos continuos? (días/semana)
6. Usualmente, ¿cuánto tiempo gastó usted en uno de esos días caminando? (horas/minutos; "no sabe" = sin respuesta)
7. Durante los últimos 7 días, ¿cuánto tiempo permaneció sentado(a) en un día en la semana? (horas/minutos)

> "Ninguna actividad" = 0 días. "No sabe / no está seguro" = sin respuesta (`null`).

---

## Interpretación

El puntaje es **MET-min/semana** (`vigorosa 8 × min × días + moderada 4 × min × días + caminata 3.3 × min × días`).

| Resultado | Categoría |
|---|---|
| MET-min/semana | Alto / Moderado / Bajo (clasificación estándar IPAQ) |

> Fuente: `docs/diagrams/3_CUESTIONARIO_FISICO/flows/ipaq.mmd` +
> `reviews/ipaq-review.md` + `expressions/examples/ipaq-expression.jsonc`.
> **Nota**: el drawio **no** define bandas categóricas (salida = MET-min/semana);
> las categorías Alto/Moderado/Bajo provienen de la clasificación **estándar**
> IPAQ y del AST del proyecto.
