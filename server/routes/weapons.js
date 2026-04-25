const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const db = require('../config/db');
const { authenticateToken, isAdmin } = require('../middlewares/auth');

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'public/uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({ 
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const allowedTypes = /jpeg|jpg|png|webp/;
        const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
        const mimetype = allowedTypes.test(file.mimetype);
        if (extname && mimetype) return cb(null, true);
        cb(new Error('Invalid file type'));
    }
});

router.get('/', async (req, res) => {
    try {
        const [weapons] = await db.execute(`
            SELECT w.*, c.name as category_name 
            FROM weapons w 
            JOIN categories c ON w.category_id = c.id
        `);
        res.json(weapons);
    } catch (error) {
        res.status(500).json({ message: 'Failed to fetch weapons' });
    }
});

router.get('/:id', async (req, res) => {
    try {
        const [weapons] = await db.execute(`
            SELECT w.*, c.name as category_name 
            FROM weapons w 
            JOIN categories c ON w.category_id = c.id
            WHERE w.id = ?
        `, [req.params.id]);
        if (weapons.length === 0) return res.status(404).json({ message: 'Weapon not found' });
        res.json(weapons[0]);
    } catch (error) {
        res.status(500).json({ message: 'Failed to fetch weapon' });
    }
});

router.post('/', authenticateToken, isAdmin, upload.single('image_file'), async (req, res) => {
    const { name, category_id, description, stock, price } = req.body;
    let image = req.body.image || '';

    if (req.file) {
        image = `/uploads/${req.file.filename}`;
    }

    try {
        await db.execute('INSERT INTO weapons (name, category_id, description, stock, image, price) VALUES (?, ?, ?, ?, ?, ?)', 
            [name, category_id, description, stock, image, price]);
        res.status(201).json({ message: 'Weapon created' });
    } catch (error) {
        res.status(500).json({ message: 'Failed to create weapon' });
    }
});

router.put('/:id', authenticateToken, isAdmin, upload.single('image_file'), async (req, res) => {
    const { name, category_id, description, stock, price } = req.body;
    let image = req.body.image;

    if (req.file) {
        image = `/uploads/${req.file.filename}`;
    }

    try {
        await db.execute('UPDATE weapons SET name=?, category_id=?, description=?, stock=?, image=?, price=? WHERE id=?', 
            [name, category_id, description, stock, image, price, req.params.id]);
        res.json({ message: 'Weapon updated' });
    } catch (error) {
        res.status(500).json({ message: 'Failed to update weapon' });
    }
});

router.delete('/:id', authenticateToken, isAdmin, async (req, res) => {
    try {
        await db.execute('DELETE FROM weapons WHERE id = ?', [req.params.id]);
        res.json({ message: 'Weapon deleted' });
    } catch (error) {
        res.status(500).json({ message: 'Failed to delete weapon' });
    }
});

module.exports = router;
