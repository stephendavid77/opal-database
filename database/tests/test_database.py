import os

import pytest
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

# Load environment variables from .env file
load_dotenv()

# Import database components
from shared.database_base.database import Base, SessionLocal, engine, get_db
from shared.database_base.models.user import User

# Override the engine and SessionLocal for testing to use an in-memory SQLite database
# This is crucial to prevent tests from interfering with the actual development database
TEST_SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

test_engine = create_engine(
    TEST_SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


@pytest.fixture(name="db_session")
def db_session_fixture():
    """Provides a test database session with tables created and dropped."""
    Base.metadata.create_all(bind=test_engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=test_engine)


@pytest.fixture(name="override_get_db")
def override_get_db_fixture(db_session):
    """Overrides the get_db dependency for FastAPI tests."""

    def _override_get_db():
        yield db_session

    return _override_get_db


def test_database_connection(db_session):
    """Test that the database connection can be established."""
    assert db_session.is_active  # Check if the session is active


def test_create_user(db_session):
    """Test creating a new user in the database."""
    new_user = User(
        username="testuser",
        email="test@example.com",
        first_name="Test",
        last_name="User",
        roles="user",
    )
    db_session.add(new_user)
    db_session.commit()
    db_session.refresh(new_user)

    assert new_user.id is not None
    assert new_user.username == "testuser"
    assert new_user.email == "test@example.com"
    assert new_user.roles == "user"


def test_get_user(db_session):
    """Test retrieving a user from the database."""
    new_user = User(
        username="getuser",
        email="get@example.com",
        first_name="Get",
        last_name="User",
        roles="user",
    )
    db_session.add(new_user)
    db_session.commit()
    db_session.refresh(new_user)

    retrieved_user = db_session.query(User).filter(User.username == "getuser").first()
    assert retrieved_user is not None
    assert retrieved_user.username == "getuser"
    assert retrieved_user.email == "get@example.com"


def test_update_user(db_session):
    """Test updating an existing user in the database."""
    new_user = User(
        username="updateuser",
        email="update@example.com",
        first_name="Update",
        last_name="User",
        roles="user",
    )
    db_session.add(new_user)
    db_session.commit()
    db_session.refresh(new_user)

    user_to_update = (
        db_session.query(User).filter(User.username == "updateuser").first()
    )
    user_to_update.email = "updated@example.com"
    db_session.add(user_to_update)
    db_session.commit()
    db_session.refresh(user_to_update)

    assert user_to_update.email == "updated@example.com"


def test_delete_user(db_session):
    """Test deleting a user from the database."""
    new_user = User(
        username="deleteuser",
        email="delete@example.com",
        first_name="Delete",
        last_name="User",
        roles="user",
    )
    db_session.add(new_user)
    db_session.commit()
    db_session.refresh(new_user)

    user_to_delete = (
        db_session.query(User).filter(User.username == "deleteuser").first()
    )
    db_session.delete(user_to_delete)
    db_session.commit()

    deleted_user = db_session.query(User).filter(User.username == "deleteuser").first()
    assert deleted_user is None
