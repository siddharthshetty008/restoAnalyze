-- ==================================================
-- Restaurant Analytics Database Schema
-- Lead AI Engineer Design - Production Ready
-- Version: 1.0
-- Date: 2025-11-27
-- ==================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For fuzzy string matching
CREATE EXTENSION IF NOT EXISTS "btree_gin"; -- For composite indexes

-- ==================================================
-- 1. RESTAURANTS TABLE (Multi-tenant ready)
-- ==================================================
CREATE TABLE IF NOT EXISTS restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200),
    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
    currency VARCHAR(10) DEFAULT 'INR',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================================================
-- 2. MENU ITEMS TABLE (Master catalog)
-- ==================================================
CREATE TABLE IF NOT EXISTS menu_items (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INTEGER REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    clean_name VARCHAR(200), -- Normalized name for matching
    category VARCHAR(100),
    subcategory VARCHAR(100),
    base_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    margin_percentage DECIMAL(5,2),
    is_active BOOLEAN DEFAULT TRUE,
    is_alcohol BOOLEAN DEFAULT FALSE,
    serving_size VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(restaurant_id, name)
);

-- ==================================================
-- 3. ORDERS TABLE (Transaction headers)
-- ==================================================
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    restaurant_id INTEGER REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    external_order_id VARCHAR(100), -- Original CSV Order No.
    client_order_id VARCHAR(100),   -- Third-party platform ID
    order_type VARCHAR(50) NOT NULL, -- "Dine In", "Delivery", "Pick Up"  
    sub_order_type VARCHAR(100),    -- "AC", "Non AC", "Zomato", "Swiggy"
    table_number VARCHAR(20),       -- Extracted from sub_order_type
    customer_name VARCHAR(200),
    customer_phone VARCHAR(20),
    customer_address TEXT,
    
    -- Financial details
    total_amount DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    delivery_charge DECIMAL(10,2) DEFAULT 0,
    container_charge DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    round_off DECIMAL(10,2) DEFAULT 0,
    grand_total DECIMAL(10,2) NOT NULL,
    
    -- Payment and status
    payment_type VARCHAR(50),
    payment_description TEXT,
    order_status VARCHAR(50) DEFAULT 'Completed',
    
    -- Timing
    order_datetime TIMESTAMPTZ NOT NULL,
    year_month VARCHAR(7) GENERATED ALWAYS AS (TO_CHAR(order_datetime, 'YYYY-MM')) STORED,
    hour_of_day INTEGER GENERATED ALWAYS AS (EXTRACT(HOUR FROM order_datetime)) STORED,
    day_of_week INTEGER GENERATED ALWAYS AS (EXTRACT(DOW FROM order_datetime)) STORED,
    
    -- Delivery details
    delivery_boy VARCHAR(100),
    delivery_phone VARCHAR(20),
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================================================
-- 4. ORDER ITEMS TABLE (Line items with allocation)
-- ==================================================
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    
    -- Item identification
    item_name VARCHAR(200) NOT NULL,        -- Raw name from CSV
    clean_item_name VARCHAR(200),           -- Normalized for matching
    menu_item_id INTEGER REFERENCES menu_items(item_id), -- Matched menu item
    
    -- Quantity and pricing
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(10,2),               -- Individual item price
    allocated_price DECIMAL(10,2) NOT NULL, -- Our revenue allocation algorithm result
    menu_price DECIMAL(10,2),              -- Known menu price if available
    
    -- Data quality metrics
    price_confidence VARCHAR(20) DEFAULT 'ESTIMATED', -- 'HIGH', 'MEDIUM', 'LOW', 'ESTIMATED'
    match_score DECIMAL(5,4),              -- Fuzzy matching confidence (0-1)
    allocation_method VARCHAR(50),          -- 'MENU_PRICE', 'PROPORTIONAL', 'ESTIMATED'
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================================================
-- 5. PRICE HISTORY TABLE (For elasticity analysis)
-- ==================================================
CREATE TABLE IF NOT EXISTS price_history (
    price_id SERIAL PRIMARY KEY,
    menu_item_id INTEGER REFERENCES menu_items(item_id) ON DELETE CASCADE,
    price DECIMAL(10,2) NOT NULL,
    effective_date DATE NOT NULL,
    end_date DATE,
    price_type VARCHAR(50) DEFAULT 'REGULAR', -- 'REGULAR', 'PROMOTION', 'DYNAMIC', 'HAPPY_HOUR'
    promotion_name VARCHAR(100),
    discount_percentage DECIMAL(5,2),
    created_by VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(menu_item_id, effective_date)
);

