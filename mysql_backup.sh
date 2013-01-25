#!/bin/bash

#E-Mail Notification Variables
SUBJECT="The MySQL backup on ${HOSTNAME} has FAILED!"
TO="you@yourdomain.com"

#MySQL Variables
MYSQL_USERNAME="backup-user"
MYSQL_PASSWORD="your_password123"
MYSQL_DATABASE="database_name" #use --all-databases to backup all databases.

#Local Backup Directories
BACKUP_DIR="$HOME/mysql_backup"
ARCHIVE_DIR="$BACKUP_DIR/archive"

#Strongspace Variables
STRONGSPACE_USERNAME="username"
STRONGSPACE_PATH="/strongspace/${STRONGSPACE_USERNAME}/home/${HOSTNAME}"

#Temporary files
BODY="/tmp/mysqlbackup.fail"
ERROR="/tmp/mysqlbackup.error"

#Nothing below this line should have to be edited for the script to function.
TODAY="`date +%0e`"

#Load the ssh-agent environment for Keychain.
source $HOME/.keychain/${HOSTNAME}-sh

#Do the backup. Send an e-mail and exit if mysqldump fails.
mysqldump --user=${MYSQL_USERNAME} --password=${MYSQL_PASSWORD} ${MYSQL_DATABASE} 2>$ERROR | gzip > "${BACKUP_DIR}/${HOSTNAME}-`date +%F-%H%M`.sql.gz"

if      [ ${PIPESTATUS[0]} -ne "0" ]; 
then
        echo "The mysqldump command failed. The backup on ${HOSTNAME} did not complete. The following message was given:">$BODY
	cat $ERROR >>$BODY
        mail  -s "$SUBJECT" "$TO" <$BODY
        rm -f $BODY $ERROR
	exit 1

#Copy backups to the archive directory on the first of every month.
else
	if      [ "$TODAY" -eq "01" ];
	then
		cp ${BACKUP_DIR}/${HOSTNAME}-*-*-01-*.* ${ARCHIVE_DIR}/
	fi

#Remove backups that are more than 2 weeks old.
find ${BACKUP_DIR} -maxdepth 1 -mtime +14 -name '*.sql.gz' -type f -exec rm '{}' +

#Remove backups from the archive that are more than 1 year old.
find ${ARCHIVE_DIR} -mtime +365 -name '*.sql.gz' -type f -exec rm '{}' +

#Push the backup to Strongspace. Send an e-mail it fails.
	rsync -a --delete-after ${BACKUP_DIR} ${STRONGSPACE_USERNAME}@${STRONGSPACE_USERNAME}.strongspace.com:${STRONGSPACE_PATH} 

	if 	[ "$?" -ne "0" ]; 
	then
  		echo "${HOSTNAME} was unable to connect to Strongspace.">$BODY	
		mail  -s "$SUBJECT" "$TO" <$BODY
 		rm -f $BODY
		exit 1
	fi	
fi
