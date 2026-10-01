sudo apt update
sudo apt upgrade -y

sudo apt install -y curl wget ca-certificates


sudo apt update
sudo apt install -y openvpn



sudo apt install -y easy-rsa


which easyrsa




----


dpkg -L easy-rsa | grep '/easyrsa$'




1. Crear el directorio de PKI
Ejecuta:

sudo mkdir -p /etc/openvpn/easy-rsa
sudo cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/

Ahora entra:

cd /etc/openvpn/easy-rsa

Comprueba:

ls -la

Deberías ver easyrsa, openssl-easyrsa.cnf, x509-types, etc.

2. Inicializar la PKI
Ejecuta:

sudo ./easyrsa init-pki

Deberías terminar con algo parecido a:

init-pki complete; you may now create a CA or requests.


sudo ./easyrsa build-ca




Te preguntará:

Enter New CA Key Passphrase:

Aquí pon una contraseña fuerte y guárdala.

Después:

Common Name (eg: your user, host, or server name) [Easy-RSA CA]:

Puedes poner:

Libersalus VPN CA


-------------


1. Crear certificado del servidor
Sigues dentro de:

/etc/openvpn/easy-rsa

Ejecuta:

sudo ./easyrsa build-server-full server nopass


2. Crear los parámetros Diffie-Hellman
Después:

sudo ./easyrsa gen-dh



3. Crear una clave TLS adicional

sudo mkdir -p /etc/openvpn/server

sudo openvpn --genkey tls-crypt /etc/openvpn/server/ta.key



-------------


1. Copiar los certificados al directorio de OpenVPN
Ejecuta exactamente:

sudo cp pki/ca.crt /etc/openvpn/server/
sudo cp pki/issued/server.crt /etc/openvpn/server/
sudo cp pki/private/server.key /etc/openvpn/server/
sudo cp pki/dh.pem /etc/openvpn/server/


comprueba:

sudo ls -lh /etc/openvpn/server/




sudo nano /etc/openvpn/server/server.conf

"""
port 1194
proto udp
dev tun

user nobody
group nogroup

topology subnet
server 10.8.0.0 255.255.255.0

persist-key
persist-tun

ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key /etc/openvpn/server/server.key
dh /etc/openvpn/server/dh.pem

tls-crypt /etc/openvpn/server/ta.key

data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
auth SHA256

keepalive 10 120

explicit-exit-notify 1

status /var/log/openvpn/status.log
log-append /var/log/openvpn/server.log
verb 3

"""


---


sudo systemctl enable openvpn-server@server
sudo systemctl start openvpn-server@server

sudo systemctl status openvpn-server@server --no-pager

---

comprobemos la interfaz VPN
Ejecuta:

ip addr show tun0

Y también quiero comprobar que realmente está escuchando en UDP 1194:

sudo ss -lunp | grep 1194




---
Crear certificado del cliente


cd /etc/openvpn/easy-rsa


sudo ./easyrsa build-client-full laptop nopass


sudo ls -lh pki/issued/laptop.crt
sudo ls -lh pki/private/laptop.key




---


libersalus-[ambiente]_[area]-[rol]



Generar el archivo .ovpn directamente en el VPS


sudo mkdir -p /etc/openvpn/client-configs


sudo bash -c 'cat > /etc/openvpn/client-configs/libersalus-laptop.ovpn <<EOF
client
dev tun
proto udp

remote 18.225.218.234 1194

resolv-retry infinite
nobind
persist-key
persist-tun

remote-cert-tls server

data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
auth SHA256

verb 3

<ca>
$(cat /etc/openvpn/easy-rsa/pki/ca.crt)
</ca>

<cert>
$(cat /etc/openvpn/easy-rsa/pki/issued/laptop.crt)
</cert>

<key>
$(cat /etc/openvpn/easy-rsa/pki/private/laptop.key)
</key>

<tls-crypt>
$(cat /etc/openvpn/server/ta.key)
</tls-crypt>
EOF'



-rw-r--r-- 1 root root



sudo chmod 600 /etc/openvpn/client-configs/libersalus-laptop.ovpn
sudo ls -lh /etc/openvpn/client-configs/libersalus-laptop.ovpn

