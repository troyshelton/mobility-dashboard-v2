  #!/bin/bash
  set -e
  STORAGE_ACCOUNT="ihazurestoragedev"
  CONTAINER_NAME="\$web"
  TARGET_PATH="sepsis-dashboard"
  SOURCE_DIR="./src/web"
  echo "🚀 Azure Storage Deployment"
  echo "Storage Account: $STORAGE_ACCOUNT"
  echo "Container: $CONTAINER_NAME"
  echo ""
  if [ ! -d "$SOURCE_DIR" ]; then
      echo "❌ Source directory not found"
      exit 1
  fi
  if ! az account show &> /dev/null; then
      echo "❌ Not logged in to Azure"
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
  read -p "Deploy? (y/N): " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
  fi
  echo "🚀 Uploading..."
  az storage blob upload-batch --source "$SOURCE_DIR" --destination "$CONTAINER_NAME" --destination-path "$TARGET_PATH" --account-name
  "$STORAGE_ACCOUNT" --overwrite
  echo "✅ Complete! https://$STORAGE_ACCOUNT.z13.web.core.windows.net/$TARGET_PATH/"
