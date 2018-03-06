#!/bin/sh

clear
echo ""
echo "*************************************************************"
echo "* Wataniya Postpaid AUC command file generator              *"
echo "*************************************************************"
echo ""
echo ""

printf "Please enter the resource filename      :> "
read RESOURCE

# ------------------------------------
# Verify that the RESOURCE file exists
# ------------------------------------
if [ ! -e $RESOURCE ]
then
	echo "Resource file  \"$RESOURCE\"  not found !!!\n"
	exit
fi

printf "Please enter the batch no. (1 - 999999) :> "
read BATCHNUM

# ---------------------------------------------------------------------
# Generate the directory needed to store files related to current batch
# ---------------------------------------------------------------------
BATCHDIR=`echo $BATCHNUM | awk '{ printf( "BATCH%06d", $1 ); }'`

if [ ! -d $BATCHDIR ]
then
	mkdir $BATCHDIR
fi

# -------------------------------------------------------
# Generate all the valid filenames for this PREPAID batch
# -------------------------------------------------------
HLRDELCMD=`echo $BATCHNUM | awk '{ printf( "B%06dA.CMD", $1 ); }'`
HLRDELRES=`echo $BATCHNUM | awk '{ printf( "PT.B%06dA", $1 ); }'`

AUCDELCMD=`echo $BATCHNUM | awk '{ printf( "B%06dB.CMD", $1 ); }'`
AUCDELRES=`echo $BATCHNUM | awk '{ printf( "PT.B%06dB", $1 ); }'`

AUCCRECMD=`echo $BATCHNUM | awk '{ printf( "B%06dC.CMD", $1 ); }'`
AUCCRERES=`echo $BATCHNUM | awk '{ printf( "PT.B%06dC", $1 ); }'`
echo ""

# -----------------------------------------------------
# Generate MML command files to remove from AUC and HLR
# -----------------------------------------------------
wal_hlrloader DEL    $RESOURCE 2190000000 $HLRDELCMD $HLRDELRES
wal_aucloader DEL    $RESOURCE $AUCDELCMD $AUCDELRES
mv $HLRDELCMD $AUCDELCMD $BATCHDIR

# -------------------------------------------
# Generate MML command files to create in AUC
# -------------------------------------------
wal_aucloader CREATE $RESOURCE $AUCCRECMD $AUCCRERES
mv $AUCCRECMD $BATCHDIR
echo ""

# ---------------------------------------------------------
# Move processed resource input file to PROCESSED directory
# ---------------------------------------------------------
mv $RESOURCE $BATCHDIR


