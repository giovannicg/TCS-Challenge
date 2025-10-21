import jwt
import time
from fastapi import HTTPException
from jwt import InvalidTokenError

ALLOWED_KEY = "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c"
JWT_SECRET = "dev-secret-key-change-in-production"

def validate_api_key(api_key: str) -> None:
    """Validate API key"""
    if api_key != ALLOWED_KEY:
        raise HTTPException(status_code=401, detail="Invalid API key")

def validate_jwt(token: str) -> None:
    """Validate JWT token"""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        
        # Check expiration
        current_time = time.time()
        if payload.get("exp", 0) < current_time:
            raise HTTPException(status_code=401, detail="Expired JWT")
            
    except InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid JWT")