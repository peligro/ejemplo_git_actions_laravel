#!/bin/bash

# Asegurar permisos en directorios montados
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Ejecutar el comando original como www-data
exec gosu www-data "$@"