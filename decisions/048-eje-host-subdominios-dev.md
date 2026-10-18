# ADR 048: Eje host en DEV — un subdominio por micro-frontend

## Estado
Aceptado (2026-10-18)

## Contexto

El entorno de desarrollo servía todos los micro-frontends como **sub-rutas del
dominio raíz** (`libersalus.dev/signin/`, `/signup/`, `/app/`), sobre un único
`server` block de nginx con un `location` por aplicación y un certificado de un
solo nombre.

Ese modelo presenta límites:

- la URL de cada micro-frontend depende del raíz y no expresa propiedad;
- sumar una aplicación obliga a editar el mismo `server` block;
- la agrupación por sub-ruta no escala a los servicios de backend (`api`,
  `fhir`), que necesitan `proxy_pass` en vez de un docroot;
- el mapa se repite en cada ambiente, cuando el objetivo es tener **uno solo**
  (`docs_devops/guides/domains.md`) y que únicamente cambie el TLD.

Restricción conocida: `.dev` está en la lista **HSTS preload**, así que el
navegador fuerza HTTPS en cualquier host de ese TLD — el certificado es
obligatorio, y el reto HTTP-01 exige el puerto `80` abierto durante la emisión.

## Decisión

- **Un subdominio por micro-frontend.** El raíz queda para la landing y cada
  aplicación o servicio recibe su host: `account.` (signin **y** signup),
  `app.`, `tami.`, `admin.`, `console.`, `api.` y `fhir.`
  - `signin` y `signup` comparten `account.` **a propósito**: sus enlaces mutuos
    (`/signup` ↔ `/signin`) siguen siendo relativos y sobreviven a cualquier modo
    de despliegue.
  - `api.` y `fhir.` son **servicios**: se crean con placeholder y una nota que
    recuerda reemplazar `root`/`location` por `proxy_pass` en la fase
    `06_backend`.
- **Un `server` block y un docroot por host** (`/var/www/<host>/`), generados
  desde una única lista (`HOSTS = "host|paths"`) en
  `scripts/01_web/00-nginx.sh`. Los `location` de cada host viven en un snippet
  regenerable (`snippets/<host>-mf.conf`), separado del bloque TLS que
  administra Certbot.
- **Un solo certificado multi-SAN** para los ocho nombres: el apex va primero
  para conservar la *lineage* (`live/libersalus.dev/`) y `--expand` permite
  ampliarlo en cada reedición. La emisión usa **HTTP-01** con el `80` abierto de
  forma temporal; la vía DNS-01 (wildcard) queda descartada mientras dependa de
  un plugin de Hostinger.
- **El frontend resuelve base, URLs cruzadas y API por ambiente en el código del
  proyecto**, nunca en los workflows: `vite.config.ts` e
  `infrastructure/config.ts` leen `VITE_ENVIRONMENT`
  ([ADR 040 del frontend](../../frontend/docs/decisions/040-per-environment-base-and-urls.md)).
- **El despliegue sigue siendo build-in-CI + `rsync`**, ahora contra el docroot
  del host de cada micro-frontend (`/var/www/<host>/…`).

## Consecuencias

- La URL de cada micro-frontend es estable y propia, y el mapa de DEV coincide
  con el de QA y PROD (solo cambia el TLD).
- Un certificado único cubre los ocho nombres: menos renovaciones que el esquema
  de un certificado por host.
- Sumar un host implica un registro A, un `80` temporal para la emisión y volver
  a correr `01-certbot.sh` con `EXTRA_DOMAINS` actualizado.
- Con el `80` cerrado, la **renovación** requiere reabrirlo (o migrar a
  DNS-01); queda registrado como pendiente operativo.
- Los enlaces que **cruzan de host** deben ser absolutos en DEV; los que no
  cruzan se mantienen relativos.
- Un cliente VPN que no aplique el DNS empujado por el servidor no resuelve los
  nombres del entorno: OpenVPN **≥ 2.7** y NetworkManager lo aplican, mientras
  que el cliente de línea de comandos anterior requiere un script o una entrada
  en `hosts`.

## Referencias

- [Reporte — Entorno de desarrollo con dominio público (2026-10-05)](../reports/2026-10-05_ARCH_entorno-desarrollo-vps-dominio-publico.md)
- [Reporte — Acceso privado por VPN y cierre de puertos públicos (2026-10-06)](../reports/2026-10-06_ARCH_acceso-privado-vpn-openvpn.md)
- [Reporte — Eje host en el entorno DEV (2026-10-18)](../reports/2026-10-18_ARCH_eje-host-subdominios-entorno-dev.md)
- Mapa de dominios y rutas: `docs_devops/guides/domains.md`
- Scripts de la fase web: `docs_devops/scripts/01_web/README.md` · `docs_devops/scripts/PENDING.md`
- Decisión espejo del frontend: `frontend/docs/decisions/040-per-environment-base-and-urls.md`
