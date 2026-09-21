# A. REGISTRO

> **Fuente:** `flows/registro.mmd` (drawio `0_DEMO_HISTORIA_CLINICA.drawio`, tab
> "A - REGISTRO"). **Modelado:** **componente/endpoint de dominio** (no `form`);
> edita el perfil de la persona (`people`/`care`) — ver ADR 045.

## 3 bloques de captura

El componente agrupa la captura en **3 bloques condicionables** (no `form.section`):

| Bloque | Condición | Contenido |
|---|---|---|
| **1. Tutor** | se captura si `1.0 = "Sí"` | Datos del tutor/responsable |
| **2. Usuario** | siempre | Datos de la persona en seguimiento |
| **3. Emergencia** | opcional (campos no obligatorios) | Contacto de emergencia |

> El `.mmd` tiene **2 rutas** (1.1 con tutor / 1.2 sin tutor) que **repiten** los
> datos del usuario; aquí se **unifican** en el bloque *Usuario*. Los TODO de la
> fuente se conservan señalados.

## Origen de las listas

| Campo | Origen |
|---|---|
| 1.1.2 Parentesco (tutor) | catálogo `relationship` |
| 1.2.9 Parentesco (emergencia) | catálogo `relationship` |
| 1.2.12A Género | catálogo `gender` |
| 1.2.14 Religión | catálogo `religion` |
| 1.2.17 Ocupación | catálogo `occupation` |
| 1.1.3 Relación · 1.1.17 Depende económicamente · 1.2.11 Sexo al nacer · 1.2.15 Escolaridad · 1.2.16 Estado civil · 1.2.18 Ingresos · 1.2.19 Dependientes | **enum** |

> **Nota:** el seed `relationship.json` cubre **tutor + emergencia**
> (madre/padre, pareja, hermano(a), hijo(a), amigo(a), cuidador(a), tutor legal).

---

## Bloque 1 — Tutor

### 1.0 ¿Requiere apoyo de tutor o responsable? _(condición de entrada)_
- 1.1 Sí
- 1.2 No

> ⚠️ **1.1.1 Nombre completo (tutor)** — **no está en la fuente**
> (drawio/`.mmd`); se agrega como **divergencia intencional** (gap **G1**): es
> necesario para identificar al tutor/responsable.

### Datos del tutor (condición: `1.0 = "Sí"`)

- **1.1.1 Nombre completo** _(Apellido Paterno, Apellido Materno, Nombre(s))_ ⚠️ divergencia G1
- **1.1.2 Parentesco** _(condicional)_ _(catálogo `relationship`)_
  - 1.1.2.1 Madre
  - 1.1.2.2 Padre
  - 1.1.2.3 Cuidador(a)
  - 1.1.2.4 Tutor legal
  - 1.1.2.6 Otro
    - 1.1.2.6.1 _Especifique_
- **1.1.3 ¿Cuál es su relación en el cuidado y vida diaria del paciente?** _(condicional)_ _(enum)_
  - 1.1.3.1 Vive con el usuario y participa en su cuidado diario
  - 1.1.3.2 Participa en su cuidado, pero no vive con él/ella
  - 1.1.3.3 Sólo brinda apoyo administrativo o legal
- **1.1.17 ¿El usuario depende económicamente de usted?** _(condicional)_ _(enum)_
  - 1.1.17.1 Sí
  - 1.1.17.2 Parcialmente
  - 1.1.17.3 No

---

## Bloque 2 — Usuario (persona en seguimiento)

> En la ruta 1.1 estos datos los recopila el tutor; en la 1.2 el propio usuario.
> Es **el mismo dato**, por eso se unifican aquí.

### Identidad
- **1.2.1 Nombre completo** _(Apellido Paterno, Apellido Materno, Nombre(s))_
- **1.2.3 Fecha de nacimiento** _(dd, mmm, aaaa)_
- **1.2.4 Lugar de nacimiento** _(Ciudad, Edo)_
- **1.2.11 Sexo al nacer** _(enum)_
  - 1.2.11.1 Mujer
  - 1.2.11.2 Hombre
  - 1.2.11.3 Intersexual
  - 1.2.11.4 Prefiere no decirlo
