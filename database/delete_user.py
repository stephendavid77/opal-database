import os
import sys

# Add the project root to PYTHONPATH
script_dir = os.path.dirname(__file__)
project_root = os.path.abspath(os.path.join(script_dir, os.pardir, os.pardir))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

from sqlalchemy.sql import or_

from shared.database_base.database import SessionLocal
from shared.database_base.models.user import User


def delete_user(identifier):
    db = SessionLocal()
    try:
        user_to_delete = (
            db.query(User)
            .filter(or_(User.username == identifier, User.email == identifier))
            .first()
        )

        if user_to_delete:
            print(f"Deleting user: {user_to_delete.username} ({user_to_delete.email})")
            db.delete(user_to_delete)
            db.commit()
            print("User deleted successfully.")
        else:
            print(f"User with username or email '{identifier}' not found.")
    except Exception as e:
        db.rollback()
        print(f"Error deleting user: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    # Specify the username or email to delete here
    user_to_delete = ""  # Replace with the actual username or email

    delete_user(user_to_delete)
