# Casino Slot King

A full-stack, self-hosted online casino web application with provably fair slot machine games.

## Features

- **Provably Fair Games**: Verifiable random outcomes for slot machine games
- **User Management**: Account creation, authentication, and profile management
- **Real Money Transactions**: Deposit and withdraw using integrated payment systems
- **Admin Dashboard**: Complete control over all aspects of the casino
- **Responsive UI**: Works on all devices from mobile to desktop
- **Multiple Deployment Options**: Self-host on Android 14 or Ubuntu Linux

## Technology Stack

- **Frontend**: React, TypeScript, Next.js, Tailwind CSS
- **Backend**: Next.js API routes
- **Database**: MySQL
- **Payment Processing**: Stripe integration
- **Authentication**: JWT-based authentication system

## Getting Started

### Prerequisites

- Node.js 18+ and npm/pnpm
- MySQL server
- Git

### Installation

#### Ubuntu Server

```bash
sudo bash deployment/ubuntu/install.sh
```

#### Android 14 (via Termux)

1. Install Termux from F-Droid
2. Run the installer:

```bash
bash deployment/android/install.sh
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/casino-slot-king.git
cd casino-slot-king
```

2. Install dependencies:
```bash
pnpm install
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration details
```

4. Run database migrations:
```bash
node -e "require('./db/mysql-adapter').runMigrations()"
```

5. Build and start the application:
```bash
pnpm build
pnpm start
```

## Usage

### Player Interface

- Visit `http://your-server-ip` to access the casino
- Create an account or login
- Deposit funds via the wallet page
- Play games in the play section
- Withdraw winnings

### Admin Interface

- Access admin dashboard at `http://your-server-ip/admin`
- Login with admin credentials
- Manage users, games, transactions, and settings

## Security

- All passwords are hashed with a per-user salt
- Game results use a provably fair algorithm
- Financial transactions are secured with industry-standard protocols
- Regular security updates recommended
