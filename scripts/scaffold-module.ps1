param(
    [Parameter(Mandatory)]
    [string]$ModuleName,

    [Parameter(Mandatory)]
    [string]$ModelName,

    [Parameter(Mandatory)]
    [string]$TableName
)

Write-Host "Scaffolding module '$ModuleName' with model '$ModelName' (table: $TableName)..." -ForegroundColor Cyan

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

Write-Host "Done. Proceed with Controller, FormRequests, and file content generation." -ForegroundColor Green
