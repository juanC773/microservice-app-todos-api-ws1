# TODOs API - Node.js

Node.js service for managing TODO tasks with Redis logging integration and automated CI/CD pipeline.

## Architecture

Provides CRUD operations for TODO entries with Redis message logging:
- **GET /todos** - List all TODOs for authenticated user
- **POST /todos** - Create new TODO  
- **DELETE /todos/:taskId** - Delete TODO by ID

Creates and deletes operations are logged to Redis queue for processing by Log Message Processor.

## Configuration

The service uses environment variables:
- `TODO_API_PORT` - Port for the service (default: 8082)
- `JWT_SECRET` - JWT token processing secret (must match other services)
- `REDIS_HOST` - Redis server hostname
- `REDIS_PORT` - Redis server port (default: 6379)
- `REDIS_CHANNEL` - Redis channel for operation logging

## Run Locally

**Prerequisites:**
- Node.js 8.17.0
- Redis server running

**Complete local stack:**
```bash
# 1. Redis
docker run -d -p 6379:6379 --name redis redis:7.0

# 2. Users API  
docker run -d -p 8083:8083 -e JWT_SECRET=PRFT -e SERVER_PORT=8083 --name users-api torres05/users-api-ws1:latest

# 3. Auth API
docker run -d -p 8000:8000 -e JWT_SECRET=PRFT -e AUTH_API_PORT=8000 -e USERS_API_ADDRESS=http://host.docker.internal:8083 --name auth-api torres05/auth-api-ws1:latest

# 4. TODOs API
docker run -d -p 8082:8082 -e JWT_SECRET=PRFT -e TODO_API_PORT=8082 -e REDIS_HOST=host.docker.internal -e REDIS_PORT=6379 -e REDIS_CHANNEL=log_channel --name todos-api juanc7773/todos-api-ws1:latest
```

**PowerShell (Windows):**
```powershell
$env:JWT_SECRET="PRFT"; $env:TODO_API_PORT="8082"; $env:REDIS_HOST="127.0.0.1"; $env:REDIS_PORT="6379"; $env:REDIS_CHANNEL="log_channel"; npm start
```

**Linux/macOS/Git Bash:**
```bash
JWT_SECRET=PRFT TODO_API_PORT=8082 REDIS_HOST=127.0.0.1 REDIS_PORT=6379 REDIS_CHANNEL=log_channel npm start
```

## Testing

Requires valid JWT token from Auth API. Test with these credentials:
- Username: `admin`, Password: `admin`
- Username: `johnd`, Password: `foo`  
- Username: `janed`, Password: `ddd`

**PowerShell testing:**
```powershell
# Get token
$response = Invoke-RestMethod -Uri "http://127.0.0.1:8000/login" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username":"admin","password":"admin"}'
$token = $response.accessToken

# List TODOs
Invoke-RestMethod -Uri "http://127.0.0.1:8082/todos" -Headers @{"Authorization"="Bearer $token"}

# Create TODO
Invoke-RestMethod -Uri "http://127.0.0.1:8082/todos" -Method POST -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} -Body '{"content":"New test task"}'

# Delete TODO (replace 1 with actual ID)
Invoke-RestMethod -Uri "http://127.0.0.1:8082/todos/1" -Method DELETE -Headers @{"Authorization"="Bearer $token"}
```

## CI/CD Pipeline

### Setup Requirements:
**GitHub Secrets (Repository → Settings → Secrets):**
- `DOCKERHUB_USERNAME`: juanc7773  
- `DOCKERHUB_TOKEN`: Your Docker Hub access token

### Automated Process:
1. **Push to master** → GitHub Actions triggers
2. **Build & Test** → npm install, npm test
3. **Docker Build** → Creates Node.js 8.17.0 container
4. **Push to Registry** → Uploads to Docker Hub as `juanc7773/todos-api-ws1:latest`

### Pipeline File:
`.github/workflows/main.yml` - Runs on every push to master branch

## Infrastructure (Terraform)

Deploys to Azure Container Apps with environment variables:
- **Local:** `REDIS_HOST=127.0.0.1` or `host.docker.internal`
- **Azure:** `REDIS_HOST=redis-app` (internal Azure Container App name)

## Key Files

- `package.json` - Dependencies and start script
- `Dockerfile` - Node.js 8.17.0 container configuration
- `server.js` - Main application entry point  
- `controller/TodoController.js` - CRUD operations logic
- `routes/` - API endpoint definitions
- `.github/workflows/main.yml` - CI/CD pipeline

## Data Model

**TODO Object:**
```json
{
  "id": 1,
  "content": "Create new todo"
}
```

**Log Message:**
```json
{
  "opName": "CREATE",
  "username": "admin", 
  "todoId": 5
}
```

## Common Issues

**Redis connection fails:**
Check REDIS_HOST configuration - use `host.docker.internal` for local Docker or service name for Azure

**JWT token invalid:**  
Ensure JWT_SECRET matches across all services (Auth, Users, TODOs APIs)

**Node.js version errors:**
Use Node.js 8.17.0 specifically for compatibility with dependencies

## Dependencies

- Node.js 8.17.0
- Express.js 4.x
- Redis 7.0  
- JWT authentication
- Docker (for containerization)

---

**Result:** Automated deployment pipeline that builds and deploys TODOs API on every code change with Redis logging integration.