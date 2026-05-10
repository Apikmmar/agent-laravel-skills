#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./scripts/make-graphql/make-graphql.sh {ModuleName} {ModelName} [/path/to/project]"
    exit 1
fi

MODULE_NAME=$1
MODEL_NAME=$2
PROJECT_PATH=${3:-$(pwd)}

if [ "$3" = "" ]; then
    echo "No project path provided. Using current directory: $PROJECT_PATH"
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "ERROR: Project path '$PROJECT_PATH' does not exist."
    exit 1
fi

cd "$PROJECT_PATH" || exit 1

echo "Creating GraphQL files for '$MODEL_NAME' in module '$MODULE_NAME'..."

php artisan module:make-graphql $MODEL_NAME $MODULE_NAME

# module:make-graphql deletes the .graphql schema files after creating them.
# Create the 3 required stub files directly.
BASE_PATH="Modules/$MODULE_NAME/GraphQL/Schema"
STUBS=(
    "$BASE_PATH/Components/${MODEL_NAME}Schema.graphql"
    "$BASE_PATH/Mutations/${MODEL_NAME}Mutation.graphql"
    "$BASE_PATH/Queries/${MODEL_NAME}Queries.graphql"
)

for stub in "${STUBS[@]}"; do
    touch "$stub"
    echo "Created stub: $stub"
done

echo "Done. Proceed with filling in GraphQL schema content."
