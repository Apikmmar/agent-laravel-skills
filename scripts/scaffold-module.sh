#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: ./scripts/scaffold-module.sh {ModuleName} {ModelName} {table_name} [/path/to/project]"
    exit 1
fi

MODULE_NAME=$1
MODEL_NAME=$2
TABLE_NAME=$3
PROJECT_PATH=${4:-$(pwd)}

if [ "$4" = "" ]; then
    echo "No project path provided. Using current directory: $PROJECT_PATH"
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "ERROR: Project path '$PROJECT_PATH' does not exist."
    exit 1
fi

cd "$PROJECT_PATH" || exit 1

echo "Scaffolding module '$MODULE_NAME' with model '$MODEL_NAME' (table: $TABLE_NAME) in '$PROJECT_PATH'..."

php artisan module:make $MODULE_NAME
php artisan module:make-model $MODEL_NAME $MODULE_NAME
php artisan module:make-graphql $MODEL_NAME $MODULE_NAME
php artisan make:migration "create_${TABLE_NAME}_table"

# Rename scaffold artifact .graphql files to the correct suffixed names the skill requires.
BASE_PATH="Modules/$MODULE_NAME/GraphQL/Schema"

declare -A RENAMES=(
    ["$BASE_PATH/Components/$MODEL_NAME.graphql"]="$BASE_PATH/Components/${MODEL_NAME}Schema.graphql"
    ["$BASE_PATH/Mutations/$MODEL_NAME.graphql"]="$BASE_PATH/Mutations/${MODEL_NAME}Mutation.graphql"
    ["$BASE_PATH/Queries/$MODEL_NAME.graphql"]="$BASE_PATH/Queries/${MODEL_NAME}Queries.graphql"
)

for from in "${!RENAMES[@]}"; do
    to="${RENAMES[$from]}"
    if [ -f "$from" ]; then
        mv "$from" "$to"
        echo "Renamed: $from → $to"
    fi
done

echo "Done. Proceed with Controller, FormRequests, and file content generation."
