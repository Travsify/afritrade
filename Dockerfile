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

# --- CRITICAL PERMANENT FIX: Environment Cleanup ---
# Forcefully remove all environment files and cached config
RUN rm -rf /var/www/.env* /var/www/bootstrap/cache/*.php

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Nginx config
COPY nginx.conf /etc/nginx/sites-available/default
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
RUN rm -rf /etc/nginx/conf.d/*

# Permissions
RUN chown -R www-data:www-data /var/www && \
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Diagnostic file
RUN echo "<?php echo 'PHP-FPM is seeing: ' . __FILE__; phpinfo(); ?>" > /var/www/public/test-php.php

EXPOSE 80

# Improved Startup script with explicit cache clearing and environment dumping
RUN echo "#!/bin/sh\necho \"--- BOOT DIAGNOSTICS ---\"\necho \"Checking for .env file:\"\nls -la /var/www/.env 2>&1\necho \"Checking DB_CONNECTION env var: \$DB_CONNECTION\"\necho \"Clearing Laravel caches...\"\nphp artisan config:clear\nphp artisan cache:clear\necho \"--- STARTING SERVICES ---\"\nphp-fpm -D\nnginx -g 'daemon off;'" > /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
