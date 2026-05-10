param(
    [Parameter(Mandatory)]
    [string]$ModuleName,

    [Parameter(Mandatory)]
    [string]$RequestName,

    [string]$ProjectPath = ""
)

if ($ProjectPath -eq "") {
    $ProjectPath = (Get-Location).Path
    Write-Host "No -ProjectPath provided. Using current directory: $ProjectPath" -ForegroundColor Yellow
}

if (-not (Test-Path $ProjectPath)) {
    Write-Host "ERROR: Project path '$ProjectPath' does not exist." -ForegroundColor Red
    exit 1
}

Push-Location $ProjectPath

Write-Host "Creating request '$RequestName' in module '$ModuleName'..." -ForegroundColor Cyan

php artisan module:make-request $RequestName $ModuleName

Pop-Location

Write-Host "Done. Proceed with filling in validation rules." -ForegroundColor Green
