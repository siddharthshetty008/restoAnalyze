# Restaurant Analytics Database Architecture

**Lead AI Engineer Design** | **Version**: 1.0 | **Date**: 2025-11-27

## System Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Data Sources  │    │   PostgreSQL     │    │   Analytics     │
│                 │    │   Database       │    │   Layer         │
│ • CSV Files     │───▶│ • Normalized     │───▶│ • FastAPI       │
│ • Menu Data     │    │ • Indexed        │    │ • ML Models     │
│ • External APIs │    │ • Time-series    │    │ • Dashboards    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Database Schema Design

### Core Tables

#### 1. **restaurants** (Multi-tenant ready)
```sql
CREATE TABLE restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200),
    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 2. **menu_items** (Master item catalog)
```sql
CREATE TABLE menu_items (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INTEGER REFERENCES restaurants(restaurant_id),
    name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    base_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 3. **orders** (Transaction headers)
```sql
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    restaurant_id INTEGER REFERENCES restaurants(restaurant_id),
    external_order_id VARCHAR(100), -- Original CSV Order No.
    order_type VARCHAR(50), -- "Dine In", "Delivery", "Pick Up"
    sub_order_type VARCHAR(100), -- "AC", "Non AC", "Zomato", etc.
    customer_name VARCHAR(200),
    customer_phone VARCHAR(20),
    total_amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    payment_type VARCHAR(50),
    order_datetime TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 4. **order_items** (Transaction details with accurate allocation)
```sql
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    item_name VARCHAR(200) NOT NULL, -- Raw name from CSV
    menu_item_id INTEGER REFERENCES menu_items(item_id), -- Matched item
    quantity INTEGER DEFAULT 1,
    allocated_price DECIMAL(10,2) NOT NULL, -- Our calculated allocation
    menu_price DECIMAL(10,2), -- Known menu price if available
    price_confidence VARCHAR(20), -- 'HIGH', 'MEDIUM', 'LOW', 'ESTIMATED'
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 5. **price_history** (For elasticity analysis)
```sql
CREATE TABLE price_history (
    price_id SERIAL PRIMARY KEY,
    menu_item_id INTEGER REFERENCES menu_items(item_id),
    price DECIMAL(10,2) NOT NULL,
    effective_date DATE NOT NULL,
    price_type VARCHAR(50) DEFAULT 'REGULAR', -- 'REGULAR', 'PROMOTION', 'DYNAMIC'
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Performance Optimization

#### Indexes for Fast Analytics
```sql
-- Time-series analysis optimization
CREATE INDEX idx_orders_datetime ON orders(order_datetime);
CREATE INDEX idx_orders_sub_type_date ON orders(sub_order_type, order_datetime);

-- Revenue analysis optimization  
CREATE INDEX idx_order_items_menu_confidence ON order_items(menu_item_id, price_confidence);
CREATE INDEX idx_order_items_allocation ON order_items(allocated_price) WHERE allocated_price > 0;

-- Menu matching optimization
CREATE INDEX idx_menu_items_name_trgm ON menu_items USING gin(name gin_trgm_ops);
CREATE INDEX idx_order_items_name_trgm ON order_items USING gin(item_name gin_trgm_ops);
```

#### Partitioning Strategy
```sql
-- Partition orders by month for time-series performance
CREATE TABLE orders_2025_q4 PARTITION OF orders 
FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

CREATE TABLE orders_2025_q3 PARTITION OF orders 
FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');
```

## Data Migration Strategy

### Phase 1: Schema Setup
1. Run `setup_database.sql` - Creates tables, indexes, extensions
2. Run `insert_reference_data.sql` - Adds restaurant and base menu items

### Phase 2: CSV Import
1. Run `migrate_menu_data.py` - Imports and normalizes menu pricing
2. Run `migrate_transaction_data.py` - Imports CSV files with revenue allocation
3. Run `validate_migration.py` - Verifies 100% accuracy against source data

### Phase 3: Analytics Setup  
1. Create materialized views for common queries
2. Set up scheduled refresh for real-time analytics
3. Initialize ML model training data

## Analytics Capabilities

### Real-time Queries (Sub-second response)
```sql
-- Monthly sub-order type trends
SELECT 
    DATE_TRUNC('month', order_datetime) as month,
    sub_order_type,
    COUNT(*) as order_count,
    SUM(total_amount) as revenue
FROM orders 
WHERE order_datetime >= NOW() - INTERVAL '12 months'
GROUP BY 1, 2 ORDER BY 1, 2;

-- Verified menu item performance
SELECT 
    mi.name,
    mi.category,
    COUNT(oi.*) as quantity_sold,
    SUM(oi.allocated_price) as total_revenue,
    AVG(oi.allocated_price) as avg_price
FROM order_items oi
JOIN menu_items mi ON oi.menu_item_id = mi.item_id
WHERE oi.price_confidence IN ('HIGH', 'MEDIUM')
GROUP BY mi.item_id, mi.name, mi.category
ORDER BY total_revenue DESC;
```

### Advanced Analytics Views
```sql
-- Materialized view for BCG Matrix analysis
CREATE MATERIALIZED VIEW bcg_matrix_analysis AS
SELECT 
    mi.name,
    mi.category,
    COUNT(oi.*) as quantity_sold,
    SUM(oi.allocated_price) as total_revenue,
    PERCENT_RANK() OVER (ORDER BY COUNT(oi.*)) as popularity_percentile,
    PERCENT_RANK() OVER (ORDER BY SUM(oi.allocated_price)) as revenue_percentile,
    CASE 
        WHEN PERCENT_RANK() OVER (ORDER BY COUNT(oi.*)) >= 0.5 
         AND PERCENT_RANK() OVER (ORDER BY SUM(oi.allocated_price)) >= 0.5 
        THEN 'STAR'
        WHEN PERCENT_RANK() OVER (ORDER BY COUNT(oi.*)) >= 0.5 
         AND PERCENT_RANK() OVER (ORDER BY SUM(oi.allocated_price)) < 0.5 
        THEN 'PLOWHORSE'
        WHEN PERCENT_RANK() OVER (ORDER BY COUNT(oi.*)) < 0.5 
         AND PERCENT_RANK() OVER (ORDER BY SUM(oi.allocated_price)) >= 0.5 
        THEN 'PUZZLE'
        ELSE 'DOG'
    END as bcg_category
FROM order_items oi
JOIN menu_items mi ON oi.menu_item_id = mi.item_id
WHERE oi.price_confidence IN ('HIGH', 'MEDIUM')
GROUP BY mi.item_id, mi.name, mi.category;
```

## Deployment Architecture

### Local Development
```bash
# Docker Compose setup for local development
docker-compose up -d  # PostgreSQL + pgAdmin + Redis
./scripts/setup_database.sh  # Initialize schema and data
```

### Production Deployment
```bash
# AWS RDS PostgreSQL with read replicas
# Separate analytics replica for heavy queries
# Connection pooling via PgBouncer
```

## Security & Compliance

### Data Protection
- Encrypted connections (SSL/TLS)
- Row-level security for multi-tenant data
- Audit logging for all data modifications
- GDPR-compliant customer data handling

### Access Control
```sql
-- Role-based access control
CREATE ROLE analytics_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytics_readonly;

CREATE ROLE ml_engineer;
GRANT SELECT, INSERT ON price_history TO ml_engineer;
```

## Monitoring & Observability

### Performance Monitoring
- Query performance insights via pg_stat_statements
- Real-time connection monitoring
- Automated index recommendations
- Slow query alerts

### Business Metrics Tracking
- Revenue accuracy validation (daily)
- Data freshness monitoring
- ML model performance tracking
- API response time monitoring

---

**Next Steps**: Implement database setup scripts and migration tools.