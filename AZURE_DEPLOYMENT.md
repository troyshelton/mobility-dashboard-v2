# Azure Storage Deployment Guide

## Quick Reference

### For Future Deployments (Copy & Paste Ready):
```bash
# Direct command - replace account and path as needed
az storage blob upload-batch --source "./src/web" --destination "\$web" --destination-path "sepsis-dashboard" --account-name "ihazurestoragedev" --auth-mode login --overwrite
```

### Script Method:
```bash
# Create script (if needed)
cat << 'EOF' > deploy-azure.sh
[see full script below]
EOF
chmod +x deploy-azure.sh
./deploy-azure.sh
```

## Overview
This document describes the automated deployment process for web assets to Azure Blob Storage, replacing manual drag-and-drop operations in Azure Storage Explorer.

### Proven Success Record
- **Date**: September 29, 2025
- **Deployed**: 21 files successfully uploaded to production
- **Live Dashboard**: https://ihazurestoragedev.z13.web.core.windows.net/sepsis-dashboard/
- **Status**: ✅ Working with Cerner CCL integration

## Benefits Over Storage Explorer
- ✅ **Faster**: Batch upload vs individual file dragging
- ✅ **Consistent**: Repeatable commands vs manual process
- ✅ **Verifiable**: Shows exactly what's being deployed where
- ✅ **Safer**: Clear confirmation before overwriting
- ✅ **Documented**: Command history for troubleshooting

## Authentication Setup

### One-time Setup
```bash
# Install Azure CLI (Mac)
brew install azure-cli

# Login to your Azure account
az login
```

### Account Verification
Always verify you're logged into the correct Azure account:
```bash
az account show --query "{name:name, user:user.name}" -o table
```

## Deployment Methods

### Method 1: Direct Command (Recommended for Quick Deployments)
```bash
az storage blob upload-batch \
    --source "./src/web" \
    --destination "\$web" \
    --destination-path "sepsis-dashboard" \
    --account-name "ihazurestoragedev" \
    --auth-mode login \
    --overwrite
```

### Method 2: Deployment Script (For Repeated Use)

#### Creating the Script (Mac/Unix)
Due to line ending issues when creating scripts in Claude Code, use this method:

```bash
# Create deployment script with proper Unix line endings
cat << 'EOF' > deploy-azure.sh
#!/bin/bash
set -e
STORAGE_ACCOUNT="ihazurestoragedev"
CONTAINER_NAME="\$web"
TARGET_PATH="sepsis-dashboard"
SOURCE_DIR="./src/web"

echo "🚀 Azure Storage Deployment"
echo "Storage Account: $STORAGE_ACCOUNT"
echo ""

# Verify source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Source directory not found"
    exit 1
fi

# Verify Azure authentication
if ! az account show &> /dev/null; then
    echo "❌ Not logged in to Azure - run 'az login' first"
    exit 1
fi

echo "📂 Subdirectories to upload:"
find "$SOURCE_DIR" -type d | grep -v "^$SOURCE_DIR$" | sort
echo ""
echo "📄 Sample files:"
find "$SOURCE_DIR" -type f | head -3
FILE_COUNT=$(find "$SOURCE_DIR" -type f | wc -l)
echo "($FILE_COUNT total files)"
echo ""
echo "🎯 DEPLOYMENT TARGET:"
echo "   https://$STORAGE_ACCOUNT.z13.web.core.windows.net/$TARGET_PATH/"
echo ""
echo "⚠️  VERIFY: INTEROP HEALTH DEV ACCOUNT"
echo ""

read -p "Deploy to the above location? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

echo "🚀 Uploading files..."
az storage blob upload-batch \
    --source "$SOURCE_DIR" \
    --destination "$CONTAINER_NAME" \
    --destination-path "$TARGET_PATH" \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login \
    --overwrite

echo "✅ Deployment Complete!"
echo "🌐 Dashboard available at:"
echo "   https://$STORAGE_ACCOUNT.z13.web.core.windows.net/$TARGET_PATH/"
EOF

# Make script executable
chmod +x deploy-azure.sh

# Run the script
./deploy-azure.sh
```

#### Why This Method is Needed
- **Line Ending Issues**: Scripts created in some editors may have Windows line endings (`^M`)
- **Error**: `zsh: ./script.sh: bad interpreter: /bin/bash^M: no such file or directory`
- **Solution**: Use `cat << 'EOF'` method to ensure proper Unix line endings

