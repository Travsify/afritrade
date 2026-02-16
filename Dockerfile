# Base stage for PHP dependencies
FROM php:8.2-fpm as backend-builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

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

# --- Final image ---
FROM php:8.2-fpm

# Install nginx and PostgreSQL client extensions
RUN apt-get update && apt-get install -y nginx libpq-dev procps && \
    docker-php-ext-install pdo_pgsql && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www

# Copy files from builder stage
COPY --from=backend-builder /var/www /var/www

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/sites-available/default

# Set permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Create a test file to verify PHP is working
RUN echo "<?php phpinfo(); ?>" > /var/www/public/test-php.php

# Expose port
EXPOSE 80

# Use a shell script to start processes and handle logs
RUN echo "#!/bin/sh\nphp-fpm -D\nnginx -g 'daemon off;'" > /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
