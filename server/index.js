const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const { OAuth2Client } = require('google-auth-library');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

const port = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'your_secret_key_at_least_20_chars_long_12345';
const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID;

const client = new OAuth2Client(GOOGLE_CLIENT_ID);

// Database Connection
const db = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'genshin_import'
});

// Middleware: Authenticate Token
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.status(401).json({ message: 'No token provided' });

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ message: 'Invalid or expired token' });
        req.user = user;
        next();
    });
};

// Middleware: Admin only
const isAdmin = (req, res, next) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Admin access required' });
    }
    next();
};

// --- AUTH ENDPOINTS ---

// Local Register
app.post('/auth/register', async (req, res) => {
    const { username, email, password } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        await db.execute('INSERT INTO users (username, email, password) VALUES (?, ?, ?)', [username, email, hashedPassword]);
        res.status(201).json({ message: 'User registered' });
    } catch (error) {
        res.status(500).json({ message: 'Registration failed', error: error.message });
    }
});

// Local Login
app.post('/auth/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        const user = users[0];
        if (!user || !(await bcrypt.compare(password, user.password))) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }
        const token = jwt.sign({ id: user.id, role: user.role, email: user.email }, JWT_SECRET, { expiresIn: '1h' });
        res.json({ token, user: { id: user.id, username: user.username, role: user.role } });
    } catch (error) {
        res.status(500).json({ message: 'Login failed', error: error.message });
    }
});

// Google OAuth Login
app.post('/auth/google', async (req, res) => {
    const { idToken } = req.body;
    try {
        const ticket = await client.verifyIdToken({
            idToken,
            audience: GOOGLE_CLIENT_ID,
        });
        const payload = ticket.getPayload();
        const { sub: external_id, email, name: username } = payload;

        let [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        let user = users[0];
        
        if (!user) {
            await db.execute('INSERT INTO users (username, email, external_id) VALUES (?, ?, ?)', [username, email, external_id]);
            [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
            user = users[0];
        } else if (!user.external_id) {
            // Link account if it was previously local but now using Google
            await db.execute('UPDATE users SET external_id = ? WHERE id = ?', [external_id, user.id]);
        }

        const token = jwt.sign({ id: user.id, role: user.role, email: user.email }, JWT_SECRET, { expiresIn: '1h' });
        res.json({ token, user: { id: user.id, username: user.username, role: user.role } });
    } catch (error) {
        console.error('Google OAuth error:', error);
        res.status(500).json({ message: 'OAuth failed', error: error.message });
    }
});

// --- WEAPON ENDPOINTS ---

// Retrieve all weapons (GET 1)
app.get('/weapons', async (req, res) => {
    try {
        const [weapons] = await db.execute('SELECT * FROM weapons');
        res.json(weapons);
    } catch (error) {
        res.status(500).json({ message: 'Failed to fetch weapons' });
    }
});

// Retrieve specific weapon (GET 2)
app.get('/weapons/:id', async (req, res) => {
    try {
        const [weapons] = await db.execute('SELECT * FROM weapons WHERE id = ?', [req.params.id]);
        if (weapons.length === 0) return res.status(404).json({ message: 'Weapon not found' });
        res.json(weapons[0]);
    } catch (error) {
        res.status(500).json({ message: 'Failed to fetch weapon' });
    }
});

// Create weapon (Admin - POST)
app.post('/weapons', authenticateToken, isAdmin, async (req, res) => {
    const { name, type, description, stock, image, price } = req.body;
    try {
        await db.execute('INSERT INTO weapons (name, type, description, stock, image, price) VALUES (?, ?, ?, ?, ?, ?)', 
            [name, type, description, stock, image, price]);
        res.status(201).json({ message: 'Weapon created' });
    } catch (error) {
        res.status(500).json({ message: 'Failed to create weapon' });
    }
});

// Update weapon (Admin - PUT)
app.put('/weapons/:id', authenticateToken, isAdmin, async (req, res) => {
    const { name, type, description, stock, image, price } = req.body;
    try {
        await db.execute('UPDATE weapons SET name=?, type=?, description=?, stock=?, image=?, price=? WHERE id=?', 
            [name, type, description, stock, image, price, req.params.id]);
        res.json({ message: 'Weapon updated' });
    } catch (error) {
        res.status(500).json({ message: 'Failed to update weapon' });
    }
});

// Delete weapon (Admin - DELETE)
app.delete('/weapons/:id', authenticateToken, isAdmin, async (req, res) => {
    try {
        await db.execute('DELETE FROM weapons WHERE id = ?', [req.params.id]);
        res.json({ message: 'Weapon deleted' });
    } catch (error) {
        res.status(500).json({ message: 'Failed to delete weapon' });
    }
});

// --- TRANSACTION ENDPOINTS ---

// Buy weapons (User - POST)
app.post('/buy', authenticateToken, async (req, res) => {
    const { items } = req.body; // Array of { weapon_id, quantity }
    const userId = req.user.id;
    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();
        let total = 0;
        const [transaction] = await connection.execute('INSERT INTO transactions (user_id, total_price) VALUES (?, 0)', [userId]);
        const transactionId = transaction.insertId;

        for (const item of items) {
            const [weaponRows] = await connection.execute('SELECT * FROM weapons WHERE id = ? FOR UPDATE', [item.weapon_id]);
            const weapon = weaponRows[0];
            if (!weapon || weapon.stock < item.quantity) {
                throw new Error(`Insufficient stock for weapon: ${weapon?.name || 'Unknown'}`);
            }
            const itemTotal = weapon.price * item.quantity;
            total += itemTotal;
            await connection.execute('INSERT INTO transaction_items (transaction_id, weapon_id, quantity, price_at_time) VALUES (?, ?, ?, ?)', 
                [transactionId, item.weapon_id, item.quantity, weapon.price]);
            await connection.execute('UPDATE weapons SET stock = stock - ? WHERE id = ?', [item.quantity, item.weapon_id]);
        }

        await connection.execute('UPDATE transactions SET total_price = ? WHERE id = ?', [total, transactionId]);
        await connection.commit();
        res.json({ message: 'Purchase successful', transactionId });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ message: error.message });
    } finally {
        connection.release();
    }
});

app.listen(port, () => console.log(`Server running on port ${port}`));
