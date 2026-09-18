# UC2 — Prefill (al cargar)

**Cuándo:** el usuario abre el form, antes de contestar.
**Qué pasa:** si el ítem ya está registrado en la columna (por otro medio), la
pregunta se **autorrelena**.

1. El runner toma los bindings del form con `read`.
2. Lee el valor en el destino.
3. Si hay valor → **precarga** la pregunta.
4. Al enviar → aplica UC1.
