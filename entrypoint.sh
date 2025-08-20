#!/bin/bash
set -e

cd /var/www/html

# Asegurar permisos
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Generar APP_KEY si no existe
if ! grep -q "^APP_KEY=.*base64:.*" .env; then
  echo "🔑 Generando APP_KEY..."
  php artisan key:generate --force
fi

# Ejecutar migraciones
echo "🔄 Ejecutando migraciones..."
php artisan migrate --force

# Limpiar cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Iniciar supervisord
echo "🚀 Iniciando supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf