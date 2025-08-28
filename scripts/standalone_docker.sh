#!/bin/bash

echo "--- Starting opal-database Docker container setup ---"

# 1. Install Dependencies
echo "1. Installing Python dependencies..."
# Change to the project root before installing dependencies
pushd .. > /dev/null # Push current directory and change to parent
pip install . 
popd > /dev/null # Pop back to original directory

# Check if installation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Python dependencies."
    exit 1
fi
echo "Python dependencies installed."

# Determine environment: local or cloud
# If OPAL_ENV is not set, default to 'local' for standalone execution
OPAL_ENV=${OPAL_ENV:-local}

echo "Detected environment: $OPAL_ENV"

# Set DATABASE_URL based on environment
if [ "$OPAL_ENV" == "local" ]; then
    if [ -z "$DATABASE_URL" ]; then
        echo "DATABASE_URL not set for local environment. Defaulting to SQLite."
        # Construct an absolute path for the database file
        DB_FILE_PATH="$(pwd)/../opal_database/database_base/data/opal_suite.db"
        export DATABASE_URL="sqlite:///$DB_FILE_PATH"
        echo "DATABASE_URL set to: $DATABASE_URL"
    else
        echo "DATABASE_URL already set for local environment: $DATABASE_URL"
        # Add a check for common placeholder errors
        if [[ "$DATABASE_URL" == *"host:port"* ]]; then
            echo "Error: DATABASE_URL contains placeholder 'host:port'. Please replace with actual host and port."
            exit 1
        fi
        if [[ "$DATABASE_URL" == *":port"* ]]; then
            echo "Error: DATABASE_URL contains placeholder ':port'. Please replace with actual port number."
            exit 1
        fi
    fi
elif [ "$OPAL_ENV" == "cloud" ]; then
    echo "Running in cloud environment. Assuming DATABASE_URL is provided by environment or opal-shared-utils."
    # In a real cloud deployment, DATABASE_URL would typically be injected by the CI/CD pipeline
    # or a secrets manager. The Python application would then use opal-shared-utils to retrieve it.
    # This script assumes it's already available in the environment for cloud context.
    if [ -z "$DATABASE_URL" ]; then
        echo "Error: DATABASE_URL environment variable is not set for cloud environment."
        echo "Please ensure it's provided by your cloud environment or secrets management."
        exit 1
    fi
else
    echo "Error: Invalid OPAL_ENV value. Must be 'local' or 'cloud'."
    exit 1
fi

# Ensure the data directory exists before creating tables
echo "Ensuring data directory exists..."
mkdir -p ../opal_database/database_base/data # Create data directory relative to scripts/
if [ $? -ne 0 ]; then
    echo "Error: Failed to create data directory."
    exit 1
fi

# 2. Create Tables (if not exists)
echo "2. Creating database tables..."
# Change to the project root before running Python script
pushd .. > /dev/null
python -m opal_database.database_base.create_tables
popd > /dev/null

# Check if table creation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to create database tables."
    exit 1
fi
echo "Database tables created."

# 3. Run Unit Tests
echo "3. Running unit tests..."
# Change to the project root before running pytest
pushd .. > /dev/null
pytest
popd > /dev/null

# Check if tests passed
if [ $? -ne 0 ]; then
    echo "Error: Unit tests failed."
    exit 1
fi
echo "Unit tests passed."

echo "--- opal-database Docker container setup complete ---"