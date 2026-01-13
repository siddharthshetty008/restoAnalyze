# Technical Decisions - Restaurant Analytics Platform

**Lead AI Engineer Decisions** | **Date**: 2025-11-27

## 🏗️ **Architecture Decisions**

### **1. Database Choice: PostgreSQL over SQLite**

**Decision**: Use PostgreSQL as the primary database instead of SQLite

**Rationale**:
- **Concurrent Access**: Multiple analysts can query simultaneously
- **Advanced Analytics**: Built-in statistical functions and window operations
- **Full-Text Search**: pg_trgm extension for fuzzy menu matching
- **Scalability**: Handles 100K+ transactions with partitioning
- **Extensions**: PostGIS for location analytics, TimescaleDB for time-series

**Trade-offs**:
- ✅ Production-ready with ACID compliance
- ✅ Advanced indexing (GIN, BTREE) for text matching
- ✅ Materialized views for sub-second analytics
- ❌ More complex setup than SQLite
- ❌ Requires PostgreSQL knowledge

### **2. Schema Design: Normalized vs Denormalized**

**Decision**: Fully normalized schema with analytics caching layer

**Rationale**:
- **Data Integrity**: Foreign keys ensure referential integrity
- **Storage Efficiency**: Reduce duplication of menu items and restaurants
- **Flexibility**: Easy to add new restaurants (multi-tenant ready)
- **Analytics Speed**: Materialized views cache expensive computations

**Implementation**:
```sql
-- Normalized core tables
restaurants → menu_items → order_items → orders

-- Cached analytics tables  
bcg_analysis_cache, elasticity_analysis_cache
```

### **3. Revenue Allocation Algorithm: Hybrid Approach**

**Decision**: Menu-price prioritized with proportional fallback

**Rationale**:
- **Accuracy Priority**: Use verified menu prices when available (79% coverage)
- **Total Preservation**: Always ensure allocated total equals order total
- **Confidence Tracking**: Label each allocation with confidence level

**Algorithm**:
1. Allocate known menu prices first
2. Distribute remaining amount proportionally
3. Apply rounding adjustment to maintain exact totals
4. Track allocation method for quality analysis

### **4. Fuzzy Matching: Jaccard Similarity + Text Cleaning**

**Decision**: Custom PostgreSQL function using Jaccard similarity

**Rationale**:
- **Database-Native**: Leverage PostgreSQL's text processing capabilities
- **Customizable**: Tailored cleaning rules for restaurant items
- **Performance**: GIN indexes on trigrams for fast matching
- **Accuracy**: 79%+ match rate with confidence scoring

**Implementation**:
```sql
CREATE FUNCTION jaccard_similarity(text1 TEXT, text2 TEXT)
-- Clean → Tokenize → Intersect → Score
```

## 📊 **Data Processing Decisions**

### **5. CSV Parsing: Pandas + Custom Logic**

**Decision**: Use Pandas for CSV reading with custom parsing logic

**Rationale**:
- **Robustness**: Handle encoding issues (UTF-8/Latin-1)
- **Complex Fields**: Parse comma-separated items within CSV fields
- **Memory Efficiency**: Process in batches for large datasets
- **Error Handling**: Skip malformed rows, log issues

### **6. Time-Series Storage: PostgreSQL Partitioning**

**Decision**: Partition orders table by month with generated columns

**Rationale**:
- **Query Performance**: Partition pruning for date-range queries
- **Maintenance**: Easier archival of old data
- **Generated Columns**: Pre-compute year_month, hour_of_day for analytics

**Implementation**:
```sql
-- Automatic partitioning
CREATE TABLE orders_2025_q4 PARTITION OF orders 
FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

-- Generated analytics columns
year_month VARCHAR(7) GENERATED ALWAYS AS (TO_CHAR(order_datetime, 'YYYY-MM')) STORED
```

### **7. Price Confidence System: Four-Level Classification**

**Decision**: HIGH, MEDIUM, LOW, ESTIMATED confidence levels

**Rationale**:
- **Data Quality Transparency**: Users know reliability of each price
- **Business Logic**: Only HIGH/MEDIUM used for pricing recommendations  
- **ML Training**: Confidence weights for model training
- **Audit Trail**: Track matching algorithm improvements

## 🔧 **Performance Decisions**

### **8. Indexing Strategy: Composite + Specialized**

**Decision**: Multi-column indexes optimized for specific query patterns

**Strategy**:
```sql
-- Time-series analytics
idx_orders_sub_type_date ON (sub_order_type, order_datetime)

-- Text matching
idx_menu_items_name_trgm ON name USING gin(name gin_trgm_ops)

-- Revenue analysis  
idx_order_items_confidence ON (price_confidence) WHERE confidence IN ('HIGH', 'MEDIUM')
```

### **9. Caching Strategy: Materialized Views + Application Cache**

**Decision**: Database-level materialized views for complex aggregations

**Rationale**:
- **Consistency**: Single source of truth in database
- **Performance**: Sub-second response for dashboard queries
- **Automatic Refresh**: Scheduled updates maintain freshness
- **Memory Efficient**: PostgreSQL manages cache memory

