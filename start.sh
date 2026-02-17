#!/bin/sh
set -e

echo "=== AFRITRAD PRODUCTION BOOT ==="

# Step 1: Generate .env from Render environment variables
# This is THE critical step - it ensures Laravel's env() helper can see Render's vars
cat > /var/www/.env << ENVFILE
APP_NAME=Afritrad
APP_ENV=${APP_ENV:-production}
APP_KEY=${APP_KEY:-base64:uXKB0w8Ce1VPMDOPqIv/j/864HJNxTy/JB2Tkm29Cio=}
APP_DEBUG=${APP_DEBUG:-false}
APP_URL=${APP_URL:-https://afritrade.onrender.com}

LOG_CHANNEL=${LOG_CHANNEL:-stderr}
LOG_LEVEL=${LOG_LEVEL:-debug}

DB_CONNECTION=pgsql
DATABASE_URL=${DATABASE_URL}
DB_URL=${DB_URL:-$DATABASE_URL}
DB_SSLMODE=${DB_SSLMODE:-prefer}

SESSION_DRIVER=file
CACHE_STORE=file
QUEUE_CONNECTION=sync
FILESYSTEM_DISK=local
ENVFILE

echo "Generated .env file with DB_CONNECTION=pgsql"

# Step 2: Set permissions
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Step 3: Clear all caches and rebuild
cd /var/www
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

echo "=== RUNNING MIGRATIONS ==="
php artisan migrate --force

echo "=== SEEDING DEFAULT MARKUPS ==="
php artisan db:seed --class=ServiceMarkupSeeder --force

echo "=== CONFIG VERIFICATION ==="
php artisan tinker --execute="echo 'DB Connection: ' . config('database.default') . PHP_EOL . 'DB URL set: ' . (config('database.connections.pgsql.url') ? 'YES' : 'NO');"
echo "=== STARTING SERVICES ==="

# Step 4: Start PHP-FPM and Nginx
php-fpm -D
nginx -g 'daemon off;'
