#!/bin/bash

# Verificar si se ejecuta como root
if [ "$(id -u)" != "0" ]; then
   echo "Este script debe ser ejecutado como root" 
   exit 1
fi

# Cargar configuración de HestiaCP
source /usr/local/hestia/conf/hestia.conf
source /usr/local/hestia/data/users/$ROOT_USER/user.conf

# Instalar Maldet
cd /usr/local/src
wget http://www.rfxn.com/downloads/maldetect-current.tar.gz
tar -xzf maldetect-current.tar.gz
cd maldetect-*
./install.sh

# Descargar y aplicar nuestra configuración personalizada
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

echo "Instalación de Maldet completada. Email de notificaciones configurado: $CONTACT"