### **10. Deployment Strategy: Docker + Infrastructure as Code**

**Decision**: Containerized deployment with automated setup scripts

**Components**:
- `setup_database.sh`: One-command PostgreSQL setup
- `docker-compose.yml`: Development environment
- `migrate_data.py`: Production data migration
- `requirements.txt`: Dependency management

## 🧪 **Data Quality Decisions**

### **11. Validation Framework: Multi-Layer Approach**

**Decision**: Revenue validation + Data quality metrics + Statistical checks

**Validation Layers**:
1. **Revenue Accuracy**: CSV total must match database total (±₹1)
2. **Data Completeness**: Track missing fields and malformed records  
3. **Business Logic**: Validate price ranges and item categories
4. **Statistical Validation**: Detect outliers and anomalies

### **12. Error Handling: Fail-Fast vs Graceful Degradation**

**Decision**: Graceful degradation with comprehensive logging

**Approach**:
- **Critical Errors**: Stop on database connection failures
- **Data Errors**: Skip malformed rows, log for review
- **Matching Failures**: Fall back to proportional allocation
- **Audit Trail**: Complete log of all decisions and fallbacks

## 🚀 **Scalability Decisions**

### **13. Multi-Tenant Architecture: Restaurant-Scoped**

**Decision**: Single database with restaurant_id partitioning

**Benefits**:
- **Cost Effective**: Shared infrastructure
- **Cross-Restaurant Analytics**: Compare performance across locations
- **Simplified Maintenance**: Single schema to maintain
- **Row-Level Security**: PostgreSQL RLS for data isolation

### **14. API Design: FastAPI + SQLAlchemy Ready**

**Decision**: Database schema optimized for REST API integration

**Design Principles**:
- **ORM Compatible**: SQLAlchemy models map directly to tables
- **RESTful Resources**: Tables align with API endpoints
- **Performance**: Eager loading patterns for related data
- **Versioning**: Schema evolution support

## 📈 **Analytics Decisions**

### **15. BCG Matrix Implementation: Percentile-Based**

**Decision**: Use percentile ranking instead of fixed thresholds

**Rationale**:
- **Adaptive**: Automatically adjusts to restaurant's item distribution
- **Meaningful**: Always provides balanced classification
- **Database Native**: PostgreSQL window functions for efficiency

### **16. Price Elasticity: Linear Regression + Validation**

**Decision**: Simple linear regression with extensive validation

**Validation Framework**:
- **Data Requirements**: Minimum 90 days, 10 transactions, 8% price variation
- **Statistical Tests**: R², p-value, confidence intervals
- **Business Logic**: Category-specific elasticity bounds
- **Economic Validation**: Reject unrealistic coefficients

## 🔒 **Security Decisions**

### **17. Data Protection: Encryption + Access Control**

**Security Measures**:
- **Connection Security**: SSL/TLS for all database connections
- **Access Control**: Role-based permissions (admin vs readonly)
- **Audit Logging**: Track all data modifications
- **GDPR Compliance**: Customer data protection framework

### **18. Credential Management: Environment Variables + Secrets**

**Decision**: Environment-based configuration with secure defaults

**Implementation**:
```bash
# Database configuration via environment
export DB_PASSWORD="$(cat /run/secrets/db_password)"
export DATABASE_URL="postgresql://user:$DB_PASSWORD@host/db"
```

## 🔮 **Future-Proofing Decisions**

### **19. Extension Points: Plugin Architecture**

**Design for Future Extensions**:
- **Custom Analytics**: Plugin system for new analysis types
- **External Integrations**: API gateway for third-party services
- **ML Pipeline**: Model versioning and A/B testing framework
- **Real-Time Processing**: Event streaming integration points

### **20. Technology Migration Path: Cloud-Native Ready**

**Cloud Migration Strategy**:
- **Container-First**: Docker deployment from day one
- **Kubernetes Ready**: StatefulSet configurations prepared  
- **Managed Services**: PostgreSQL RDS/CloudSQL compatibility
- **Microservices**: Database schema supports service decomposition

---

## 📋 **Decision Impact Summary**

| Decision | Impact on Performance | Impact on Accuracy | Impact on Maintainability |
|----------|---------------------|-------------------|-------------------------|
| PostgreSQL over SQLite | ✅ High | ✅ High | ✅ High |
| Normalized Schema | ✅ High | ✅ High | ✅ High |
| Hybrid Revenue Allocation | ⚡ Medium | ✅ Critical | ✅ High |
| Fuzzy Matching | ⚡ Medium | ✅ High | ✅ High |
| Materialized Views | ✅ Critical | ✅ High | ⚡ Medium |
| Docker Deployment | ✅ High | ⚡ N/A | ✅ Critical |

**Key**: ✅ Positive Impact | ⚡ Neutral | ❌ Negative Impact

---

**These decisions prioritize accuracy, performance, and maintainability while ensuring production readiness and future scalability.**