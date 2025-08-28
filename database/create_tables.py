import shared.database_base.models.user  # Import models to create tables
from shared.database_base.database import Base, engine


def create_db_tables():
    Base.metadata.create_all(bind=engine)
    print("Database tables created successfully.")

    # Verify tables
    from sqlalchemy import inspect

    inspector = inspect(engine)
    print(f"Tables found in database: {inspector.get_table_names()}")
    engine.dispose()  # Explicitly close the engine connection


if __name__ == "__main__":
    create_db_tables()
