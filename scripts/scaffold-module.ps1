param(
    [Parameter(Mandatory)]
    [string]$ModuleName,

    [Parameter(Mandatory)]
    [string]$ModelName,

    [Parameter(Mandatory)]
    [string]$TableName,

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

Write-Host "Scaffolding module '$ModuleName' with model '$ModelName' (table: $TableName) in '$ProjectPath'..." -ForegroundColor Cyan

php artisan module:make $ModuleName
php artisan module:make-model $ModelName $ModuleName
php artisan module:make-graphql $ModelName $ModuleName
php artisan make:migration "create_${TableName}_table"

# Rename scaffold artifact .graphql files to the correct suffixed names the skill requires.
$basePath = "Modules/$ModuleName/GraphQL/Schema"
$renames = @(
    @{ From = "$basePath/Components/$ModelName.graphql"; To = "$basePath/Components/${ModelName}Schema.graphql" },
    @{ From = "$basePath/Mutations/$ModelName.graphql"; To = "$basePath/Mutations/${ModelName}Mutation.graphql" },
    @{ From = "$basePath/Queries/$ModelName.graphql";   To = "$basePath/Queries/${ModelName}Queries.graphql" }
)

foreach ($entry in $renames) {
    if (Test-Path $entry.From) {
        Rename-Item $entry.From $entry.To
        Write-Host "Renamed: $($entry.From) → $($entry.To)" -ForegroundColor Yellow
    }
}

Pop-Location

Write-Host "Done. Proceed with Controller, FormRequests, and file content generation." -ForegroundColor Green