- **1.2.12A Género** ⚠️ _(agregado: estaba en el `.mmd`, faltaba en la ficha)_ _(catálogo `gender`)_
  - 1.2.12A.1 Femenino
  - 1.2.12A.2 Masculino
  - 1.2.12A.3 No binario
  - 1.2.12A.4 Otro _(especifique)_
  - 1.2.12A.5 Prefiere no decirlo

### Domicilio
- **1.2.2 Domicilio actual** _(Calle, Manzana Lote o # Ext., # Int., Unidad, Colonia o Pueblo, Ciudad o Municipio, Entidad federativa, CP.)_

### Contacto
- **1.2.5 Teléfono fijo**
- **1.2.6 Celular**
- **1.2.7 Correo electrónico**

### Perfil
- **1.2.14 Religión** _(condicional)_ _(catálogo `religion`)_
  - 1.2.14.1 Católica
  - 1.2.14.2 Cristiana
  - 1.2.14.3 Otra religión
    - _Especifique_
  - 1.2.14.4 Ninguna
  - 1.2.14.5 Prefiere no decirlo
- **1.2.15 Escolaridad** _(enum)_
  - 1.2.15.1 Sin estudios
  - 1.2.15.2 Primaria
  - 1.2.15.3 Secundaria
  - 1.2.15.4 Media superior
  - 1.2.15.5 Superior
  - 1.2.15.6 Posgrado
  - Prefiere no decirlo
- **1.2.16 Estado civil** _(enum)_
  - 1.2.16.1 Soltero/a
  - 1.2.16.2 Casado/a
  - 1.2.16.3 Unión libre / convivencia
  - 1.2.16.4 Separado/a
  - 1.2.16.5 Divorciado/a
  - 1.2.16.6 Viudo/a
  - 1.2.16.7 Prefiere no decirlo
- **1.2.17 Ocupación** _(catálogo `occupation`)_
  - 1.2.17.1 Empleado/a
  - 1.2.17.2 Independiente
  - 1.2.17.3 Estudiante
  - 1.2.17.4 Trabajo del hogar
  - 1.2.17.5 Desempleado/a
  - 1.2.17.6 Jubilado/a o pensionado/a
  - 1.2.17.7 Otro
    - _Especifique_
  - 1.2.17.8 Prefiere no decirlo
- **1.2.18 Ingresos** ⚠️ _(opciones del `.mmd`; la ficha previa usaba rangos de $)_ _(enum)_
  - 1.2.18.1 Son suficientes para el cuidado de mi salud
  - 1.2.18.2 Cubren parcialmente
  - 1.2.18.3 Frecuentemente dificultan
  - 1.2.18.4 Prefiere no responder
- **1.2.19 ¿Cuántas personas dependen económicamente de usted?** ⚠️ _(agregado: estaba en el `.mmd`, faltaba en la ficha)_ _(enum)_
  - 1.2.19.1 Ninguna
  - 1.2.19.2 1
  - 1.2.19.3 2
  - 1.2.19.4 3 o más
  - 1.2.19.5 Prefiere no decirlo

- **1.2.13 Edad** _(dato ya ingresado en el pre-registro; se deriva de 1.2.3)_
- ⏳ **Grupo étnico**: TODO de la fuente ("FALTA PONER GRUPO ÉTNICO") — **pendiente** (gap **G2**).

---

## Bloque 3 — Emergencia (opcional)

> Opcional: los campos no son obligatorios.

- **1.2.8B Nombre completo del contacto**
- **1.2.9 Parentesco** _(catálogo `relationship`)_
  - 1.2.9.1 Madre
  - 1.2.9.2 Padre
  - 1.2.9.3 Pareja
  - 1.2.9.4 Hermano(a)
  - 1.2.9.5 Hijo(a)
  - 1.2.9.6 Amigo(a)
  - 1.2.9.7 Cuidador(a)
  - 1.2.9.8 Otro
    - _Especifique_
- **1.2.10 Teléfono principal**