### Command Breakdown
- `--source "./src/web"` - Local directory to upload FROM
- `--destination "\$web"` - Azure container (static website container)
- `--destination-path "sepsis-dashboard"` - Target folder in Azure
- `--account-name "ihazurestoragedev"` - Your Azure storage account
- `--auth-mode login` - Use Azure AD authentication (avoids warning)
- `--overwrite` - Replace existing files

## Pre-Deployment Verification

### Always Check Before Deploying:
1. **Source Directory**: What you're uploading
   ```bash
   find ./src/web -type d | sort
   ```

2. **File Count**: Total files to upload
   ```bash
   find ./src/web -type f | wc -l
   ```

3. **Account Context**: Which Azure account you're using
   ```bash
   az account show --query "name" -o tsv
   ```

4. **Target URL**: Where files will be accessible
   ```
   https://{storage-account}.z13.web.core.windows.net/{destination-path}/
   ```

## Project Standardization Strategy

### Current Structure (Working)
```
$web/camc-sepsis-mpage/
└── src/                        # Web assets
    ├── index.html
    ├── styles.css
    ├── js/
    └── lib/
```

### Recommended Structure (Oracle Health Cerner Standard)
```
$web/camc-sepsis-mpage/         # Direct CCL integration
├── index.html                  # Main entry point
├── test.html                   # Testing entry point (optional)
├── styles.css
├── js/
└── lib/
```

**Benefits of Cerner Standard:**
- ✅ **CCL Integration**: Matches Oracle Health's image driver pattern
- ✅ **Flat Structure**: No unnecessary `/src/` subdirectory
- ✅ **Flexible Entry Points**: `index.html` for production, `test.html` for testing
- ✅ **Parameter-Driven**: CCL can pass directory name + specific HTML file
- ✅ **Environment Isolation**: Test without affecting other users

### Migration Plan (Future Enhancement)
1. **Flatten** structure: Move from `/src/` to project root
2. **Update** CCL parameters to reference specific HTML file
3. **Add** testing flexibility with multiple HTML entry points
4. **Test** CCL image driver integration

### CCL Integration Pattern
```ccl
; Production deployment
; Parameter 1: Directory name = "camc-sepsis-mpage"
; Parameter 2: HTML file = "index.html"

; Testing deployment
; Parameter 1: Directory name = "camc-sepsis-mpage"
; Parameter 2: HTML file = "test.html"
```

**Directory Naming Logic:**
- `camc-sepsis-mpage` = Client + Application + Type (self-explanatory)
- `index.html` = Standard entry point
- Flexible HTML parameter allows environment-specific testing

### What TO Deploy
- ✅ **Web assets**: HTML, CSS, JavaScript, libraries
- ✅ **Static resources**: Images, fonts, icons
- ✅ **Client-side dependencies**: Libraries like Handsontable, Font Awesome

### What NOT to Deploy
- ❌ **CCL programs**: Stay in Cerner environment only
- ❌ **Development files**: .DS_Store, node_modules, .git
- ❌ **Documentation**: README.md, CLAUDE.md (GitHub handles this)
- ❌ **Build tools**: package.json, scripts, tests

### Source Control Benefits
Since everything is in GitHub:
- **Version history**: See exactly what changed when
- **Rollback capability**: Revert to previous versions easily
- **Branch tracking**: Know which features are deployed
- **Tag releases**: Mark stable deployment points

## Safety Checklist

### Before Every Deployment:
- [ ] Verify Azure account: `az account show`
- [ ] Check source directory: `ls -la src/web/`
- [ ] Confirm storage account name in command
- [ ] Verify destination path is correct
- [ ] Test locally first (if applicable)

### Command Verification Process:
1. **Share the command** with someone for review
2. **Double-check account name** and destination
3. **Verify source path** matches what you want to deploy
4. **Confirm overwrite behavior** is intended

## Example Verification Workflow

