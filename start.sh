#!/bin/sh
set -e

echo "=== AFRITRAD PRODUCTION BOOT ==="

# Step 1: Generate .env from Render environment variables
cat > /var/www/.env << ENVFILE
APP_NAME=Afritrad
APP_ENV=${APP_ENV:-production}
APP_KEY=${APP_KEY:-base64:uXKB0w8Ce1VPMDOPqIv/j/864HJNxTy/JB2Tkm29Cio=}
APP_DEBUG=${APP_DEBUG:-false}
APP_URL=${APP_URL:-https://afritrade.onrender.com}

LOG_CHANNEL=${LOG_CHANNEL:-stderr}
LOG_LEVEL=${LOG_LEVEL:-warning}

DB_CONNECTION=pgsql
DATABASE_URL=${DATABASE_URL}
DB_URL=${DB_URL:-$DATABASE_URL}
DB_SSLMODE=${DB_SSLMODE:-prefer}

SESSION_DRIVER=file
CACHE_STORE=file
QUEUE_CONNECTION=sync
FILESYSTEM_DISK=local

FLUTTERWAVE_SECRET_KEY=${FLUTTERWAVE_SECRET_KEY:-}
FLUTTERWAVE_PUBLIC_KEY=${FLUTTERWAVE_PUBLIC_KEY:-}
FLUTTERWAVE_WEBHOOK_HASH=${FLUTTERWAVE_WEBHOOK_HASH:-}
FIREBASE_SERVER_KEY=${FIREBASE_SERVER_KEY:-}
FINCRA_BUSINESS_ID=${FINCRA_BUSINESS_ID:-}
FINCRA_SECRET_KEY=${FINCRA_SECRET_KEY:-}
ENVFILE

echo "Generated .env file with DB_CONNECTION=pgsql"

# Step 2: Set permissions
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Step 3: Clear stale caches
cd /var/www
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

echo "=== RUNNING MIGRATIONS ==="
php artisan migrate --force

echo "=== SEEDING DEFAULT SYSTEM DATA ==="
php artisan db:seed --force

# Step 4: Create storage symlink for public file access
php artisan storage:link --force 2>/dev/null || true

# Step 5: Build production caches for performance
echo "=== BUILDING PRODUCTION CACHES ==="
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "=== CONFIG VERIFICATION ==="
php artisan tinker --execute="echo 'DB Connection: ' . config('database.default') . PHP_EOL . 'DB URL set: ' . (config('database.connections.pgsql.url') ? 'YES' : 'NO');"
echo "=== STARTING SERVICES ==="

# Step 6: Start PHP-FPM and Nginx
php-fpm -D
nginx -g 'daemon off;'
