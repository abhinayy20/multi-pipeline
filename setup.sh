#!/bin/bash

# Quick Setup Script for Jenkins BYOD3 Project
# This script helps you set up the project quickly

echo "================================================"
echo "Jenkins BYOD3 - Quick Setup Helper"
echo "================================================"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit: Jenkins CI/CD pipeline setup"
    git branch -M main
    echo "✅ Git initialized"
else
    echo "✅ Git already initialized"
fi

echo ""
echo "📋 Next Steps:"
echo ""
echo "1. CREATE GITHUB REPOSITORY:"
echo "   - Go to https://github.com/new"
echo "   - Create a new repository (e.g., jenkins-byod3)"
echo "   - Don't initialize with README"
echo ""

echo "2. PUSH TO GITHUB:"
read -p "   Enter your GitHub repository URL (e.g., https://github.com/username/repo.git): " REPO_URL
if [ ! -z "$REPO_URL" ]; then
    git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"
    git push -u origin main
    git checkout -b dev
    git push -u origin dev
    echo "   ✅ Pushed to GitHub"
fi

echo ""
echo "3. UPDATE SSH KEY NAME:"
read -p "   Enter your AWS SSH key pair name: " KEY_NAME
if [ ! -z "$KEY_NAME" ]; then
    sed -i.bak "s/your-ssh-key-name/$KEY_NAME/g" dev.tfvars
    sed -i.bak "s/your-ssh-key-name/$KEY_NAME/g" staging.tfvars
    sed -i.bak "s/your-ssh-key-name/$KEY_NAME/g" prod.tfvars
    rm -f *.bak
    git add *.tfvars
    git commit -m "Update SSH key name"
    git push origin dev
    echo "   ✅ SSH key name updated"
fi

echo ""
echo "4. START NGROK:"
read -p "   Enter your Jenkins port (default 8080): " JENKINS_PORT
JENKINS_PORT=${JENKINS_PORT:-8080}
echo "   Run this command in a new terminal:"
echo "   ngrok http $JENKINS_PORT"
echo ""

echo "================================================"
echo "✅ Setup complete! Check README.md for next steps"
echo "================================================"
