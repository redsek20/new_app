<?php
$host = "localhost";
$user = "root";
$pass = "";

// Create connection
$conn = new mysqli($host, $user, $pass);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Create database
$sql = "CREATE DATABASE IF NOT EXISTS outfit_matcher";
if ($conn->query($sql) === TRUE) {
    echo "Database created successfully\n";
} else {
    echo "Error creating database: " . $conn->error . "\n";
}

$conn->select_db("outfit_matcher");

// Tables SQL
$tables = [
    "users" => "CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        name VARCHAR(255),
        password VARCHAR(255),
        last_login DATETIME,
        auth_token TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )",
    "products" => "CREATE TABLE IF NOT EXISTS products (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        price DECIMAL(10,2),
        category VARCHAR(50),
        subcategory VARCHAR(50),
        target VARCHAR(50), 
        brand VARCHAR(100),
        imageUrl TEXT,
        stock INT DEFAULT 0,
        sizes VARCHAR(255), 
        rating DECIMAL(3,2) DEFAULT 0,
        isFeatured BOOLEAN DEFAULT 0,
        isNew BOOLEAN DEFAULT 0
    )",
    "favorites" => "CREATE TABLE IF NOT EXISTS favorites (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255),
        imageUrl TEXT,
        category VARCHAR(50),
        tags TEXT
    )",
    "orders" => "CREATE TABLE IF NOT EXISTS orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_email VARCHAR(255),
        total_amount DECIMAL(10,2),
        shipping_address TEXT,
        payment_method VARCHAR(50),
        card_holder VARCHAR(255),
        card_number VARCHAR(20),
        expiry_date VARCHAR(10),
        status VARCHAR(20),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )",
    "order_items" => "CREATE TABLE IF NOT EXISTS order_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        order_id INT,
        outfit_title VARCHAR(255),
        price DECIMAL(10,2),
        quantity INT,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
    )"
];

foreach ($tables as $name => $sql) {
    if ($conn->query($sql) === TRUE) {
        echo "Table $name created successfully\n";
    } else {
        echo "Error creating table $name: " . $conn->error . "\n";
    }
}

// Update users table to have password if not exists
$conn->query("ALTER TABLE users ADD COLUMN IF NOT EXISTS password VARCHAR(255)");
$conn->query("ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP");

// RE-SEED PRODUCTS (User requested 50 of each: Men, Women, Children)
// We truncate to ensure a clean fresh set of 150 items so the user gets exactly what they asked for.
$conn->query("TRUNCATE TABLE products");
echo "Table cleared. Generating 150 new creative items...\n";

