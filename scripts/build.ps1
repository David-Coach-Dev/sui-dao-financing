# PowerShell Build Script for Sui DAO Financing

Write-Host "🔨 Building Sui DAO Financing..." -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

Set-Location contracts

Write-Host "🧹 Cleaning previous build..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item "build" -Recurse -Force
    Write-Host "✅ Previous build cleaned" -ForegroundColor Green
}

Write-Host "📦 Building project..." -ForegroundColor Yellow
sui move build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Build artifacts created:" -ForegroundColor Cyan
    if (Test-Path "build") {
        Get-ChildItem "build" -Recurse -Directory | ForEach-Object {
            Write-Host "  📁 $($_.Name)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "❌ Build failed" -ForegroundColor Red
    exit 1
}
