Si ya tienes la EC2 creada, podemos hacerlo directamente desde la UI de AWS. Por ahora no cierres SSH; primero configuraremos OpenVPN.

Ve al Security Group

En AWS Console:

EC2 → Instances → selecciona tu instancia → Security

Busca Security groups y haz clic en el Security Group asociado.

Luego:

Inbound rules → Edit inbound rules

Deja estas reglas temporalmente

Configúralas así:

Type Protocol Port Source Acción
Custom UDP UDP 1194 0.0.0.0/0 ✅
SSH TCP 22 tu IP /32 ✅ temporal
HTTP TCP 80 — ❌
HTTPS TCP 443 — ❌

Para SSH, no recomiendo 0.0.0.0/0. Si AWS te muestra la opción My IP, selecciónala. Quedará algo parecido a:

SSH
TCP
22
203.xxx.xxx.xxx/32
My IP

Eso permite administrar la EC2 desde tu conexión actual sin exponer SSH a todo Internet.

El resultado
INBOUND

UDP 1194 0.0.0.0/0 ✅ OpenVPN
TCP 22 TU_IP/32 ✅ temporal
TCP 80 — ❌
TCP 443 — ❌

Pulsa Save rules.

Importante: no cierres el 22 todavía

Aunque nuestro objetivo final sea:

UDP 1194 Internet → VPS ✅
TCP 22 Internet → VPS ❌
TCP 80 Internet → VPS ❌
TCP 443 Internet → VPS ❌

todavía no estamos ahí.

Primero vamos a:

AWS Security Group
│
│ UDP 1194
▼
OpenVPN
│
▼
10.8.0.0/24
│
▼
SSH

Cuando puedas conectarte por:

ssh ubuntu@10.8.0.1

a través de la VPN, entonces sí quitamos la regla pública de SSH.

Una cosa más

AWS tiene dos capas diferentes que conviene no mezclar:

Internet
│
▼
AWS Security Group ← primero
│
▼
Ubuntu UFW ← después
│
▼
OpenVPN / Nginx / Docker

Por ahora configura solamente el Security Group. No actives todavía un ufw deny incoming, porque podríamos bloquear accidentalmente tu acceso.

