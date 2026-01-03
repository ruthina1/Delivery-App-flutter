-- =====================================================
-- Fix Favorites Table - Remove Foreign Key Constraint
-- Run this if you're getting foreign key constraint errors
-- =====================================================

USE deliveryapp;

-- Drop foreign key constraints if they exist
ALTER TABLE favorites DROP FOREIGN KEY IF EXISTS favorites_ibfk_1;
ALTER TABLE favorites DROP FOREIGN KEY IF EXISTS favorites_ibfk_2;

-- Verify the table structure
DESCRIBE favorites;

