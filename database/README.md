# `database_base` Module

## Purpose

The `database_base` module provides the centralized database configuration and SQLAlchemy ORM models for the entire OpalSuite monorepo. Its primary goal is to ensure consistent database interactions and schema definitions across all sub-applications.

## Location

`shared/database_base/`

## Key Components

*   **`database.py`**: This file defines the core SQLAlchemy components necessary for database connectivity:
    *   `engine`: The SQLAlchemy engine for connecting to the database.
    *   `SessionLocal`: A session factory for creating database sessions.
    *   `Base`: The declarative base for defining SQLAlchemy ORM models.
    *   `get_db()`: A FastAPI dependency for managing database sessions within API routes.

*   **`models/`**: This directory contains the SQLAlchemy ORM models (e.g., `user.py` for the `User` model) that define the database schema for entities shared across the OpalSuite platform.

## Configuration

The `SQLALCHEMY_DATABASE_URL` is dynamically configured using the `secrets_manager` module. This allows for flexible deployment across different environments (local development, staging, production) without code changes.

*   **Local Development**: The `DATABASE_URL` can be specified in a `.env` file at the project root (e.g., `DATABASE_URL=sqlite:///./shared/database_base/data/opal_suite.db`).
*   **Cloud Deployment**: In cloud environments, the `secrets_manager` will retrieve the `DATABASE_URL` from a configured cloud secret manager (e.g., Google Cloud Secret Manager).

## Usage

Other modules and sub-applications can interact with the database by importing `get_db` for dependency injection in FastAPI routes and importing models from `shared.database_base.models`.

Example (FastAPI route):

```python
from fastapi import Depends
from sqlalchemy.orm import Session

from shared.database_base.database import get_db
from shared.database_base.models.user import User

# ... (FastAPI app setup)

@app.get("/users/{user_id}")
async def read_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    return user
```

## Testing

Dedicated unit tests for the `database_base` module are located in `shared/database_base/tests/`. These tests ensure the core functionalities of the database module, including CRUD operations and session management, are working correctly in an isolated environment (using an in-memory SQLite database).
