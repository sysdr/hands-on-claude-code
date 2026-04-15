# Sample Flask API

## Context
- **Language:** Python 3.11+
- **Framework:** Flask (microframework for HTTP endpoints)
- **Pattern:** Health check / readiness probe endpoints for orchestration systems
- **Recent Changes:** Converting all endpoints to async; adding structured logging

## Known Issues and Constraints
- `health_check()` function is separate from route; could be inlined
- Error handling uses `print()` instead of structured logging
- Metrics endpoint is stubbed out; needs real implementation
- No authentication or rate limiting (acceptable for internal health checks)

## Style Guide
- Use async/await for all endpoints where applicable
- Import logging at the top; configure once per module
- Return both status code and body; never rely on implicit defaults
- Timestamps must be in ISO 8601 format, UTC timezone
- All error responses should follow the pattern: `{"error": "message", "status": "error_code"}`
