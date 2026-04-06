"""Application configuration loader.

Reads from environment variables with typed defaults.
"""
from __future__ import annotations
import os


class Config:
    APP_NAME: str = os.getenv("APP_NAME", "claudeforge-sample-service")
    DEBUG: bool = os.getenv("DEBUG", "false").lower() == "true"
    TOKEN_TTL_SECONDS: int = int(os.getenv("TOKEN_TTL_SECONDS", "3600"))
    MAX_LOGIN_ATTEMPTS: int = int(os.getenv("MAX_LOGIN_ATTEMPTS", "5"))
    ALLOWED_ORIGINS: list[str] = os.getenv(
        "ALLOWED_ORIGINS", "http://localhost:3000"
    ).split(",")
