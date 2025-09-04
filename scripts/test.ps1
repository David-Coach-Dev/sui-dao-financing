# PowerShell Test Script for Sui DAO Financing

Write-Host "🧪 Running Sui DAO Financing Tests..." -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Set-Location contracts

Write-Host "📦 Building project..." -ForegroundColor Yellow
sui move build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful" -ForegroundColor Green
    Write-Host ""
    Write-Host "🧪 Running tests..." -ForegroundColor Yellow
    sui move test
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "🎉 All tests passed!" -ForegroundColor Green
        Write-Host "✅ Project is ready for deployment" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ Some tests failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ Build failed" -ForegroundColor Red
    exit 1
}
