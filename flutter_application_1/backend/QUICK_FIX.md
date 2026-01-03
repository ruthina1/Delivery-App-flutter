# Quick Fix for Favorites Foreign Key Error

## Problem
You're getting this error:
```
Cannot add or update a child row: a foreign key constraint fails 
(`deliveryapp`.`favorites`, CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`userId`) 
REFERENCES `users` (`id`) ON DELETE CASCADE)
```

## Solution

### Option 1: Run the Fix SQL Script (Recommended)

```bash
mysql -u root -p < fix_favorites_table.sql
```

Or manually in MySQL:
```sql
USE deliveryapp;
ALTER TABLE favorites DROP FOREIGN KEY IF EXISTS favorites_ibfk_1;
ALTER TABLE favorites DROP FOREIGN KEY IF EXISTS favorites_ibfk_2;
```

### Option 2: Drop and Recreate the Table

```sql
USE deliveryapp;
DROP TABLE IF EXISTS favorites;

CREATE TABLE favorites (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId VARCHAR(255) NOT NULL DEFAULT 'default_user',
  productId VARCHAR(255) NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_product (userId, productId),
  INDEX idx_userId (userId),
  INDEX idx_productId (productId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Option 3: Restart the Server

The server will now automatically remove foreign key constraints on startup. Just restart:

```bash
# Stop the server (Ctrl+C)
# Then restart
npm start
```

## Why This Happens

The `favorites` table was created with a foreign key constraint referencing the `users` table. However, when using `default_user` as a placeholder, that user doesn't exist in the `users` table, causing the constraint to fail.

The fix removes the foreign key constraint so favorites can work independently without requiring users to exist first.

## After Fixing

1. Restart your backend server: `npm start`
2. Try adding a favorite again in your Flutter app
3. Check the favorites section - it should now work!

