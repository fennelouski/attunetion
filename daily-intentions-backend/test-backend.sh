#!/bin/bash

# Backend Health Test Script
# Tests the backend structure and validates endpoints

echo "🔍 Testing Daily Intentions Backend..."
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to test file existence
test_file_exists() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} Missing: $1"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Function to test TypeScript compilation
test_typescript() {
    echo ""
    echo "📝 Testing TypeScript compilation..."
    if npm run type-check > /tmp/ts-check.log 2>&1; then
        echo -e "${GREEN}✓${NC} TypeScript compilation successful"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} TypeScript compilation failed"
        cat /tmp/ts-check.log | tail -20
        ((TESTS_FAILED++))
        return 1
    fi
}

# Function to test endpoint structure
test_endpoint() {
    local endpoint=$1
    if [ -f "$endpoint" ]; then
        echo -e "${GREEN}✓${NC} Endpoint exists: $endpoint"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} Missing endpoint: $endpoint"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo "1️⃣  Testing Project Structure..."
echo "--------------------------------"

# Test core files
test_file_exists "package.json"
test_file_exists "tsconfig.json"
test_file_exists "vercel.json"
test_file_exists "README.md"

echo ""
echo "2️⃣  Testing API Endpoints..."
echo "--------------------------------"

# Test API endpoints
test_endpoint "api/health.ts"
test_endpoint "api/ai/generate-theme.ts"
test_endpoint "api/ai/generate-quote.ts"
test_endpoint "api/ai/rephrase-intention.ts"
test_endpoint "api/ai/generate-monthly-intention.ts"
test_endpoint "api/ai/generate-weekly-intentions.ts"
test_endpoint "api/intentions/index.ts"
test_endpoint "api/intentions/[id].ts"
test_endpoint "api/legal/[document].ts"

echo ""
echo "3️⃣  Testing Library Files..."
echo "--------------------------------"

# Test library files
test_file_exists "lib/auth.ts"
test_file_exists "lib/openai.ts"
test_file_exists "lib/rateLimit.ts"
test_file_exists "lib/errors.ts"
test_file_exists "lib/db.ts"

echo ""
echo "4️⃣  Testing Type Definitions..."
echo "--------------------------------"

test_file_exists "types/index.ts"

echo ""
echo "5️⃣  Testing Dependencies..."
echo "--------------------------------"

if [ -d "node_modules" ]; then
    echo -e "${GREEN}✓${NC} Dependencies installed"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠${NC} Dependencies not installed (run: npm install)"
    ((TESTS_FAILED++))
fi

# Check for required packages
if [ -d "node_modules/openai" ]; then
    echo -e "${GREEN}✓${NC} OpenAI package installed"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} OpenAI package missing"
    ((TESTS_FAILED++))
fi

# Test TypeScript compilation
test_typescript

echo ""
echo "6️⃣  Testing Environment Configuration..."
echo "--------------------------------"

# Check for environment variables (optional)
if [ -f ".env" ] || [ -f ".env.local" ]; then
    echo -e "${GREEN}✓${NC} Environment file found"
    ((TESTS_PASSED++))
    
    if grep -q "OPENAI_API_KEY" .env 2>/dev/null || grep -q "OPENAI_API_KEY" .env.local 2>/dev/null; then
        echo -e "${GREEN}✓${NC} OPENAI_API_KEY configured"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} OPENAI_API_KEY not found in .env (set in Vercel dashboard for production)"
    fi
else
    echo -e "${YELLOW}⚠${NC} No .env file found (set environment variables in Vercel dashboard)"
fi

echo ""
echo "========================================"
echo "📊 Test Results:"
echo "   ${GREEN}Passed: ${TESTS_PASSED}${NC}"
echo "   ${RED}Failed: ${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed! Backend structure is healthy.${NC}"
    echo ""
    echo "📝 Next Steps:"
    echo "   1. Deploy to Vercel: vercel --prod"
    echo "   2. Set environment variables in Vercel dashboard"
    echo "   3. Test deployed endpoints: curl https://your-project.vercel.app/api/health"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Please review the errors above.${NC}"
    exit 1
fi


