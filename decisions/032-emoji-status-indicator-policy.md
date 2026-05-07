# ADR 032: Politica de Emojis como Indicadores de Estado

## Estado
Aceptado

## Contexto

AGENTS.md y las reglas de escritura en `.agents/rules/WRITING.md` prohiben el uso de emojis en todos los archivos del proyecto. Sin embargo, en documentacion de referencia como los mappers de base de datos (`docs/historial_clinico/A.REGISTRO.MAPPER.md`), los emojis **representan datos semanticos** — no son decorativos, son la informacion misma.

La eliminacion indiscriminada de emojis destruye informacion en archivos donde el emoji es el dato (ej. una tabla de cobertura de mapeo DB con indicadores de estado).

## Decision

Se permite el uso de emojis **exclusivamente como indicadores de estado** cuando cumplen una funcion de datos semanticos, bajo las siguientes condiciones:

### 1. Convencion estandar de tres colores

| Emoji | Significado | Uso |
|---|---|---|
| 🟢 | Completo / Mapeado / Activo / Aprobado / Validado | Cobertura total de mapeo DB, servicio activo, paso completado |
| 🟡 | Parcial / En progreso | Cobertura parcial, entidad existe pero falta columna, paso en curso |
| 🔴 | Faltante / Pendiente / Bloqueado / Rechazado | Sin implementar, pendiente de definir, paso bloqueado |

Se permite un cuarto color (🔵 azul) si se requieren mas estados diferenciados (ej. "deprecated", "external", "delegated"). Cualquier color adicional debe definirse explicitamente en el documento que lo usa.

### 2. Contextos permitidos

- Tablas de cobertura de mapeo DB (schema mapping tables)
- Grids de estado de despliegue (deployment status)
- Indicadores de progreso en planificacion tecnica
- Tablas de estados de verificacion (aprobado/pendiente/rechazado)
- Cualquier contexto donde el emoji **es** el dato, no un adorno del dato

### 3. Contextos prohibidos

- Titulos de seccion o encabezados
- Bullet points decorativos
- Iconos de accion (lapiz, ojo, llave, engranaje)
- Emojis de tono o emocion
- Dentro de codigo fuente, docstrings, o comentarios
- En archivos fuera de `docs/`

### 4. Regla practica

> Si quitas el emoji y la informacion se pierde, el emoji es valido.
> Si quitas el emoji y el texto sigue comunicando lo mismo, el emoji es decorativo y debe eliminarse.

## Consecuencias

### Positivas
- Preserva datos semanticos en documentacion de referencia (mappers, matrices de estado).
- Estandariza el significado de los tres colores en todo el proyecto.
- Elimina ambiguedad sobre que emojis son validos y cuales no.

### Negativas
- Riesgo de que desarrolladores abusen de la excepcion para uso decorativo.
- La regla practica ("quita el emoji, se pierde la info?") requiere criterio humano.

## Referencias

- [WRITING.md](../.agents/rules/WRITING.md) — regla original que prohibe emojis.
- [AGENTS.md](../AGENTS.md) — politica actualizada con esta excepcion.
- `docs/historial_clinico/A.REGISTRO.MAPPER.md` — ejemplo canonico de uso valido.
- `docs/architecture/deployment-port-mapping.md` — ejemplo de tabla de estado de despliegue.
