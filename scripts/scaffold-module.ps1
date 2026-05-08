param(
    [Parameter(Mandatory)]
    [string]$ModuleName,

    [Parameter(Mandatory)]
    [string]$ModelName,

    [Parameter(Mandatory)]
    [string]$TableName,

    [Parameter(Mandatory)]
    [string]$ProjectPath
)

if (-not (Test-Path $ProjectPath)) {
    Write-Host "ERROR: Project path '$ProjectPath' does not exist." -ForegroundColor Red
    exit 1
}

Push-Location $ProjectPath

Write-Host "Scaffolding module '$ModuleName' with model '$ModelName' (table: $TableName) in '$ProjectPath'..." -ForegroundColor Cyan

php artisan module:make $ModuleName
php artisan module:make-model $ModelName $ModuleName
php artisan module:make-graphql $ModelName $ModuleName
php artisan make:migration "create_${TableName}_table"

# Remove scaffold artifact .graphql files generated with just the model name.
# These conflict with the correctly suffixed files the skill requires.
$basePath = "Modules/$ModuleName/GraphQL/Schema"
$artifacts = @(
    "$basePath/Components/$ModelName.graphql",
    "$basePath/Mutations/$ModelName.graphql",
    "$basePath/Queries/$ModelName.graphql"
)

foreach ($file in $artifacts) {
    if (Test-Path $file) {
        Remove-Item $file
        Write-Host "Deleted artifact: $file" -ForegroundColor Yellow
    }
}

Pop-Location

Write-Host "Done. Proceed with Controller, FormRequests, and file content generation." -ForegroundColor Green
