#!/bin/bash

set -e

if [[ "$UID" != "" ]]; then
    if [[ "$IMAGE_VARIANT" != "cli" ]]; then
        usermod -u $UID www-data;
    fi
fi
#chown -R www-data:www-data /var/www/html;

if [ -z "$XDEBUG_REMOTE_HOST" ]; then
    XDEBUG_REMOTE_HOST=`/sbin/ip route|awk '/default/ { print $3 }'`

    # On mac, check that docker.for.mac.localhost exists. it true, use this.
    # Linux systems can report the value exists, but it is bound to localhost. In this case, ignore.
    set +e
    host docker.for.mac.localhost &> /dev/null

    if [[ $? == 0 ]]; then
        # The host exists.
        DOCKER_FOR_MAC_REMOTE_HOST=`host docker.for.mac.localhost | awk '/has address/ { print $4 }'`
        if [ "$DOCKER_FOR_MAC_REMOTE_HOST" -ne "127.0.0.1" ]; then
            XDEBUG_REMOTE_HOST=$DOCKER_FOR_MAC_REMOTE_HOST
        fi
        unset DOCKER_FOR_MAC_REMOTE_HOST
    fi
    set -e
fi

php /usr/local/bin/generate_conf.php > /usr/local/etc/php/conf.d/generated_conf.ini
php /usr/local/bin/generate_cron.php > /etc/cron.d/generated_crontab
chmod 0644 /etc/cron.d/generated_crontab

if [[ "$IMAGE_VARIANT" == "apache" ]]; then
    eval $( php /usr/local/bin/enable_apache_mods.php )
fi

cron

if [ -e /etc/container/startup.sh ]; then
    source /etc/container/startup.sh
fi
eval $( php /usr/local/bin/startup_commands.php )

exec "$@";
