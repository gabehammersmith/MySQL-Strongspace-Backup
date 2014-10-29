## About
A simple bash script I created to backup MySQL databases to [Strongspace](https://www.strongspace.com/).
It makes use of [Keychain](http://www.funtoo.org/wiki/Keychain) so that a passphrase protected key may be used in
automated backups. I run it from CRON. Daily backups are stored for two weeks. On the first of every month, the backup is archived and stored for one year. The freshest dump is always available as latest.sql.gz. If mysqldump fails, an e-mail is sent. The same happens if rsync fails. 

## This script deletes files!

mysql_backup.sh uses rsync's --delete-after flag. If you don't know what that 
means, you should read the [rsync man page](http://rsync.samba.org/ftp/rsync/rsync.html) before attempting to use this script.

