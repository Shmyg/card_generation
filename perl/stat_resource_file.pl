#!/usr/contrib/bin/perl -w

# Script to get all information about resource file to create SIM-cards
# Outputs following information:
# number of lines in the file - first MSIN - last MSIN - first DN - last DN
#
# $Log: stat_resource_file.pl,v $
# Revision 1.1  2005/02/13 10:11:19  serge
# Added file to get resource file information
#

$line_num=1;
$first_msin=1;
$last_msin=1;
$first_dn=1;
$last_dn=1;

# Check if the filename is provided
die "Incorrect usage: filename to process is missing\n" if ($#ARGV == -1);

# Check if the file is a regular file and is readable
die "$ARGV[0] is not a file or is not readable\n" unless -f $ARGV[0];

$filename=$ARGV[0];

# Opening all the files
open (IN,"$filename") or die "$!\n";

while(<IN>) {
 chomp;
 
 # Deleting prefix
 s/CRE:SUBA,//;

 # Splitting line (delimiter - ',')
 @fields = split (/,/);

 # We need to get info from the first and the last line - see below
 if ( $line_num == 1 ) {
  # MSIN is the first field in the line
  $first_msin = "$fields[0]";
  # Phone number is 9th field
  $first_dn = "$fields[8]";
 }
 $line_num++;
}

# We need to extract 1 from line counter to get real number of pages
$line_num--;

# Now we have all the data belonging to the last line and can extract data
# that is needed

$last_msin = "$fields[0]";
$last_dn = "$fields[8]";

print "$line_num,$first_msin,$first_dn,$last_msin,$last_dn\n";

close(IN);
