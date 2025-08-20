#!/bin/bash
set -e

cd /var/www/html

# Verificar que artisan exista
if [ ! -f "artisan" ]; then
  echo "❌ ERROR: No se encontró artisan. ¿El código se copió bien?"
  exit 1
fi

# Asegurar permisos (aunque USER www-data, por si acaso)
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Instalar dependencias si no hay vendor
if [ ! -d "vendor" ]; then
  echo "📦 Instalando dependencias con Composer..."
  composer install --no-dev --optimize-autoloader
fi

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

# Iniciar supervisord como usuario www-data
echo "🚀 Iniciando supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf