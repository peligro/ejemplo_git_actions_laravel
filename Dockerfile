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

# Copiar configuración personalizada de php.ini
COPY php.ini /usr/local/etc/php/

# Copiar configuración de Supervisor
COPY supervisor/supervisor.conf /etc/supervisor/supervisord.conf

# Directorio de trabajo
WORKDIR /var/www/html

# Copiar composer.json y composer.lock
COPY composer.json composer.lock ./

# Instalar dependencias
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-autoloader

# Copiar TODO el código (pero .dockerignore evita sobrescribir vendor/)
COPY . ./

# Regenerar autoloader
RUN composer dump-autoload --optimize

# Permisos
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 775 storage bootstrap/cache

# Cambiar a usuario www-data
USER www-data



# Instalar gosu
RUN set -ex && \
    fetchDeps='ca-certificates wget' && \
    apt-get update && apt-get install -y $fetchDeps --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.16/gosu-$dpkgArch" && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.16/gosu-$dpkgArch.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    gpgconf --kill all && \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    apt-get purge -y --auto-remove $fetchDeps

# Copiar entrypoint
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Ejecutar como root para que el entrypoint pueda usar chown
USER root

# Definir entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# CMD (se pasará al entrypoint)
CMD ["php-fpm"]