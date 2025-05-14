#!/bin/bash
set -e

echo "Testing database migrations..."

# Set up Liquibase and dependencies
mkdir -p /tmp/liquibase
curl -L https://github.com/liquibase/liquibase/releases/download/v4.20.0/liquibase-4.20.0.tar.gz | tar xz -C /tmp/liquibase
export PATH=$PATH:/tmp/liquibase

# Install PostgreSQL JDBC Driver
curl -L https://jdbc.postgresql.org/download/postgresql-42.5.4.jar -o /tmp/liquibase/lib/postgresql-42.5.4.jar

# Create Liquibase properties file for testing
cat > /tmp/liquibase.properties << EOF
driver: org.postgresql.Driver
url: jdbc:postgresql://localhost:5432/testdb
username: postgres
password: postgres
changeLogFile: migrations/changelog/db.changelog-master.yaml
EOF

# Test validation of the changelog
/tmp/liquibase/liquibase --defaults-file=/tmp/liquibase.properties validate

# Run the actual migrations
/tmp/liquibase/liquibase --defaults-file=/tmp/liquibase.properties update

# Verify table was created
PGPASSWORD=postgres psql -h localhost -U postgres -d testdb -c "SELECT * FROM players LIMIT 0;"

echo "✅ Database migration tests completed successfully"