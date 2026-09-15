# Mapper (feature transversal)

Feature Nº 3. Vincula **preguntas** de formularios (cuestionarios e historia
clínica) con **propiedades del dominio físico** (`people`, `health_profile`,
`care`, ...), habilitando:

- **read / prefill**: si la propiedad ya tiene valor en la BD, autocompletar la
  pregunta.
- **write-through**: al enviar, persistir la respuesta además en la entidad de
  dominio (upsert).

**Estado:** Propuesta (contrato por definir/pulir).

**Depende de:** [`../questionnaires/`](../questionnaires/) y
[`../clinical_history/`](../clinical_history/).

## Por qué es un feature aparte

- **Transversal**: vincula dos productores (cuestionarios, HC) con un consumidor
  (el dominio físico). No pertenece a ninguno.
- **Ciclo de vida propio**: existe *después* de ambos módulos y evoluciona solo.
- **Configuración dinámica**: conectar/desconectar vínculos **sin** tocar el
  formulario (un `form` `verified` es inmutable).
- **Store editable** en Mongo + **UI administrativa** (futuro).

## Estructura

| Ruta | Contenido |
|---|---|
| `README.md` | Este índice: contrato, semántica, pendientes. |
| [`examples/binding.example.jsonc`](./examples/binding.example.jsonc) | Ejemplo (borrador) de binding. |
| `views/<dominio>/<form>.md` | Vista legible de los bindings por formulario. |

## Contrato del binding (borrador)

Ver [`examples/binding.example.jsonc`](./examples/binding.example.jsonc).

Semántica:

- `read` → el runner busca el valor en `target` y autocompleta la pregunta.
- `write` → al enviar, upsert en `target`.
- La **`answer` siempre se guarda** (snapshot/auditoría); el binding es adicional.
- Referencias por `form_key` / `question_key` (estables), no por ids internos,
  para sobrevivir a cambios de motor.
- El binding declara su **motor destino** (`postgres` por columna; `mongo` por
  documento/campo).

## Pendientes

- Definir el **store** en Mongo (`docs/db/mongo/mapper/`).
- Definir política de **conflicto** (`keep_existing` / `overwrite` / `flag`) y
  **transformaciones**.
- **Validación**: el `target` debe existir en el modelo (`docs/db/`); unicidad
  por target.
- **UI administrativa** para conectar/desconectar vínculos — propuesta.
- Migrar los bindings de `views/` a la **fuente ejecutable** cuando exista el
  store (hoy `views/` es documentación de lectura).
