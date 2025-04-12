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

# Configurar Maldet
sed -i "s/^email_addr=.*/email_addr=\"$CONTACT\"/" /usr/local/maldetect/conf.maldet

# Configuraciones adicionales de Maldet
sed -i 's/^quarantine_hits=.*/quarantine_hits="1"/' /usr/local/maldetect/conf.maldet
sed -i 's/^quarantine_clean=.*/quarantine_clean="1"/' /usr/local/maldetect/conf.maldet
sed -i 's/^scan_clamscan=.*/scan_clamscan="1"/' /usr/local/maldetect/conf.maldet
sed -i 's/^scan_tmpdir_paths=.*/scan_tmpdir_paths="/tmp /var/tmp /dev/shm /var/www/*/public_html"/' /usr/local/maldetect/conf.maldet

# Crear cron para actualizaciones diarias
echo "# Maldet daily update
0 0 * * * /usr/local/maldetect/maldet -u >> /dev/null 2>&1
2 0 * * * /usr/local/maldetect/maldet -b -r /home/?/web/*/*/public_html/,/home/?/web/*/*/private/ >> /dev/null 2>&1" > /etc/cron.d/maldet

# Establecer permisos correctos
chmod 644 /etc/cron.d/maldet

echo "Instalación de Maldet completada. Email de notificaciones configurado: $CONTACT"