function generateItems($target, $count, $conn)
{
    $adjectives = ['Urban', 'Vintage', 'Modern', 'Essential', 'Premium', 'Street', 'Cozy', 'Active', 'Classic', 'Retro', 'Bold', 'Minimal', 'Tech', 'Luxury', 'Casual'];
    $colors = ['Black', 'White', 'Grey', 'Navy', 'Beige', 'Red', 'Olive', 'Blue', 'Cream', 'Charcoal', 'Burgundy', 'Teal'];
    $materials = ['Cotton', 'Fleece', 'Denim', 'Polyester', 'Wool Blend', 'Organic Cotton', 'Leather', 'French Terry', 'Linen'];

    // Category specific data: [Name suffix, Price Range, Image URLs]
    $categories = [
        'Hoodies' => [
            'suffixes' => ['Hoodie', 'Pullover', 'Sweatshirt', 'Fleece Zip'],
            'price_min' => 800,
            'price_max' => 1500,
            'images' => [
                'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=800&q=80', // Grey hoodie
                'https://images.unsplash.com/photo-1578768079052-aa76e52ff62e?w=800&q=80', // Portrait hoodie
                'https://images.unsplash.com/photo-1509942774463-acf339cf87d5?w=800&q=80', // Colored hoodie
                'https://images.unsplash.com/photo-1620799140408-ed5341cd2431?w=800&q=80'  // White hoodie
            ],
            'cat' => 'Tops',
            'sub' => 'Hoodies'
        ],
        'T-Shirts' => [
            'suffixes' => ['Tee', 'T-Shirt', 'Crewneck', 'Graphic Tee', 'Oversized Tee'],
            'price_min' => 300,
            'price_max' => 800,
            'images' => [
                'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&q=80', // White tee
                'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=800&q=80', // Black tee
                'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=800&q=80', // Graphic
                'https://images.unsplash.com/photo-1503341455253-b2e72333dbdb?w=800&q=80'  // Casual
            ],
            'cat' => 'Tops',
            'sub' => 'T-Shirts'
        ],
        'Pants' => [
            'suffixes' => ['Joggers', 'Cargo Pants', 'Chinos', 'Denim Jeans', 'Sweatpants', 'Trousers'],
            'price_min' => 600,
            'price_max' => 1200,
            'images' => [
                'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=800&q=80', // Chinos
                'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800&q=80', // Jeans
                'https://images.unsplash.com/photo-1552902865-b72c031ac5ea?w=800&q=80', // Formal
                'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=800&q=80'  // Hiking/Cargo
            ],
            'cat' => 'Bottoms',
            'sub' => 'Pants'
        ],
        'Shoes' => [
            'suffixes' => ['Sneakers', 'Runners', 'Trainers', 'High Tops', 'Boots', 'Slides'],
            'price_min' => 900,
            'price_max' => 2500,
            'images' => [
                'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80', // Red Nike
                'https://images.unsplash.com/photo-1600185365926-3a6d3de66f06?w=800&q=80', // Colorful
                'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=800&q=80', // White sneaker
                'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=800&q=80'  // Vans
            ],
            'cat' => 'Footwear',
            'sub' => 'Sneakers'
        ]
    ];

    $brands = ['Nike', 'Adidas', 'Zara', 'H&M', 'Uniqlo', 'Puma', 'New Balance', 'Ralph Lauren', 'Tommy Hilfiger', 'Calvin Klein'];
    $stmt = $conn->prepare("INSERT INTO products (name, description, price, category, subcategory, target, brand, imageUrl, stock, sizes, isFeatured, isNew) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

    $keys = array_keys($categories);

    for ($i = 0; $i < $count; $i++) {
        // Round-robin or random category
        $catKey = $keys[$i % count($keys)];
        $catData = $categories[$catKey];

        $adj = $adjectives[array_rand($adjectives)];
        $color = $colors[array_rand($colors)];
        $suffix = $catData['suffixes'][array_rand($catData['suffixes'])];
        $brand = $brands[array_rand($brands)];
        $material = $materials[array_rand($materials)];

        $name = "$adj $brand $suffix";
        $desc = "Stay stylish with this $adj $color $suffix. Crafted from premium $material for maximum comfort and durability.";
        $price = rand($catData['price_min'], $catData['price_max']);

        // Pick an image
        $img = $catData['images'][array_rand($catData['images'])];

        $stock = rand(5, 50);
        $rating = rand(35, 50) / 10.0;

        // Contextual sizes
        if ($catKey == 'Shoes') {
            if ($target == 'Children')
                $sizes = '28,30,32,34';
            else
                $sizes = '38,40,42,44,45';
        } else if ($target == 'Children') {
            $sizes = '4Y,6Y,8Y,10Y,12Y';
        } else {
            $sizes = 'XS,S,M,L,XL';
        }

        $isFeatured = (rand(0, 10) > 8) ? 1 : 0;
        $isNew = (rand(0, 10) > 7) ? 1 : 0;

        $stmt->bind_param("ssdsssssisii", $name, $desc, $price, $catData['cat'], $catData['sub'], $target, $brand, $img, $stock, $sizes, $isFeatured, $isNew);
        $stmt->execute();
    }
}

// Generate 50 for Men
generateItems('Men', 50, $conn);
// Generate 50 for Women
generateItems('Women', 50, $conn);
// Generate 50 for Children
generateItems('Children', 50, $conn);

echo "Successfully seeded 150 diverse items.\n";

$conn->close();
?>