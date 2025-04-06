#!/bin/bash

# Casino Slot King - Android 14 Deployment Script
# This script sets up the Casino Slot King application on Android 14 via Termux

# Variables
APP_DIR="/data/data/com.termux/files/home/casino-slot-king"
NODE_VERSION="20.x"

# Print colored messages
print_message() {
  echo -e "\033[1;34m>>> $1\033[0m"
}

print_error() {
  echo -e "\033[1;31m!!! $1\033[0m"
}

print_success() {
  echo -e "\033[1;32m✓ $1\033[0m"
}

# Check if running on Android
if [ ! -d "/data/data/com.termux" ]; then
  print_error "This script must be run on Android in Termux"
  exit 1
fi

# Update system
print_message "Updating Termux packages..."
pkg update && pkg upgrade -y
print_success "System updated"

# Install required dependencies
print_message "Installing dependencies..."
pkg install -y curl wget git nodejs-lts openssh mariadb nginx

# Install Node package manager
print_message "Installing pnpm and PM2..."
npm install -g pm2 pnpm

# Start and configure MariaDB (MySQL)
print_message "Setting up MariaDB (MySQL)..."
termux-sudo svc -d termux-mariadbd
sleep 2
termux-sudo svc -u termux-mariadbd
sleep 5

# Generate passwords
MYSQL_ROOT_PASSWORD="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)"
MYSQL_USER="slotking"
MYSQL_PASSWORD="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)"
MYSQL_DATABASE="slotking_db"

# Configure MariaDB
mysql -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE ${MYSQL_DATABASE};
CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

# Clone application
print_message "Cloning application..."
mkdir -p ${APP_DIR}
git clone https://github.com/gotthisrandomly/casino-slot-king.git ${APP_DIR}
cd ${APP_DIR}

# Create environment file
print_message "Creating environment configuration..."
cat > ${APP_DIR}/.env << EOFENV
# Database Configuration
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=${MYSQL_USER}
MYSQL_PASSWORD=${MYSQL_PASSWORD}
MYSQL_DATABASE=${MYSQL_DATABASE}

# Application Configuration
NODE_ENV=production
PORT=3000
SECRET_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)

# Stripe Configuration
STRIPE_SECRET_KEY=your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
STRIPE_WEBHOOK_SECRET=your_stripe_webhook_secret
EOFENV

# Install dependencies
print_message "Installing application dependencies..."
cd ${APP_DIR}
pnpm install

# Run database migrations
print_message "Running database migrations..."
cd ${APP_DIR}
node -e "require('./db/mysql-adapter').runMigrations()"

# Build application
print_message "Building application..."
cd ${APP_DIR}
pnpm build

# Setup PM2 for process management
print_message "Configuring PM2 process manager..."
pm2 start npm --name "casino-slot-king" -- start
pm2 save
pm2 startup

# Configure Nginx
print_message "Configuring Nginx..."
mkdir -p $PREFIX/etc/nginx/sites-available
mkdir -p $PREFIX/etc/nginx/sites-enabled

cat > $PREFIX/etc/nginx/sites-available/casino-slot-king << 'EOFNGINX'
server {
    listen 8080;
    server_name localhost;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOFNGINX

# Enable site
ln -sf $PREFIX/etc/nginx/sites-available/casino-slot-king $PREFIX/etc/nginx/sites-enabled/

# Start Nginx
nginx -t
nginx

print_success "Installation complete!"
print_message "MySQL Root Password: ${MYSQL_ROOT_PASSWORD}"
print_message "MySQL User: ${MYSQL_USER}"
print_message "MySQL Password: ${MYSQL_PASSWORD}"
print_message "MySQL Database: ${MYSQL_DATABASE}"
print_message "Please save these credentials securely."
print_message "Your Casino Slot King application is now running at http://localhost:8080"
print_message "You should complete the following manual steps:"
print_message "1. Configure port forwarding on your device if you want to access from other devices"
print_message "2. Update Stripe API keys in ${APP_DIR}/.env"
