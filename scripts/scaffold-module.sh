#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: ./scripts/scaffold-module.sh {ModuleName} {ModelName} {table_name}"
    exit 1
fi

MODULE_NAME=$1
MODEL_NAME=$2
TABLE_NAME=$3

echo "Scaffolding module '$MODULE_NAME' with model '$MODEL_NAME' (table: $TABLE_NAME)..."

php artisan module:make $MODULE_NAME
php artisan module:make-model $MODEL_NAME $MODULE_NAME
php artisan module:make-graphql $MODEL_NAME $MODULE_NAME
php artisan make:migration "create_${TABLE_NAME}_table"

# Remove scaffold artifact .graphql files generated with just the model name.
# These conflict with the correctly suffixed files the skill requires.
BASE_PATH="Modules/$MODULE_NAME/GraphQL/Schema"
ARTIFACTS=(
    "$BASE_PATH/Components/$MODEL_NAME.graphql"
    "$BASE_PATH/Mutations/$MODEL_NAME.graphql"
    "$BASE_PATH/Queries/$MODEL_NAME.graphql"
)

for file in "${ARTIFACTS[@]}"; do
    if [ -f "$file" ]; then
        rm "$file"
        echo "Deleted artifact: $file"
    fi
done

echo "Done. Proceed with Controller, FormRequests, and file content generation."
