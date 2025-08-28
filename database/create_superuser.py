import os
import sys

# Add the project root to PYTHONPATH
script_dir = os.path.dirname(__file__)
project_root = os.path.abspath(os.path.join(script_dir, os.pardir, os.pardir))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

from auth_service.utils.password_hasher import hash_password
from sqlalchemy import func  # Import func
from sqlalchemy.sql import or_  # Import or_

from shared.database_base.database import SessionLocal
from shared.database_base.models.user import User


def create_superuser(username, email, password):
    db = SessionLocal()
    try:
        # Delete existing user with same username or email
        existing_user = (
            db.query(User)
            .filter(or_(User.username == username, User.email == email))
            .first()
        )
        if existing_user:
            print(
                f"Deleting existing user: {existing_user.username} ({existing_user.email})"
            )
            db.delete(existing_user)
            db.commit()

        hashed_password = hash_password(password)
        superuser = User(
            username=username,
            email=email,
            hashed_password=hashed_password,
            roles="super_user",  # Set role to super_user
            is_active=True,  # Superuser should be active by default
        )
        db.add(superuser)
        db.commit()
        db.refresh(superuser)
        print(f"Superuser '{username}' created successfully with ID: {superuser.id}")
    except Exception as e:
        db.rollback()
        print(f"Error creating superuser: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    # Specified superuser credentials
    create_superuser("", "", "")
