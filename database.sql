CREATE DATABASE IF NOT EXISTS genshin_import;
USE genshin_import;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255),
    role ENUM('admin', 'user') DEFAULT 'user',
    external_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS weapons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category_id INT NOT NULL,
    description TEXT,
    stock INT NOT NULL DEFAULT 0,
    image VARCHAR(255),
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE IF NOT EXISTS transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS transaction_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    weapon_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_time DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (weapon_id) REFERENCES weapons(id)
);

-- Categories
INSERT IGNORE INTO categories (name) VALUES ('Sword'), ('Claymore'), ('Polearm'), ('Bow'), ('Catalyst');

-- Weapons
INSERT IGNORE INTO weapons (name, category_id, description, stock, price, image) VALUES 
('Mistsplitter Reforged', 1, 'Violet sword.', 10, 199.99, 'https://static.wikia.nocookie.net/gensin-impact/images/2/21/Weapon_Mistsplitter_Reforged.png'),
('Wolf\'s Gravestone', 2, 'Wolf Knight longsword.', 5, 189.99, 'https://static.wikia.nocookie.net/gensin-impact/images/0/03/Weapon_Wolf%27s_Gravestone.png'),
('Staff of Homa', 3, 'Ritual staff.', 8, 199.99, 'https://static.wikia.nocookie.net/gensin-impact/images/1/17/Weapon_Staff_of_Homa.png'),
('Aqua Simulacra', 4, 'Unpredictable longbow.', 12, 179.99, 'https://static.wikia.nocookie.net/gensin-impact/images/1/1e/Weapon_Aqua_Simulacra.png'),
('Kagura\'s Verity', 5, 'Kagura Dance bells.', 7, 189.99, 'https://static.wikia.nocookie.net/gensin-impact/images/d/db/Weapon_Kagura%27s_Verity.png');

-- Admin user (admin123)
INSERT INTO users (username, email, password, role) VALUES ('Admin', 'admin@genshin.com', '$2a$10$siA90oLux4j8b9taVGCl3eCwC1jDOc8XjWgMZy7ytIzEXNr9W0KiG', 'admin');
