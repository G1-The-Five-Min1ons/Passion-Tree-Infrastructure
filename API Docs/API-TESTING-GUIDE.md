# API Testing Guide - AI Integration & Node Reordering

This guide provides instructions for testing the AI integration and node reordering features in the Passion Tree backend.

## Features Implemented

### 1. AI Path Generation Integration
- **Endpoint**: `POST /api/v1/learningpaths/:path_id/generate`
- **Description**: Generates a learning path using AI based on a topic
- **Integration**: Go backend connects to Python AI service

### 2. Node Reordering
- **Endpoint**: `PUT /api/v1/learningpaths/:path_id/nodes/reorder`
- **Description**: Updates the sequence/order of nodes in a learning path
- **Body**: `{ "node_ids": ["id1", "id2", "id3"] }`

## Prerequisites

1. **Services Running**:
   - Backend (Go): `http://localhost:8080`
   - AI Service (Python): `http://localhost:8000`
   - Database: Connected and migrations applied

2. **Tools Required**:
   - **Option A (Bash)**: `curl`, `jq`
   - **Option B (PowerShell)**: PowerShell 5.1 or later
   - **Option C (Bruno)**: Bruno API client

## Testing Methods

### Method 1: Automated Test Script (Recommended)

#### For Linux/Mac/Git Bash:
```bash
cd Passion-Tree-Infrastructure/scripts
chmod +x test-api-integration.sh
./test-api-integration.sh
```

#### For Windows PowerShell:
```powershell
cd Passion-Tree-Infrastructure\scripts
.\test-api-integration.ps1
```

#### With Custom URLs:
```bash
# Bash
BACKEND_URL=http://localhost:8080 AI_URL=http://localhost:8000 ./test-api-integration.sh

# PowerShell
.\test-api-integration.ps1 -BackendUrl "http://localhost:8080" -AIUrl "http://localhost:8000"
```

### Method 2: Bruno API Client

1. Open Bruno and load the collection:
   ```
   Passion-Tree-Infrastructure/API Docs/API-Test
   ```

2. **Test AI Generation**:
   - Navigate to `Generator > POST`
   - Click "Send"
   - Verify response contains generated nodes

3. **Test Backend AI Integration**:
   - Navigate to `Learning-Path > generate-path-with-ai`
   - Replace `:path_id` with actual path ID
   - Update `topic` in request body
   - Click "Send"

4. **Test Node Reordering**:
   - Navigate to `Node > reorder-nodes`
   - Replace `:path_id` with actual path ID
   - Update `node_ids` array with actual node IDs
   - Click "Send"

### Method 3: Manual cURL Testing

#### 1. Test AI Service Directly
```bash
curl -X POST http://localhost:8000/api/v1/generator/learning-path \
  -H "Content-Type: application/json" \
  -d '{"topic": "Machine Learning"}'
```

Expected response:
```json
{
  "topic": "Machine Learning",
  "result": "Node 1: Introduction to ML, Node 2: Supervised Learning, ...",
  "used_context": [...]
}
```

#### 2. Create a Learning Path
```bash
curl -X POST http://localhost:8080/api/v1/learningpaths \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Path",
    "description": "Testing AI integration",
    "objective": "Learn and test",
    "creator_id": "user-123"
  }'
```

Save the returned `path_id` for next steps.

#### 3. Generate Path with AI (Backend Integration)
```bash
PATH_ID="your-path-id-here"

curl -X POST "http://localhost:8080/api/v1/learningpaths/$PATH_ID/generate" \
  -H "Content-Type: application/json" \
  -d '{"topic": "Python Programming"}'
```

Expected response:
```json
{
  "success": true,
  "message": "Path generated successfully",
  "data": {
    "topic": "Python Programming",
    "nodes": [
      {"sequence": 1, "title": "Introduction to Python"},
      {"sequence": 2, "title": "Data Structures"},
      {"sequence": 3, "title": "OOP Concepts"}
    ]
  }
}
```

#### 4. Create Nodes
```bash
PATH_ID="your-path-id-here"

# Node 1
NODE_ID_1=$(curl -s -X POST "http://localhost:8080/api/v1/learningpaths/$PATH_ID/nodes" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Introduction",
    "description": "Basic concepts"
  }' | jq -r '.data.node_id')

# Node 2
NODE_ID_2=$(curl -s -X POST "http://localhost:8080/api/v1/learningpaths/$PATH_ID/nodes" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Intermediate",
    "description": "Advanced concepts"
  }' | jq -r '.data.node_id')

# Node 3
NODE_ID_3=$(curl -s -X POST "http://localhost:8080/api/v1/learningpaths/$PATH_ID/nodes" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Advanced",
    "description": "Expert level"
  }' | jq -r '.data.node_id')

echo "Created nodes: $NODE_ID_1, $NODE_ID_2, $NODE_ID_3"
```

