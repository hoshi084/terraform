const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

const useDatabase = process.env.DATABASE_URL !== undefined;
let pool;
if (useDatabase) {
  pool = new Pool({ connectionString: process.env.DATABASE_URL });
}

let memProducts = [
  { id: 1, name: 'Laptop Pro', description: 'Ordinateur portable haute performance', price: 1299.99, stock: 50, created_at: new Date() },
  { id: 2, name: 'Souris ergonomique', description: 'Souris sans fil ergonomique', price: 49.99, stock: 200, created_at: new Date() },
  { id: 3, name: 'Clavier mécanique', description: 'Clavier mécanique RGB', price: 89.99, stock: 150, created_at: new Date() },
];
let nextId = 4;

async function initDb() {
  if (!useDatabase) return;
  await pool.query(`
    CREATE TABLE IF NOT EXISTS products (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      description TEXT,
      price DECIMAL(10,2) NOT NULL,
      stock INTEGER DEFAULT 0,
      created_at TIMESTAMP DEFAULT NOW()
    )
  `);
  console.log('Table products créée');
}

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'product-service' });
});

app.get('/products', async (req, res) => {
  try {
    if (useDatabase) {
      const { rows } = await pool.query('SELECT * FROM products ORDER BY id');
      return res.json(rows);
    }
    res.json(memProducts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/products/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  try {
    if (useDatabase) {
      const { rows } = await pool.query('SELECT * FROM products WHERE id = $1', [id]);
      if (!rows.length) return res.status(404).json({ error: 'Produit introuvable' });
      return res.json(rows[0]);
    }
    const product = memProducts.find(p => p.id === id);
    if (!product) return res.status(404).json({ error: 'Produit introuvable' });
    res.json(product);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/products', async (req, res) => {
  const { name, description, price, stock } = req.body;
  if (!name || price === undefined) return res.status(400).json({ error: 'name et price requis' });
  try {
    if (useDatabase) {
      const { rows } = await pool.query(
        'INSERT INTO products (name, description, price, stock) VALUES ($1, $2, $3, $4) RETURNING *',
        [name, description || '', price, stock || 0]
      );
      return res.status(201).json(rows[0]);
    }
    const product = { id: nextId++, name, description: description || '', price, stock: stock || 0, created_at: new Date() };
    memProducts.push(product);
    res.status(201).json(product);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.patch('/products/:id/stock', async (req, res) => {
  const id = parseInt(req.params.id);
  const { quantity } = req.body;
  if (quantity === undefined) return res.status(400).json({ error: 'quantity requis' });
  try {
    if (useDatabase) {
      const { rows } = await pool.query(
        'UPDATE products SET stock = stock + $1 WHERE id = $2 RETURNING *',
        [quantity, id]
      );
      if (!rows.length) return res.status(404).json({ error: 'Produit introuvable' });
      return res.json(rows[0]);
    }
    const product = memProducts.find(p => p.id === id);
    if (!product) return res.status(404).json({ error: 'Produit introuvable' });
    product.stock += quantity;
    res.json(product);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/products/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  try {
    if (useDatabase) {
      await pool.query('DELETE FROM products WHERE id = $1', [id]);
      return res.status(204).send();
    }
    memProducts = memProducts.filter(p => p.id !== id);
    res.status(204).send();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3002;
app.listen(PORT, async () => {
  await initDb();
  console.log(`product-service démarré sur le port ${PORT}`);
});
