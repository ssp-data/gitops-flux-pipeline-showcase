#!/bin/bash
set -e

echo "Testing database migrations..."

# Set up Java for Liquibase
# Install Liquibase
mkdir -p /tmp/liquibase
curl -L https://github.com/liquibase/liquibase/releases/download/v4.20.0/liquibase-4.20.0.tar.gz | tar xz -C /tmp/liquibase
export PATH=$PATH:/tmp/liquibase

# Install PostgreSQL JDBC Driver
curl -L https://jdbc.postgresql.org/download/postgresql-42.5.4.jar -o /tmp/liquibase/lib/postgresql-42.5.4.jar

# Create a simple changelog for testing
cat > /tmp/changelog-test.yaml << EOF
databaseChangeLog:
  - changeSet:
      id: 1
      author: ci-pipeline
      changes:
        - createTable:
            tableName: players
            columns:
              - column:
                  name: id
                  type: int
                  autoIncrement: true
                  constraints:
                    primaryKey: true
                    nullable: false
              - column:
                  name: username
                  type: varchar(255)
                  constraints:
                    nullable: false
EOF

# Create a Liquibase properties file
cat > /tmp/liquibase.properties << EOF
driver: org.postgresql.Driver
url: jdbc:postgresql://localhost:5432/testdb
username: postgres
password: postgres
changeLogFile: /tmp/changelog-test.yaml
EOF

# Run Liquibase update
/tmp/liquibase/liquibase --defaults-file=/tmp/liquibase.properties update

# Validate that the table was created
PGPASSWORD=postgres psql -h localhost -U postgres -d testdb -c "SELECT * FROM players LIMIT 0;"

echo "✅ Database migration tests completed successfully"