#### 5. Reorder Nodes
```bash
PATH_ID="your-path-id-here"
NODE_ID_1="node-id-1"
NODE_ID_2="node-id-2"
NODE_ID_3="node-id-3"

# Reorder: 3, 2, 1 (reverse order)
curl -X PUT "http://localhost:8080/api/v1/learningpaths/$PATH_ID/nodes/reorder" \
  -H "Content-Type: application/json" \
  -d "{
    \"node_ids\": [\"$NODE_ID_3\", \"$NODE_ID_2\", \"$NODE_ID_1\"]
  }"
```

Expected response:
```json
{
  "success": true,
  "message": "Nodes reordered successfully"
}
```

#### 6. Verify Order
```bash
PATH_ID="your-path-id-here"

curl -X GET "http://localhost:8080/api/v1/learningpaths/$PATH_ID" | jq '.data.nodes[] | {sequence, title}'
```

## API Endpoints Reference

### AI Generation

#### Generate Learning Path (AI Service)
```http
POST http://localhost:8000/api/v1/generator/learning-path
Content-Type: application/json

{
  "topic": "string"
}
```

#### Generate Learning Path (Backend Integration)
```http
POST http://localhost:8080/api/v1/learningpaths/:path_id/generate
Content-Type: application/json

{
  "topic": "string"
}
```

### Node Management

#### Create Node
```http
POST http://localhost:8080/api/v1/learningpaths/:path_id/nodes
Content-Type: application/json

{
  "title": "string",
  "description": "string"
}
```

#### Reorder Nodes
```http
PUT http://localhost:8080/api/v1/learningpaths/:path_id/nodes/reorder
Content-Type: application/json

{
  "node_ids": ["string", "string", "string"]
}
```

#### Get Learning Path Details
```http
GET http://localhost:8080/api/v1/learningpaths/:path_id
```

## Troubleshooting

### AI Service Not Reachable
```bash
# Check if AI service is running
curl http://localhost:8000

# Check Docker containers
docker ps | grep ai-fastapi

# View AI service logs
docker logs passion-tree-infra-ai-fastapi-1
```

### Backend Service Not Reachable
```bash
# Check if backend is running
curl http://localhost:8080

# Check Docker containers
docker ps | grep backend-go

# View backend logs
docker logs passion-tree-infra-backend-go-1
```

### Database Connection Issues
```bash
# Check database connection
docker logs passion-tree-infra-backend-go-1 | grep -i "database"

# Verify environment variables
docker exec passion-tree-infra-backend-go-1 env | grep AZURESQL
```

### Node Order Not Updating
- Verify that node IDs in the request body are valid
- Check that all node IDs belong to the specified path
- Ensure the sequence is being updated in the database

## Expected Behavior

### AI Generation Flow
1. User provides a topic (e.g., "Python Programming")
2. Backend receives request at `/learningpaths/:path_id/generate`
3. Backend calls AI service at `http://ai-service:8000/api/v1/generator/learning-path`
4. AI service generates structured learning path
5. Backend parses AI response and returns formatted nodes
6. Nodes include sequence number and title

### Node Reordering Flow
1. User provides ordered array of node IDs
2. Backend receives request at `/learningpaths/:path_id/nodes/reorder`
3. Backend updates sequence field for each node
4. First node in array gets sequence 0, second gets 1, etc.
5. Database is updated with new sequences
6. Subsequent GET requests return nodes in new order

## Testing Checklist

- [ ] AI service is running and accessible
- [ ] Backend service is running and accessible
- [ ] Database connection is established
- [ ] AI generation endpoint works directly (port 8000)
- [ ] AI generation endpoint works through backend (port 8080)
- [ ] Learning path can be created
- [ ] Nodes can be created
- [ ] Nodes can be reordered
- [ ] Node order persists after reorder
- [ ] Error handling works for invalid inputs

## Architecture

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Client    │────────▶│  Backend-Go  │────────▶│  AI-FastAPI │
│  (Bruno/    │         │  Port: 8080  │         │  Port: 8000 │
│   cURL)     │         │              │         │             │
└─────────────┘         └──────┬───────┘         └─────────────┘
                               │
                               ▼
                        ┌──────────────┐
                        │   Database   │
                        │   (Azure SQL)│
                        └──────────────┘
```

## Support

If you encounter any issues:
1. Check service logs
2. Verify environment variables
3. Ensure all services are running
4. Check network connectivity between services
5. Review error messages in response

For more information, refer to:
- [API Docs](../API%20Docs/)
- [Backend README](../../Passion-Tree-Backend/README.md)
- [AI Service README](../../Passion-Tree-AI/README.md)
