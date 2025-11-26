# Industry-Standard ML Engineering Architecture
## Menu Engineering AI Platform - Complete Technical Specification

**Version:** 1.0  
**Author:** Principal AI/ML Engineer  
**Date:** November 2025  
**Purpose:** Learning-focused ML system with production-grade architecture

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [System Architecture Overview](#system-architecture-overview)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Database Design](#database-design)
6. [ML Model Architecture](#ml-model-architecture)
7. [API Design](#api-design)
8. [MLOps Pipeline](#mlops-pipeline)
9. [Testing Strategy](#testing-strategy)
10. [Deployment Architecture](#deployment-architecture)
11. [16-Week Implementation Roadmap](#16-week-implementation-roadmap)
12. [Learning Resources](#learning-resources)

---

## Executive Summary

### Project Goals
Build a production-grade ML system that:
- **Learning**: Teaches industry-standard ML engineering practices
- **Business Value**: Optimizes restaurant menu profitability through AI
- **Career Development**: Portfolio piece demonstrating ML engineering expertise

### Why This Architecture
This design follows patterns used at FAANG companies and top ML organizations:
- **Scalable**: Handles growth from 1 to 1000+ restaurants
- **Maintainable**: Clean separation of concerns, comprehensive testing
- **Observable**: Full monitoring, logging, and experiment tracking
- **Reproducible**: Version-controlled models, data, and infrastructure

### Key Learning Outcomes
By building this system, you'll master:
- Production ML model development (scikit-learn → XGBoost → PyTorch)
- MLOps workflows (MLflow, experiment tracking, model registry)
- API development (FastAPI, REST design, async processing)
- Database design (PostgreSQL, time-series optimization)
- DevOps (Docker, Kubernetes, CI/CD)
- Testing (unit, integration, ML-specific tests)
- Monitoring (Prometheus, Grafana, observability)

---

## System Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Client Layer                           │
│  (React Frontend / API Clients / Mobile Apps)               │
└─────────────────┬───────────────────────────────────────────┘
                  │ HTTPS/REST
                  ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway                              │
│         (Load Balancer + Rate Limiting)                     │
└─────────────────┬───────────────────────────────────────────┘
                  │
        ┌─────────┴──────────┐
        ▼                    ▼
┌──────────────┐    ┌──────────────────┐
│  FastAPI     │    │  Background      │
│  Servers     │◄───┤  Workers         │
│  (Sync API)  │    │  (Celery/Redis)  │
└──────┬───────┘    └─────────┬────────┘
       │                      │
       ├──────────────────────┤
       ▼                      ▼
┌─────────────────────────────────────┐
│         Data Layer                  │
│  ┌──────────────┐  ┌─────────────┐ │
│  │ PostgreSQL   │  │   Redis     │ │
│  │ (Primary DB) │  │   (Cache)   │ │
│  └──────────────┘  └─────────────┘ │
└─────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│         ML Layer                    │
│  ┌──────────────┐  ┌─────────────┐ │
│  │   MLflow     │  │   Models    │ │
│  │  (Registry)  │  │  (Serving)  │ │
│  └──────────────┘  └─────────────┘ │
└─────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│      Monitoring Layer               │
│  ┌──────────────┐  ┌─────────────┐ │
│  │ Prometheus   │  │   Grafana   │ │
│  │  (Metrics)   │  │ (Dashboard) │ │
│  └──────────────┘  └─────────────┘ │
└─────────────────────────────────────┘
```

### Component Responsibilities

**API Layer (FastAPI)**
- Request validation (Pydantic)
- Authentication/authorization
- Rate limiting
- Response serialization
- Async request handling

**ML Layer**
- Model training (offline)
- Model serving (online)
- Feature engineering
- Prediction generation
- Experiment tracking

**Data Layer**
- Transaction storage (PostgreSQL)
- Feature caching (Redis)
- Analytics queries (TimescaleDB)
- Data validation

**Background Workers (Celery)**
- Scheduled model retraining
- Batch predictions
- Report generation
- Data pipeline orchestration

**Monitoring**
- Application metrics (Prometheus)
- Model performance tracking
- System health monitoring
- Alerting

---

## Technology Stack

### Core Technologies

#### Backend
```yaml
Language: Python 3.11+
Framework: FastAPI 0.104+
ORM: SQLAlchemy 2.0+
Migrations: Alembic 1.12+
Validation: Pydantic 2.5+
```

**Why FastAPI:**
- Automatic API documentation (OpenAPI/Swagger)
- Native async support (handle concurrent requests efficiently)
- Type hints everywhere (better IDE support, fewer bugs)
- Fastest Python framework (important for inference latency)
- Industry standard for ML APIs

#### Database
```yaml
Primary: PostgreSQL 15+
Extension: TimescaleDB (time-series optimization)
Cache: Redis 7+
```

**Why PostgreSQL:**
- ACID compliance (data integrity)
- JSON support (flexible schemas)
- Full-text search
- Mature ecosystem
- Industry standard

#### ML Stack
```yaml
Classical ML: scikit-learn 1.3+
Gradient Boosting: XGBoost 2.0+ / LightGBM 4.0+
Deep Learning: PyTorch 2.1+
Experiment Tracking: MLflow 2.8+
Hyperparameter Tuning: Optuna 3.4+
Feature Store: Feast 0.35+ (advanced)
```

**Learning Path:**
1. Start: scikit-learn (classical ML fundamentals)
2. Intermediate: XGBoost (gradient boosting, advanced ML)
3. Advanced: PyTorch (deep learning, neural networks)
4. Production: MLflow (experiment tracking, model registry)

#### Data Processing
```yaml
Data Manipulation: pandas 2.1+
Numerical Computing: numpy 1.24+
Data Validation: Great Expectations 0.18+
```

#### API & Async
```yaml
HTTP Client: httpx 0.25+ (async)
Task Queue: Celery 5.3+
Message Broker: Redis 7+ (also used for caching)
```

#### Testing
```yaml
Testing Framework: pytest 7.4+
Coverage: pytest-cov 4.1+
Mocking: pytest-mock 3.12+
Fixtures: factory-boy 3.3+
API Testing: httpx (built into FastAPI testing)
```

#### DevOps
```yaml
Containerization: Docker 24+
Orchestration: Kubernetes 1.28+ (advanced)
CI/CD: GitHub Actions
IaC: Terraform 1.6+ (optional)
```

#### Monitoring
```yaml
Metrics: Prometheus 2.47+
Visualization: Grafana 10.0+
Logging: structlog 23.2+
Error Tracking: Sentry 1.38+
APM: Datadog / New Relic (optional)
```

### Development Tools
```yaml
Package Management: uv (faster than pip)
Linting: Ruff (replaces flake8, black, isort)
Type Checking: mypy 1.7+
Pre-commit Hooks: pre-commit 3.5+
Documentation: MkDocs 1.5+ (with Material theme)
```

---

## Project Structure

```
menu-ml-platform/
│
├── .github/                         # GitHub configuration
│   └── workflows/
│       ├── ci.yml                   # Continuous Integration
│       ├── cd.yml                   # Continuous Deployment
│       ├── ml-training.yml          # Scheduled model training
│       └── code-quality.yml         # Linting, type checking
│
├── src/                             # Source code
│   ├── __init__.py
│   │
│   ├── data/                        # Data engineering
│   │   ├── __init__.py
│   │   ├── ingestion.py            # Load data from sources
│   │   ├── validation.py           # Data quality checks (Great Expectations)
│   │   ├── preprocessing.py        # Clean & transform
│   │   └── feature_engineering.py  # Create ML features
│   │
│   ├── models/                      # ML models
│   │   ├── __init__.py
│   │   ├── base.py                 # Abstract base model class
│   │   ├── menu_classifier.py      # Classification (Stars/Dogs/etc)
│   │   ├── price_optimizer.py      # Regression (price elasticity)
│   │   ├── demand_forecaster.py    # Time-series (XGBoost/LSTM)
│   │   └── cross_sell.py           # Association rules (recommendations)
│   │
│   ├── training/                    # Model training
│   │   ├── __init__.py
│   │   ├── train.py                # Training orchestration
│   │   ├── evaluate.py             # Model evaluation
│   │   ├── hyperparameter_tuning.py # HPO with Optuna
│   │   └── registry.py             # MLflow model registry ops
│   │
│   ├── api/                         # REST API
│   │   ├── __init__.py
│   │   ├── main.py                 # FastAPI app
│   │   ├── dependencies.py         # Shared dependencies
│   │   │
│   │   ├── routes/
│   │   │   ├── __init__.py
│   │   │   ├── predictions.py      # ML prediction endpoints
│   │   │   ├── analytics.py        # Analytics endpoints
│   │   │   ├── restaurants.py      # Restaurant CRUD
│   │   │   └── health.py           # Health checks
│   │   │
│   │   └── schemas/                # Pydantic models
│   │       ├── __init__.py
│   │       ├── base.py
│   │       ├── restaurant.py
│   │       ├── menu.py
│   │       ├── prediction.py
│   │       └── analytics.py
│   │
│   ├── db/                          # Database layer
│   │   ├── __init__.py
│   │   ├── base.py                 # SQLAlchemy Base
│   │   ├── session.py              # Database sessions
│   │   ├── models/                 # ORM models
│   │   │   ├── __init__.py
│   │   │   ├── restaurant.py
│   │   │   ├── menu_item.py
│   │   │   ├── transaction.py
│   │   │   └── analysis.py
│   │   └── repositories/           # Data access layer
│   │       ├── __init__.py
│   │       ├── base.py
│   │       ├── restaurant.py
│   │       └── transaction.py
│   │
│   ├── workers/                     # Background tasks
│   │   ├── __init__.py
│   │   ├── celery_app.py          # Celery configuration
│   │   ├── tasks/
│   │   │   ├── __init__.py
│   │   │   ├── training.py        # Model training tasks
│   │   │   ├── predictions.py     # Batch predictions
│   │   │   └── reports.py         # Report generation
│   │   └── schedules.py           # Celery beat schedules
│   │
│   ├── utils/                       # Utilities
│   │   ├── __init__.py
│   │   ├── logging.py              # Structured logging
│   │   ├── metrics.py              # Custom Prometheus metrics
│   │   ├── config.py               # Configuration management
│   │   └── exceptions.py           # Custom exceptions
│   │
│   └── migrations/                  # Alembic migrations
│       ├── env.py
│       ├── script.py.mako
│       └── versions/
│
├── tests/                           # Test suite
│   ├── __init__.py
│   ├── conftest.py                 # Pytest configuration & fixtures
│   │
│   ├── unit/                        # Unit tests
│   │   ├── test_preprocessing.py
│   │   ├── test_features.py
│   │   ├── test_models.py
│   │   └── test_utils.py
│   │
│   ├── integration/                 # Integration tests
│   │   ├── test_api.py
│   │   ├── test_database.py
│   │   └── test_pipeline.py
│   │
│   └── ml/                          # ML-specific tests
│       ├── test_model_training.py
│       ├── test_model_serving.py
│       └── test_data_validation.py
│
├── notebooks/                       # Jupyter notebooks
│   ├── 01_eda.ipynb                # Exploratory data analysis
│   ├── 02_feature_engineering.ipynb
│   ├── 03_model_experiments.ipynb
│   └── 04_error_analysis.ipynb
│
├── mlflow/                          # MLflow artifacts
│   ├── mlruns/                     # Experiment runs
│   └── models/                     # Model registry storage
│
├── deployment/                      # Deployment configs
│   ├── docker/
│   │   ├── Dockerfile.api          # API service
│   │   ├── Dockerfile.worker       # Background worker
│   │   ├── Dockerfile.mlflow       # MLflow server
│   │   └── docker-compose.yml      # Local development
│   │
│   ├── kubernetes/
│   │   ├── namespace.yaml
│   │   ├── api-deployment.yaml
│   │   ├── worker-deployment.yaml
│   │   ├── postgres-statefulset.yaml
│   │   ├── redis-deployment.yaml
│   │   ├── services.yaml
│   │   └── ingress.yaml
│   │
│   └── terraform/                   # Infrastructure as code
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── modules/
│
├── monitoring/                      # Monitoring configs
│   ├── prometheus/
│   │   └── prometheus.yml
│   ├── grafana/
│   │   └── dashboards/
│   │       ├── api-metrics.json
│   │       └── ml-metrics.json
│   └── alerts/
│       └── alerting-rules.yml
│
├── scripts/                         # Utility scripts
│   ├── train_model.py              # CLI for training
│   ├── evaluate_model.py           # CLI for evaluation
│   ├── deploy_model.py             # CLI for deployment
│   ├── seed_database.py            # Seed test data
│   └── backup_database.sh          # Database backup
│
├── docs/                            # Documentation
│   ├── index.md
│   ├── architecture.md
│   ├── api.md
│   ├── ml-system-design.md
│   └── deployment.md
│
├── .env.example                     # Environment variables template
├── .gitignore
├── .pre-commit-config.yaml         # Pre-commit hooks
├── pyproject.toml                   # Python project config (uv)
├── requirements.txt                 # Production dependencies
├── requirements-dev.txt             # Development dependencies
├── Makefile                         # Common commands
├── README.md
└── LICENSE
```

### Directory Explanations

**src/data/** - Data engineering pipeline
- Ingestion: Load data from various sources (CSV, databases, APIs)
- Validation: Ensure data quality using Great Expectations
- Preprocessing: Clean, normalize, handle missing values
- Feature Engineering: Create ML features from raw data

**src/models/** - ML model implementations
- Base class enforces consistent interface
- Each model is self-contained (training + inference)
- Models inherit from base class for consistency

**src/training/** - Training orchestration
- Centralized training logic
- Experiment tracking with MLflow
- Hyperparameter tuning
- Model registration

**src/api/** - REST API implementation
- FastAPI application
- Routes organized by domain
- Pydantic schemas for validation
- Dependency injection for database sessions

**src/db/** - Database layer
- SQLAlchemy ORM models
- Repository pattern (abstracts data access)
- Database session management
- Alembic migrations

**src/workers/** - Background job processing
- Celery tasks for long-running operations
- Scheduled jobs (model retraining, reports)
- Batch predictions

**tests/** - Comprehensive test suite
- Unit tests: Test individual functions/classes
- Integration tests: Test component interactions
- ML tests: Model performance, data validation

**deployment/** - Deployment configurations
- Docker: Containerization
- Kubernetes: Orchestration
- Terraform: Infrastructure as code

---

## Database Design

### Entity-Relationship Diagram

```
┌─────────────────┐
│  restaurants    │
├─────────────────┤
│ id (PK)         │
│ name            │
│ owner_email     │
│ created_at      │
└────────┬────────┘
         │
         │ 1:N
         │
┌────────▼────────┐
│  menu_items     │
├─────────────────┤
│ id (PK)         │
│ restaurant_id   │
│ name            │
│ current_price   │
│ food_cost       │
│ is_active       │
└────────┬────────┘
         │
         │ 1:N
         │
┌────────▼──────────┐
│ transaction_items │
├───────────────────┤
│ id (PK)           │
│ transaction_id    │
│ menu_item_id      │
│ quantity          │
│ unit_price        │
└─────────┬─────────┘
          │
          │ N:1
          │
┌─────────▼────────┐
│  transactions    │
├──────────────────┤
│ id (PK)          │
│ restaurant_id    │
│ transaction_date │
│ total            │
│ order_type       │
└──────────────────┘
```

### Core Tables

#### restaurants
```sql
CREATE TABLE restaurants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    owner_email VARCHAR(255) NOT NULL UNIQUE,
    owner_name VARCHAR(255),
    
    -- Settings
    currency VARCHAR(3) DEFAULT 'USD',
    timezone VARCHAR(50) DEFAULT 'UTC',
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,  -- Soft delete
    
    -- Indexes
    CONSTRAINT restaurants_email_unique UNIQUE (owner_email)
);

CREATE INDEX idx_restaurants_email ON restaurants(owner_email) 
    WHERE deleted_at IS NULL;
```

**Design Decisions:**
- UUID for primary keys (better for distributed systems)
- Soft delete (keep historical data, set deleted_at instead of DELETE)
- Timestamps (track when everything happened)
- Settings (currency, timezone) stored per restaurant

#### menu_items
```sql
CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    category_id UUID REFERENCES menu_categories(id) ON DELETE SET NULL,
    
    -- Basic info
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Pricing
    current_price DECIMAL(10,2) NOT NULL,
    food_cost DECIMAL(10,2),  -- NULL if unknown
    
    -- Operational
    prep_time_minutes INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Flexible metadata (JSON for extensibility)
    metadata JSONB DEFAULT '{}',
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT menu_items_name_unique UNIQUE (restaurant_id, name, deleted_at),
    CONSTRAINT menu_items_price_positive CHECK (current_price > 0)
);

-- Indexes
CREATE INDEX idx_menu_items_restaurant ON menu_items(restaurant_id) 
    WHERE deleted_at IS NULL;
CREATE INDEX idx_menu_items_active ON menu_items(restaurant_id, is_active) 
    WHERE deleted_at IS NULL;
```

**Design Decisions:**
- JSONB metadata (flexible schema for custom attributes)
- Decimal for prices (avoid floating point errors)
- Constraints (ensure data integrity)
- Indexes on frequently queried columns

#### transactions
```sql
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    
    -- Transaction info
    external_id VARCHAR(255),  -- POS transaction ID
    transaction_date TIMESTAMPTZ NOT NULL,
    
    -- Classification
    order_type VARCHAR(50),  -- dine-in, takeout, delivery
    service_period VARCHAR(50),  -- breakfast, lunch, dinner
    
    -- Totals
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2),
    tip DECIMAL(10,2),
    total DECIMAL(10,2) NOT NULL,
    
    -- Context (for ML features)
    weather_condition VARCHAR(50),
    day_of_week INTEGER,  -- 0=Monday, 6=Sunday
    hour_of_day INTEGER,  -- 0-23
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes (critical for query performance)
CREATE INDEX idx_transactions_restaurant_date ON transactions(
    restaurant_id, 
    transaction_date DESC
);
CREATE INDEX idx_transactions_date ON transactions(transaction_date DESC);
```

**Design Decisions:**
- Denormalized context (day_of_week, hour_of_day) for faster ML queries
- external_id links to POS system
- Multiple indexes for different query patterns

#### transaction_items
```sql
CREATE TABLE transaction_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    menu_item_id UUID NOT NULL REFERENCES menu_items(id),
    
    -- Item details at time of sale
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    item_name VARCHAR(255) NOT NULL,  -- Denormalized for history
    
    -- Modifiers (JSON array)
    modifiers JSONB DEFAULT '[]',
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes (most queried table)
CREATE INDEX idx_transaction_items_transaction ON transaction_items(transaction_id);
CREATE INDEX idx_transaction_items_menu_item ON transaction_items(menu_item_id);
CREATE INDEX idx_transaction_items_composite ON transaction_items(
    menu_item_id, 
    transaction_id
);
```

**Design Decisions:**
- Denormalized item_name (preserve history if menu item changes)
- JSONB modifiers (flexible, searchable)
- Composite indexes for common join patterns

### Materialized Views (Performance Optimization)

#### menu_item_performance
```sql
CREATE MATERIALIZED VIEW menu_item_performance AS
SELECT 
    mi.id as menu_item_id,
    mi.restaurant_id,
    mi.name,
    mi.current_price,
    mi.food_cost,
    
    -- Sales metrics
    COUNT(DISTINCT ti.transaction_id) as order_count,
    SUM(ti.quantity) as total_quantity_sold,
    SUM(ti.quantity * ti.unit_price) as total_revenue,
    AVG(ti.unit_price) as avg_selling_price,
    
    -- Profitability
    CASE 
        WHEN mi.food_cost IS NOT NULL 
        THEN SUM(ti.quantity * (ti.unit_price - mi.food_cost))
        ELSE NULL 
    END as total_contribution_margin,
    
    -- Rankings (for classification)
    PERCENT_RANK() OVER (
        PARTITION BY mi.restaurant_id 
        ORDER BY SUM(ti.quantity)
    ) as popularity_percentile,
    
    PERCENT_RANK() OVER (
        PARTITION BY mi.restaurant_id 
        ORDER BY SUM(ti.quantity * (ti.unit_price - COALESCE(mi.food_cost, 0)))
    ) as profitability_percentile,
    
    MAX(t.transaction_date) as last_sold_date
    
FROM menu_items mi
LEFT JOIN transaction_items ti ON mi.id = ti.menu_item_id
LEFT JOIN transactions t ON ti.transaction_id = t.id
WHERE mi.deleted_at IS NULL
GROUP BY mi.id, mi.restaurant_id, mi.name, mi.current_price, mi.food_cost;

-- Unique index (required for CONCURRENTLY refresh)
CREATE UNIQUE INDEX idx_menu_item_performance_pk 
    ON menu_item_performance(menu_item_id);

-- Refresh function (call daily)
CREATE OR REPLACE FUNCTION refresh_menu_performance()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY menu_item_performance;
END;
$$ LANGUAGE plpgsql;
```

**Why Materialized Views:**
- Pre-compute expensive aggregations
- Avoid scanning millions of transaction rows on every query
- Refresh nightly or on-demand
- 10-100x faster queries

### TimescaleDB Extension (Time-Series Optimization)

```sql
-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Convert transactions to hypertable (time-series optimization)
SELECT create_hypertable('transactions', 'transaction_date');

-- Automatic data retention (keep 2 years)
SELECT add_retention_policy('transactions', INTERVAL '2 years');

-- Continuous aggregates (automatic materialized views)
CREATE MATERIALIZED VIEW daily_sales
WITH (timescaledb.continuous) AS
SELECT 
    time_bucket('1 day', transaction_date) as day,
    restaurant_id,
    COUNT(*) as transaction_count,
    SUM(total) as daily_revenue,
    AVG(total) as avg_transaction_value
FROM transactions
GROUP BY day, restaurant_id;
```

**TimescaleDB Benefits:**
- 20x faster queries on time-series data
- Automatic data compression (save 90% storage)
- Continuous aggregates (auto-updating materialized views)
- Data retention policies (automatic cleanup)

---

## ML Model Architecture

### Base Model Class (Design Pattern)

All models inherit from this base class to ensure consistent interface:

```python
# src/models/base.py
from abc import ABC, abstractmethod
from typing import Any, Dict, Optional
import mlflow
import joblib
from pathlib import Path
import pandas as pd

class BaseModel(ABC):
    """
    Abstract base class for all ML models
    
    Design Pattern: Template Method Pattern
    - Defines skeleton of algorithm
    - Subclasses implement specific steps
    
    Benefits:
    - Consistent interface across all models
    - Shared functionality (save/load, MLflow logging)
    - Forces implementation of key methods
    """
    
    def __init__(self, model_name: str):
        self.model_name = model_name
        self.model = None
        self.metrics = {}
        self.feature_names = []
        self.version = "1.0.0"
    
    @abstractmethod
    def train(self, X, y, **kwargs):
        """
        Train the model
        
        Args:
            X: Training features (pandas DataFrame or numpy array)
            y: Training labels
            **kwargs: Additional training parameters
            
        Returns:
            self: Trained model instance
        """
        pass
    
    @abstractmethod
    def predict(self, X) -> Any:
        """
        Make predictions
        
        Args:
            X: Features to predict on
            
        Returns:
            Predictions (format depends on model type)
        """
        pass
    
    def evaluate(self, X, y) -> Dict[str, float]:
        """
        Evaluate model performance
        
        Args:
            X: Test features
            y: True labels
            
        Returns:
            Dictionary of metrics
        """
        # Default implementation - override for custom metrics
        predictions = self.predict(X)
        
        from sklearn.metrics import mean_squared_error, r2_score
        return {
            'mse': mean_squared_error(y, predictions),
            'r2': r2_score(y, predictions)
        }
    
    def save(self, path: Path):
        """
        Save model to disk
        
        Args:
            path: Directory to save model
        """
        path.mkdir(parents=True, exist_ok=True)
        
        # Save model
        model_path = path / f"{self.model_name}.joblib"
        joblib.dump(self.model, model_path)
        
        # Save metadata
        metadata = {
            'model_name': self.model_name,
            'version': self.version,
            'feature_names': self.feature_names,
            'metrics': self.metrics
        }
        
        metadata_path = path / "metadata.json"
        import json
        with open(metadata_path, 'w') as f:
            json.dump(metadata, f, indent=2)
    
    def load(self, path: Path):
        """
        Load model from disk
        
        Args:
            path: Directory containing saved model
        """
        model_path = path / f"{self.model_name}.joblib"
        self.model = joblib.load(model_path)
        
        # Load metadata
        metadata_path = path / "metadata.json"
        import json
        with open(metadata_path, 'r') as f:
            metadata = json.load(f)
        
        self.feature_names = metadata['feature_names']
        self.metrics = metadata['metrics']
        self.version = metadata['version']
    
    def log_to_mlflow(self, experiment_name: str):
        """
        Log model and metrics to MLflow
        
        Args:
            experiment_name: MLflow experiment name
        """
        mlflow.set_experiment(experiment_name)
        
        with mlflow.start_run(run_name=self.model_name):
            # Log parameters
            mlflow.log_params(self.get_params())
            
            # Log metrics
            mlflow.log_metrics(self.metrics)
            
            # Log model
            mlflow.sklearn.log_model(self.model, "model")
            
            # Log feature names
            mlflow.log_dict(
                {'features': self.feature_names},
                "features.json"
            )
    
    @abstractmethod
    def get_params(self) -> Dict[str, Any]:
        """
        Get model hyperparameters
        
        Returns:
            Dictionary of hyperparameters
        """
        pass
    
    def __repr__(self):
        return f"{self.__class__.__name__}(name='{self.model_name}')"
```

### Model 1: Menu Classifier

**Problem**: Classify menu items into performance quadrants  
**Algorithm**: Random Forest Classifier  
**Learning**: Multi-class classification, feature engineering

```python
# src/models/menu_classifier.py
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score, train_test_split
from sklearn.metrics import classification_report, confusion_matrix
from typing import Dict, Any

from .base import BaseModel

class MenuClassifier(BaseModel):
    """
    Classify menu items into quadrants:
    - STAR: High profit, high popularity (feature & promote)
    - PLOWHORSE: Low profit, high popularity (raise price or reduce cost)
    - PUZZLE: High profit, low popularity (improve marketing)
    - DOG: Low profit, low popularity (consider removing)
    
    ML Technique: Random Forest Classification
    
    Learning Objectives:
    - Feature engineering from transactional data
    - Multi-class classification
    - Cross-validation
    - Model interpretability (feature importance)
    """
    
    def __init__(self, n_estimators: int = 100, max_depth: int = 10):
        super().__init__("menu_classifier")
        
        self.n_estimators = n_estimators
        self.max_depth = max_depth
        
        self.scaler = StandardScaler()
        self.model = RandomForestClassifier(
            n_estimators=n_estimators,
            max_depth=max_depth,
            random_state=42,
            n_jobs=-1  # Use all CPU cores
        )
    
    def engineer_features(self, sales_df: pd.DataFrame) -> pd.DataFrame:
        """
        Engineer features from transaction data
        
        Feature Engineering Patterns:
        1. Aggregation: Count, sum, average
        2. Ratios: Revenue per order, margin percentage
        3. Rankings: Percentile ranks for popularity/profitability
        4. Time-based: Recency, velocity
        
        Args:
            sales_df: Transaction data with columns:
                - item_name
                - transaction_id
                - quantity
                - unit_price
                - food_cost
                - transaction_date
        
        Returns:
            DataFrame with engineered features per item
        """
        # Aggregate by item
        features = sales_df.groupby('item_name').agg({
            'transaction_id': 'nunique',     # Frequency (how many orders)
            'quantity': 'sum',                # Volume (total sold)
            'unit_price': ['mean', 'std'],   # Price statistics
        })
        
        # Flatten multi-level columns
        features.columns = ['_'.join(col).strip() for col in features.columns]
        
        # Calculate revenue
        revenue_df = sales_df.groupby('item_name').apply(
            lambda x: (x['quantity'] * x['unit_price']).sum()
        )
        features['total_revenue'] = revenue_df
        
        # Contribution margin (if cost data available)
        if 'food_cost' in sales_df.columns:
            cost_df = sales_df.groupby('item_name')['food_cost'].mean()
            features['avg_food_cost'] = cost_df
            
            features['contribution_margin'] = (
                features['unit_price_mean'] - features['avg_food_cost']
            )
            
            features['margin_pct'] = (
                features['contribution_margin'] / features['unit_price_mean'] * 100
            )
        
        # Popularity metrics
        features['revenue_per_order'] = (
            features['total_revenue'] / features['transaction_id_nunique']
        )
        
        # Percentile rankings (key for classification)
        features['popularity_percentile'] = (
            features['quantity_sum'].rank(pct=True)
        )
        
        if 'contribution_margin' in features.columns:
            # Rank by absolute profit
            features['profitability_percentile'] = (
                (features['contribution_margin'] * features['quantity_sum'])
                .rank(pct=True)
            )
        else:
            # Fallback to revenue if no cost data
            features['profitability_percentile'] = (
                features['total_revenue'].rank(pct=True)
            )
        
        # Recency (days since last sale)
        if 'transaction_date' in sales_df.columns:
            last_sale = sales_df.groupby('item_name')['transaction_date'].max()
            features['days_since_last_sale'] = (
                pd.Timestamp.now() - last_sale
            ).dt.days
        
        return features
    
    def create_labels(self, features: pd.DataFrame) -> pd.Series:
        """
        Create classification labels based on percentiles
        
        Classification Logic:
        - Threshold at 50th percentile (median)
        - STAR: Above median in both dimensions
        - PLOWHORSE: Above median popularity, below median profit
        - PUZZLE: Below median popularity, above median profit
        - DOG: Below median in both dimensions
        
        Args:
            features: DataFrame with popularity_percentile and 
                     profitability_percentile columns
        
        Returns:
            Series of labels
        """
        threshold = 0.5  # 50th percentile
        
        labels = []
        for _, row in features.iterrows():
            pop = row['popularity_percentile']
            prof = row['profitability_percentile']
            
            if pop >= threshold and prof >= threshold:
                labels.append('STAR')
            elif pop >= threshold and prof < threshold:
                labels.append('PLOWHORSE')
            elif pop < threshold and prof >= threshold:
                labels.append('PUZZLE')
            else:
                labels.append('DOG')
        
        return pd.Series(labels, index=features.index, name='label')
    
    def train(self, sales_df: pd.DataFrame, test_size: float = 0.2, **kwargs):
        """
        Train the menu classification model
        
        Training Pipeline:
        1. Feature engineering
        2. Label creation
        3. Train/test split
        4. Feature scaling
        5. Model training
        6. Cross-validation
        7. Evaluation
        
        Args:
            sales_df: Transaction data
            test_size: Fraction of data for testing
            **kwargs: Additional parameters
        
        Returns:
            self: Trained model
        """
        print(f"🏋️ Training {self.model_name}...")
        
        # Feature engineering
        features = self.engineer_features(sales_df)
        labels = self.create_labels(features)
        
        # Select features for training
        feature_cols = [
            'quantity_sum',
            'transaction_id_nunique',
            'unit_price_mean',
            'revenue_per_order',
            'popularity_percentile',
            'profitability_percentile'
        ]
        
        # Add optional features if available
        if 'margin_pct' in features.columns:
            feature_cols.append('margin_pct')
        if 'days_since_last_sale' in features.columns:
            feature_cols.append('days_since_last_sale')
        
        X = features[feature_cols]
        y = labels
        
        self.feature_names = feature_cols
        
        # Train/test split
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=42, stratify=y
        )
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Train model
        self.model.fit(X_train_scaled, y_train)
        
        # Evaluate on test set
        test_score = self.model.score(X_test_scaled, y_test)
        
        # Cross-validation on full dataset
        X_full_scaled = self.scaler.transform(X)
        cv_scores = cross_val_score(
            self.model,
            X_full_scaled,
            y,
            cv=5,
            scoring='accuracy'
        )
        
        # Generate predictions for detailed metrics
        y_pred = self.model.predict(X_test_scaled)
        
        # Store metrics
        self.metrics = {
            'test_accuracy': test_score,
            'cv_mean_accuracy': cv_scores.mean(),
            'cv_std_accuracy': cv_scores.std(),
            'n_train_samples': len(X_train),
            'n_test_samples': len(X_test),
            'n_features': len(self.feature_names)
        }
        
        # Generate detailed classification report
        report = classification_report(y_test, y_pred, output_dict=True)
        for label, metrics in report.items():
            if isinstance(metrics, dict):
                for metric_name, value in metrics.items():
                    self.metrics[f'{label}_{metric_name}'] = value
        
        # Feature importance
        self.feature_importance = pd.DataFrame({
            'feature': self.feature_names,
            'importance': self.model.feature_importances_
        }).sort_values('importance', ascending=False)
        
        print(f"✅ Training complete!")
        print(f"   Test Accuracy: {test_score:.3f}")
        print(f"   CV Accuracy: {cv_scores.mean():.3f} (±{cv_scores.std():.3f})")
        print(f"\n📊 Feature Importance:")
        print(self.feature_importance.to_string(index=False))
        
        return self
    
    def predict(self, sales_df: pd.DataFrame) -> pd.DataFrame:
        """
        Classify menu items
        
        Args:
            sales_df: Transaction data
        
        Returns:
            DataFrame with predictions and probabilities
        """
        # Feature engineering
        features = self.engineer_features(sales_df)
        
        # Select same features used in training
        X = features[self.feature_names]
        
        # Scale
        X_scaled = self.scaler.transform(X)
        
        # Predict
        predictions = self.model.predict(X_scaled)
        probabilities = self.model.predict_proba(X_scaled)
        
        # Create results DataFrame
        results = features.copy()
        results['predicted_class'] = predictions
        results['confidence'] = probabilities.max(axis=1)
        
        # Add probability for each class
        for i, class_label in enumerate(self.model.classes_):
            results[f'prob_{class_label}'] = probabilities[:, i]
        
        return results
    
    def generate_recommendations(self, predictions: pd.DataFrame) -> pd.DataFrame:
        """
        Generate actionable recommendations based on classifications
        
        Args:
            predictions: Output from predict() method
        
        Returns:
            DataFrame with recommendations
        """
        recommendations = []
        
        for item_name, row in predictions.iterrows():
            classification = row['predicted_class']
            confidence = row['confidence']
            
            if classification == 'STAR':
                rec = {
                    'item_name': item_name,
                    'classification': classification,
                    'confidence': confidence,
                    'action': 'FEATURE',
                    'priority': 'HIGH',
                    'reason': 'High profit and popularity',
                    'suggestions': [
                        'Feature prominently on menu',
                        'Train staff to recommend',
                        'Consider slight price increase (5-10%)',
                        'Use in marketing campaigns'
                    ]
                }
            
            elif classification == 'PLOWHORSE':
                rec = {
                    'item_name': item_name,
                    'classification': classification,
                    'confidence': confidence,
                    'action': 'OPTIMIZE',
                    'priority': 'MEDIUM',
                    'reason': 'Popular but low profit margin',
                    'suggestions': [
                        f'Increase price by 5-10% (current: ${row["unit_price_mean"]:.2f})',
                        'Reduce portion size slightly',
                        'Negotiate better ingredient costs',
                        'Simplify preparation to reduce labor'
                    ]
                }
            
            elif classification == 'PUZZLE':
                rec = {
                    'item_name': item_name,
                    'classification': classification,
                    'confidence': confidence,
                    'action': 'PROMOTE',
                    'priority': 'MEDIUM',
                    'reason': 'High profit but underperforming sales',
                    'suggestions': [
                        'Improve menu description',
                        'Reposition on menu (move higher)',
                        'Add professional photo',
                        'Train staff to recommend',
                        'Run promotional campaign',
                        'Test lower price point'
                    ]
                }
            
            elif classification == 'DOG':
                rec = {
                    'item_name': item_name,
                    'classification': classification,
                    'confidence': confidence,
                    'action': 'REMOVE_OR_REVAMP',
                    'priority': 'LOW',
                    'reason': 'Low profit and low popularity',
                    'suggestions': [
                        'Consider removing from menu',
                        'Reformulate recipe to reduce costs',
                        'Rebrand/rename item',
                        'Replace with better alternative',
                        f'Last sold {row.get("days_since_last_sale", "N/A")} days ago'
                    ]
                }
            
            recommendations.append(rec)
        
        return pd.DataFrame(recommendations)
    
    def get_params(self) -> Dict[str, Any]:
        """Get model hyperparameters"""
        return {
            'n_estimators': self.n_estimators,
            'max_depth': self.max_depth,
            'random_state': 42
        }
```

### Model 2: Price Optimizer

**Problem**: Determine optimal pricing for maximum profit  
**Algorithm**: Ridge Regression with Polynomial Features  
**Learning**: Price elasticity, optimization, non-linear relationships

```python
# src/models/price_optimizer.py
import pandas as pd
import numpy as np
from sklearn.preprocessing import PolynomialFeatures, StandardScaler
from sklearn.linear_model import Ridge
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
from sklearn.model_selection import train_test_split
from typing import Dict, Any, Tuple

from .base import BaseModel

class PriceOptimizer(BaseModel):
    """
    Optimize pricing using demand forecasting and elasticity estimation
    
    Economic Concept: Price Elasticity of Demand
    - How does quantity demanded change with price?
    - Elasticity = % change in quantity / % change in price
    - Elastic (|E| > 1): Demand very sensitive to price
    - Inelastic (|E| < 1): Demand not very sensitive to price
    
    ML Technique: Polynomial Regression
    - Captures non-linear relationship between price and demand
    - Ridge regularization prevents overfitting
    
    Learning Objectives:
    - Economic theory + ML
    - Polynomial regression
    - Optimization under constraints
    - Business metric optimization (profit, not just accuracy)
    """
    
    def __init__(self, poly_degree: int = 2, alpha: float = 1.0):
        super().__init__("price_optimizer")
        
        self.poly_degree = poly_degree
        self.alpha = alpha
        
        self.poly_features = PolynomialFeatures(degree=poly_degree)
        self.scaler = StandardScaler()
        self.model = Ridge(alpha=alpha)
        
        self.elasticities = {}  # Store elasticity by item
    
    def calculate_elasticity(
        self,
        price_history: pd.DataFrame,
        item_name: str
    ) -> float:
        """
        Calculate price elasticity of demand
        
        Formula: 
        Elasticity = (% change in quantity) / (% change in price)
        
        Interpretation:
        - E = -2: 1% price increase → 2% demand decrease
        - E = -0.5: 1% price increase → 0.5% demand decrease
        - More negative = more elastic (price sensitive)
        
        Args:
            price_history: DataFrame with price and quantity over time
            item_name: Item to calculate elasticity for
        
        Returns:
            Elasticity coefficient
        """
        item_data = price_history[
            price_history['item_name'] == item_name
        ].sort_values('date')
        
        if len(item_data) < 3:
            return None  # Not enough data
        
        # Calculate percentage changes
        item_data = item_data.copy()
        item_data['price_pct_change'] = item_data['price'].pct_change()
        item_data['quantity_pct_change'] = item_data['quantity'].pct_change()
        
        # Remove NaN and infinite values
        valid_data = item_data[
            np.isfinite(item_data['price_pct_change']) & 
            np.isfinite(item_data['quantity_pct_change']) &
            (item_data['price_pct_change'] != 0)  # Avoid division by zero
        ]
        
        if len(valid_data) < 2:
            return None
        
        # Calculate elasticity
        elasticity = (
            valid_data['quantity_pct_change'] / 
            valid_data['price_pct_change']
        ).median()  # Use median for robustness
        
        return elasticity
    
    def prepare_features(self, price_history: pd.DataFrame) -> Tuple[pd.DataFrame, pd.Series]:
        """
        Prepare features for demand prediction
        
        Features:
        - Price (main predictor)
        - Time features (day of week, hour)
        - Context features (weather, holidays)
        - Lagged features (past demand)
        
        Args:
            price_history: Historical data with:
                - item_name
                - date
                - price
                - quantity
                - day_of_week
                - hour
                - is_weekend
                - is_holiday (optional)
        
        Returns:
            Tuple of (features, target)
        """
        # Base features
        features = price_history[[
            'price',
            'day_of_week',
            'hour',
            'is_weekend',
        ]].copy()
        
        # Add optional features if available
        if 'is_holiday' in price_history.columns:
            features['is_holiday'] = price_history['is_holiday']
        
        if 'weather_temp' in price_history.columns:
            features['weather_temp'] = price_history['weather_temp']
        
        # Time-based features
        features['days_since_launch'] = (
            (price_history['date'] - price_history['date'].min()).dt.days
        )
        
        # Lagged demand (previous period's quantity)
        features['quantity_lag_1'] = price_history.groupby('item_name')['quantity'].shift(1)
        features['quantity_lag_7'] = price_history.groupby('item_name')['quantity'].shift(7)
        
        # Fill NaN in lagged features with median
        features['quantity_lag_1'].fillna(features['quantity_lag_1'].median(), inplace=True)
        features['quantity_lag_7'].fillna(features['quantity_lag_7'].median(), inplace=True)
        
        target = price_history['quantity']
        
        return features, target
    
    def train(self, price_history: pd.DataFrame, test_size: float = 0.2, **kwargs):
        """
        Train demand prediction model
        
        Training Pipeline:
        1. Prepare features
        2. Calculate elasticities
        3. Create polynomial features
        4. Train/test split
        5. Feature scaling
        6. Model training
        7. Evaluation
        
        Args:
            price_history: Historical price and sales data
            test_size: Fraction for testing
        
        Returns:
            self: Trained model
        """
        print(f"🏋️ Training {self.model_name}...")
        
        # Prepare features
        X, y = self.prepare_features(price_history)
        
        self.feature_names = X.columns.tolist()
        
        # Calculate elasticities for each item
        for item in price_history['item_name'].unique():
            elasticity = self.calculate_elasticity(price_history, item)
            if elasticity is not None:
                self.elasticities[item] = elasticity
        
        print(f"📊 Calculated elasticity for {len(self.elasticities)} items")
        
        # Train/test split
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=42
        )
        
        # Create polynomial features (capture non-linear price effects)
        X_train_poly = self.poly_features.fit_transform(X_train)
        X_test_poly = self.poly_features.transform(X_test)
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train_poly)
        X_test_scaled = self.scaler.transform(X_test_poly)
        
        # Train model
        self.model.fit(X_train_scaled, y_train)
        
        # Evaluate
        y_pred_train = self.model.predict(X_train_scaled)
        y_pred_test = self.model.predict(X_test_scaled)
        
        # Calculate metrics
        self.metrics = {
            'train_r2': r2_score(y_train, y_pred_train),
            'test_r2': r2_score(y_test, y_pred_test),
            'train_rmse': np.sqrt(mean_squared_error(y_train, y_pred_train)),
            'test_rmse': np.sqrt(mean_squared_error(y_test, y_pred_test)),
            'train_mae': mean_absolute_error(y_train, y_pred_train),
            'test_mae': mean_absolute_error(y_test, y_pred_test),
            'n_train_samples': len(X_train),
            'n_test_samples': len(X_test),
            'n_features': len(self.feature_names),
            'n_poly_features': X_train_poly.shape[1]
        }
        
        print(f"✅ Training complete!")
        print(f"   Test R²: {self.metrics['test_r2']:.3f}")
        print(f"   Test RMSE: {self.metrics['test_rmse']:.2f}")
        print(f"   Test MAE: {self.metrics['test_mae']:.2f}")
        
        return self
    
    def predict_demand(
        self,
        price: float,
        context: Dict[str, Any]
    ) -> float:
        """
        Predict demand at given price and context
        
        Args:
            price: Price point to test
            context: Dict with keys matching feature names
        
        Returns:
            Predicted quantity demanded
        """
        # Create feature vector
        features = pd.DataFrame([{
            'price': price,
            **context
        }])
        
        # Ensure all required features present
        for feat in self.feature_names:
            if feat not in features.columns:
                features[feat] = 0  # Default value
        
        features = features[self.feature_names]
        
        # Transform
        X_poly = self.poly_features.transform(features)
        X_scaled = self.scaler.transform(X_poly)
        
        # Predict
        demand = self.model.predict(X_scaled)[0]
        
        return max(0, demand)  # Demand can't be negative
    
    def optimize_price(
        self,
        item_name: str,
        current_price: float,
        food_cost: float,
        context: Dict[str, Any],
        price_range: Tuple[float, float] = None
    ) -> Dict[str, Any]:
        """
        Find optimal price that maximizes profit
        
        Optimization Problem:
        Maximize: Profit = (Price - Cost) × Demand(Price)
        Subject to: Price >= Cost (don't sell at loss)
                   Price in reasonable range
        
        Args:
            item_name: Name of menu item
            current_price: Current selling price
            food_cost: Cost to produce item
            context: Context features (day_of_week, etc.)
            price_range: Optional (min, max) price range
        
        Returns:
            Dict with optimal price and impact estimates
        """
        # Set price range if not provided
        if price_range is None:
            # Test ±30% of current price
            price_range = (
                max(food_cost * 1.2, current_price * 0.7),  # At least 20% margin
                current_price * 1.3
            )
        
        # Generate candidate prices
        candidate_prices = np.linspace(
            price_range[0],
            price_range[1],
            50  # Test 50 price points
        )
        
        # Calculate profit at each price
        profits = []
        demands = []
        
        for test_price in candidate_prices:
            # Predict demand at this price
            predicted_demand = self.predict_demand(test_price, context)
            demands.append(predicted_demand)
            
            # Calculate profit
            profit = (test_price - food_cost) * predicted_demand
            profits.append(profit)
        
        # Find optimal price
        optimal_idx = np.argmax(profits)
        optimal_price = candidate_prices[optimal_idx]
        optimal_demand = demands[optimal_idx]
        optimal_profit = profits[optimal_idx]
        
        # Current state for comparison
        current_demand = self.predict_demand(current_price, context)
        current_profit = (current_price - food_cost) * current_demand
        
        # Calculate changes
        price_change_pct = (optimal_price - current_price) / current_price * 100
        demand_change = optimal_demand - current_demand
        demand_change_pct = demand_change / current_demand * 100 if current_demand > 0 else 0
        profit_change = optimal_profit - current_profit
        profit_change_pct = profit_change / current_profit * 100 if current_profit > 0 else 0
        
        # Get elasticity if available
        elasticity = self.elasticities.get(item_name, None)
        
        # Determine confidence based on R²
        r2 = self.metrics.get('test_r2', 0)
        if r2 > 0.8:
            confidence = 'HIGH'
        elif r2 > 0.6:
            confidence = 'MEDIUM'
        else:
            confidence = 'LOW'
        
        # Generate recommendation text
        if abs(price_change_pct) < 2:
            recommendation = f"Current price (${current_price:.2f}) is near optimal. No change recommended."
        elif price_change_pct > 0:
            recommendation = f"Increase price to ${optimal_price:.2f} (+{price_change_pct:.1f}%) for {profit_change_pct:.1f}% more profit."
        else:
            recommendation = f"Decrease price to ${optimal_price:.2f} ({price_change_pct:.1f}%) to increase volume and profit by {profit_change_pct:.1f}%."
        
        # Warnings
        warnings = []
        if confidence == 'LOW':
            warnings.append("Low model confidence - collect more data before implementing")
        if abs(demand_change_pct) > 20:
            warnings.append("Large demand change predicted - consider gradual price adjustment")
        if optimal_price < food_cost * 1.3:
            warnings.append("Recommended price has low margin (<30%) - verify food cost accuracy")
        
        return {
            # Optimal
            'optimal_price': round(optimal_price, 2),
            'optimal_demand': round(optimal_demand, 1),
            'optimal_profit': round(optimal_profit, 2),
            
            # Current
            'current_price': round(current_price, 2),
            'current_demand': round(current_demand, 1),
            'current_profit': round(current_profit, 2),
            
            # Changes
            'price_change': round(optimal_price - current_price, 2),
            'price_change_pct': round(price_change_pct, 2),
            'demand_change': round(demand_change, 1),
            'demand_change_pct': round(demand_change_pct, 2),
            'profit_change': round(profit_change, 2),
            'profit_change_pct': round(profit_change_pct, 2),
            
            # Context
            'food_cost': food_cost,
            'elasticity': elasticity,
            'confidence': confidence,
            'model_r2': round(r2, 3),
            
            # Guidance
            'recommendation': recommendation,
            'warnings': warnings
        }
    
    def predict(self, X) -> np.ndarray:
        """
        Make demand predictions
        
        Args:
            X: Features (must match training features)
        
        Returns:
            Predicted demand
        """
        X_poly = self.poly_features.transform(X)
        X_scaled = self.scaler.transform(X_poly)
        return self.model.predict(X_scaled)
    
    def get_params(self) -> Dict[str, Any]:
        """Get model hyperparameters"""
        return {
            'poly_degree': self.poly_degree,
            'alpha': self.alpha
        }
```

---

## (Document continues with API Design, MLOps Pipeline, Testing Strategy, Deployment, and Learning Resources...)

**Due to length limitations, I'm creating the rest of the document in the next part. This is a comprehensive 100+ page document covering all aspects.**

Would you like me to:
1. Continue with the remaining sections (API, MLOps, Deployment, etc.)
2. Create this as a Word document (.docx) with proper formatting
3. Convert to PDF with table of contents

Let me know and I'll complete it!
