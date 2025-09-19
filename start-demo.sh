#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Starting Nginx Load Balancing Demo ===${NC}"
echo ""

# Function to check if Docker is running
check_docker() {
    if ! docker info &> /dev/null; then
        echo -e "${RED}Error: Docker is not running. Please start Docker first.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Docker is running${NC}"
}

# Function to check if docker compose is available
check_docker_compose() {
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}Error: docker compose is not available.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ docker compose is available${NC}"
}

# Function to start services
start_services() {
    echo -e "${YELLOW}Building and starting services...${NC}"
    docker compose down 2>/dev/null  # Clean up any existing containers
    docker compose up -d --build
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Services started successfully${NC}"
    else
        echo -e "${RED}✗ Failed to start services${NC}"
        exit 1
    fi
}

# Function to wait for services to be ready
wait_for_services() {
    echo -e "${YELLOW}Waiting for services to be ready...${NC}"
    
    # Wait for nginx to be ready
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost/health-check &> /dev/null; then
            echo -e "${GREEN}✓ Nginx is ready${NC}"
            break
        fi
        
        echo -e "  Attempt $attempt/$max_attempts - waiting for nginx..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        echo -e "${RED}✗ Services did not start within expected time${NC}"
        echo -e "${YELLOW}Check logs with: docker-compose logs${NC}"
        exit 1
    fi
    
    # Wait a bit more for all backend services to be ready
    echo -e "${YELLOW}Waiting for backend services to be fully ready...${NC}"
    sleep 5
    echo -e "${GREEN}✓ All services should now be ready${NC}"
}

# Function to show service status
show_status() {
    echo ""
    echo -e "${BLUE}Service Status:${NC}"
    docker compose ps
    echo ""
    
    echo -e "${BLUE}Quick connectivity test:${NC}"
    response=$(curl -s http://localhost/ 2>/dev/null)
    if [ $? -eq 0 ]; then
        server_id=$(echo "$response" | grep -o '"serverId":"[^"]*"' | cut -d'"' -f4)
        echo -e "${GREEN}✓ Load balancer is working! First request routed to: ${server_id}${NC}"
    else
        echo -e "${RED}✗ Load balancer is not responding${NC}"
    fi
}

# Function to show next steps
show_next_steps() {
    echo ""
    echo -e "${BLUE}=== Demo is Ready! ===${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Test the load balancing: ${GREEN}./test-load-balance.sh${NC}"
    echo -e "  2. Run distribution analysis: ${GREEN}./test-load-balance.sh distribution${NC}"
    echo -e "  3. Run continuous testing: ${GREEN}./test-load-balance.sh continuous${NC}"
    echo -e "  4. View service logs: ${GREEN}docker compose logs -f${NC}"
    echo -e "  5. Stop the demo: ${GREEN}./stop-demo.sh${NC}"
    echo ""
    echo -e "${YELLOW}Access points:${NC}"
    echo -e "  - Load balanced app: ${GREEN}http://localhost/${NC}"
    echo -e "  - Nginx status: ${GREEN}http://localhost/nginx-status${NC}"
    echo -e "  - Nginx health: ${GREEN}http://localhost/health-check${NC}"
    echo ""
}

# Main execution
main() {
    check_docker
    check_docker_compose
    start_services
    wait_for_services
    show_status
    show_next_steps
}

# Run main function
main