import jwt
import time
import os
from fastapi import HTTPException
from jwt import InvalidTokenError
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

# Initialize Azure Key Vault client
key_vault_url = os.getenv("AZURE_KEY_VAULT_URL")
if key_vault_url:
    credential = DefaultAzureCredential()
    secret_client = SecretClient(vault_url=key_vault_url, credential=credential)

    # Get secrets from Key Vault
    API_KEY = secret_client.get_secret("api-key").value
    JWT_SECRET = secret_client.get_secret("jwt-secret").value
else:
    # Fallback to environment variables for local development
    API_KEY = os.getenv("API_KEY")
    JWT_SECRET = os.getenv("JWT_SECRET")

def validate_api_key(api_key: str) -> None:
    """Validate API key"""
    if api_key != API_KEY:
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

def generate_jwt() -> str:
    """Generate a unique JWT for this transaction"""
    payload = {
        "exp": time.time() + 3600,  # 1 hour from now
        "iat": time.time(),
        "jti": str(time.time())  # Unique identifier
    }
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")