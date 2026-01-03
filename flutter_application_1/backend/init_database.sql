-- =====================================================
-- Quick Database Initialization Script
-- Run this to create the database and favorites table
-- =====================================================

CREATE DATABASE IF NOT EXISTS deliveryapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE deliveryapp;

CREATE TABLE IF NOT EXISTS favorites (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId VARCHAR(255) NOT NULL DEFAULT 'default_user',
  productId VARCHAR(255) NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_product (userId, productId),
  INDEX idx_userId (userId),
  INDEX idx_productId (productId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

