#!/bin/bash

# Purpose:
#   Sync copy of each p17c case directory to ~/scratch/archive/
#
# Usage:
#   To be run on Cheyenne:
#     ./archive_case_p17c.sh
#
# Author:
#   Benjamin S. Grandey, 2017

ARCHIVE_DIR=/glade/scratch/bgrandey/archive

# Loop over cases
for CASENAME in p17c_marc_1850 p17c_marc_2000 p17c_mam3_1850 p17c_mam3_2000 p17c_mam7_2000
do
    echo $CASENAME
    rsync -av /glade/u/home/bgrandey/cesm1_2_2_1_cases/$CASENAME $ARCHIVE_DIR/$CASENAME/arch_case/ 
done

echo "Finished"
