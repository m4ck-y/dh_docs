# Casos de uso — Mapper

> **Propuesta** (en definición). El contrato y el store **aún no están
> decididos** — ver [`../store/README.md`](../store/README.md) y
> [`../examples/`](../examples/).

El mapper vincula una **pregunta de un `form`** con una **propiedad física de
dominio**, en dos direcciones:

- [UC1 — Write-through (al responder)](./uc1_write_through.md)
- [UC2 — Prefill (al cargar)](./uc2_prefill.md)

---

## Notas comunes

- La **`answer` siempre se guarda**; el binding es **adicional**.
- `target.operations` determina qué flujos corren: `READ` (prefill), `WRITE` (guardar),
  o ambos.
- La pregunta **prefilled** es **editable**.
- **Reglas de conflicto fijas** (sin campo): prefill solo si la pregunta está vacía;
  write → la respuesta manda (solo se escribe si la pregunta fue respondida).
- **No aplica a componentes** (A/B/D): tienen su propio endpoint.
- **No es mapper**: catálogos (`list_options.catalog`), activadores
  (`form.condition`) ni scoring (`expression`).
