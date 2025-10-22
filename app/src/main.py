import os
from fastapi import FastAPI, Header, HTTPException, Request
from pydantic import BaseModel
from .auth import validate_api_key, validate_jwt, generate_jwt

# Load environment variables from .env file
if os.path.exists(".env"):
    with open(".env", "r") as f:
        for line in f:
            if line.strip() and not line.startswith("#"):
                key, value = line.strip().split("=", 1)
                os.environ[key] = value

# Fallback to config.env if .env doesn't exist
elif os.path.exists("config.env"):
    with open("config.env", "r") as f:
        for line in f:
            if line.strip() and not line.startswith("#"):
                key, value = line.strip().split("=", 1)
                os.environ[key] = value

class DevOpsIn(BaseModel):
    message: str
    to: str
    from_: str | None = None
    timeToLifeSec: int

app = FastAPI(title="DevOps Microservice", version="1.0.0")

@app.get("/health")
async def health_check():
    """Health check endpoint for load balancer"""
    return {"status": "healthy"}

@app.post("/DevOps")
async def devops_endpoint(
    body: DevOpsIn,
    x_parse_rest_api_key: str = Header(alias="X-Parse-REST-API-Key"),
    x_jwt_kwy: str = Header(alias="X-JWT-KWY")
 ):
    validate_api_key(x_parse_rest_api_key)
    validate_jwt(x_jwt_kwy)

    # Generate unique JWT for this transaction
    unique_jwt = generate_jwt()

    return {
        "message": f"Hello {body.to} your message will be send",
        "transaction_jwt": unique_jwt
    }

@app.api_route("/DevOps", methods=["GET", "PUT", "DELETE", "PATCH", "OPTIONS"])
async def devops_error(request: Request):
    return "ERROR"