sudo mv \
/etc/openvpn/client-configs/libersalus-laptop.ovpn \
/etc/openvpn/client-configs/libersalus-dev_project-manager.ovpn






sudo cp /etc/openvpn/client-configs/libersalus-dev_project-manager.ovpn /home/libersalus/
sudo chown libersalus:libersalus /home/libersalus/libersalus-dev_project-manager.ovpn
sudo chmod 600 /home/libersalus/libersalus-dev_project-manager.ovpn




--[MI PC LOCAL]:
scp libersalus@18.225.218.234:/home/libersalus/libersalus-dev_project-manager.ovpn ~/Downloads/


ssh -i "dev1_aws_libersalus.pem" libersalus@18.225.218.234
[VPS]
sudo rm /home/libersalus/libersalus-dev_project-manager.ovpn



-- [DNS MASQ]


1. Instalar dnsmasq
En el VPS:

sudo apt update
sudo apt install -y dnsmasq

dnsmasq --version

--
sudo nano /etc/dnsmasq.d/libersalus-vpn.conf
--


"""
# Solo escuchar en la interfaz VPN
interface=tun0
listen-address=10.8.0.1
bind-interfaces

# No utilizar /etc/resolv.conf
no-resolv

# DNS externos
server=1.1.1.1
server=8.8.8.8

# DNS interno
address=/libersalus.dev/10.8.0.1

# No DHCP
no-dhcp-interface=tun0

"""

sudo dnsmasq --test


sudo systemctl restart dnsmasq
sudo systemctl status dnsmasq --no-pager


[Comprobar que DNS funciona]

sudo apt install -y dnsutils

dig @10.8.0.1 libersalus.dev




[openvpn dns]


sudo nano /etc/openvpn/server/server.conf


push "dhcp-option DNS 10.8.0.1"


algo asi:"""

server 10.8.0.0 255.255.255.0

push "dhcp-option DNS 10.8.0.1"

persist-key
persist-tun
"""



sudo systemctl restart openvpn-server@server


sudo systemctl status openvpn-server@server --no-pager


[nginx]

sudo apt install -y nginx
sudo systemctl status nginx --no-pager


[web html]

sudo mkdir -p /var/www/libersalus.dev

sudo nano /var/www/libersalus.dev/index.html



sudo nano /etc/nginx/sites-available/libersalus.dev

"""
server {
    listen 80;
    listen [::]:80;

    server_name libersalus.dev;

    root /var/www/libersalus.dev;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
"""

sudo ln -s /etc/nginx/sites-available/libersalus.dev \
/etc/nginx/sites-enabled/libersalus.dev


sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t


sudo systemctl reload nginx



[]


Queremos que la VPS use dnsmasq para resolver libersalus.dev, pero que siga utilizando el DNS de AWS para los dominios normales.

La forma más limpia con systemd-resolved es hacer que tun0 use 10.8.0.1 como DNS.

1. Configura el DNS de tun0
Ejecuta:

sudo resolvectl dns tun0 10.8.0.1

Después:

sudo resolvectl domain tun0 '~.'

Comprueba:

resolvectl status tun0

resolvectl query libersalus.dev


--
sudo resolvectl dns tun0 10.8.0.1

sudo resolvectl domain tun0 '~libersalus.dev'

resolvectl status tun0

---

sudo mkdir -p /etc/libersalus-ca
sudo chmod 700 /etc/libersalus-ca

--
sudo ls -lh /etc/libersalus-ca/

-
sudo openssl genrsa -aes256 \
  -out /etc/libersalus-ca/ca.key 4096

--

sudo openssl req -x509 -new \
  -key /etc/libersalus-ca/ca.key \
  -sha256 \
  -days 3650 \
  -out /etc/libersalus-ca/ca.crt \
  -subj "/C=MX/O=Libersalus/OU=Development/CN=Libersalus Development CA"


