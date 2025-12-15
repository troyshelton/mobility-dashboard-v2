# Azure Storage Deployment Script for Sepsis Dashboard (PowerShell)
# Deploys web assets to Azure Blob Storage ($web container)
#
# Usage: .\deploy-to-azure.ps1
#
# Prerequisites:
# - Azure CLI installed (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
# - Run 'az login' first time to authenticate

param(
    [switch]$Force  # Skip confirmation prompt
)

# Configuration
$StorageAccount = "ihazurestoragedev"
$ContainerName = "`$web"
$TargetPath = "sepsis-dashboard"
$SourceDir = "./src/web"

Write-Host "🚀 Azure Storage Deployment for Sepsis Dashboard" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Storage Account: $StorageAccount"
Write-Host "Container: $ContainerName"
Write-Host "Target Path: $TargetPath"
Write-Host "Source: $SourceDir"
Write-Host ""

# Check if Azure CLI is installed
try {
    az --version | Out-Null
}
catch {
    Write-Host "❌ Azure CLI not found. Please install: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Red
    exit 1
}

# Check if source directory exists
if (!(Test-Path $SourceDir)) {
    Write-Host "❌ Source directory '$SourceDir' not found" -ForegroundColor Red
    exit 1
}

# Check if logged into Azure
Write-Host "🔐 Checking Azure authentication..." -ForegroundColor Yellow
try {
    $null = az account show 2>$null
}
catch {
    Write-Host "📱 Opening browser for Azure login (will use MFA like Storage Explorer)..." -ForegroundColor Yellow
    az login
}

# Get current account info
$AccountInfo = az account show --query "{name:name, user:user.name}" -o table
Write-Host "✅ Authenticated as:" -ForegroundColor Green
Write-Host $AccountInfo
Write-Host ""

# Show files to deploy
Write-Host "📁 Files to deploy from $SourceDir:" -ForegroundColor Yellow
$Files = Get-ChildItem -Path $SourceDir -Recurse -File
$Files | Select-Object -First 10 | ForEach-Object { Write-Host "   $($_.FullName.Replace((Get-Location).Path, '.'))" }
Write-Host "... ($($Files.Count) total files)"
Write-Host ""

# Confirm deployment (unless -Force is used)
if (-not $Force) {
    $Confirmation = Read-Host "🤔 Deploy these files to Azure Storage? (y/N)"
    if ($Confirmation -notmatch '^[Yy]$') {
        Write-Host "❌ Deployment cancelled" -ForegroundColor Red
        exit 1
    }
}

Write-Host "🚀 Starting deployment..." -ForegroundColor Cyan
Write-Host ""

# Upload files to Azure Blob Storage
az storage blob upload-batch `
    --source $SourceDir `
    --destination $ContainerName `
    --destination-path $TargetPath `
    --account-name $StorageAccount `
    --overwrite `
    --no-progress

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Your sepsis dashboard should be accessible at:" -ForegroundColor Cyan
Write-Host "   https://$StorageAccount.z13.web.core.windows.net/$TargetPath/" -ForegroundColor Blue
Write-Host ""
Write-Host "💡 Tip: You can also view files in Azure Storage Explorer:" -ForegroundColor Yellow
Write-Host "   Storage Accounts > $StorageAccount > Blob Containers > `$web > $TargetPath" -ForegroundColor Yellow