#!/usr/local/bin/bash

#***********************************************************************#
# NAME
#       
#  gen_prepaid.sh
#
# SYNOPSIS
#       
#  gen_prepaid.sh resource_filename batch_no refmsin provider_id
#
# DESCRIPTION
#
#  Script to create HLR command files for SIM-card generation
#  Looks for script files specified in WORK_DIR variable.
#  TODO
#
# AUTHOR
#       
#  Originally developped by Yong Heng Peng. Re-developped by Shmyg
#
# HISTORY OF CHANGES
#
#	$Log: gen_prepaid.sh,v $
#	Revision 1.5  2005/05/24 13:53:18  serge
#	*** empty log message ***
#
#	Revision 1.4  2005/02/13 12:43:52  serge
#	*** empty log message ***
#	
#	Revision 1.2  2005/02/09 11:49:16  serge
#	Fixed path to perl scripts
#	
#	Revision 1.1  2005/02/09 11:39:44  serge
#	Added forgotten file
#	
#
#***********************************************************************#

trap "exit 1" 1 2 15

# Configuration section
# Checking if working directory is specified
: ${WORK_DIR?Working directory to look for files is not specified!}
perl_script_dir="${work_dir}"/perl

# Checking parameters passed
if [ $# -lt 1 ]
then
 echo Mandatory parameters are missing!
 echo Usage: `basename $0` resource_filename 
 exit 1
fi

RESOURCE="${1}"
BATCHNUM=`echo "${RESOURCE}" | sed 's/INP00*\(.*\)\.CMD/\1/'`
REFMSIN=2190000000
PROVIDER=2

# Verifying if the RESOURCE file exists
[ -e $RESOURCE ] || { echo Resource file "${RESOURCE}" is not found; exit 1; }

# ---------------------------------------------
# Verify that REFMSIN must be exactly 10 digits
# ---------------------------------------------
if [[ `echo $REFMSIN | grep ^'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'` = "" ]]
then
 echo "Error: REFMSIN must be exactly 10 digits\n"
 exit 1
fi

# --------------------------------------------
# Verify that PROVIDER must be exactly 1 digit
# --------------------------------------------
if [[ `echo $PROVIDER | grep ^'[0-9]'` = "" ]]
then
 echo "Error: PROVIDER_ID must be exactly 1 digit\n"
 exit 1
fi

# Creating a directory needed to store files related to current batch
BATCHDIR=`printf "BATCH%06d" $BATCHNUM`
if [ ! -d $BATCHDIR ]
then
 mkdir $BATCHDIR || { echo Cannot create directory "${BATCHDIR}"; exit 1; }
fi

# Generating all the valid filenames for this PREPAID batch
HLRDELCMD=`printf "B%06dA.CMD" "${BATCHNUM}"`
HLRDELRES=`printf "PT.B%06dA" "${BATCHNUM}"`
AUCDELCMD=`printf "B%06dB.CMD" "${BATCHNUM}"`
AUCDELRES=`printf "PT.B%06dB" "${BATCHNUM}"`
AUCCRECMD=`printf "B%06dC.CMD" "${BATCHNUM}"`
AUCCRERES=`printf "PT.B%06dC" "${BATCHNUM}"`
HLRCRECMD=`printf "B%06dD.CMD" "${BATCHNUM}"`
HLRCRERES=`printf "PT.B%06dD" "${BATCHNUM}"`
INCREATE=`printf "B%06dIN" "${BATCHNUM}"`
INDELETE=`printf "B%06dINDEL" "${BATCHNUM}"`
LDAPFILE=`printf "B%06d.ldap" "${BATCHNUM}"`

# Generating MML command files to delete from AUC, HLR and IN
$perl_script_dir/wal_hlrloader DEL $RESOURCE $REFMSIN   $HLRDELCMD $HLRDELRES
$perl_script_dir/wal_aucloader DEL $RESOURCE $AUCDELCMD $AUCDELRES
$perl_script_dir/wal_indelete      $RESOURCE $INDELETE  $PROVIDER

mv $HLRDELCMD $AUCDELCMD $INDELETE.txt $INDELETE.xml $BATCHDIR

# Generate MML command files to create in AUC, HLR and IN
$perl_script_dir/wal_aucloader CREATE $RESOURCE $AUCCRECMD $AUCCRERES
$perl_script_dir/wal_hlrloader CREATE $RESOURCE $REFMSIN   $HLRCRECMD $HLRCRERES
$perl_script_dir/wal_inloader         $RESOURCE $INCREATE  $PROVIDER
$perl_script_dir/wal_ldap             $RESOURCE $LDAPFILE

mv $AUCCRECMD $HLRCRECMD $INCREATE.txt $INCREATE.xml $LDAPFILE $BATCHDIR

# Move processed resource input file to the batch directory
mv $RESOURCE $BATCHDIR

exit 0
