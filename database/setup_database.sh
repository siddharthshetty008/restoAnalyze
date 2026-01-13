#!/bin/bash

# ==================================================
# Restaurant Analytics Database Setup Script
# Lead AI Engineer - Production Ready Setup
# ==================================================

set -e  # Exit on any error

echo "🍽️  Restaurant Analytics Database Setup"
echo "======================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DB_NAME="restaurant_analytics"
DB_USER="restaurant_admin"
DB_PASSWORD="analytics123"  # Change this in production!
DB_HOST="localhost"
DB_PORT="5432"

# Check if PostgreSQL is installed and running
check_postgresql() {
    echo -e "${BLUE}Checking PostgreSQL installation...${NC}"
    
    if ! command -v psql &> /dev/null; then
        echo -e "${RED}❌ PostgreSQL is not installed. Please install PostgreSQL first.${NC}"
        echo -e "${YELLOW}On macOS: brew install postgresql${NC}"
        echo -e "${YELLOW}On Ubuntu: sudo apt-get install postgresql postgresql-contrib${NC}"
        exit 1
    fi
    
    if ! pg_isready -h $DB_HOST -p $DB_PORT &> /dev/null; then
        echo -e "${RED}❌ PostgreSQL is not running on $DB_HOST:$DB_PORT${NC}"
        echo -e "${YELLOW}Start PostgreSQL service:${NC}"
        echo -e "${YELLOW}On macOS: brew services start postgresql${NC}"
        echo -e "${YELLOW}On Ubuntu: sudo systemctl start postgresql${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ PostgreSQL is running${NC}"
}

# Create database and user
create_database() {
    echo -e "${BLUE}Creating database and user...${NC}"
    
    # Connect as postgres superuser to create database
    export PGPASSWORD="postgres"  # Adjust if your postgres user has different password
    
    # Create user if not exists
    psql -h $DB_HOST -p $DB_PORT -U postgres -c "
        DO \$\$
        BEGIN
            IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$DB_USER') THEN
                CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' CREATEDB;
            END IF;
        END
        \$\$;
    " 2>/dev/null || echo -e "${YELLOW}⚠️  User creation skipped (may already exist)${NC}"
    
    # Create database if not exists
    psql -h $DB_HOST -p $DB_PORT -U postgres -c "
        SELECT 'CREATE DATABASE $DB_NAME' WHERE NOT EXISTS (
            SELECT FROM pg_database WHERE datname = '$DB_NAME'
        )\\gexec
    " 2>/dev/null || echo -e "${YELLOW}⚠️  Database creation skipped (may already exist)${NC}"
    
    # Grant privileges
    psql -h $DB_HOST -p $DB_PORT -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" 2>/dev/null
    
    echo -e "${GREEN}✅ Database '$DB_NAME' and user '$DB_USER' ready${NC}"
    unset PGPASSWORD
}

# Run schema setup
setup_schema() {
    echo -e "${BLUE}Setting up database schema...${NC}"
    
    export PGPASSWORD="$DB_PASSWORD"
    
    # Run the main schema setup script
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "scripts/setup_database.sql"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Database schema setup complete${NC}"
    else
        echo -e "${RED}❌ Schema setup failed${NC}"
        exit 1
    fi
    
    unset PGPASSWORD
}

# Create configuration file
create_config() {
    echo -e "${BLUE}Creating configuration file...${NC}"
    
    cat > database_config.env << EOF
# Restaurant Analytics Database Configuration
# Generated on $(date)

DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT

# Connection string
DATABASE_URL=postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME

# For Python applications
DB_CONFIG = {
    'database': '$DB_NAME',
    'user': '$DB_USER', 
    'password': '$DB_PASSWORD',
    'host': '$DB_HOST',
    'port': '$DB_PORT'
}
EOF
    
    echo -e "${GREEN}✅ Configuration saved to database_config.env${NC}"
}

# Test database connection
test_connection() {
    echo -e "${BLUE}Testing database connection...${NC}"
    
    export PGPASSWORD="$DB_PASSWORD"
    
    # Test basic connection
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        SELECT 
            current_database() as database,
            current_user as user,
            version() as postgresql_version;
    "
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Database connection successful${NC}"
    else
        echo -e "${RED}❌ Database connection failed${NC}"
        exit 1
    fi
    
    # Test table creation
    table_count=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
        SELECT COUNT(*) FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
    " | xargs)
    
    echo -e "${GREEN}✅ Found $table_count tables in database${NC}"
    
    unset PGPASSWORD
}

# Create Docker Compose file for easy development
create_docker_setup() {
    echo -e "${BLUE}Creating Docker Compose setup...${NC}"
    
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: restaurant_analytics_db
    environment:
      POSTGRES_DB: $DB_NAME
      POSTGRES_USER: $DB_USER
      POSTGRES_PASSWORD: $DB_PASSWORD
    ports:
      - "$DB_PORT:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $DB_USER -d $DB_NAME"]
      interval: 30s
      timeout: 10s
      retries: 3

  pgadmin:
    image: dpage/pgadmin4
    container_name: restaurant_analytics_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@restaurant.com
      PGADMIN_DEFAULT_PASSWORD: admin123
    ports:
      - "8080:80"
    depends_on:
      - postgres

volumes:
  postgres_data:
EOF
    
    echo -e "${GREEN}✅ Docker Compose file created${NC}"
    echo -e "${YELLOW}💡 To use Docker: docker-compose up -d${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}Starting database setup process...${NC}"
    echo ""
    
    # Check prerequisites
    check_postgresql
    
    # Setup database
    create_database
    setup_schema
    create_config
    test_connection
    create_docker_setup
    
    echo ""
    echo -e "${GREEN}🎉 Database setup complete!${NC}"
    echo -e "${GREEN}==============================${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo "1. Source the config: source database_config.env"
    echo "2. Run migration scripts to import CSV data"
    echo "3. Test with: python migrate_data.py"
    echo ""
    echo -e "${YELLOW}📊 Database Access:${NC}"
    echo "• Database: $DB_NAME"
    echo "• Host: $DB_HOST:$DB_PORT"  
    echo "• User: $DB_USER"
    echo "• PgAdmin: http://localhost:8080 (if using Docker)"
    echo ""
    echo -e "${YELLOW}🔗 Connection String:${NC}"
    echo "postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME"
    echo ""
    echo -e "${GREEN}Ready for analytics! 📈${NC}"
}

# Run main function
main "$@"