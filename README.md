# OpalSuite Database (`opal-database`)

This repository contains the shared database models and connection logic for the OpalSuite ecosystem. It primarily defines the schema for core entities like users and handles database interactions.

## Table Schema

### `users` Table

The `users` table stores information about users within the OpalSuite platform.

| Column                     | Type                 | Description                                       |
| :------------------------- | :------------------- | :------------------------------------------------ |
| `id`                       | `Integer` (PK)       | Unique identifier for the user.                   |
| `username`                 | `String(80)` (Unique)| User's chosen username.                           |
| `is_active`                | `Boolean`            | Indicates if the user account is active.          |
| `email`                    | `String(120)` (Unique)| User's email address.                             |
| `first_name`               | `String(80)`         | User's first name.                                |
| `last_name`                | `String(80)`         | User's last name.                                 |
| `roles`                    | `String(256)`        | User roles (e.g., "user", "admin").               |
| `refresh_token`            | `String(512)`        | Hashed refresh token for authentication.          |
| `refresh_token_expires_at` | `DateTime`           | Expiration timestamp for the refresh token.       |
| `otp_code`                 | `String(6)`          | One-Time Password (OTP) code.                     |
| `otp_expiry`               | `DateTime`           | Expiration timestamp for the OTP code.            |
| `social_provider`          | `String(50)`         | Name of the social login provider (e.g., "google").|
| `social_id`                | `String(255)`        | Unique ID from the social login provider.         |
| `profile_picture_url`      | `String(255)`        | URL to the user's profile picture from social provider.|

## Functionality

The `opal-database` module provides:

*   **Database Models:** SQLAlchemy ORM models for defining the structure of core database entities.
*   **Database Connection:** Utilities for establishing and managing connections to the database.
*   **Schema Management:** Tools for creating and dropping database tables based on the defined models.
*   **User Management:** Basic CRUD (Create, Read, Update, Delete) operations for user data.

## Technology Stack

*   **Python:** Primary programming language.
*   **SQLAlchemy:** Python SQL Toolkit and Object Relational Mapper for database interactions.
*   **PostgreSQL:** Recommended production database.
*   **SQLite:** Used for local development and testing.

## Dependencies

Key Python dependencies are managed via `pyproject.toml` and `requirements.txt`. Notable dependencies include:

*   `SQLAlchemy`: Core ORM.
*   `psycopg2-binary` (for PostgreSQL connectivity).
*   `python-dotenv`: For loading environment variables from `.env` files.
*   `passlib`: For password hashing (used in `User` model for `CryptContext`).
*   `opal_shared_utils`: For shared utilities like secrets management.

## Local Development Setup

This section guides you through setting up and running `opal-database` locally.

### Prerequisites

*   Python 3.7+
*   `pip`
*   (Optional) Docker and Docker Compose for containerized development.

### 1. Install Dependencies and Initialize Database

The `scripts/standalone.sh` script automates the local setup, including installing Python dependencies, creating database tables (using SQLite by default), and running unit tests.

To run it:

```bash
./scripts/standalone.sh
```

**Important:** The `DATABASE_URL` environment variable is crucial.
*   If `OPAL_ENV` is `local` and `DATABASE_URL` is not set, the script will default to a SQLite database at `./opal_database/database_base/data/opal_suite.db`.
*   If you wish to use a local PostgreSQL instance (e.g., one running via `docker run`), you must set `DATABASE_URL` before running the script. For example:
    ```bash
    export DATABASE_URL="postgresql://opal_user:securepassword@localhost:5432/opal_db"
    ./scripts/standalone.sh
    ```
    Replace `opal_user`, `securepassword`, and `opal_db` with your PostgreSQL credentials.

### 2. Docker Development

The `scripts/standalone_docker.sh` script is designed to run inside the `opal-database` Docker container. It handles dependency installation and database table creation/migration within the container.

To build and run the `opal-database` service using Docker Compose (as part of the larger OpalSuite environment):

```bash
docker-compose up --build opal-database
```

Ensure your `docker-compose.yml` is configured to build the `opal-database` service from its Dockerfile and provides the necessary `DATABASE_URL` environment variable (e.g., `postgresql://opal_user:securepassword@db:5432/opalsuite_db` if connecting to a `db` service within the Docker network).

## Cloud Deployment (Google Cloud Platform)

This module includes a script for deploying the OpalSuite environment (including `opal-database`) to a Google Compute Engine instance.

### `scripts/cloud_gcp_deployment.sh`

This script provisions a new GCE VM, installs Docker and Docker Compose, copies project files, and starts the services using `docker-compose`.

**Prerequisites:**

*   `gcloud` CLI installed and authenticated.
*   Compute Engine API enabled for your GCP project.

**Usage:**

1.  **Configure Environment Variables:** Before running, ensure the following environment variables are set in your local shell:
    ```bash
    export GCP_PROJECT_ID="your-gcp-project-id"
    export GCP_REGION="your-desired-gcp-region"
    export GCP_ZONE="your-desired-gcp-zone" # Optional, defaults to us-central1-b
    ```
    Replace placeholders with your actual GCP project ID, region, and zone.

2.  **Execute the script:**
    ```bash
    ./scripts/cloud_gcp_deployment.sh
    ```

**Important Notes:**

*   The script will prompt you to enable the Compute Engine API if it's not already enabled.
*   The script will create a new VM instance and configure it.
*   PostgreSQL will be accessible internally within the VM on port 5432.
*   The `opal-database` application (running in its container) will be exposed externally on port 5000 via the VM's external IP.
*   For production deployments, consider advanced Cloud SQL features, robust backup strategies, and more restrictive firewall rules.

## Pre-commit Hooks

This project uses `pre-commit` hooks to enforce code quality and architectural standards. These hooks are configured globally via `opal-dev-tools`.

### Installation

1.  **Navigate to the project root:**
    ```bash
    cd /path/to/opal-database
    ```
2.  **Install hooks:**
    ```bash
    pre-commit install
    ```

### Updating Hooks

To ensure you have the latest versions of the global hooks:

```bash
pre-commit autoupdate
```

## Running Unit Tests

To run the unit tests for `opal-database`:

1.  **Navigate to the project root:**
    ```bash
    cd /Users/srinivasan.arulsivam/projects/python/OpalSuite/opal-database
    ```
2.  **Ensure dependencies are installed:**
    ```bash
    pip install -e .
    ```
3.  **Execute tests:**
    ```bash
    pytest
    ```