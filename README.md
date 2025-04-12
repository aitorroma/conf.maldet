# Maldet Installer para HestiaCP

Este script instala y configura Maldet (Linux Malware Detect) integrado con HestiaCP, utilizando la configuración de correo del usuario administrador de HestiaCP.

## Características

- Instalación automatizada de Maldet
- Integración con la configuración de correo de HestiaCP
- Configuración de escaneo automático de directorios web
- Cuarentena automática de archivos maliciosos
- Integración con ClamAV
- Actualizaciones diarias automáticas

## Instalación

```bash
wget https://raw.githubusercontent.com/aitorroma/conf.maldet/main/install.sh
chmod +x install.sh
./install.sh
```

## Configuración

El script configura automáticamente:

- Email de notificaciones desde HestiaCP
- Escaneo diario de directorios web
- Actualizaciones diarias de firmas
- Cuarentena automática
- Integración con ClamAV

## Directorios escaneados

- /tmp
- /var/tmp
- /dev/shm
- /var/www/*/public_html
- Directorios web de usuarios

## Soporte

Para reportar problemas o sugerencias, por favor crear un issue en este repositorio.