-- MySQL Database Schema for Casino Slot King

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(36) PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  salt VARCHAR(36) NOT NULL,
  balance DECIMAL(15, 2) DEFAULT 0.00,
  role ENUM('user', 'admin') DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login TIMESTAMP NULL
);

-- Game Sessions Table
CREATE TABLE IF NOT EXISTS game_sessions (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  game_id VARCHAR(36) NOT NULL,
  server_seed VARCHAR(64) NOT NULL,
  client_seed VARCHAR(64) NOT NULL,
  server_seed_hash VARCHAR(64) NOT NULL,
  nonce BIGINT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ended_at TIMESTAMP NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Game Spins Table
CREATE TABLE IF NOT EXISTS game_spins (
  id VARCHAR(36) PRIMARY KEY,
  session_id VARCHAR(36) NOT NULL,
  user_id VARCHAR(36) NOT NULL,
  game_id VARCHAR(36) NOT NULL, 
  bet_amount DECIMAL(15, 2) NOT NULL,
  win_amount DECIMAL(15, 2) NOT NULL,
  multiplier DECIMAL(10, 2) NOT NULL,
  result JSON NOT NULL,
  verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (session_id) REFERENCES game_sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Transactions Table
CREATE TABLE IF NOT EXISTS transactions (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  type ENUM('deposit', 'withdrawal', 'bet', 'win', 'bonus') NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'USD',
  status ENUM('pending', 'completed', 'failed', 'canceled') DEFAULT 'pending',
  payment_method VARCHAR(50) NULL,
  payment_id VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Leaderboard Table
CREATE TABLE IF NOT EXISTS leaderboard (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  username VARCHAR(50) NOT NULL,
  game_id VARCHAR(36) NULL,
  total_bets INT DEFAULT 0,
  total_wins INT DEFAULT 0,
  total_bet_amount DECIMAL(15, 2) DEFAULT 0.00,
  total_win_amount DECIMAL(15, 2) DEFAULT 0.00,
  largest_win DECIMAL(15, 2) DEFAULT 0.00,
  period ENUM('daily', 'weekly', 'monthly', 'all-time') NOT NULL,
  period_start TIMESTAMP NOT NULL,
  period_end TIMESTAMP NOT NULL,
  rank INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Game Configurations Table
CREATE TABLE IF NOT EXISTS game_configs (
  id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  type VARCHAR(50) NOT NULL,
  config JSON NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  min_bet DECIMAL(15, 2) NOT NULL,
  max_bet DECIMAL(15, 2) NOT NULL,
  rtp DECIMAL(5, 2) NOT NULL,
  volatility VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Settings Table
CREATE TABLE IF NOT EXISTS settings (
  id VARCHAR(36) PRIMARY KEY,
  category VARCHAR(50) NOT NULL,
  key_name VARCHAR(100) NOT NULL,
  value TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY category_key_name (category, key_name)
);
