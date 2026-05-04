const express = require('express');
const cors = require('cors');
const axios = require('axios');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

// URLs des autres services (injectées via variables d'environnement)
const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://localhost:3001';
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://localhost:3002';

const useDatabase = process.env.DATABASE_URL !== undefined;
let pool;
if (useDatabase) {
  pool = new Pool({ connectionString: process.env.DATABASE_URL });
}

let memOrders = [
  {
    id: 1,
    user_id: 1,
    items: [{ product_id: 1, quantity: 1, unit_price: 1299.99 }],
    total: 1299.99,
    status: 'completed',
    created_at: new Date(),
  },
];
let nextId = 2;

async function initDb() {
  if (!useDatabase) return;
  await pool.query(`
    CREATE TABLE IF NOT EXISTS orders (
      id SERIAL PRIMARY KEY,
      user_id INTEGER NOT NULL,
      total DECIMAL(10,2) NOT NULL,
      status VARCHAR(50) DEFAULT 'pending',
      created_at TIMESTAMP DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS order_items (
      id SERIAL PRIMARY KEY,
      order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
      product_id INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      unit_price DECIMAL(10,2) NOT NULL
    );
  `);
  console.log('Tables orders et order_items créées');
}

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'order-service' });
});

app.get('/orders', async (req, res) => {
  try {
    if (useDatabase) {
      const { rows: orders } = await pool.query('SELECT * FROM orders ORDER BY id');
      for (const order of orders) {
        const { rows: items } = await pool.query(
          'SELECT * FROM order_items WHERE order_id = $1',
          [order.id]
        );
        order.items = items;
      }
      return res.json(orders);
    }
    res.json(memOrders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/orders/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  try {
    if (useDatabase) {
      const { rows } = await pool.query('SELECT * FROM orders WHERE id = $1', [id]);
      if (!rows.length) return res.status(404).json({ error: 'Commande introuvable' });
      const order = rows[0];
      const { rows: items } = await pool.query(
        'SELECT * FROM order_items WHERE order_id = $1',
        [id]
      );
      order.items = items;
      return res.json(order);
    }
    const order = memOrders.find(o => o.id === id);
    if (!order) return res.status(404).json({ error: 'Commande introuvable' });
    res.json(order);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /orders — vérifie que l'utilisateur et les produits existent
app.post('/orders', async (req, res) => {
  const { user_id, items } = req.body;
  if (!user_id || !items?.length) {
    return res.status(400).json({ error: 'user_id et items[] requis' });
  }

  try {
    // Vérification de l'utilisateur via user-service
    await axios.get(`${USER_SERVICE_URL}/users/${user_id}`);

    // Calcul du total via product-service
    let total = 0;
    const enrichedItems = [];
    for (const item of items) {
      const { data: product } = await axios.get(
        `${PRODUCT_SERVICE_URL}/products/${item.product_id}`
      );
      const unit_price = parseFloat(product.price);
      total += unit_price * item.quantity;
      enrichedItems.push({ product_id: item.product_id, quantity: item.quantity, unit_price });
    }

    if (useDatabase) {
      const { rows } = await pool.query(
        'INSERT INTO orders (user_id, total, status) VALUES ($1, $2, $3) RETURNING *',
        [user_id, total, 'pending']
      );
      const order = rows[0];
      for (const item of enrichedItems) {
        await pool.query(
          'INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES ($1, $2, $3, $4)',
          [order.id, item.product_id, item.quantity, item.unit_price]
        );
      }
      order.items = enrichedItems;
      return res.status(201).json(order);
    }

    const order = { id: nextId++, user_id, items: enrichedItems, total, status: 'pending', created_at: new Date() };
    memOrders.push(order);
    res.status(201).json(order);
  } catch (err) {
    if (err.response?.status === 404) {
      return res.status(404).json({ error: 'Utilisateur ou produit introuvable' });
    }
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3003;
app.listen(PORT, async () => {
  await initDb();
  console.log(`order-service démarré sur le port ${PORT}`);
});
