-- =====================================================
-- Delivery App Database Schema
-- Database: deliveryapp
-- =====================================================

-- Create database
CREATE DATABASE IF NOT EXISTS deliveryapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE deliveryapp;

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(255) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(20) NOT NULL,
  avatarUrl TEXT,
  passwordHash VARCHAR(255), -- For future authentication
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

select * from users;
-- =====================================================
-- CATEGORIES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS categories (
  id VARCHAR(255) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  icon VARCHAR(255) NOT NULL, -- Icon name or emoji
  image TEXT NOT NULL,
  displayOrder INT DEFAULT 0,
  isActive BOOLEAN DEFAULT TRUE,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_displayOrder (displayOrder),
  INDEX idx_isActive (isActive)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PRODUCTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS products (
  id VARCHAR(255) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  image TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  originalPrice DECIMAL(10, 2) NULL,
  rating DECIMAL(3, 2) DEFAULT 0.00,
  reviewCount INT DEFAULT 0,
  categoryId VARCHAR(255) NOT NULL,
  ingredients JSON, -- Array of ingredient strings
  isPopular BOOLEAN DEFAULT FALSE,
  isFeatured BOOLEAN DEFAULT FALSE,
  preparationTime INT NOT NULL DEFAULT 15, -- in minutes
  calories INT DEFAULT 0,
  isActive BOOLEAN DEFAULT TRUE,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE RESTRICT,
  INDEX idx_categoryId (categoryId),
  INDEX idx_isPopular (isPopular),
  INDEX idx_isFeatured (isFeatured),
  INDEX idx_isActive (isActive),
  INDEX idx_price (price),
  FULLTEXT INDEX idx_search (name, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- FAVORITES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS favorites (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId VARCHAR(255) NOT NULL DEFAULT 'default_user',
  productId VARCHAR(255) NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (productId) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_product (userId, productId),
  INDEX idx_userId (userId),
  INDEX idx_productId (productId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ADDRESSES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS addresses (
  id VARCHAR(255) PRIMARY KEY,
  userId VARCHAR(255) NOT NULL,
  label VARCHAR(100) NOT NULL, -- Home, Work, etc.
  fullAddress TEXT NOT NULL,
  street VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  zipCode VARCHAR(20),
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  isDefault BOOLEAN DEFAULT FALSE,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_userId (userId),
  INDEX idx_isDefault (isDefault),
  INDEX idx_location (latitude, longitude)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ORDERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS orders (
  id VARCHAR(255) PRIMARY KEY,
  orderNumber VARCHAR(50) NOT NULL UNIQUE,
  userId VARCHAR(255) NOT NULL,
  addressId VARCHAR(255) NOT NULL,
  subtotal DECIMAL(10, 2) NOT NULL,
  deliveryFee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  discount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  total DECIMAL(10, 2) NOT NULL,
  status ENUM('placed', 'confirmed', 'preparing', 'onTheWay', 'delivered', 'cancelled') DEFAULT 'placed',
  driverName VARCHAR(255) NULL,
  driverPhone VARCHAR(20) NULL,
  estimatedDelivery TIMESTAMP NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (addressId) REFERENCES addresses(id) ON DELETE RESTRICT,
  INDEX idx_userId (userId),
  INDEX idx_orderNumber (orderNumber),
  INDEX idx_status (status),
  INDEX idx_createdAt (createdAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ORDER ITEMS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  orderId VARCHAR(255) NOT NULL,
  productId VARCHAR(255) NOT NULL,
  productName VARCHAR(255) NOT NULL,
  productImage TEXT,
  price DECIMAL(10, 2) NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  customizations JSON, -- Array of customization strings
  specialInstructions TEXT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (orderId) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (productId) REFERENCES products(id) ON DELETE RESTRICT,
  INDEX idx_orderId (orderId),
  INDEX idx_productId (productId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- CART TABLE (Optional - for server-side cart management)
-- =====================================================
CREATE TABLE IF NOT EXISTS cart (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId VARCHAR(255) NOT NULL,
  productId VARCHAR(255) NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  customizations JSON, -- Array of customization strings
  specialInstructions TEXT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (productId) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_product (userId, productId),
  INDEX idx_userId (userId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PAYMENT METHODS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS payment_methods (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId VARCHAR(255) NOT NULL,
  type ENUM('cash', 'card', 'mobile', 'chapa') NOT NULL,
  cardNumber VARCHAR(20) NULL, -- Last 4 digits for cards
  cardHolderName VARCHAR(255) NULL,
  expiryDate VARCHAR(10) NULL, -- MM/YY format
  isDefault BOOLEAN DEFAULT FALSE,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_userId (userId),
  INDEX idx_isDefault (isDefault)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50) DEFAULT 'info', -- info, order, promotion, etc.
  isRead BOOLEAN DEFAULT FALSE,
  orderId VARCHAR(255) NULL, -- Link to order if notification is order-related
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (orderId) REFERENCES orders(id) ON DELETE SET NULL,
  INDEX idx_userId (userId),
  INDEX idx_isRead (isRead),
  INDEX idx_createdAt (createdAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- REVIEWS TABLE (Optional - for product reviews)
-- =====================================================
CREATE TABLE IF NOT EXISTS reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  productId VARCHAR(255) NOT NULL,
  userId VARCHAR(255) NOT NULL,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (productId) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_product_review (userId, productId),
  INDEX idx_productId (productId),
  INDEX idx_userId (userId),
  INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- SAMPLE DATA (Optional - for testing)
-- =====================================================

-- Insert default user
INSERT IGNORE INTO users (id, name, email, phone) VALUES
('default_user', 'Default User', 'user@example.com', '+251900000000');

-- Insert sample categories
INSERT IGNORE INTO categories (id, name, icon, image, displayOrder) VALUES
('cat_1', 'Burgers', '🍔', 'https://example.com/burger.jpg', 1),
('cat_2', 'Pizza', '🍕', 'https://example.com/pizza.jpg', 2),
('cat_3', 'Chips', '🍟', 'https://example.com/chips.jpg', 3),
('cat_4', 'Ice Cream', '🍦', 'https://example.com/icecream.jpg', 4),
('cat_5', 'Ethiopian', '🍛', 'https://example.com/ethiopian.jpg', 5),
('cat_6', 'Drinks', '🥤', 'https://example.com/drinks.jpg', 6);

-- =====================================================
-- VIEWS (Optional - for easier queries)
-- =====================================================

-- View for order details with items
CREATE OR REPLACE VIEW order_details_view AS
SELECT 
  o.id,
  o.orderNumber,
  o.userId,
  o.status,
  o.total,
  o.createdAt,
  COUNT(oi.id) as itemCount,
  GROUP_CONCAT(oi.productName SEPARATOR ', ') as items
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.orderId
GROUP BY o.id, o.orderNumber, o.userId, o.status, o.total, o.createdAt;

-- View for user favorites with product details
CREATE OR REPLACE VIEW user_favorites_view AS
SELECT 
  f.userId,
  f.productId,
  f.createdAt as favoritedAt,
  p.name as productName,
  p.image as productImage,
  p.price as productPrice,
  p.rating as productRating
FROM favorites f
JOIN products p ON f.productId = p.id;

-- =====================================================
-- END OF SCHEMA
-- =====================================================

