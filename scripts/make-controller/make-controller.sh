#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./scripts/make-controller/make-controller.sh {ModuleName} {ControllerName} [/path/to/project]"
    exit 1
fi

MODULE_NAME=$1
CONTROLLER_NAME=$2
PROJECT_PATH=${3:-$(pwd)}

if [ "$3" = "" ]; then
    echo "No project path provided. Using current directory: $PROJECT_PATH"
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "ERROR: Project path '$PROJECT_PATH' does not exist."
    exit 1
fi

cd "$PROJECT_PATH" || exit 1

echo "Creating controller '$CONTROLLER_NAME' in module '$MODULE_NAME'..."

php artisan module:make-controller $CONTROLLER_NAME $MODULE_NAME

echo "Done. Proceed with filling in controller content."
