#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Nginx Load Balancing Demo Test Script ===${NC}"
echo -e "${YELLOW}This script will demonstrate load balancing by making requests to the nginx load balancer${NC}"
echo ""

# Function to make a request and show the response
make_request() {
    local request_num=$1
    echo -e "${GREEN}Request #${request_num}:${NC}"
    
    # Make the request and capture both status and response
    response=$(curl -s http://localhost/ 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        # Parse the JSON response to extract serverId
        server_id=$(echo "$response" | grep -o '"serverId":"[^"]*"' | cut -d'"' -f4)
        timestamp=$(echo "$response" | grep -o '"timestamp":"[^"]*"' | cut -d'"' -f4)
        hostname=$(echo "$response" | grep -o '"hostname":"[^"]*"' | cut -d'"' -f4)
        
        echo -e "  Server ID: ${YELLOW}${server_id}${NC}"
        echo -e "  Hostname: ${server_id}"
        echo -e "  Timestamp: ${timestamp}"
        echo -e "  Full Response: ${response}"
    else
        echo -e "  ${RED}Request failed${NC}"
    fi
    echo ""
}

# Function to check if services are running
check_services() {
    echo -e "${BLUE}Checking if services are running...${NC}"
    
    # Check nginx health
    nginx_health=$(curl -s http://localhost/health-check 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓ Nginx is running${NC}"
    else
        echo -e "  ${RED}✗ Nginx is not responding${NC}"
        echo -e "  ${YELLOW}Make sure to run: docker-compose up -d${NC}"
        return 1
    fi
    
    # Check if we can reach the backend through nginx
    backend_response=$(curl -s http://localhost/ 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓ Backend services are reachable through nginx${NC}"
    else
        echo -e "  ${RED}✗ Backend services are not reachable${NC}"
        return 1
    fi
    
    echo ""
    return 0
}

# Function to show nginx status
show_nginx_status() {
    echo -e "${BLUE}Nginx Status:${NC}"
    nginx_status=$(curl -s http://localhost/nginx-status 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "$nginx_status"
    else
        echo -e "${RED}Could not retrieve nginx status${NC}"
    fi
    echo ""
}

# Function to run load balancing test
run_load_balance_test() {
    local num_requests=${1:-10}
    
    echo -e "${BLUE}Running load balancing test with ${num_requests} requests...${NC}"
    echo -e "${YELLOW}You should see requests distributed across different servers (app1, app2, app3, app4, app5)${NC}"
    echo ""
    
    for i in $(seq 1 $num_requests); do
        make_request $i
        sleep 0.5  # Small delay between requests
    done
}

# Function to show server distribution
show_distribution() {
    local num_requests=${1:-20}
    
    echo -e "${BLUE}Analyzing server distribution with ${num_requests} requests...${NC}"
    
    # Create a temporary file to store server IDs
    temp_file=$(mktemp)
    
    for i in $(seq 1 $num_requests); do
        response=$(curl -s http://localhost/ 2>/dev/null)
        if [ $? -eq 0 ]; then
            server_id=$(echo "$response" | grep -o '"serverId":"[^"]*"' | cut -d'"' -f4)
            echo "$server_id" >> "$temp_file"
        fi
    done
    
    echo -e "${YELLOW}Server Distribution:${NC}"
    sort "$temp_file" | uniq -c | while read count server; do
        echo -e "  ${server}: ${count} requests"
    done
    
    rm "$temp_file"
    echo ""
}

# Main script execution
main() {
    # Check if services are running
    if ! check_services; then
        exit 1
    fi
    
    # Show nginx status
    show_nginx_status
    
    # Parse command line arguments
    case "${1:-demo}" in
        "demo")
            run_load_balance_test 8
            ;;
        "distribution")
            show_distribution ${2:-20}
            ;;
        "continuous")
            echo -e "${YELLOW}Running continuous test (Press Ctrl+C to stop)...${NC}"
            counter=1
            while true; do
                make_request $counter
                counter=$((counter + 1))
                sleep 1
            done
            ;;
        "quick")
            run_load_balance_test 5
            ;;
        *)
            echo -e "${YELLOW}Usage: $0 [demo|distribution|continuous|quick] [num_requests]${NC}"
            echo -e "  demo         - Run a standard demo with 8 requests (default)"
            echo -e "  distribution - Show distribution of requests across servers"
            echo -e "  continuous   - Run continuous requests (Ctrl+C to stop)"
            echo -e "  quick        - Run a quick test with 5 requests"
            exit 1
            ;;
    esac
}

# Run the main function with all arguments
main "$@"