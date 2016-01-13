#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Populate configuration files, this is always necessary.
php $DIR/docker-config.php

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
        php-fpm --allow-to-run-as-root -c /atom/php.ini --fpm-config /atom/fpm.ini
        ;;
esac
