const db = require('./config/db');
const bcrypt = require('bcryptjs');

async function seed() {
    try {
        console.log('Starting seeding...');

        // 1. Seed Categories
        const categories = ['Sword', 'Claymore', 'Polearm', 'Bow', 'Catalyst'];
        for (const category of categories) {
            await db.execute('INSERT IGNORE INTO categories (name) VALUES (?)', [category]);
        }
        console.log('Categories seeded.');

        const [categoryRows] = await db.execute('SELECT id, name FROM categories');
        const categoryMap = {};
        categoryRows.forEach(row => {
            categoryMap[row.name] = row.id;
        });

        // 2. Seed Admin User
        const adminEmail = 'admin@genshin.com';
        const [adminRows] = await db.execute('SELECT id FROM users WHERE email = ?', [adminEmail]);
        if (adminRows.length === 0) {
            const hashedPassword = await bcrypt.hash('admin123', 10);
            await db.execute(
                'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
                ['Admin', adminEmail, hashedPassword, 'admin']
            );
            console.log('Admin user created (admin@genshin.com / admin123).');
        } else {
            console.log('Admin user already exists.');
        }

        // 3. Seed Weapons
        const weapons = [
            {
                name: 'Mistsplitter Reforged',
                category_id: categoryMap['Sword'],
                description: 'A sword that blazes with a fierce violet light.',
                stock: 10,
                price: 199.99,
                image: 'https://static.wikia.nocookie.net/gensin-impact/images/0/09/Weapon_Mistsplitter_Reforged.png'
            },
            {
                name: 'Wolf\'s Gravestone',
                category_id: categoryMap['Claymore'],
                description: 'A longsword used by the Wolf Knight.',
                stock: 5,
                price: 189.99,
                image: 'https://static.wikia.nocookie.net/gensin-impact/images/4/4f/Weapon_Wolf%27s_Gravestone.png'
            },
            {
                name: 'Staff of Homa',
                category_id: categoryMap['Polearm'],
                description: 'A firewood staff used in ancient rituals.',
                stock: 8,
                price: 199.99,
                image: 'https://static.wikia.nocookie.net/gensin-impact/images/1/17/Weapon_Staff_of_Homa.png'
            },
            {
                name: 'Aqua Simulacra',
                category_id: categoryMap['Bow'],
                description: 'A longbow whose color is as unpredictable as still water.',
                stock: 12,
                price: 179.99,
                image: 'https://static.wikia.nocookie.net/gensin-impact/images/c/cd/Weapon_Aqua_Simulacra.png'
            },
            {
                name: 'Kagura\'s Verity',
                category_id: categoryMap['Catalyst'],
                description: 'Bells used when performing the Kagura Dance.',
                stock: 7,
                price: 189.99,
                image: 'https://static.wikia.nocookie.net/gensin-impact/images/b/b7/Weapon_Kagura%27s_Verity.png'
            }
        ];

        for (const w of weapons) {
            const [rows] = await db.execute('SELECT id FROM weapons WHERE name = ?', [w.name]);
            if (rows.length === 0) {
                await db.execute(
                    'INSERT INTO weapons (name, category_id, description, stock, price, image) VALUES (?, ?, ?, ?, ?, ?)',
                    [w.name, w.category_id, w.description, w.stock, w.price, w.image]
                );
            }
        }
        console.log('Weapons seeded.');

        console.log('Seeding process completed successfully.');
        process.exit(0);
    } catch (err) {
        console.error('Seeding failed:', err);
        process.exit(1);
    }
}

seed();
