#!/bin/bash

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"%d%b%Y-%H%M"`

################################################################

DB_BACKUP_PATH='/tmp/fromscripts/mysqlbackup'
MYSQL_HOST='127.0.0.1'
MYSQL_PORT='3306'
MYSQL_USER='root'
MYSQL_PASSWORD='perconapw'
#DATABASE_NAME=''
#BACKUP_RETAIN_DAYS=30   ## Number of days to keep local backup copy

#################################################################

mkdir -p ${DB_BACKUP_PATH}
echo "Starting to backup..."

mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --all-databases --skip-lock-tables | gzip > ${DB_BACKUP_PATH}/alldb-${TODAY}.sql.gz

result=${PIPESTATUS[0]}
if [ $result -eq 0 ]; then
  echo "Database backup successfully completed"
else
  echo "Error found during backup"
fi


### upload backup file to s3 bucket and delete the file on local machine

aws s3 cp ${DB_BACKUP_PATH}/alldb-${TODAY}.sql.gz s3://sw-main-backup/w88/w88blog/ && rm  ${DB_BACKUP_PATH}/alldb-${TODAY}.sql.gz
