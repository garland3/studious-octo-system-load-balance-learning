#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Stopping Nginx Load Balancing Demo ===${NC}"
echo ""

# Function to stop services
stop_services() {
    echo -e "${YELLOW}Stopping services...${NC}"
    docker compose down
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Services stopped successfully${NC}"
    else
        echo -e "${RED}✗ Error stopping services${NC}"
        exit 1
    fi
}

# Function to clean up (optional)
cleanup() {
    if [ "$1" = "--clean" ]; then
        echo -e "${YELLOW}Cleaning up containers and images...${NC}"
        docker compose down --rmi all --volumes --remove-orphans
        echo -e "${GREEN}✓ Cleanup completed${NC}"
    fi
}

# Function to show final status
show_final_status() {
    echo ""
    echo -e "${BLUE}Final Status:${NC}"
    
    # Check if any containers are still running
    running_containers=$(docker compose ps -q 2>/dev/null)
    if [ -z "$running_containers" ]; then
        echo -e "${GREEN}✓ All demo containers have been stopped${NC}"
    else
        echo -e "${YELLOW}Some containers may still be running:${NC}"
        docker compose ps
    fi
    
    echo ""
    echo -e "${BLUE}Demo stopped successfully!${NC}"
    
    if [ "$1" != "--clean" ]; then
        echo -e "${YELLOW}Tip: Use './stop-demo.sh --clean' to remove all containers and images${NC}"
    fi
}

# Main execution
main() {
    stop_services
    cleanup "$1"
    show_final_status "$1"
}

# Run main function with arguments
main "$@"