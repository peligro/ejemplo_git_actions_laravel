#!/bin/bash

set -e

# Si no hay vendor, instalar dependencias
if [ ! -d "vendor" ]; then
    echo "Instalando dependencias con Composer..."
    composer install --no-dev --optimize-autoloader
fi

# Ejecutar migraciones
echo "Ejecutando migraciones..."
php artisan migrate --force

# Iniciar supervisord
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf