# Casos de uso — Mapper

> **Propuesta** (en definición). El contrato y el store **aún no están
> decididos** — ver [`../store/README.md`](../store/README.md) y
> [`../examples/`](../examples/).

El mapper vincula una **pregunta de un `form`** con una **propiedad física de
dominio**, en dos direcciones:

---

## UC1 — Write-through (al responder)

**Cuándo:** el usuario responde una pregunta con binding habilitado.
**Qué pasa:** además de la `answer`, se persiste el valor en la columna destino.

1. Se guarda la `answer` (siempre).
2. El runner busca el binding de `(form, question)` con `write`.
3. Si existe → **upsert** en el destino.
4. Si el destino ya tenía valor → **la respuesta manda** (solo se escribe si la
   pregunta fue respondida).

---

## UC2 — Prefill (al cargar)

**Cuándo:** el usuario abre el form, antes de contestar.
**Qué pasa:** si el ítem ya está registrado en la columna (por otro medio), la
pregunta se **autorrelena**.

1. El runner toma los bindings del form con `read`.
2. Lee el valor en el destino.
3. Si hay valor → **precarga** la pregunta.
4. Al enviar → aplica UC1.

---

## Notas comunes

- La **`answer` siempre se guarda**; el binding es **adicional**.
- `target.operations` determina qué flujos corren: `READ` (prefill), `WRITE` (guardar),
  o ambos.
- La pregunta **prefilled** es **editable**.
- **Reglas de conflicto fijas** (sin campo): prefill solo si la pregunta está vacía;
  write → la respuesta manda (solo escribe si la pregunta fue respondida).
- **No aplica a componentes** (A/B/D): tienen su propio endpoint.
- **No es mapper**: catálogos (`list_options.catalog`), activadores
  (`form.condition`) ni scoring (`expression`).
