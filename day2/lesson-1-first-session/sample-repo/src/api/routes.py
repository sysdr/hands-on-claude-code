"""HTTP route handlers for the auth API.

Thin layer — delegates all logic to UserAuthService.
"""
from __future__ import annotations
from typing import Any


def handle_register(body: dict[str, Any], svc: Any) -> dict[str, Any]:
    """POST /register"""
    try:
        user = svc.register(
            username=body["username"],
            email=body["email"],
            password=body["password"],
        )
        return {"status": "created", "user_id": user.id}
    except (KeyError, ValueError) as exc:
        return {"status": "error", "message": str(exc)}


def handle_login(body: dict[str, Any], svc: Any) -> dict[str, Any]:
    """POST /login"""
    try:
        token = svc.authenticate(
            username=body["username"],
            password=body["password"],
        )
        return {"status": "ok", "token": token}
    except Exception as exc:
        return {"status": "error", "message": str(exc)}


def handle_logout(body: dict[str, Any], svc: Any) -> dict[str, Any]:
    """POST /logout"""
    token = body.get("token", "")
    svc.revoke_session(token)
    return {"status": "ok"}
