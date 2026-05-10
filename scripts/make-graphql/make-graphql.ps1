param(
    [Parameter(Mandatory)]
    [string]$ModuleName,

    [Parameter(Mandatory)]
    [string]$ModelName,

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

Write-Host "Creating GraphQL files for '$ModelName' in module '$ModuleName'..." -ForegroundColor Cyan

php artisan module:make-graphql $ModelName $ModuleName

# module:make-graphql deletes the .graphql schema files after creating them.
# Create the 3 required stub files directly.
$basePath = "Modules/$ModuleName/GraphQL/Schema"
$stubs = @(
    "$basePath/Components/${ModelName}Schema.graphql",
    "$basePath/Mutations/${ModelName}Mutation.graphql",
    "$basePath/Queries/${ModelName}Queries.graphql"
)

foreach ($stub in $stubs) {
    New-Item -ItemType File -Path $stub -Force | Out-Null
    Write-Host "Created stub: $stub" -ForegroundColor Yellow
}

Pop-Location

Write-Host "Done. Proceed with filling in GraphQL schema content." -ForegroundColor Green
