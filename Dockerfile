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

# Copiar configuración personalizada de php.ini
COPY php.ini /usr/local/etc/php/

# Copiar configuración de Supervisor
COPY supervisor/supervisor.conf /etc/supervisor/supervisord.conf

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar composer.json y composer.lock primero (para cachear dependencias)
COPY composer.json composer.lock ./

# Instalar dependencias PHP
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-progress

# Copiar el resto del código
COPY --chown=www-data:www-data . .

# Copiar y hacer ejecutable entrypoint.sh
COPY --chown=www-data:www-data entrypoint.sh /var/www/html/entrypoint.sh
RUN chmod +x /var/www/html/entrypoint.sh

# Cambiar a usuario www-data
USER www-data

# Entrypoint
ENTRYPOINT ["./entrypoint.sh"]