const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');
const axios = require('axios');
const db = require('../config/db');
const { JWT_SECRET } = require('../middlewares/auth');

const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
const client = new OAuth2Client(GOOGLE_CLIENT_ID);

router.post('/register', async (req, res) => {
    const { username, email, password } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        await db.execute('INSERT INTO users (username, email, password) VALUES (?, ?, ?)', [username, email, hashedPassword]);
        res.status(201).json({ message: 'User registered' });
    } catch (error) {
        res.status(500).json({ message: 'Registration failed', error: error.message });
    }
});

router.post('/login', async (req, res) => {
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

router.post('/google', async (req, res) => {
    const { idToken, accessToken } = req.body;
    try {
        let external_id, email, username;

        if (idToken) {
            const ticket = await client.verifyIdToken({
                idToken,
                audience: GOOGLE_CLIENT_ID,
            });
            const payload = ticket.getPayload();
            external_id = payload.sub;
            email = payload.email;
            username = payload.name;
        } else if (accessToken) {
            const response = await axios.get('https://www.googleapis.com/oauth2/v3/userinfo', {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                },
            });
            const payload = response.data;
            external_id = payload.sub;
            email = payload.email;
            username = payload.name;
        } else {
            return res.status(400).json({ message: 'No token provided' });
        }

        if (!email) {
            return res.status(400).json({ message: 'Email not provided' });
        }

        let [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        let user = users[0];

        if (!user) {
            await db.execute('INSERT INTO users (username, email, external_id) VALUES (?, ?, ?)', [username, email, external_id]);
            [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
            user = users[0];
        } else if (!user.external_id) {
            await db.execute('UPDATE users SET external_id = ? WHERE id = ?', [external_id, user.id]);
        }

        const token = jwt.sign({ id: user.id, role: user.role, email: user.email }, JWT_SECRET, { expiresIn: '1h' });
        res.json({ token, user: { id: user.id, username: user.username, role: user.role } });
    } catch (error) {
        res.status(500).json({ message: 'OAuth failed', error: error.message });
    }
});

module.exports = router;
