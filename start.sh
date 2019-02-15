#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-password}
MYSQL_DATABASE=${MYSQL_DATABASE:-petclinic}

log ()
{
        timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
        echo "[${timestamp}] $1"
}

setup_mysql()
{
  dpkg-query -l mysql-server > /dev/null
  install_status=$?
  if [ ${install_status} -ne 0 ]; then
    log "Updating packages..."
    apt-get update -y > /dev/null

    log "Installing MySQL server"
    apt-get install mysql-server -y > /dev/null
  fi
}

start_mysql()
{
  local process_count=$(pgrep mysql | wc -l)
  if [ ${process_count} -eq 0 ]; then
    log "Starting MySQL server..."
    service mysql start
    sleep 5
  fi
}

prepare_db()
{
  setup_mysql
  start_mysql

  log "Preparing databases..."
  mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} <<EOF
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION; FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} DEFAULT CHARACTER SET utf8;
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_DATABASE}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}'; FLUSH PRIVILEGES;
EOF

  if [ ! -f "/etc/mysql/myapp.cnf" ]; then
    cp myapp.cnf /etc/mysql/
    service mysql restart
  fi
}

start_app()
{
  log "Running application..."
  ./mvnw -Dmaven.local.repo=${DIR}/.m2 spring-boot:run
}

pushd ${DIR} > /dev/null
prepare_db
start_app
popd > /dev/null
