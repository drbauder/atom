#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"

# Populate configuration files, this is always necessary.
php ${__dir}/docker-config.php

case $1 in
    '')
        echo "Usage:"
        echo "  php-fpm: execute php-fpm"
        echo "  shell: open shell"
        echo "  worker: execute worker"
        echo "  syncdb: populate database"
        exit 1
        ;;
    'syncdb')
        php /atom/src/symfony tools:purge --demo
        ;;
    'worker')
        php -d memory_limit=-1 /atom/src/symfony jobs:worker
        ;;
    'shell')
        bash
        ;;
    'php-fpm')
        trap 'kill -INT $PID' TERM INT
        php-fpm --nodaemonize --allow-to-run-as-root -c /atom/php.ini --fpm-config /atom/fpm.ini &
        PID=$!
        wait $PID
        trap - TERM INT
        wait $PID
        exit $?
        ;;
esac
