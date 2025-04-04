import { query } from '../../../db/mysql-adapter';
import { v4 as uuidv4 } from 'uuid';
import { User, GameSession, Spin, LeaderboardEntry, Transaction } from '@/types';
import { generateHashedPassword, verifyPassword } from '../auth-utils';

export class MySQLDatabase {
  // User Methods
  async createUser(username: string, email: string, password: string, isAdmin = false): Promise<User> {
    const { hash, salt } = generateHashedPassword(password);
    const userId = uuidv4();
    const role = isAdmin ? 'admin' : 'user';
    
    await query(
      `INSERT INTO users (id, username, email, password_hash, salt, role)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [userId, username, email, hash, salt, role]
    );
    
    return {
      id: userId,
      username,
      email,
      balance: 0,
      role,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
  }
  
  async getUserById(userId: string): Promise<User | null> {
    const users = await query<User[]>(
      `SELECT id, username, email, balance, role, created_at as createdAt, updated_at as updatedAt
       FROM users WHERE id = ?`,
      [userId]
    );
    
    return users.length > 0 ? users[0] : null;
  }
  
  async getUserByEmail(email: string): Promise<User | null> {
    const users = await query<User[]>(
      `SELECT id, username, email, balance, role, created_at as createdAt, updated_at as updatedAt
       FROM users WHERE email = ?`,
      [email]
    );
    
    return users.length > 0 ? users[0] : null;
  }
  
  async authenticateUser(email: string, password: string): Promise<User | null> {
    const users = await query<any[]>(
      `SELECT id, username, email, password_hash, salt, balance, role, created_at as createdAt, updated_at as updatedAt
       FROM users WHERE email = ?`,
      [email]
    );
    
    if (users.length === 0) return null;
    
    const user = users[0];
    const isValid = verifyPassword(password, user.password_hash, user.salt);
    
    if (!isValid) return null;
    
    // Update last login
    await query(
      `UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?`,
      [user.id]
    );
    
    // Return user without password
    const { password_hash, salt, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }
  
  async updateUserBalance(userId: string, amount: number): Promise<User> {
    await query(
      `UPDATE users SET balance = balance + ? WHERE id = ?`,
      [amount, userId]
    );
    
    const users = await query<User[]>(
      `SELECT id, username, email, balance, role, created_at as createdAt, updated_at as updatedAt
       FROM users WHERE id = ?`,
      [userId]
    );
    
    if (users.length === 0) {
      throw new Error(`User not found: ${userId}`);
    }
    
    return users[0];
  }
  
  // Game Session Methods
  async createGameSession(userId: string, gameId: string, serverSeed: string, clientSeed: string, serverSeedHash: string): Promise<GameSession> {
    const sessionId = uuidv4();
    
    await query(
      `INSERT INTO game_sessions (id, user_id, game_id, server_seed, client_seed, server_seed_hash)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [sessionId, userId, gameId, serverSeed, clientSeed, serverSeedHash]
    );
    
    return {
      id: sessionId,
      userId,
      gameId,
      serverSeed,
      clientSeed,
      serverSeedHash,
      nonce: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
  }
  
  async getGameSession(sessionId: string): Promise<GameSession | null> {
    const sessions = await query<GameSession[]>(
      `SELECT id, user_id as userId, game_id as gameId, server_seed as serverSeed, 
              client_seed as clientSeed, server_seed_hash as serverSeedHash, nonce, 
              created_at as createdAt, updated_at as updatedAt, ended_at as endedAt
       FROM game_sessions WHERE id = ?`,
      [sessionId]
    );
    
    return sessions.length > 0 ? sessions[0] : null;
  }
  
  async getUserGameSessions(userId: string): Promise<GameSession[]> {
    return await query<GameSession[]>(
      `SELECT id, user_id as userId, game_id as gameId, server_seed as serverSeed, 
              client_seed as clientSeed, server_seed_hash as serverSeedHash, nonce, 
              created_at as createdAt, updated_at as updatedAt, ended_at as endedAt
       FROM game_sessions WHERE user_id = ? ORDER BY created_at DESC`,
      [userId]
    );
  }
  
  async incrementSessionNonce(sessionId: string): Promise<number> {
    await query(
      `UPDATE game_sessions SET nonce = nonce + 1 WHERE id = ?`,
      [sessionId]
    );
    
    const sessions = await query<any[]>(
      `SELECT nonce FROM game_sessions WHERE id = ?`,
      [sessionId]
    );
    
    if (sessions.length === 0) {
      throw new Error(`Session not found: ${sessionId}`);
    }
    
    return sessions[0].nonce;
  }
  
  // Game Spin Methods
  async recordSpin(
    sessionId: string, 
    userId: string, 
    gameId: string, 
    betAmount: number, 
    winAmount: number, 
    multiplier: number, 
    result: any
  ): Promise<Spin> {
    const spinId = uuidv4();
    
    await query(
      `INSERT INTO game_spins 
       (id, session_id, user_id, game_id^
22",
    "@types/react": "
^
19",
    "@types/react-dom": "
^
19",
    "@types/bcrypt": "latest",
    "@types/jsonwebtoken": "latest",
    "@types/cookie": "latest",
    "postcss": "
^
8",
    "tailwindcss": "
^
3.4.17",
    "typescript": "
^
5",
    "autoprefixer": "latest"
  }
}
