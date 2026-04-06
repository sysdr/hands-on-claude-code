"""User domain model."""
from __future__ import annotations
from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional


@dataclass
class User:
    """Represents an authenticated application user."""
    id: int
    email: str
    username: str
    password_hash: str
    created_at: datetime = field(default_factory=datetime.utcnow)
    last_login: Optional[datetime] = None
    is_active: bool = True

    def __post_init__(self) -> None:
        if not self.email or "@" not in self.email:
            raise ValueError(f"Invalid email: {self.email!r}")
        if not self.username or len(self.username) < 3:
            raise ValueError(f"Username must be >=3 chars: {self.username!r}")

    def deactivate(self) -> None:
        """Soft-delete: mark inactive without removing from storage."""
        self.is_active = False
