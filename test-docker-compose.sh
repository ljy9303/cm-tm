#!/bin/bash

# Docker Compose Test Environment Validation Script
# This script validates the Docker Compose test environment setup

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    print_status "Checking Docker installation and status..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running"
        exit 1
    fi
    
    print_success "Docker is installed and running"
}

# Function to check if Docker Compose is available
check_docker_compose() {
    print_status "Checking Docker Compose availability..."
    
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available"
        exit 1
    fi
    
    print_success "Docker Compose is available"
}

# Function to validate environment files
validate_env_files() {
    print_status "Validating environment files..."
    
    if [[ ! -f ".env.test" ]]; then
        print_error "Missing .env.test file"
        exit 1
    fi
    
    # Check for required environment variables
    required_vars=("POSTGRES_DB" "POSTGRES_USER" "POSTGRES_PASSWORD" "SPRING_DATASOURCE_URL")
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" .env.test; then
            print_error "Missing required environment variable: $var"
            exit 1
        fi
    done
    
    print_success "Environment files are valid"
}

# Function to validate Docker Compose configuration
validate_compose_config() {
    print_status "Validating Docker Compose configuration..."
    
    if [[ ! -f "docker-compose.test.yml" ]]; then
        print_error "Missing docker-compose.test.yml file"
        exit 1
    fi
    
    # Validate Docker Compose syntax
    if ! docker compose -f docker-compose.test.yml config &> /dev/null; then
        print_error "Invalid Docker Compose configuration"
        exit 1
    fi
    
    print_success "Docker Compose configuration is valid"
}

# Function to start services
start_services() {
    print_status "Starting Docker Compose services..."
    
    # Clean up any existing containers
    docker compose -f docker-compose.test.yml down --remove-orphans
    
    # Start services in background
    docker compose -f docker-compose.test.yml up -d
    
    print_success "Services started successfully"
}

# Function to wait for services to be healthy
wait_for_services() {
    print_status "Waiting for services to become healthy..."
    
    # Wait for PostgreSQL
    print_status "Waiting for PostgreSQL to be ready..."
    local postgres_ready=false
    local max_attempts=30
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if docker compose -f docker-compose.test.yml exec -T postgres-test pg_isready -U test_user -d lastwar_test &> /dev/null; then
            postgres_ready=true
            break
        fi
        sleep 2
        ((attempt++))
        print_status "PostgreSQL not ready yet (attempt $attempt/$max_attempts)..."
    done
    
    if [[ $postgres_ready == false ]]; then
        print_error "PostgreSQL failed to become ready within timeout"
        show_logs
        exit 1
    fi
    
    print_success "PostgreSQL is ready"
    
    # Wait for Spring Boot API
    print_status "Waiting for Spring Boot API to be ready..."
    local api_ready=false
    max_attempts=60
    attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if curl -f http://localhost:8081/actuator/health &> /dev/null; then
            api_ready=true
            break
        fi
        sleep 3
        ((attempt++))
        print_status "Spring Boot API not ready yet (attempt $attempt/$max_attempts)..."
    done
    
    if [[ $api_ready == false ]]; then
        print_error "Spring Boot API failed to become ready within timeout"
        show_logs
        exit 1
    fi
    
    print_success "Spring Boot API is ready"
    
    # Wait for Next.js frontend
    print_status "Waiting for Next.js frontend to be ready..."
    local frontend_ready=false
    max_attempts=40
    attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if curl -f http://localhost:3001/api/health &> /dev/null; then
            frontend_ready=true
            break
        fi
        sleep 3
        ((attempt++))
        print_status "Next.js frontend not ready yet (attempt $attempt/$max_attempts)..."
    done
    
    if [[ $frontend_ready == false ]]; then
        print_error "Next.js frontend failed to become ready within timeout"
        show_logs
        exit 1
    fi
    
    print_success "Next.js frontend is ready"
}

# Function to run health checks
run_health_checks() {
    print_status "Running comprehensive health checks..."
    
    # Check PostgreSQL connection
    print_status "Testing PostgreSQL connection..."
    if docker compose -f docker-compose.test.yml exec -T postgres-test psql -U test_user -d lastwar_test -c "SELECT 1;" &> /dev/null; then
        print_success "PostgreSQL connection test passed"
    else
        print_error "PostgreSQL connection test failed"
        return 1
    fi
    
    # Check Spring Boot health endpoint
    print_status "Testing Spring Boot health endpoint..."
    local health_response=$(curl -s http://localhost:8081/actuator/health)
    if echo "$health_response" | grep -q '"status":"UP"'; then
        print_success "Spring Boot health check passed"
    else
        print_error "Spring Boot health check failed"
        print_error "Health response: $health_response"
        return 1
    fi
    
    # Check Next.js health endpoint
    print_status "Testing Next.js health endpoint..."
    local frontend_health=$(curl -s http://localhost:3001/api/health)
    if echo "$frontend_health" | grep -q '"status":"ok"'; then
        print_success "Next.js health check passed"
    else
        print_error "Next.js health check failed"
        print_error "Frontend health response: $frontend_health"
        return 1
    fi
    
    # Test database connectivity from API
    print_status "Testing API database connectivity..."
    local db_test_response=$(curl -s http://localhost:8081/actuator/health)
    if echo "$db_test_response" | grep -q '"db":.*"status":"UP"'; then
        print_success "API database connectivity test passed"
    else
        print_warning "API database connectivity test inconclusive"
    fi
    
    return 0
}

# Function to show service logs
show_logs() {
    print_status "Showing service logs..."
    echo "=== PostgreSQL Logs ==="
    docker compose -f docker-compose.test.yml logs postgres-test --tail=20
    echo ""
    echo "=== Spring Boot API Logs ==="
    docker compose -f docker-compose.test.yml logs lastwar-api-test --tail=20
    echo ""
    echo "=== Next.js Frontend Logs ==="
    docker compose -f docker-compose.test.yml logs lastwar-www-test --tail=20
}

# Function to show service status
show_status() {
    print_status "Service status:"
    docker compose -f docker-compose.test.yml ps
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up test environment..."
    docker compose -f docker-compose.test.yml down --remove-orphans
    print_success "Cleanup completed"
}

# Main execution
main() {
    print_status "Starting Docker Compose test environment validation..."
    
    # Change to project directory
    cd "$(dirname "$0")"
    
    # Pre-flight checks
    check_docker
    check_docker_compose
    validate_env_files
    validate_compose_config
    
    # Start services
    start_services
    
    # Wait for services to be ready
    wait_for_services
    
    # Run health checks
    if run_health_checks; then
        print_success "All health checks passed!"
        show_status
        
        print_success "Test environment is ready for use!"
        print_status "Service URLs:"
        print_status "  - PostgreSQL: localhost:5433"
        print_status "  - Spring Boot API: http://localhost:8081"
        print_status "  - Next.js Frontend: http://localhost:3001"
        print_status "  - API Documentation: http://localhost:8081/swagger-ui.html"
        print_status "  - API Health: http://localhost:8081/actuator/health"
        print_status "  - Frontend Health: http://localhost:3001/api/health"
        
        print_status "To stop the environment, run: docker compose -f docker-compose.test.yml down"
        
    else
        print_error "Health checks failed!"
        show_logs
        cleanup
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    "cleanup")
        cleanup
        exit 0
        ;;
    "logs")
        show_logs
        exit 0
        ;;
    "status")
        show_status
        exit 0
        ;;
    "health")
        run_health_checks
        exit $?
        ;;
    *)
        main
        ;;
esac