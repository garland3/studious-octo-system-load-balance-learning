# Nginx Load Balancing Demo

A hands-on learning project demonstrating load balancing with Nginx and multiple backend services using Docker Compose.

## 🎯 What This Demo Shows

This project demonstrates:
- **Load Balancing**: Nginx distributing requests across 5 backend Node.js servers
- **Round-Robin Distribution**: Requests are automatically distributed evenly
- **Health Checks**: Both Nginx and backend services have health monitoring
- **Container Orchestration**: All services managed with Docker Compose
- **Real-time Testing**: Scripts to visualize load balancing in action

## 🏗️ Architecture

```
                    ┌─────────────┐
                    │   Client    │
                    └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    Nginx    │  (Load Balancer)
                    │   Port 80   │
                    └─────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
  ┌──────────┐      ┌──────────┐      ┌──────────┐
  │   App1   │      │   App2   │ ... │   App5   │
  │ Port 3000│      │ Port 3000│      │ Port 3000│
  └──────────┘      └──────────┘      └──────────┘
```

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Bash shell (Linux/macOS/WSL)

### 1. Start the Demo
```bash
./start-demo.sh
```

This will:
- Build and start 5 backend Node.js servers
- Start Nginx load balancer
- Wait for all services to be ready
- Show connection status

### 2. Test Load Balancing
```bash
# Run standard demo (8 requests)
./test-load-balance.sh

# Analyze request distribution
./test-load-balance.sh distribution

# Run continuous testing (Ctrl+C to stop)
./test-load-balance.sh continuous

# Quick test (5 requests)
./test-load-balance.sh quick
```

### 3. Monitor Services
```bash
# View all service logs
docker compose logs -f

# View specific service logs
docker compose logs -f nginx
docker compose logs -f app1

# Check service status
docker compose ps
```

### 4. Access Endpoints
- **Main Application**: http://localhost/
- **Nginx Status**: http://localhost/nginx-status
- **Nginx Health**: http://localhost/health-check

### 5. Stop the Demo
```bash
# Stop services
./stop-demo.sh

# Stop and clean up everything
./stop-demo.sh --clean
```

## 📁 Project Structure

```
├── README.md                 # This file
├── docker-compose.yml        # Service orchestration
├── Dockerfile               # Backend service container
├── package.json             # Node.js dependencies
├── server.js                # Backend server code
├── nginx/
│   └── nginx.conf           # Nginx configuration
├── start-demo.sh            # Start all services
├── stop-demo.sh             # Stop all services
├── test-load-balance.sh     # Test load balancing
└── .gitignore               # Git ignore rules
```

## 🔧 Configuration Details

### Backend Services
- **Technology**: Node.js with Express
- **Port**: 3000 (internal)
- **Instances**: 5 (app1, app2, app3, app4, app5)
- **Endpoints**:
  - `GET /` - Main endpoint with server identification
  - `GET /health` - Health check
  - `GET /status` - Detailed server status

### Nginx Load Balancer
- **Algorithm**: Round-robin (default)
- **Port**: 80 (external)
- **Features**:
  - Health checks for backend servers
  - Request timeout handling
  - Status monitoring endpoint
  - Access and error logging

### Docker Compose
- **Network**: Custom bridge network for service communication
- **Health Checks**: Automated health monitoring for all services
- **Dependencies**: Nginx waits for all backend services

## 🧪 Testing Scenarios

### Basic Load Balancing Test
```bash
./test-load-balance.sh
```
Shows how requests are distributed across different servers.

### Distribution Analysis
```bash
./test-load-balance.sh distribution 50
```
Makes 50 requests and shows the distribution count per server.

### Continuous Testing
```bash
./test-load-balance.sh continuous
```
Runs continuous requests to observe real-time load balancing.

## 📊 Example Output

When you run the test script, you'll see output like:
```
Request #1:
  Server ID: app1
  Hostname: app1
  Timestamp: 2024-01-15T10:30:45.123Z

Request #2:
  Server ID: app2
  Hostname: app2
  Timestamp: 2024-01-15T10:30:45.678Z
```

## 🎓 Learning Objectives

After running this demo, you'll understand:

1. **Load Balancing Concepts**:
   - How requests are distributed across multiple servers
   - Round-robin algorithm behavior
   - Benefits of load balancing

2. **Nginx Configuration**:
   - Upstream server definitions
   - Proxy settings and headers
   - Health check configurations

3. **Container Orchestration**:
   - Multi-service Docker Compose setup
   - Service dependencies and networking
   - Health monitoring and scaling

4. **Practical Testing**:
   - How to verify load balancing is working
   - Monitoring and debugging techniques
   - Performance considerations

## 🔧 Customization

### Change Load Balancing Algorithm
Edit `nginx/nginx.conf` and modify the upstream block:

```nginx
upstream backend_servers {
    # For least connections
    least_conn;
    
    # For IP hash (session persistence)
    ip_hash;
    
    # For weighted round-robin
    server app1:3000 weight=3;
    server app2:3000 weight=1;
    # ... other servers
}
```

### Add More Backend Servers
1. Add new service in `docker-compose.yml`
2. Add server to nginx upstream configuration
3. Restart services

### Modify Backend Response
Edit `server.js` to customize the response format or add new endpoints.

## 🐛 Troubleshooting

### Services Won't Start
```bash
# Check Docker status
docker info

# View service logs
docker compose logs

# Restart services
./stop-demo.sh
./start-demo.sh
```

### Load Balancer Not Working
```bash
# Check nginx configuration
docker compose exec nginx nginx -t

# Check if backend services are reachable
docker compose exec nginx ping app1

# View nginx logs
docker compose logs nginx
```

### Port Already in Use
If port 80 is busy, modify `docker-compose.yml`:
```yaml
nginx:
  ports:
    - "8080:80"  # Use port 8080 instead
```

## 📚 Further Learning

- [Nginx Load Balancing Documentation](https://nginx.org/en/docs/http/load_balancing.html)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)
- [Express.js Documentation](https://expressjs.com/)

## 🤝 Contributing

This is a learning project! Feel free to:
- Add new load balancing algorithms
- Create additional monitoring endpoints
- Improve the testing scripts
- Add new backend service types

## 📝 License

MIT License - feel free to use this for learning and teaching!