#!/usr/bin/env bash

ENV_NAMES=$(export | cut -d' ' -f 3- | cut -d'=' -f 1)

DIST_FILE=/etc/nginx/dist/project-site.conf.dist
CONF_FILE=/etc/nginx/sites-enabled/${PROJECT_NAME}.conf
NGINX_SSL_MOUNT=/etc/nginx-certs
NGINX_SSL_SHARED=/etc/nginx-ssl
NGINX_LOG_PREFIX=${PROJECT_NAME}

if ! [ -f ${DIST_FILE} ]; then
	echo "File not found, exiting..."
	exit 1
fi

mkdir -p /etc/nginx/sites-enabled

cp ${DIST_FILE} ${CONF_FILE}

for i in ${ENV_NAMES}; do 
	#echo "ENV: s/__${i}__/${!i}/g"
	if [ -z ${!i} ]; then continue; fi
	#if echo ${!i} | grep '/' >/dev/null 2>&1 ; then continue; fi

	env_name=$(echo ${i} | sed -e 's:/:\\/:g')
	env_val=$(echo ${!i} | sed -e 's:/:\\/:g')
	sed -i ${CONF_FILE} -e "s/__$env_name__/$env_val/g"
done

if cat ${CONF_FILE} | grep '__' >/dev/null 2>&1 ; then
	echo "Warning: They're still unbound variables in ${CONF_FILE}, you probabely didn't define those in your environment section"
fi

mkdir -p ${NGINX_SSL_SHARED}/${SERVER_NAME}/ >/dev/null 2>&1
# Move SSL Configs to the right path
cp -Rv ${NGINX_SSL_MOUNT}/* ${NGINX_SSL_SHARED}/${SERVER_NAME}/ >/dev/null 2>&1

tail -f /dev/null
