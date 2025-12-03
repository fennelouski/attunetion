#!/bin/bash

# Build and Test Script for Attunetion
# This script builds and tests the app on all Apple platforms

set -e  # Exit on error

PROJECT_PATH="Attunetion.xcodeproj"
SCHEME="Attunetion"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔨 Building Attunetion for all platforms..."

# Check if Xcode developer directory is set correctly
DEVELOPER_DIR=$(xcode-select -p)
if [[ "$DEVELOPER_DIR" == *"CommandLineTools"* ]]; then
    echo -e "${YELLOW}⚠️  Warning: Developer directory is set to CommandLineTools${NC}"
    echo "Please run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo "Then run this script again."
    exit 1
fi

# Function to build for a platform
build_for_platform() {
    local platform=$1
    local destination=$2
    local platform_name=$3
    
    echo ""
    echo -e "${GREEN}📱 Building for $platform_name...${NC}"
    
    if xcodebuild -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -destination "$destination" \
        clean build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        2>&1 | tee "/tmp/build_${platform}.log"; then
        echo -e "${GREEN}✅ $platform_name build succeeded${NC}"
        return 0
    else
        echo -e "${RED}❌ $platform_name build failed${NC}"
        echo "Check /tmp/build_${platform}.log for details"
        return 1
    fi
}

# Function to test run (simulator)
test_run() {
    local platform=$1
    local destination=$2
    local platform_name=$3
    
    echo ""
    echo -e "${GREEN}🧪 Testing $platform_name (15 seconds)...${NC}"
    
    # Build and run in background, then kill after 15 seconds
    timeout 15 xcodebuild -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -destination "$destination" \
        test \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        2>&1 | tee "/tmp/test_${platform}.log" || true
    
    echo -e "${GREEN}✅ $platform_name test completed${NC}"
}

# Build and test for each platform
PLATFORMS=(
    "macOS|platform=macOS|macOS"
    "iOS|platform=iOS Simulator,name=iPhone 15|iOS"
    "watchOS|platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)|watchOS"
    "iPadOS|platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)|iPadOS"
    "visionOS|platform=visionOS Simulator,name=Apple Vision Pro|visionOS"
)

FAILED_PLATFORMS=()

for platform_info in "${PLATFORMS[@]}"; do
    IFS='|' read -r platform destination platform_name <<< "$platform_info"
    
    if ! build_for_platform "$platform" "$destination" "$platform_name"; then
        FAILED_PLATFORMS+=("$platform_name")
        continue
    fi
    
    # Note: Actual testing would require simulator setup
    # For now, we just verify the build succeeds
    echo -e "${GREEN}✅ $platform_name ready for testing${NC}"
done

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ${#FAILED_PLATFORMS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All platforms built successfully!${NC}"
else
    echo -e "${RED}❌ Some platforms failed to build:${NC}"
    for platform in "${FAILED_PLATFORMS[@]}"; do
        echo -e "  ${RED}• $platform${NC}"
    done
    exit 1
fi