-- ==================================================
-- 6. ANALYTICS CACHE TABLES
-- ==================================================

-- BCG Matrix analysis cache
CREATE TABLE IF NOT EXISTS bcg_analysis_cache (
    item_id INTEGER REFERENCES menu_items(item_id),
    period_start DATE,
    period_end DATE,
    quantity_sold INTEGER,
    total_revenue DECIMAL(12,2),
    popularity_percentile DECIMAL(5,4),
    revenue_percentile DECIMAL(5,4),
    bcg_category VARCHAR(20), -- 'STAR', 'PLOWHORSE', 'PUZZLE', 'DOG'
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (item_id, period_start, period_end)
);

-- Price elasticity cache
CREATE TABLE IF NOT EXISTS elasticity_analysis_cache (
    item_id INTEGER REFERENCES menu_items(item_id),
    analysis_date DATE,
    elasticity_coefficient DECIMAL(8,6),
    r_squared DECIMAL(6,4),
    p_value DECIMAL(10,8),
    confidence_level VARCHAR(20), -- 'HIGH', 'MEDIUM', 'LOW'
    data_points INTEGER,
    price_variation_cv DECIMAL(6,4), -- Coefficient of variation
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (item_id, analysis_date)
);

-- ==================================================
-- 7. PERFORMANCE INDEXES
-- ==================================================

-- Orders table indexes (time-series optimized)
CREATE INDEX IF NOT EXISTS idx_orders_datetime ON orders(order_datetime);
CREATE INDEX IF NOT EXISTS idx_orders_year_month ON orders(year_month);
CREATE INDEX IF NOT EXISTS idx_orders_sub_type_date ON orders(sub_order_type, order_datetime);
CREATE INDEX IF NOT EXISTS idx_orders_type_date ON orders(order_type, order_datetime);
CREATE INDEX IF NOT EXISTS idx_orders_external_id ON orders(external_order_id);

-- Order items indexes (revenue analysis optimized)
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_menu_id ON order_items(menu_item_id);
CREATE INDEX IF NOT EXISTS idx_order_items_confidence ON order_items(price_confidence);
CREATE INDEX IF NOT EXISTS idx_order_items_allocation ON order_items(allocated_price) WHERE allocated_price > 0;

