# UC1 — Write-through (al responder)

**Cuándo:** el usuario responde una pregunta con binding habilitado.
**Qué pasa:** además de la `answer`, se persiste el valor en la columna destino.

1. Se guarda la `answer` (siempre).
2. El runner busca el binding de `(form, question)` con `write`.
3. Si existe → **upsert** en el destino.
4. Si el destino ya tenía valor → **la respuesta manda** (solo se escribe si la
   pregunta fue respondida).
