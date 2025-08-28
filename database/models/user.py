import uuid

from passlib.context import CryptContext
from sqlalchemy import Boolean, Column, DateTime, Enum, Integer, String
from sqlalchemy.dialects.postgresql import (  # Although using SQLite, keep for future compatibility
    UUID,
)

from shared.database_base.database import Base

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(80), unique=True, nullable=False, index=True)

    is_active = Column(Boolean, default=False)
    email = Column(String(120), unique=True, nullable=False, index=True)  # Added email
    first_name = Column(String(80), nullable=True)
    last_name = Column(String(80), nullable=True)
    roles = Column(String(256), default="user")
    refresh_token = Column(String(512), nullable=True)  # Store hashed refresh token
    refresh_token_expires_at = Column(DateTime, nullable=True)  # Added new column
    otp_code = Column(String(6), nullable=True)
    otp_expiry = Column(DateTime, nullable=True)

    def __repr__(self):
        return f"<User {self.username}>"
