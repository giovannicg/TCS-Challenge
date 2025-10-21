import jwt
import time
from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def generate_test_jwt():
    """Generate a simple test JWT"""
    payload = {
        "exp": time.time() + 3600,  # 1 hour from now
        "iat": time.time()
    }
    return jwt.encode(payload, "dev-secret-key-change-in-production", algorithm="HS256")

def test_other_methods_return_error():
    """Test that non-POST methods return ERROR"""
    response = client.get("/DevOps")
    assert response.text == "ERROR"

def test_post_success():
    """Test successful POST request"""
    jwt_token = generate_test_jwt()
    
    response = client.post(
        "/DevOps",
        headers={
            "X-Parse-REST-API-Key": "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c",
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
    assert response.json()["message"] == "Hello Juan Perez your message will be send"

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
            "X-Parse-REST-API-Key": "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c",
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