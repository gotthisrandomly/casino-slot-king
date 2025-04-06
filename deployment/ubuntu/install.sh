#!/bin/bash

# Casino Slot King - Ubuntu Deployment Script
# This script installs and configures the Casino Slot King application on Ubuntu

# Variables
APP_DIR="/opt/casino-slot-king"
MYSQL_ROOT_PASSWORD="$(openssl rand -base64 16)"
MYSQL_USER="slotking"
MYSQL_PASSWORD="$(openssl rand -base64 16)"
MYSQL_DATABASE="slotking_db"
NODE_VERSION="20.x"

# Print colored messages
print_message() {
  echo -e "\e[1;34m>>> $1\e[0m"
}

print_error() {
  echo -e "\e[1;31m!!! $1\e[0m"
}

print_success() {
  echo -e "\e[1;32m✓ $1\e[0m"
}

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
  print_error "This script must be run as root or with sudo"
  exit 1
fi

# Update system
print_message "Updating system packages..."
apt-get update && apt-get upgrade -y
print_success "System updated"

# Install required dependencies
print_message "Installing dependencies..."
apt-get install -y curl wget git build-essential npm nginx

# Install Node.js
print_message "Installing Node.js $NODE_VERSION..."
curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash -
apt-get install -y nodejs
npm install -g pm2 pnpm

# Install MySQL
print_message "Installing MySQL..."
apt-get install -y mysql-server

# Configure MySQL
print_message "Configuring MySQL..."
# Secure the MySQL installation
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "FLUSH PRIVILEGES;"

# Create database and user
mysql -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

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
SECRET_KEY=$(openssl rand -base64 32)

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
cat > /etc/nginx/sites-available/casino-slot-king << 'EOFNGINX'
server {
    listen 80;
    server_name _;

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
ln -sf /etc/nginx/sites-available/casino-slot-king /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Check Nginx config
nginx -t

# Restart Nginx
systemctl restart nginx

# Configure firewall
print_message "Configuring firewall..."
ufw allow 'Nginx Full'
ufw allow ssh

print_success "Installation complete!"
print_message "MySQL Root Password: ${MYSQL_ROOT_PASSWORD}"
print_message "MySQL User: ${MYSQL_USER}"
print_message "MySQL Password: ${MYSQL_PASSWORD}"
print_message "MySQL Database: ${MYSQL_DATABASE}"
print_message "Please save these credentials securely."
print_message "Your Casino Slot King application is now running at http://YOUR_SERVER_IP"
print_message "You should complete the following manual steps:"
print_message "1. Set up SSL/TLS with Certbot: sudo certbot --nginx"
print_message "2. Update Stripe API keys in ${APP_DIR}/.env"
