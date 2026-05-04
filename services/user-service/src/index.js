const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

// Connexion PostgreSQL — en local on utilise un fallback en mémoire
const useDatabase = process.env.DATABASE_URL !== undefined;

let pool;
if (useDatabase) {
  pool = new Pool({ connectionString: process.env.DATABASE_URL });
}

// --- Fallback in-memory pour le dev local sans BDD ---
let memUsers = [
  { id: 1, name: 'Alice Dupont', email: 'alice@example.com', created_at: new Date() },
  { id: 2, name: 'Bob Martin', email: 'bob@example.com', created_at: new Date() },
];
let nextId = 3;

// --- Initialisation de la table (production) ---
async function initDb() {
  if (!useDatabase) return;
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      created_at TIMESTAMP DEFAULT NOW()
    )
  `);
  console.log('Table users créée');
}

// --- Routes ---

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'user-service' });
});

app.get('/users', async (req, res) => {
  try {
    if (useDatabase) {
      const { rows } = await pool.query('SELECT * FROM users ORDER BY id');
      return res.json(rows);
    }
    res.json(memUsers);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/users/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  try {
    if (useDatabase) {
      const { rows } = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
      if (!rows.length) return res.status(404).json({ error: 'Utilisateur introuvable' });
      return res.json(rows[0]);
    }
    const user = memUsers.find(u => u.id === id);
    if (!user) return res.status(404).json({ error: 'Utilisateur introuvable' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/users', async (req, res) => {
  const { name, email } = req.body;
  if (!name || !email) return res.status(400).json({ error: 'name et email requis' });
  try {
    if (useDatabase) {
      const { rows } = await pool.query(
        'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
        [name, email]
      );
      return res.status(201).json(rows[0]);
    }
    const user = { id: nextId++, name, email, created_at: new Date() };
    memUsers.push(user);
    res.status(201).json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/users/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  try {
    if (useDatabase) {
      await pool.query('DELETE FROM users WHERE id = $1', [id]);
      return res.status(204).send();
    }
    memUsers = memUsers.filter(u => u.id !== id);
    res.status(204).send();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, async () => {
  await initDb();
  console.log(`user-service démarré sur le port ${PORT}`);
});
