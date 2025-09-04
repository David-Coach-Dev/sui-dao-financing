#!/bin/bash
# Test Script for Sui DAO Financing

echo "🧪 Running Sui DAO Financing Tests..."
echo "======================================"

cd contracts

echo "📦 Building project..."
sui move build

if [ $? -eq 0 ]; then
    echo "✅ Build successful"
    echo ""
    echo "🧪 Running tests..."
    sui move test
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 All tests passed!"
        echo "✅ Project is ready for deployment"
    else
        echo ""
        echo "❌ Some tests failed"
        exit 1
    fi
else
    echo "❌ Build failed"
    exit 1
fi
