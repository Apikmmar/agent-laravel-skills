param(
    [Parameter(Mandatory)]
    [string]$ModuleName,

    [Parameter(Mandatory)]
    [string]$ServiceName,

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

$servicePath = "Modules/$ModuleName/Services"
$serviceFile = "$servicePath/${ServiceName}Service.php"

New-Item -ItemType Directory -Path $servicePath -Force | Out-Null

$stub = @"
<?php

namespace Modules\$ModuleName\Services;

class ${ServiceName}Service
{

}
"@

Set-Content -Path $serviceFile -Value $stub -Encoding utf8

Write-Host "Created stub: $serviceFile" -ForegroundColor Yellow

Pop-Location

Write-Host "Done. Proceed with filling in service logic." -ForegroundColor Green
