#!/bin/bash

# Purpose:
#   gzip NetCDF files produced by the p17c-marc-comparison simulations
#
# Usage:
#   To be run on Cheyenne:
#     ./gzip_netcdf_p17c.sh
#
# Author:
#   Benjamin S. Grandey, 2017

ARCHIVE_DIR=/glade/scratch/bgrandey/archive

# Loop over cases
for CASENAME in p17c_marc_1850 p17c_marc_2000 p17c_mam3_1850 p17c_mam3_2000 p17c_mam7_2000
do
    echo $CASENAME
    for f in $ARCHIVE_DIR/$CASENAME/*/*/*.nc
    do
	if [ -f $f ]
	then
	    echo "Gzipping $f"
	    gzip -f $f
	fi
    done
done

echo "Finished"
