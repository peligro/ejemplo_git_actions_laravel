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

# Configurar la zona horaria
RUN ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Instalar extensiones de PHP
RUN docker-php-ext-configure ldap --with-libdir=/lib/x86_64-linux-gnu && \
    docker-php-ext-install pdo_mysql mbstring zip gd pgsql pdo_pgsql && \
    docker-php-ext-enable pgsql pdo_pgsql

# Instalar Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# ✅ Copiar php.ini desde la ruta correcta
COPY docker/app/php.ini /usr/local/etc/php/

# ✅ Copiar supervisor.conf desde la ruta correcta
COPY docker/app/supervisor/supervisor.conf /etc/supervisor/supervisord.conf

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar solo los archivos de Composer desde laravel/
COPY laravel/composer.json laravel/composer.lock ./

# Instalar dependencias
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-autoloader

# Copiar el resto del código desde laravel/
COPY laravel/. .

# Generar autoloader
RUN composer dump-autoload --optimize

# Asegurar permisos
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 775 storage bootstrap/cache

# Cambiar a usuario www-data
USER www-data

CMD ["php-fpm"]