import pytest
import json
import sys
import os

# Add parent directory to path so we can import server
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from server import app

@pytest.fixture
def client():
    """Flask test client fixture."""
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_health_returns_200(client):
    """Health endpoint should return 200 status."""
    response = client.get("/health")
    assert response.status_code == 200

def test_health_returns_json(client):
    """Health endpoint should return valid JSON with 'status' field."""
    response = client.get("/health")
    data = json.loads(response.data)
    assert "status" in data
    assert data["status"] == "ok"

def test_readiness_returns_200(client):
    """Readiness endpoint should return 200 status when ready."""
    response = client.get("/readiness")
    assert response.status_code == 200

def test_readiness_returns_json(client):
    """Readiness endpoint should return valid JSON with 'ready' field."""
    response = client.get("/readiness")
    data = json.loads(response.data)
    assert "ready" in data
    assert data["ready"] is True

def test_metrics_returns_200(client):
    """Metrics endpoint should return 200 status."""
    response = client.get("/metrics")
    assert response.status_code == 200

def test_metrics_returns_json(client):
    """Metrics endpoint should return valid JSON."""
    response = client.get("/metrics")
    data = json.loads(response.data)
    assert isinstance(data, dict)
