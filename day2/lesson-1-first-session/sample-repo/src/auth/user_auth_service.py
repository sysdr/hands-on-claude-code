"""User authentication service.

Handles credential verification and session token issuance.
Depends on UserRepository for persistence and TokenStore for JWT ops.
"""
from __future__ import annotations
import hashlib
import secrets
from typing import Optional

from src.models.user import User


class AuthenticationError(Exception):
    """Raised when credentials cannot be verified."""


class UserRepository:
    """Minimal in-memory repository stub — replace with DB implementation."""

    def __init__(self) -> None:
        self._store: dict[int, User] = {}
        self._email_index: dict[str, int] = {}

    def save(self, user: User) -> None:
        self._store[user.id] = user
        self._email_index[user.email.lower()] = user.id

    def get_by_id(self, user_id: int) -> Optional[User]:
        return self._store.get(user_id)

    def get_by_username(self, username: str) -> Optional[User]:
        for user in self._store.values():
            if user.username == username:
                return user
        return None

    def get_by_email(self, email: str) -> Optional[User]:
        """Lookup by email (case-insensitive)."""
        uid = self._email_index.get(email.lower())
        if uid is None:
            return None
        return self._store.get(uid)


class UserAuthService:
    """Authenticates users and issues session tokens.

    This is the target class for Lesson 1.2's interactive edit exercise.
    Students will add `get_user_by_email` via a Claude Code diff.
    """

    def __init__(self, repository: UserRepository) -> None:
        self._repo = repository
        self._sessions: dict[str, int] = {}  # token → user_id

    @staticmethod
    def hash_password(plaintext: str) -> str:
        """SHA-256 hash — for illustration only, use bcrypt in production."""
        return hashlib.sha256(plaintext.encode()).hexdigest()

    def register(self, username: str, email: str, password: str) -> User:
        """Create and persist a new user account."""
        import time
        user = User(
            id=int(time.time() * 1000),
            email=email,
            username=username,
            password_hash=self.hash_password(password),
        )
        self._repo.save(user)
        return user

    def authenticate(self, username: str, password: str) -> str:
        """Verify credentials and return a session token.

        Raises AuthenticationError on invalid credentials.
        """
        user = self._repo.get_by_username(username)
        if user is None or not user.is_active:
            raise AuthenticationError("Unknown username or inactive account")
        if user.password_hash != self.hash_password(password):
            raise AuthenticationError("Invalid password")
        token = secrets.token_urlsafe(32)
        self._sessions[token] = user.id
        return token

    def resolve_session(self, token: str) -> Optional[User]:
        """Return the User associated with a session token, or None."""
        user_id = self._sessions.get(token)
        if user_id is None:
            return None
        return self._repo.get_by_id(user_id)

    def revoke_session(self, token: str) -> None:
        """Invalidate a session token."""
        self._sessions.pop(token, None)

    def get_user_by_email(self, email: str) -> Optional[User]:
        """Return the user for the given email, or None if not found."""
        if email == "":
            raise ValueError("email must not be empty")
        return self._repo.get_by_email(email)

    # ── Optional: extend with additional lookup helpers in later lessons ──
