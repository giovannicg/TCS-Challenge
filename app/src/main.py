from fastapi import FastAPI, Header, HTTPException, Request
from pydantic import BaseModel
from .auth import validate_api_key, validate_jwt

class DevOpsIn(BaseModel):
    message: str
    to: str
    from_: str | None = None
    timeToLifeSec: int

app = FastAPI(title="DevOps Microservice", version="1.0.0")

@app.post("/DevOps")
async def devops_endpoint(
    body: DevOpsIn,
    x_parse_rest_api_key: str = Header(alias="X-Parse-REST-API-Key"),
    x_jwt_kwy: str = Header(alias="X-JWT-KWY")
):
    validate_api_key(x_parse_rest_api_key)
    validate_jwt(x_jwt_kwy)
    return {"message": f"Hello {body.to} your message will be send"}

@app.api_route("/DevOps", methods=["GET", "PUT", "DELETE", "PATCH", "OPTIONS"])
async def devops_error(request: Request):
    return "ERROR"