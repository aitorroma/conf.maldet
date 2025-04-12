#!/bin/bash

# Verificar si se ejecuta como root
if [ "$(id -u)" != "0" ]; then
   echo "Este script debe ser ejecutado como root" 
   exit 1
fi

# Instalar inotify-tools si no está instalado
if ! command -v inotifywait &> /dev/null; then
    if [ -f /etc/debian_version ]; then
        apt-get update
        apt-get install -y inotify-tools
    elif [ -f /etc/redhat-release ]; then
        yum install -y epel-release
        yum install -y inotify-tools
    fi
fi

# Cargar configuración de HestiaCP
source /usr/local/hestia/conf/hestia.conf
source /usr/local/hestia/data/users/$ROOT_USER/user.conf

# Instalar Maldet con parámetros específicos
cd /usr/local/src
wget -4 http://www.rfxn.com/downloads/maldetect-current.tar.gz
tar -zxvf maldetect-current.tar.gz
rm -fv maldetect-current*
cd maldetect-1.6.*
./install.sh
cd

# Copiar binarios a /sbin
cp /usr/local/sbin/* /sbin

# Crear directorio de maldetect y configurar archivos
mkdir -p /usr/local/maldetect/tmp
chattr -a -i /usr/local/maldetect/* 2>/dev/null || true

# Inicialización y actualización
maldet -d
maldet -u

# Deshabilitar el servicio de systemd
systemctl disable maldet


# Descargar archivos de configuración desde nuestro repositorio
wget -O /usr/local/maldetect/ignore_paths https://raw.githubusercontent.com/aitorroma/conf.maldet/main/ignore.paths
wget -O /usr/local/maldetect/ignore_inotify https://raw.githubusercontent.com/aitorroma/conf.maldet/main/ignore.inotify
wget -O /usr/local/maldetect/conf.maldet https://raw.githubusercontent.com/aitorroma/conf.maldet/main/conf.maldet

# Configurar el email con el de HestiaCP
sed -i "s/\$CONTACT/$CONTACT/" /usr/local/maldetect/conf.maldet

# Crear cron para actualizaciones diarias
echo "# Maldet daily update
0 0 * * * /usr/local/maldetect/maldet -u >> /dev/null 2>&1
2 0 * * * /usr/local/maldetect/maldet -b -r /home/?/web/*/*/public_html/,/home/?/web/*/*/private/ >> /dev/null 2>&1" > /etc/cron.d/maldet

# Establecer permisos correctos
chmod 644 /etc/cron.d/maldet
chmod 644 /usr/local/maldetect/conf.maldet
chmod 644 /usr/local/maldetect/ignore_paths
chmod 644 /usr/local/maldetect/ignore_inotify

echo "Instalación de Maldet completada. Email de notificaciones configurado: $CONTACT"
