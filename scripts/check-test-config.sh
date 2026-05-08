#!/bin/bash

PHPUNIT_FILE="phpunit.xml"

if [ ! -f "$PHPUNIT_FILE" ]; then
    echo "FAIL: phpunit.xml not found."
    exit 1
fi

if grep -q 'DB_CONNECTION.*sqlite' "$PHPUNIT_FILE"; then
    echo "FAIL: DB_CONNECTION is set to sqlite in phpunit.xml."
    echo "Tests must run against MySQL. Update the DB_CONNECTION env entry to 'mysql' before proceeding."
    exit 1
fi

if grep -q 'DB_CONNECTION.*mysql' "$PHPUNIT_FILE"; then
    echo "OK: DB_CONNECTION is mysql."
    exit 0
fi

echo "WARNING: DB_CONNECTION not found in phpunit.xml. Add it explicitly and set it to 'mysql'."
exit 1
