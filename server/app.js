const createError = require('http-errors');
const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
const cors = require('cors');
require('dotenv').config();

const authRouter = require('./routes/auth');
const weaponsRouter = require('./routes/weapons');
const transactionsRouter = require('./routes/transactions');
const categoriesRouter = require('./routes/categories');
const db = require('./config/db');

const app = express();

db.getConnection()
  .then(async conn => {
    console.log('Database connected');
    
    await conn.execute(`CREATE TABLE IF NOT EXISTS categories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) UNIQUE NOT NULL
    )`);

    const [rows] = await conn.execute('SELECT COUNT(*) as count FROM categories');
    if (rows[0].count === 0) {
        await conn.execute("INSERT INTO categories (name) VALUES ('Sword'), ('Claymore'), ('Polearm'), ('Bow'), ('Catalyst')");
    }

    const [cols] = await conn.execute("SHOW COLUMNS FROM weapons LIKE 'category_id'");
    if (cols.length === 0) {
        await conn.execute("ALTER TABLE weapons ADD COLUMN category_id INT");
        
        await conn.execute(`
            UPDATE weapons w 
            JOIN categories c ON w.type = c.name 
            SET w.category_id = c.id
        `);

        await conn.execute("UPDATE weapons SET category_id = (SELECT id FROM categories LIMIT 1) WHERE category_id IS NULL");
        await conn.execute("ALTER TABLE weapons MODIFY COLUMN category_id INT NOT NULL");
        await conn.execute("ALTER TABLE weapons ADD CONSTRAINT fk_weapon_category FOREIGN KEY (category_id) REFERENCES categories(id)");

        const [typeCol] = await conn.execute("SHOW COLUMNS FROM weapons LIKE 'type'");
        if (typeCol.length > 0) {
            await conn.execute("ALTER TABLE weapons DROP COLUMN type");
        }
    }

    try {
        await conn.execute("ALTER TABLE transaction_items DROP FOREIGN KEY transaction_items_ibfk_2");
        await conn.execute("ALTER TABLE transaction_items ADD CONSTRAINT fk_weapon_transaction FOREIGN KEY (weapon_id) REFERENCES weapons(id) ON DELETE CASCADE");
    } catch (e) {
        // Ignored
    }

    conn.release();
  })
  .catch(err => {
    console.error('Database connection failed:', err.message);
  });

app.use(cors());
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.use('/uploads', express.static(path.join(__dirname, 'public/uploads')));

app.use('/auth', authRouter);
app.use('/weapons', weaponsRouter);
app.use('/categories', categoriesRouter);
app.use('/', transactionsRouter);

app.use(function(req, res, next) {
  next(createError(404));
});

app.use(function(err, req, res, next) {
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  res.status(err.status || 500);
  res.json({ message: err.message, error: res.locals.error });
});

module.exports = app;