"""
¿Por qué OpenSSL en vez de Certbot?
Usamos OpenSSL + una CA privada porque libersalus.dev será un dominio interno, accesible únicamente mediante la VPN, no un sitio público.

OpenSSL nos permite crear nuestra propia CA (Libersalus Development CA) y firmar certificados TLS para nuestros servicios internos.

No necesitamos depender de una CA pública como Let's Encrypt.

No necesitamos exponer HTTP/HTTPS públicamente para validar el dominio.

Podemos usar https://libersalus.dev dentro de la VPN una vez que instalemos nuestra CA como confiable en los equipos clientes.

La CA de OpenSSL para HTTPS se mantiene separada de la PKI de Easy-RSA utilizada por OpenVPN.

Certbot + Let's Encrypt sería más apropiado si quisiéramos certificados reconocidos automáticamente por todos los navegadores para un servicio público, o si configuráramos una validación DNS-01.

En este proyecto:

OpenVPN → acceso privado
dnsmasq → libersalus.dev → 10.8.0.1
OpenSSL → CA interna + certificado TLS
Nginx → HTTPS

Por eso usamos OpenSSL para la PKI HTTPS interna.
"""


---

1. Crear directorio para el certificado de libersalus.dev
sudo mkdir -p /etc/libersalus-ca/libersalus.dev
sudo chmod 700 /etc/libersalus-ca/libersalus.dev




sudo openssl genrsa -out \
  /etc/libersalus-ca/libersalus.dev/libersalus.dev.key 2048


3. Crear el archivo de extensiones
Esto es importante porque el certificado debe tener SAN (Subject Alternative Name):

sudo nano /etc/libersalus-ca/libersalus.dev/server.ext


"""
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=@alt_names

[alt_names]
DNS.1=libersalus.dev

"""


4. Crear el CSR
sudo openssl req -new \
  -key /etc/libersalus-ca/libersalus.dev/libersalus.dev.key \
  -out /etc/libersalus-ca/libersalus.dev/libersalus.dev.csr \
  -subj "/C=MX/O=Libersalus/OU=Development/CN=libersalus.dev"



5. Firmarlo con tu CA
sudo openssl x509 -req \
  -in /etc/libersalus-ca/libersalus.dev/libersalus.dev.csr \
  -CA /etc/libersalus-ca/ca.crt \
  -CAkey /etc/libersalus-ca/ca.key \
  -CAcreateserial \
  -out /etc/libersalus-ca/libersalus.dev/libersalus.dev.crt \
  -days 825 \
  -sha256 \
  -extfile /etc/libersalus-ca/libersalus.dev/server.ext


  6 verificar

  sudo openssl x509 \
  -in /etc/libersalus-ca/libersalus.dev/libersalus.dev.crt \
  -noout -subject -issuer -dates -ext subjectAltName



1. Copiar los certificados a una ubicación de Nginx
Ejecuta:

sudo mkdir -p /etc/nginx/ssl/libersalus.dev

sudo cp /etc/libersalus-ca/libersalus.dev/libersalus.dev.crt \
  /etc/nginx/ssl/libersalus.dev/

sudo cp /etc/libersalus-ca/libersalus.dev/libersalus.dev.key \
  /etc/nginx/ssl/libersalus.dev/

sudo chmod 600 /etc/nginx/ssl/libersalus.dev/libersalus.dev.key
sudo chmod 644 /etc/nginx/ssl/libersalus.dev/libersalus.dev.crt


3. Configurar Nginx para HTTPS
Abre tu configuración existente:

sudo nano /etc/nginx/sites-available/libersalus.dev

"""
server {
    listen 80;
    listen [::]:80;

    server_name libersalus.dev;

    return 301 https://libersalus.dev$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name libersalus.dev;

    root /var/www/libersalus.dev;
    index index.html;

    ssl_certificate /etc/nginx/ssl/libersalus.dev/libersalus.dev.crt;
    ssl_certificate_key /etc/nginx/ssl/libersalus.dev/libersalus.dev.key;

    ssl_protocols TLSv1.2 TLSv1.3;

    location / {
        try_files $uri $uri/ =404;
    }
}

"""

4. Verificar Nginx
Todavía no reinicies nada. Primero:

sudo nginx -t


sudo systemctl reload nginx

