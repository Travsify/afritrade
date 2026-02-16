FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev \
    nginx \
    procps

# Install PHP extensions
RUN docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy backend code
COPY backend_laravel /var/www

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Nginx config
COPY nginx.conf /etc/nginx/sites-available/default
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
RUN rm -rf /etc/nginx/conf.d/*

# Permissions
RUN chown -R www-data:www-data /var/www && \
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Test file
RUN echo "<?php echo 'PHP-FPM is seeing: ' . __FILE__; phpinfo(); ?>" > /var/www/public/test-php.php

EXPOSE 80

# Improved startup script with log tailing
RUN echo "#!/bin/sh\necho \"--- DIAGNOSTICS ---\"\nls -la /var/www/public\ntouch /var/www/storage/logs/laravel.log\nchown www-data:www-data /var/www/storage/logs/laravel.log\ntail -f /var/www/storage/logs/laravel.log &\necho \"--- STARTING ---\"\nphp-fpm -D\nnginx -g 'daemon off;'" > /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
