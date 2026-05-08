param(
    [Parameter(Mandatory)]
    [string]$ProjectPath
)

if (-not (Test-Path $ProjectPath)) {
    Write-Host "ERROR: Project path '$ProjectPath' does not exist." -ForegroundColor Red
    exit 1
}

$phpunitFile = Join-Path $ProjectPath "phpunit.xml"

if (-not (Test-Path $phpunitFile)) {
    Write-Host "FAIL: phpunit.xml not found in '$ProjectPath'." -ForegroundColor Red
    exit 1
}

$content = Get-Content $phpunitFile -Raw

if ($content -match 'DB_CONNECTION.*sqlite') {
    Write-Host "FAIL: DB_CONNECTION is set to sqlite in phpunit.xml." -ForegroundColor Red
    Write-Host "Tests must run against MySQL. Update the DB_CONNECTION env entry to 'mysql' before proceeding." -ForegroundColor Yellow
    exit 1
}

if ($content -match 'DB_CONNECTION.*mysql') {
    Write-Host "OK: DB_CONNECTION is mysql." -ForegroundColor Green
    exit 0
}

Write-Host "WARNING: DB_CONNECTION not found in phpunit.xml. Add it explicitly and set it to 'mysql'." -ForegroundColor Yellow
exit 1
