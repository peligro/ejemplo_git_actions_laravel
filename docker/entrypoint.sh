#!/bin/sh

# Esperar a que la base de datos esté lista (si es necesario)
# while ! nc -z $DB_HOST $DB_PORT; do
#   echo "Waiting for database..."
#   sleep 2
# done

# Ejecutar migraciones
php artisan migrate --force

# Limpiar cache
php artisan optimize:clear
php artisan optimize

# Ejecutar el comando principal
exec "$@"