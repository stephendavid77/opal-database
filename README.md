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

## Cloud Deployment (Google Cloud Platform)

This module includes a script for deploying a PostgreSQL instance to Google Cloud SQL.

### `scripts/cloud_gcp_deployment.sh`

This script automates the creation of a Cloud SQL PostgreSQL instance, a database, and a user.

**Usage:**

1.  **Configure Environment Variables:** Before running, ensure the following environment variables are set (e.g., in a `.env` file, loaded by `opal-shared-utils` in Python applications, or sourced in your shell):
    *   `GCP_PROJECT_ID`: Your Google Cloud Project ID.
    *   `GCP_REGION`: The GCP region for your Cloud SQL instance (e.g., `us-central1`).
    *   `DB_USER`: The desired database username.
    *   `DB_PASSWORD`: A strong password for the database user.

2.  **Execute the script:**
    ```bash
    ./scripts/cloud_gcp_deployment.sh
    ```

**Example Configuration in `.env` (for local sourcing):**

```
GCP_PROJECT_ID="your-gcp-project-id"
GCP_REGION="us-central1"
DB_USER="your_db_user"
DB_PASSWORD="your_strong_db_password"
```

**Note:** For production deployments, consider advanced Cloud SQL features like high availability, private IP, and robust backup strategies.

## Local Development Setup

1.  **Install Dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
    or
    ```bash
    pip install -e . # If installed as an editable package
    ```
2.  **Database Initialization:**
    The database schema is typically created by the application that uses this module (e.g., `opal-auth-backend`) upon startup, or via dedicated migration scripts. For testing, an in-memory SQLite database is used.

## Pre-commit Hooks

This project uses `pre-commit` hooks to enforce code quality and architectural standards. These hooks are configured globally via `opal-dev-tools`.

**Installation:**

1.  **Navigate to the project root:**
    ```bash
    cd /path/to/opal-database
    ```
2.  **Install hooks:**
    ```bash
    pre-commit install
    ```

**Updating Hooks:**

```bash
pre-commit autoupdate
```
