# Casos de uso — Mapper

El mapper vincula una **pregunta de un `form`** con una **propiedad física de
dominio**. Habilita dos flujos, según `operation.read` / `operation.write`:

---

## UC1 — Write-through (al responder)

**Cuándo:** el usuario responde una pregunta que tiene binding habilitado.

**Qué pasa:** además de guardar la `answer`, se persiste el valor en la columna
destino.

```
usuario responde ─► answer (siempre) ─► binding(form,question) ─► upsert en target
```

1. Se guarda la `answer` (siempre; snapshot/auditoría).
2. El runner busca el binding `(form_key, question_key)` con `write = true`.
3. Si existe → **upsert** en `target` (según `mode`/`match_on`).
4. Si el destino ya tenía valor distinto → `conflict`
   (`KEEP_EXISTING` | `OVERWRITE` | `FLAG`).

---

## UC2 — Prefill (al cargar / antes de responder)

**Cuándo:** el usuario abre el form, antes de contestar.

**Qué pasa:** si el ítem **ya está registrado** en la columna (por otro medio:
pre-registro, otro form, el componente de dominio), la pregunta se **autorrelena**.

```
abrir form ─► binding(form,question) ─► leer target ─► si hay valor, precargar
```

1. El runner toma los bindings del form con `read = true`.
2. Lee el valor en `target`.
3. Si hay valor → **precarga** la pregunta (marcada *prefilled*).
4. El usuario puede aceptar o editar; al enviar aplica **UC1**.

---

## Notas comunes

- La **`answer` siempre se guarda**; el binding es **adicional**.
- Un binding puede ser **solo read**, **solo write**, o **ambos**.
- **Write** al **enviar** (`SUBMITTED`), junto con `assignment.result`.
- La pregunta **prefilled** es **editable** por defecto.
- **No aplica a componentes** (A/B/D): esos ya leen/escriben el dominio por su
  propio endpoint.
- **No es mapper**: catálogos (`list_options.catalog`), activadores
  (`form.condition`) ni scoring (`expression`).
