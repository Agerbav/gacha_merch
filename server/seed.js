const db = require('./config/db');

async function seed() {
    try {
        const categories = ['Sword', 'Claymore', 'Polearm', 'Bow', 'Catalyst'];
        for (const category of categories) {
            await db.execute('INSERT IGNORE INTO categories (name) VALUES (?)', [category]);
        }

        const [categoryRows] = await db.execute('SELECT id, name FROM categories');
        const categoryMap = {};
        categoryRows.forEach(row => {
            categoryMap[row.name] = row.id;
        });

        const weapons = [
            {
                name: 'Mistsplitter Reforged',
                category_id: categoryMap['Sword'],
                description: 'A sword that blazes with a fierce violet light.',
                stock: 10,
                price: 199.99,
                image: 'https://static.wikia.nocookie.net/gensin-impact/images/2/21/Weapon_Mistsplitter_Reforged.png'
            },
            {
                name: 'Wolf\'s Gravestone',
                category_id: categoryMap['Claymore'],
                description: 'A longsword used by the Wolf Knight.',
                stock: 5,
                price: 189.99,
                image: 'https://static.wikia.nocookie.net/gensin-impact/images/0/03/Weapon_Wolf%27s_Gravestone.png'
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
                image: 'https://static.wikia.nocookie.net/gensin-impact/images/1/1e/Weapon_Aqua_Simulacra.png'
            },
            {
                name: 'Kagura\'s Verity',
                category_id: categoryMap['Catalyst'],
                description: 'Bells used when performing the Kagura Dance.',
                stock: 7,
                price: 189.99,
                image: 'https://static.wikia.nocookie.net/gensin-impact/images/d/db/Weapon_Kagura%27s_Verity.png'
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

        console.log('Seeding done');
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

seed();
