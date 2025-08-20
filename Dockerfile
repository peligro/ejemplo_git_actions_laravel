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

# Instalar extensiones de PHP
RUN docker-php-ext-configure ldap --with-libdir=/lib/x86_64-linux-gnu && \
    docker-php-ext-install pdo_mysql mbstring zip gd pgsql pdo_pgsql && \
    docker-php-ext-enable pgsql pdo_pgsql

# Instalar Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Copiar php.ini
COPY php.ini /usr/local/etc/php/

# Copiar supervisor
COPY supervisor/supervisor.conf /etc/supervisor/supervisord.conf

# Directorio de trabajo
WORKDIR /var/www/html

# Copiar código (sin entrypoint.sh)
COPY . .

# Permisos
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 storage bootstrap/cache

# No hay ENTRYPOINT ni CMD extra
# Usa el comando por defecto de php:8.4-fpm