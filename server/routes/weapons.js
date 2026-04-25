const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { authenticateToken, isAdmin } = require('../middlewares/auth');

// Retrieve all weapons (GET 1)
router.get('/', async (req, res) => {
    try {
        const [weapons] = await db.execute('SELECT * FROM weapons');
        res.json(weapons);
    } catch (error) {
        res.status(500).json({ message: 'Failed to fetch weapons' });
    }
});

// Retrieve specific weapon (GET 2)
router.get('/:id', async (req, res) => {
    try {
        const [weapons] = await db.execute('SELECT * FROM weapons WHERE id = ?', [req.params.id]);
        if (weapons.length === 0) return res.status(404).json({ message: 'Weapon not found' });
        res.json(weapons[0]);
    } catch (error) {
        res.status(500).json({ message: 'Failed to fetch weapon' });
    }
});

// Create weapon (Admin - POST)
router.post('/', authenticateToken, isAdmin, async (req, res) => {
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
router.put('/:id', authenticateToken, isAdmin, async (req, res) => {
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
router.delete('/:id', authenticateToken, isAdmin, async (req, res) => {
    try {
        await db.execute('DELETE FROM weapons WHERE id = ?', [req.params.id]);
        res.json({ message: 'Weapon deleted' });
    } catch (error) {
        res.status(500).json({ message: 'Failed to delete weapon' });
    }
});

module.exports = router;
