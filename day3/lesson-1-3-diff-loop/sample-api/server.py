import logging
from flask import Flask, jsonify, send_from_directory
import os
from datetime import datetime, timezone

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

requests_total = 0
anthropic_key_present = bool(os.getenv("ANTHROPIC_API_KEY"))


@app.before_request
def _count_requests():
    global requests_total
    requests_total += 1


async def health_check():
    """Check if the service is healthy."""
    return {"status": "ok", "timestamp": datetime.now(timezone.utc).isoformat()}


@app.route("/", methods=["GET"])
def root():
    logger.info("root endpoint called")
    return jsonify({"service": "sample-api", "status": "ok"}), 200


@app.route("/health", methods=["GET"])
async def health():
    """Health check endpoint."""
    logger.info("health endpoint called")
    result = await health_check()
    return result, 200


@app.route("/readiness", methods=["GET"])
def readiness():
    """Readiness probe for orchestration systems."""
    logger.info("readiness endpoint called")
    try:
        return jsonify({"ready": True}), 200
    except Exception as e:
        logger.error("Readiness check failed: %s", e)
        return jsonify({"ready": False, "error": str(e)}), 503


@app.route("/metrics", methods=["GET"])
def metrics():
    """Return basic metrics."""
    logger.info("metrics endpoint called")
    return jsonify({"requests_total": requests_total, "anthropic_key_present": anthropic_key_present}), 200


@app.route("/config", methods=["GET"])
def config():
    logger.info("config endpoint called")
    # Never return the key itself.
    return jsonify({"anthropic_key_present": anthropic_key_present}), 200


@app.route("/dashboard", methods=["GET"])
def dashboard():
    logger.info("dashboard endpoint called")
    # Serve the static dashboard from ../dashboard
    return send_from_directory("../dashboard", "index.html")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
