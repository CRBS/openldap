#!/bin/bash
####
## Author: Edmond Negado
## Description:  This script pushes the prod-ldap tree into
##               the dev-ldap tree.
####

## Set your path, and export
export PATH=/bin:/usr/bin:/sbin:/usr/sbin:$PATH

## set the current working path of the ldaptree dump data
LDAPDUMP=/root/ldapDump

## set the filename of the ldaptree dump file
LDAPTREEDATA=ldaptree.ldif

## check if the ldaptree dump exists in: /root/ldapDump/ldaptree.ldif
if [ -f $LDAPDUMP/$LDAPTREEDATA ]
then

    echo "Preparing ldaptree dump configuration ..."
    ## clean up the ldaptree by replacing all the 'ldap.crbs.ucsd.edu'
    ## entries in place with 'dev-ldap.crbs.ucsd.edu' entries.
    ## /bin/sed -i 's/dc=ldap,/dc=dev-ldap,/g' $LDAPDUMP/$LDAPTREEDATA

    ## clean up the automount entries with 'ldap.crbs.ucsd.edu' to be
    ## replaced by 'dev-ldap.crbs.ucsd.edu' entries
    ## /bin/sed -i 's/ldap.crbs.ucsd.edu/dev-ldap.crbs.ucsd.edu/g' $LDAPDUMP/$LDAPTREEDATA

    ## change the 'dc: ldap' to 'dc: dev-ldap'
    ## /bin/sed -i 's/dc: ldap/dc: dev-ldap/g' $LDAPDUMP/$LDAPTREEDATA

    sleep 2
    echo "ldaptree dump configuration done."

    echo "Stopping the ldap server ..."
    ## stop the ldap server; which is needed to slapadd the production
    ## ldap tree dump into dev-ldap.crbs.ucsd.edu
    /sbin/service slapd stop
    sleep 3
    echo "ldap (slapd) server stopped."

    ## check to see if the process is still running, if so, kill it.
    echo "Killing any strangling slapd processes ..."
    SLAP_PROCESS=`ps ax -opid,comm | grep slapd`
    if [ $? = 0 ]
    then
        SLAP_PID=`echo $SLAP_PROCESS | cut -d' ' -f1`
        echo "Found a slapd process stragler pid: ${SLAP_PID} killing it now ..."
        kill $SLAP_PID
    else
        echo "No slapd stranglers found (yay)."
    fi

    echo ""
    echo "Backing up the old ldap configuration to /var/lib/ldap-backups ..."
    ## create a backup directory in /var/lib/ldap-backups to move the old
    ## /var/lib/ldap into. But before we move the old directory, make a
    ## copy of the DB_CONFIG file. Once the backup has been made, create
    ## a new /var/lib/ldap and move DB_CONFIG into that directory. Set
    ## permissions to ldap:ldap on /var/lib/ldap
    
    ## make sure there is a backup driectory to move the old /var/lib/ldap into.
    mkdir -p /var/lib/ldap-backups
    ## copy the DB_CONFIG before moving the ldap directory into the backup dir.
    cp /var/lib/ldap/DB_CONFIG /var/lib/
    ## move the ldap directory into backups
    mv /var/lib/ldap /var/lib/ldap-backups/ldap-`date +"%Y-%m-%d_%H-%M"`
    ## create a new /var/lib/ldap folder
    mkdir -p /var/lib/ldap
    ## mv the DB_CONFIG file back to the /var/lib/ldap directory
    mv /var/lib/DB_CONFIG /var/lib/ldap/
    ## change perms and ownership of /var/lib/ldap
    chown -R ldap:ldap /var/lib/ldap/
    echo "Backup of old ldap configuration complete ..."

    
    echo ""
    echo "Importing ldaptree dump into ldap.crbs.ucsd.edu ..."
    ## now import the ldap tree into ldap directory
    /usr/sbin/slapadd -l $LDAPDUMP/$LDAPTREEDATA    

    ## Test exit on slapadd. if zero successful import, or non-zero failed import.
    ## if nonzero, you will need to clean the ldap database manually.

    chown -R ldap:ldap /var/lib/ldap/
    sleep 1
    echo "Import Complete."

    echo ""
    echo "Starting the slapd (ldap) server ..."
    ## Start the ldap server
    ## service nscd stop
    /usr/sbin/slapindex
    /sbin/service slapd start
    sleep 1
    ## service nscd start
    echo "Success: slapd indexed and slapd (ldap) service started."

else

    echo "FATAL: File in `pwd`/ldaptree.ldif does not exist! Exiting..."
    exit 1

fi

exit 0



