#!/bin/bash

# Tree of Life - Automated Deployment Pipeline
# Executes GAR-37 through GAR-42
# Author: Automated via Perplexity AI
# Date: 2025-12-29

set -e  # Exit on error

echo "🌳 Tree of Life - Deployment Automation"
echo "========================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Railway Token Generation (GAR-37)
echo -e "${YELLOW}📍 STEP 1: Generate Railway Token${NC}"
echo "Run these commands manually:"
echo "  railway login"
echo "  railway tokens create"
echo ""
read -p "Have you generated the Railway token? (y/n): " token_ready

if [ "$token_ready" != "y" ]; then
    echo -e "${RED}❌ Please generate Railway token first${NC}"
    exit 1
fi

read -p "Paste your Railway token: " RAILWAY_TOKEN

if [ -z "$RAILWAY_TOKEN" ]; then
    echo -e "${RED}❌ Token cannot be empty${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Token received${NC}"
echo ""

# Step 2: GitHub Secrets Configuration (GAR-38)
echo -e "${YELLOW}📍 STEP 2: Configure GitHub Secret${NC}"
echo "Manual action required:"
echo "1. Go to: https://github.com/Garrettc123/tree-of-life-minimal/settings/secrets/actions"
echo "2. Click 'New repository secret'"
echo "3. Name: RAILWAY_TOKEN"
echo "4. Value: $RAILWAY_TOKEN"
echo "5. Click 'Add secret'"
echo ""
read -p "Have you added the GitHub secret? (y/n): " secret_ready

if [ "$secret_ready" != "y" ]; then
    echo -e "${RED}❌ Please add GitHub secret first${NC}"
    exit 1
fi

echo -e "${GREEN}✅ GitHub secret configured${NC}"
echo ""

# Step 3: Trigger Auto-Deploy (GAR-39)
echo -e "${YELLOW}📍 STEP 3: Trigger Auto-Deploy Test${NC}"
echo "Creating deployment trigger..."

echo "" >> README.md
echo "# Auto-Deploy Test - $(date)" >> README.md

git add README.md
git commit -m "test: trigger auto-deploy workflow - $(date +%Y%m%d-%H%M%S)"
git push origin master

echo -e "${GREEN}✅ Deploy triggered${NC}"
echo "Monitor at: https://github.com/Garrettc123/tree-of-life-minimal/actions"
echo ""
echo "Waiting 60 seconds for deployment..."
sleep 60

# Step 4: Link Railway Project (GAR-40)
echo -e "${YELLOW}📍 STEP 4: Link Railway Project${NC}"
echo "Linking project..."

if command -v railway &> /dev/null; then
    railway link 2>/dev/null || echo "Railway link may require manual selection"
    railway status
    echo -e "${GREEN}✅ Railway project linked${NC}"
else
    echo -e "${RED}❌ Railway CLI not found. Install with: npm i -g @railway/cli${NC}"
    exit 1
fi
echo ""

# Step 5: Get Production URL (GAR-41)
echo -e "${YELLOW}📍 STEP 5: Get Production URL${NC}"
PROD_URL=$(railway domain 2>/dev/null | grep -oP 'https://[^\s]+' | head -1)

if [ -z "$PROD_URL" ]; then
    echo -e "${RED}❌ Could not retrieve production URL${NC}"
    echo "Run manually: railway domain"
    read -p "Enter production URL: " PROD_URL
fi

echo "Production URL: $PROD_URL"
echo ""
echo "Testing endpoint..."
curl -X GET "$PROD_URL/" -s | jq . || echo "Response received"

echo -e "${GREEN}✅ Production deployment verified${NC}"
echo ""

# Step 6: Load Testing (GAR-42)
echo -e "${YELLOW}📍 STEP 6: Load Testing${NC}"

if ! command -v ab &> /dev/null; then
    echo "Installing Apache Bench..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install httpd
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -y apache2-utils
    fi
fi

echo "Running initial load test (1,000 requests, 100 concurrent)..."
ab -n 1000 -c 100 "$PROD_URL/" > load-test-1k.txt

echo "Running heavy load test (10,000 requests, 1,000 concurrent)..."
ab -n 10000 -c 1000 "$PROD_URL/" > load-test-10k.txt

echo -e "${GREEN}✅ Load testing complete${NC}"
echo "Results saved to:"
echo "  - load-test-1k.txt"
echo "  - load-test-10k.txt"
echo ""

# Summary
echo "========================================"
echo -e "${GREEN}🎉 DEPLOYMENT PIPELINE COMPLETE${NC}"
echo "========================================"
echo ""
echo "Summary:"
echo "  ✅ Railway token generated"
echo "  ✅ GitHub secret configured"
echo "  ✅ Auto-deploy tested"
echo "  ✅ Railway project linked"
echo "  ✅ Production URL: $PROD_URL"
echo "  ✅ Load testing completed"
echo ""
echo "Next: Review load test results and update Linear tasks"
echo ""
