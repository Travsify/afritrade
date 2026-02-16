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

# Copy Nginx configuration - put it in conf.d for simplicity
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Remove the default Debian Nginx config if it exists
RUN rm -f /etc/nginx/sites-enabled/default

# Set permissions for everything
RUN chown -R www-data:www-data /var/www

# Create a test file to verify PHP is working
RUN echo "<?php phpinfo(); ?>" > /var/www/public/test-php.php

# Expose port
EXPOSE 80

# Improved startup script with diagnostics
RUN echo "#!/bin/sh\necho \"--- File Structure ---\"\nls -R /var/www/public | head -n 20\necho \"--- Starting Services ---\"\nphp-fpm -D\nnginx -g 'daemon off;'" > /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
