const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { authenticateToken } = require('../middlewares/auth');

// Buy weapons (User - POST)
router.post('/buy', authenticateToken, async (req, res) => {
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

module.exports = router;
