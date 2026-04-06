"""Unit tests for UserAuthService.

Run: pytest tests/unit/test_user_auth_service.py -v
"""
import pytest
from src.auth.user_auth_service import (
    UserAuthService,
    UserRepository,
    AuthenticationError,
)
from src.models.user import User


@pytest.fixture()
def repo() -> UserRepository:
    return UserRepository()


@pytest.fixture()
def svc(repo: UserRepository) -> UserAuthService:
    return UserAuthService(repo)


class TestRegister:
    def test_register_stores_user(self, svc: UserAuthService) -> None:
        user = svc.register("alice", "alice@example.com", "s3cr3t")
        assert user.username == "alice"
        assert user.email == "alice@example.com"
        assert user.is_active is True

    def test_register_hashes_password(self, svc: UserAuthService) -> None:
        user = svc.register("bob", "bob@example.com", "password123")
        assert user.password_hash != "password123"
        assert len(user.password_hash) == 64  # sha256 hex


class TestAuthenticate:
    def test_authenticate_returns_token(self, svc: UserAuthService) -> None:
        svc.register("carol", "carol@example.com", "pass")
        token = svc.authenticate("carol", "pass")
        assert isinstance(token, str)
        assert len(token) > 10

    def test_authenticate_wrong_password_raises(self, svc: UserAuthService) -> None:
        svc.register("dave", "dave@example.com", "correct")
        with pytest.raises(AuthenticationError):
            svc.authenticate("dave", "wrong")

    def test_authenticate_unknown_user_raises(self, svc: UserAuthService) -> None:
        with pytest.raises(AuthenticationError):
            svc.authenticate("nobody", "pass")


class TestResolveSession:
    def test_resolve_returns_user(self, svc: UserAuthService) -> None:
        svc.register("eve", "eve@example.com", "pass")
        token = svc.authenticate("eve", "pass")
        user = svc.resolve_session(token)
        assert user is not None
        assert user.username == "eve"

    def test_resolve_invalid_token_returns_none(self, svc: UserAuthService) -> None:
        assert svc.resolve_session("not-a-real-token") is None


class TestRevokeSession:
    def test_revoke_invalidates_token(self, svc: UserAuthService) -> None:
        svc.register("frank", "frank@example.com", "pass")
        token = svc.authenticate("frank", "pass")
        svc.revoke_session(token)
        assert svc.resolve_session(token) is None


class TestGetUserByEmail:
    """Lookup by email (case-insensitive) via UserAuthService."""

    def test_get_by_email_returns_user(self, svc: UserAuthService) -> None:
        svc.register("grace", "grace@example.com", "pass")
        user = svc.get_user_by_email("grace@example.com")
        assert user is not None
        assert user.email == "grace@example.com"

    def test_get_by_email_unknown_returns_none(self, svc: UserAuthService) -> None:
        user = svc.get_user_by_email("unknown@example.com")
        assert user is None

    def test_get_by_email_empty_raises(self, svc: UserAuthService) -> None:
        with pytest.raises(ValueError):
            svc.get_user_by_email("")