```bash
# 1. Check what you're about to deploy
echo "Source files to deploy:"
find ./src/web -type f | head -10
echo "Total files: $(find ./src/web -type f | wc -l)"

# 2. Verify Azure account
echo "Deploying from account:"
az account show --query "user.name" -o tsv

# 3. Show target destination
echo "Target URL will be:"
echo "https://ihazurestoragedev.z13.web.core.windows.net/sepsis-dashboard/"

# 4. Deploy with confirmation
az storage blob upload-batch \
    --source "./src/web" \
    --destination "\$web" \
    --destination-path "sepsis-dashboard" \
    --account-name "ihazurestoragedev" \
    --auth-mode login \
    --overwrite
```

## Multiple Storage Account Management

### For Different Environments:
- **Development**: `ihazurestoragedev` (Interop Health account)
- **Production**: `{production-storage-account}` (Different account)

### Always specify the account explicitly:
```bash
# Development deployment
--account-name "ihazurestoragedev"

# Production deployment (when ready)
--account-name "{production-storage-account-name}"
```

## Troubleshooting

### Line Ending Issues (Most Common on Mac)
**Symptoms:**
```
zsh: ./deploy-azure.sh: bad interpreter: /bin/bash^M: no such file or directory
```

**Cause:** Script has Windows line endings (`\r\n`) instead of Unix (`\n`)

**Solutions:**
1. **Recommended**: Use the `cat << 'EOF'` method shown above
2. **Alternative**: Fix existing script with `dos2unix deploy-azure.sh`
3. **Alternative**: Fix with sed: `sed -i '' 's/\r$//' deploy-azure.sh`

### Common Issues:
1. **Authentication errors**: Run `az login` again
2. **Account not found**: Verify storage account name
3. **Permission denied**: Check RBAC roles on storage account
4. **Wrong files uploaded**: Verify source directory path
5. **Script won't execute**: Check line endings (see above)

### Verification Commands:
```bash
# List what was actually uploaded
az storage blob list \
    --container-name "\$web" \
    --prefix "sepsis-dashboard/" \
    --account-name "ihazurestoragedev" \
    --auth-mode login \
    --output table
```

---

## Command Review Process (REQUIRED)

**NEVER deploy without verification!** Always follow this process:

### Step 1: Prepare Your Command
```
PROPOSED DEPLOYMENT:
Source: [local path]
Target Account: [storage account name]
Target Path: [destination path]
Command: [full az storage blob upload-batch command]
```

### Step 2: Verification Checklist
Before running ANY deployment command, verify:

- [ ] **Source path**: Correct local directory (`./src/web`)
- [ ] **Storage account**: Right environment (dev vs production)
- [ ] **Destination path**: Correct Azure folder structure
- [ ] **Overwrite behavior**: Intended to replace existing files
- [ ] **Authentication**: Correct Azure account logged in

### Step 3: Share for Review
**Paste your proposed command and ask for verification:**

```
"Here's my deployment command - can you verify before I run it?"

az storage blob upload-batch \
    --source "./src/web" \
    --destination "\$web" \
    --destination-path "camc-sepsis-mpage/src" \
    --account-name "ihazurestoragedev" \
    --overwrite
```

### Step 4: Wait for Confirmation
Do NOT execute until you get explicit approval:
- ✅ "Yes, that looks correct - go ahead"
- ❌ "Wait, the destination path should be..."

### Step 5: Execute with Confidence
Only after verification, run the command.

## Why This Process is Critical

**Real Examples of Deployment Mistakes:**
- Wrong storage account (deployed to production instead of dev)
- Wrong path (deployed to `sepsis-dashboard/` instead of `camc-sepsis-mpage/src/`)
- Wrong source (deployed old files or wrong directory)

**Cost of Mistakes:**
- Downtime in production environments
- Overwriting working code with broken code
- Time spent troubleshooting "missing" features
- Need to restart applications (like PowerChart) to clear cache

## Standard Verification Template

```
DEPLOYMENT VERIFICATION REQUEST:

Source: ./src/web
Target Account: ihazurestoragedev (Interop Health DEV)
Target Path: camc-sepsis-mpage/src
Files: 21 web assets (HTML, CSS, JS, libs)

Command:
az storage blob upload-batch \
    --source "./src/web" \
    --destination "\$web" \
    --destination-path "camc-sepsis-mpage/src" \
    --account-name "ihazurestoragedev" \
    --overwrite

Can you verify this is correct before I deploy?
```

This ensures accuracy and prevents deployment mistakes.

---
*Last Updated: 2025-09-29*
*Project: Sepsis Dashboard - Vandalia Health*