FROM php:8.4-fpm

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    nano \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libldap2-dev \
    supervisor \
    libssl-dev \
    libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configurar la zona horaria (opcional, descomenta si lo necesitas)
# RUN ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime && \
#     dpkg-reconfigure -f noninteractive tzdata

# Instalar extensiones de PHP
RUN docker-php-ext-configure ldap --with-libdir=/lib/x86_64-linux-gnu && docker-php-ext-install pdo_mysql mbstring zip gd pgsql pdo_pgsql && docker-php-ext-enable pgsql pdo_pgsql

# Instalar Node.js 21
# RUN curl -fsSL https://deb.nodesource.com/setup_21.x  | bash - && apt-get install -y nodejs && node -v && npm -v

# Instalar Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Copiar configuración personalizada de php.ini si es necesario
COPY php.ini /usr/local/etc/php/

# Copiar configuración de Supervisor
COPY supervisor/supervisor.conf /etc/supervisor/supervisord.conf

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar el código de la aplicación
COPY . .

# Crear directorio vendor si no existe y instalar dependencias
RUN mkdir -p vendor && \
    if [ ! -f vendor/autoload.php ]; then \
        composer install --no-dev --optimize-autoloader --no-interaction --no-progress; \
    fi

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Script de entrada personalizado
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["php-fpm"]