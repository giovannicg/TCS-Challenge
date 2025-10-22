import jwt
import time
import os
from fastapi.testclient import TestClient

# Load test environment variables from .env file if it exists
if os.path.exists(".env"):
    with open(".env", "r") as f:
        for line in f:
            if line.strip() and not line.startswith("#"):
                key, value = line.strip().split("=", 1)
                os.environ[key] = value
if "API_KEY" not in os.environ:
    raise ValueError("API_KEY environment variable is required")
if "JWT_SECRET" not in os.environ:
    raise ValueError("JWT_SECRET environment variable is required")

from src.main import app

client = TestClient(app)

def generate_test_jwt():
    """Generate a simple test JWT"""
    jwt_secret = os.getenv("JWT_SECRET")
    payload = {
        "exp": time.time() + 3600,  # 1 hour from now
        "iat": time.time(),
        "jti": str(time.time())
    }
    return jwt.encode(payload, jwt_secret, algorithm="HS256")

def test_health_check():
    """Test health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_other_methods_return_error():
    """Test that non-POST methods return ERROR"""
    response = client.get("/DevOps")
    assert response.text == '"ERROR"'

def test_post_success():
    """Test successful POST request"""
    jwt_token = generate_test_jwt()

    response = client.post(
        "/DevOps",
        headers={
            "X-Parse-REST-API-Key": os.getenv("API_KEY"),
            "X-JWT-KWY": jwt_token
        },
        json={
            "message": "This is a test",
            "to": "Juan Perez",
            "from": "Rita Asturia",
            "timeToLifeSec": 45
        }
    )

    assert response.status_code == 200
    response_data = response.json()
    assert response_data["message"] == "Hello Juan Perez your message will be send"
    assert "transaction_jwt" in response_data
    # Verify JWT is valid
    import jwt
    decoded = jwt.decode(response_data["transaction_jwt"], os.getenv("JWT_SECRET"), algorithms=["HS256"])
    assert "exp" in decoded
    assert "iat" in decoded
    assert "jti" in decoded

def test_invalid_api_key():
    """Test with invalid API key"""
    jwt_token = generate_test_jwt()

    response = client.post(
        "/DevOps",
        headers={
            "X-Parse-REST-API-Key": "invalid-key",
            "X-JWT-KWY": jwt_token
        },
        json={
            "message": "This is a test",
            "to": "Juan Perez",
            "from": "Rita Asturia",
            "timeToLifeSec": 45
        }
    )

    assert response.status_code == 401
    assert "Invalid API key" in response.json()["detail"]

def test_invalid_jwt():
    """Test with invalid JWT"""
    response = client.post(
        "/DevOps",
        headers={
            "X-Parse-REST-API-Key": os.getenv("API_KEY"),
            "X-JWT-KWY": "invalid-jwt"
        },
        json={
            "message": "This is a test",
            "to": "Juan Perez",
            "from": "Rita Asturia",
            "timeToLifeSec": 45
        }
    )

    assert response.status_code == 401
    assert "Invalid JWT" in response.json()["detail"]