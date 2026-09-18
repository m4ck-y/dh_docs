# UC1 — Write-through (al responder)

**Cuándo:** el usuario responde una pregunta con binding habilitado.
**Qué pasa:** además de la `answer`, se persiste el valor en la columna destino.

1. Se guarda la `answer` (siempre).
2. El runner busca el binding de `(form, question)` con `write`.
3. Si existe → **upsert** en el destino.
4. Si el destino ya tenía valor → **la respuesta manda** (solo se escribe si la
   pregunta fue respondida).

---

## Consultas

DB `dh_bindings`, colección `bindings`.

### Por pregunta

**Mongo shell** — binding `WRITE` de `(form, question)`:

```js
db.bindings.findOne(
  { "source.form": "datos_personales",
    "source.question": "datos.fecha_nacimiento",
    "target.operations": "WRITE",
    "enabled": true },
  { _id: 0, target: 1 }
);
```

**SQL — upsert (la respuesta manda):**

```sql
INSERT INTO people.birth (id_person, birth_date)
VALUES ((SELECT id FROM people.person WHERE uuid = $1), $2)
ON CONFLICT (id_person) DO UPDATE
  SET birth_date = EXCLUDED.birth_date,
      updated_at  = now();
```

> Requiere `UNIQUE(id_person)` en la tabla 1:1 destino.

### Por form (batch al enviar)

**Mongo shell** — todos los bindings `WRITE` del form:

```js
db.bindings.find(
  { "source.form": "datos_personales",
    "target.operations": "WRITE",
    "enabled": true },
  { _id: 0, "source.question": 1, target: 1 }
);
```

**SQL** — un upsert por destino dentro de una transacción:

```sql
BEGIN;
INSERT INTO people.birth (id_person, birth_date)
VALUES ((SELECT id FROM people.person WHERE uuid = $1), $2)
ON CONFLICT (id_person) DO UPDATE
  SET birth_date = EXCLUDED.birth_date,
      updated_at = now();
-- ... un statement por cada binding WRITE del form ...
COMMIT;
```
