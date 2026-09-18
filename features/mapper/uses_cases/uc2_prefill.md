# UC2 — Prefill (al cargar)

**Cuándo:** el usuario abre el form, antes de contestar.
**Qué pasa:** si el ítem ya está registrado en la columna (por otro medio), la
pregunta se **autorrelena**.

1. El runner toma los bindings del form con `read`.
2. Lee el valor en el destino.
3. Si hay valor → **precarga** la pregunta.
4. Al enviar → aplica UC1.

---

## Consultas (propuesta)

> Store propuesto: MongoDB `dh_mapper`, colección `bindings`. Lectura por
> `person.uuid`.

### Por pregunta

**Mongo shell** — binding `READ` de `(form, question)`:

```js
db.bindings.findOne(
  { "source.form": "datos_personales",
    "source.question": "datos.fecha_nacimiento",
    "target.operations": "READ" },
  { _id: 0, target: 1 }
);
```

**SQL — ¿ya contestado?:**

```sql
SELECT b.birth_date
FROM people.person p
JOIN people.birth b ON b.id_person = p.id
WHERE p.uuid = $1;
```

> Con valor ≠ `NULL` → prefill; sin fila o `NULL` → pregunta vacía.

### Por form (batch)

**Mongo shell** — todos los bindings `READ` del form:

```js
db.bindings.find(
  { "source.form": "datos_personales", "target.operations": "READ" },
  { _id: 0, "source.question": 1, target: 1 }
);
```

**SQL** — una consulta con `LEFT JOIN` por destino:

```sql
SELECT b.birth_date, pr.education_level, li.civil_status
FROM people.person p
LEFT JOIN people.birth      b   ON b.id_person  = p.id
LEFT JOIN people.profile    pr  ON pr.id_person = p.id
LEFT JOIN people.legal_info li  ON li.id_person = p.id
WHERE p.uuid = $1;
```
