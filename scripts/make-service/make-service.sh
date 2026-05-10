#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./scripts/make-service/make-service.sh {ModuleName} {ServiceName} [/path/to/project]"
    exit 1
fi

MODULE_NAME=$1
SERVICE_NAME=$2
PROJECT_PATH=${3:-$(pwd)}

if [ "$3" = "" ]; then
    echo "No project path provided. Using current directory: $PROJECT_PATH"
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "ERROR: Project path '$PROJECT_PATH' does not exist."
    exit 1
fi

cd "$PROJECT_PATH" || exit 1

SERVICE_DIR="Modules/$MODULE_NAME/Services"
SERVICE_FILE="$SERVICE_DIR/${SERVICE_NAME}Service.php"

mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_FILE" <<PHP
<?php

namespace Modules\\${MODULE_NAME}\\Services;

class ${SERVICE_NAME}Service
{

}
PHP

echo "Created stub: $SERVICE_FILE"
echo "Done. Proceed with filling in service logic."
