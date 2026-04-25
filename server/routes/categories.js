const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { authenticateToken, isAdmin } = require('../middlewares/auth');

router.use((req, res, next) => {
    console.log(`Categories Router: ${req.method} ${req.url}`);
    next();
});

// Get all categories
router.get('/', async (req, res) => {
    try {
        const [categories] = await db.execute('SELECT * FROM categories ORDER BY name ASC');
        res.json(categories);
    } catch (error) {
        console.error('Error fetching categories:', error.message);
        if (error.code === 'ER_NO_SUCH_TABLE') {
            return res.json([{ id: 1, name: 'Sword' }, { id: 2, name: 'Claymore' }, { id: 3, name: 'Polearm' }, { id: 4, name: 'Bow' }, { id: 5, name: 'Catalyst' }]);
        }
        res.status(500).json({ message: 'Failed to fetch categories' });
    }
});

// Create new category (Admin only)
router.post('/', authenticateToken, isAdmin, async (req, res) => {
    const { name } = req.body;
    if (!name) return res.status(400).json({ message: 'Name is required' });
    
    try {
        await db.execute('INSERT INTO categories (name) VALUES (?)', [name]);
        res.status(201).json({ message: 'Category created' });
    } catch (error) {
        res.status(500).json({ message: 'Failed to create category', error: error.message });
    }
});

// Update category (Admin only)
router.put('/:id', authenticateToken, isAdmin, async (req, res) => {
    const { name } = req.body;
    if (!name) return res.status(400).json({ message: 'Name is required' });
    
    try {
        await db.execute('UPDATE categories SET name = ? WHERE id = ?', [name, req.params.id]);
        res.json({ message: 'Category updated' });
    } catch (error) {
        res.status(500).json({ message: 'Failed to update category', error: error.message });
    }
});

// Delete category (Admin only)
router.delete('/:id', authenticateToken, isAdmin, async (req, res) => {
    const categoryId = req.params.id;
    console.log('Attempting to delete category ID:', categoryId);
    try {
        const [result] = await db.execute('DELETE FROM categories WHERE id = ?', [categoryId]);
        if (result.affectedRows === 0) {
            console.log('Category not found for deletion:', categoryId);
            return res.status(404).json({ message: 'Category not found' });
        }
        console.log('Category deleted successfully:', categoryId);
        res.json({ message: 'Category deleted' });
    } catch (error) {
        if (error.code === 'ER_ROW_IS_REFERENCED_2') {
            return res.status(400).json({ message: 'Cannot delete category that is in use by weapons' });
        }
        res.status(500).json({ message: 'Failed to delete category', error: error.message });
    }
});

module.exports = router;
