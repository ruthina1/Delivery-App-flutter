# Database Setup Guide

## Quick Setup (Favorites Only)

If you only need the favorites table for now, run:

```bash
mysql -u root -p < init_database.sql
```

Or manually:
```sql
CREATE DATABASE IF NOT EXISTS deliveryapp;
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
```

## Full Database Setup

To create the complete database schema with all tables:

```bash
mysql -u root -p < database_schema.sql
```

Or manually execute the SQL file in MySQL:
```sql
SOURCE /path/to/database_schema.sql;
```

## Database Structure

The `deliveryapp` database includes the following tables:

### Core Tables

1. **users** - User accounts
2. **categories** - Product categories (Burgers, Pizza, etc.)
3. **products** - Food items/products
4. **favorites** - User favorite products
5. **addresses** - User delivery addresses
6. **orders** - Order records
7. **order_items** - Items in each order
8. **cart** - Shopping cart (optional server-side)
9. **payment_methods** - User payment methods
10. **notifications** - User notifications
11. **reviews** - Product reviews (optional)

### Views

- **order_details_view** - Order summary with item count
- **user_favorites_view** - User favorites with product details

## Table Relationships

```
users
  ├── addresses (1:N)
  ├── favorites (1:N)
  ├── orders (1:N)
  ├── cart (1:N)
  ├── payment_methods (1:N)
  ├── notifications (1:N)
  └── reviews (1:N)

categories
  └── products (1:N)

products
  ├── favorites (1:N)
  ├── order_items (1:N)
  ├── cart (1:N)
  └── reviews (1:N)

orders
  ├── order_items (1:N)
  └── notifications (1:N)
```

## Configuration

Update `config.js` or `.env` to use the `deliveryapp` database:

```javascript
database: {
  database: 'deliveryapp'
}
```

Or in `.env`:
```env
DB_NAME=deliveryapp
```

## Sample Data

The schema includes sample data for:
- Default user
- 6 categories (Burgers, Pizza, Chips, Ice Cream, Ethiopian, Drinks)

You can add your own products and data as needed.

## Notes

- All tables use `utf8mb4` charset for full Unicode support
- Foreign keys are properly set up with CASCADE/RESTRICT rules
- Indexes are created for optimal query performance
- Timestamps are automatically managed
- JSON fields are used for flexible data storage (ingredients, customizations)

