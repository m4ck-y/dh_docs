**Proyecto o Apartado:** Infraestructura — Acceso y seguridad (repo `docs_devops`)

**Título de la actividad o tarea:** Implementación del acceso privado por VPN (OpenVPN) y cierre de los puertos públicos

**Descripción de la actividad o tarea:** Se implementó el **acceso privado por VPN** al entorno de desarrollo mediante **OpenVPN**, con el fin de **dejar de exponer** los puertos públicos del VPS. El objetivo de negocio es que el entorno de pruebas **no sea accesible desde Internet abierto**: la única entrada pública pasa a ser el puerto de la VPN (`1194/UDP`) y el resto (`22`, `80`, `443`) se cierran.

Además de la seguridad, la VPN responde a un objetivo de **control del acceso**: permite que las **últimas características en desarrollo no queden visibles al público** mientras no se hayan liberado a producción. El entorno queda accesible **solo** para quien recibe el archivo `.ovpn` (equipo interno, probadores o usuarios invitados), lo que proporciona un ambiente **más controlado** y coherente con el objetivo de no exhibir el trabajo en curso en el sitio oficial.

Técnicamente se creó la fase `02_vpn`, con los siguientes componentes:

- **Servidor OpenVPN** (`01-openvpn-server.sh`): instalación, **PKI** propia (CA + certificado del servidor), `server.conf` y servicio. La PKI **no se regenera** si ya existe, para proteger los `.ovpn` ya emitidos.
- **Clientes** (`02-openvpn-client.sh`): por cliente se emite un certificado y se genera un `.ovpn` que embebe CA, certificado, clave y `tls-crypt`. El prefijo `libersalus-dev_` es fijo; por defecto se crea `libersalus-dev_public` (acceso del público/probadores, con **multisesión** habilitada vía `duplicate-cn`) y pueden crearse individuales (`libersalus-dev_<area>-<rol>`).
- **Revocación** (`revoke-client.sh`, a demanda): revoca un certificado y regenera la **CRL**; el servidor la verifica (`crl-verify`), de modo que un cliente revocado deja de entrar.
- **Backup / restauración de la PKI** (`03-backup-pki.sh` / `00-restore-pki.sh`): la PKI se empaqueta para **reutilizarla** en una migración de VPS, sin regenerar la CA y sin romper los `.ovpn`.
- **DNS interno** (`04-dns.sh`): `dnsmasq` resuelve el dominio a la IP interna de la VPN (`10.8.0.1`) y OpenVPN lo difunde, permitiendo acceder al entorno **por dominio a través de la VPN** una vez cerrados `80`/`443`.
- **Passphrase de la CA** (opcional): si existe `secrets/ca-passphrase`, la CA se cifra; si no, se crea sin passphrase (`nopass`).

Con la VPN activa, el acceso administrativo (SSH) y el sitio se consumen por la **red interna** (`10.8.0.1`), y la renovación del certificado migra a **DNS-01** (registro `TXT`), al no poder usarse HTTP-01 con el puerto `80` cerrado.

Para el **acceso del usuario final**, la conexión se realiza con la aplicación **OpenVPN Connect** (disponible para **Android** y **Windows**): basta **cargar el archivo `.ovpn` público** ([enlace al `.ovpn` público]) y conectar; una vez establecida la VPN, el navegador accede a la **página de desarrollo** por el dominio `libersalus.dev`.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad:**
- **Fase VPN concluida:** conexión privada operativa, `.ovpn` generado y **acceso privado al HTML** del entorno al entrar en `libersalus.dev`.
- Fase `02_vpn` implementada y publicada en el repositorio: `01-openvpn-server.sh`, `02-openvpn-client.sh`, `03-backup-pki.sh`, `00-restore-pki.sh`, `04-dns.sh`, `revoke-client.sh` y `lib/easyrsa-env.sh`.
- Regla de **Security Group** para `1194/UDP` documentada; cierre de `22`/`80`/`443` definido como estado final.
- Nomenclatura de clientes estandarizada (`libersalus-dev_<sufijo>`).
- Documentación de **respaldo y recuperación** de secretos (`scripts/secrets_backup.md`, `scripts/secrets_init.md`).
- **Pendiente:** desarrollar el **manual de usuario** para conectarse: descargar **OpenVPN Connect** (**Android** / **Windows**) y cargar el archivo **`.ovpn` público** ([enlace al `.ovpn` público]), para acceder a la página de desarrollo.
