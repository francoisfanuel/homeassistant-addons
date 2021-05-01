#!/usr/bin/env bashio
set -e

bashio::log.info "Setting paperless host: $(bashio::config paperless_host)"
sed -i "s/PAPERLESS_HOST/$(bashio::config paperless_host)/g" /haproxy.cfg

bashio::log.info "Setting paperless port: $(bashio::config paperless_port)"
sed -i "s/PAPERLESS_PORT/$(bashio::config paperless_port)/g" /haproxy.cfg

if $(bashio::config.true ssl.enabled); then
	bashio::log.info "SSL communitcation to paperless enabled"
	sed -i "s/USE_SSL/ssl/g" /haproxy.cfg

	if $(bashio::config.true ssl.verify); then
		bashio::log.info "SSL verification enabled"
		sed -i "s/VERIFY_SSL//g" /haproxy.cfg
	else
		bashio::log.info "SSL verification disabled"
		sed -i "s/VERIFY_SSL/verify none/g" /haproxy.cfg
	fi

else
	bashio::log.info "SSL communitcation to paperless not enabled"
	sed -i "s/USE_SSL VERIFY_SSL//g" /haproxy.cfg
fi

bashio::log.info "Server line: $(cat /haproxy.cfg | grep 'server paperless')"

bashio::log.info "Starting haproxy"
haproxy -W -db -f /haproxy.cfg