-- Menu items indexes (matching optimized)
CREATE INDEX IF NOT EXISTS idx_menu_items_name_trgm ON menu_items USING gin(name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_menu_items_clean_name_trgm ON menu_items USING gin(clean_name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_order_items_name_trgm ON order_items USING gin(item_name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_order_items_clean_name_trgm ON order_items USING gin(clean_item_name gin_trgm_ops);

-- Category and filtering indexes
CREATE INDEX IF NOT EXISTS idx_menu_items_category ON menu_items(category, is_active);
CREATE INDEX IF NOT EXISTS idx_menu_items_alcohol ON menu_items(is_alcohol) WHERE is_alcohol = TRUE;

-- Price history indexes (elasticity analysis optimized)
CREATE INDEX IF NOT EXISTS idx_price_history_item_date ON price_history(menu_item_id, effective_date);
CREATE INDEX IF NOT EXISTS idx_price_history_date_range ON price_history(effective_date, end_date);

-- ==================================================
-- 8. HELPER FUNCTIONS
-- ==================================================

-- Function to clean item names for better matching
CREATE OR REPLACE FUNCTION clean_item_name(input_name TEXT) 
RETURNS TEXT AS $$
BEGIN
    RETURN LOWER(
        TRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(input_name, '\s*\([^)]*\)', '', 'g'), -- Remove parentheses
                    '\s*\d+\s*(ml|ML|Ml)\s*', ' ', 'g'), -- Remove volume indicators
                '\s+', ' ', 'g') -- Normalize whitespace
        )
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to calculate Jaccard similarity
CREATE OR REPLACE FUNCTION jaccard_similarity(text1 TEXT, text2 TEXT)
RETURNS DECIMAL(5,4) AS $$
DECLARE
    words1 TEXT[];
    words2 TEXT[];
    intersection INTEGER;
    union_count INTEGER;
BEGIN
    words1 := string_to_array(clean_item_name(text1), ' ');
    words2 := string_to_array(clean_item_name(text2), ' ');
    
    -- Calculate intersection
    SELECT COUNT(*)
    INTO intersection
    FROM (
        SELECT UNNEST(words1)
        INTERSECT
        SELECT UNNEST(words2)
    ) AS intersect_result;
    
    -- Calculate union
    SELECT COUNT(DISTINCT word)
    INTO union_count
    FROM (
        SELECT UNNEST(words1) AS word
        UNION
        SELECT UNNEST(words2) AS word
    ) AS union_result;
    
    RETURN CASE 
        WHEN union_count = 0 THEN 0
        ELSE intersection::DECIMAL / union_count::DECIMAL
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ==================================================
-- 9. TRIGGERS FOR AUTO-UPDATES
-- ==================================================

-- Update timestamps automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_restaurants_updated_at 
    BEFORE UPDATE ON restaurants 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_menu_items_updated_at 
    BEFORE UPDATE ON menu_items 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at 
    BEFORE UPDATE ON orders 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-populate clean names
CREATE OR REPLACE FUNCTION populate_clean_names()
RETURNS TRIGGER AS $$
BEGIN
    NEW.clean_name := clean_item_name(NEW.name);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER menu_items_clean_name_trigger
    BEFORE INSERT OR UPDATE ON menu_items
    FOR EACH ROW EXECUTE FUNCTION populate_clean_names();

-- Auto-populate clean item names in order_items
CREATE OR REPLACE FUNCTION populate_order_item_clean_names()
RETURNS TRIGGER AS $$
BEGIN
    NEW.clean_item_name := clean_item_name(NEW.item_name);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_items_clean_name_trigger
    BEFORE INSERT OR UPDATE ON order_items
    FOR EACH ROW EXECUTE FUNCTION populate_order_item_clean_names();

-- ==================================================
-- 10. MATERIALIZED VIEWS FOR ANALYTICS
-- ==================================================

-- Real-time revenue summary view
CREATE MATERIALIZED VIEW IF NOT EXISTS revenue_summary_view AS
SELECT 
    DATE_TRUNC('month', o.order_datetime) as month,
    o.sub_order_type,
    COUNT(o.*) as order_count,
    SUM(o.total_amount) as total_revenue,
    SUM(o.grand_total) as grand_total_revenue,
    AVG(o.total_amount) as avg_order_value,
    COUNT(DISTINCT CASE WHEN oi.price_confidence IN ('HIGH', 'MEDIUM') THEN oi.menu_item_id END) as verified_items
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY 1, 2
ORDER BY 1 DESC, 2;

-- Create index on materialized view
CREATE INDEX IF NOT EXISTS idx_revenue_summary_month_type ON revenue_summary_view(month, sub_order_type);

-- ==================================================
-- 11. SAMPLE DATA AND VALIDATION
-- ==================================================

-- Insert default restaurant
INSERT INTO restaurants (name, location) 
VALUES ('Konkan Swad Gomantak', 'Mumbai, Maharashtra') 
ON CONFLICT DO NOTHING;

-- ==================================================
-- SETUP COMPLETE
-- ==================================================

-- Grant permissions (add specific users as needed)
-- GRANT ALL ON ALL TABLES IN SCHEMA public TO restaurant_admin;
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytics_readonly;

-- Display setup completion message
DO $$
BEGIN
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Restaurant Analytics Database Setup Complete!';
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Tables created: restaurants, menu_items, orders, order_items, price_history';
    RAISE NOTICE 'Analytics tables: bcg_analysis_cache, elasticity_analysis_cache';
    RAISE NOTICE 'Indexes: Optimized for time-series and text matching';
    RAISE NOTICE 'Functions: clean_item_name(), jaccard_similarity()';
    RAISE NOTICE 'Views: revenue_summary_view';
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Next: Run migration scripts to import CSV data';
    RAISE NOTICE '=================================================';
END $$;