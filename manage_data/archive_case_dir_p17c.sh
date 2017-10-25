#!/bin/bash

# Purpose:
#   Sync copy of each p17c case directory to ~/scratch/archive/
#
# Usage:
#   To be run on Cheyenne:
#     ./archive_case_dir_p17c.sh
#
# Author:
#   Benjamin S. Grandey, 2017

ARCHIVE_DIR=/glade/scratch/bgrandey/archive

# Loop over comparison cases
for CASENAME in p17c_marc_1850 p17c_marc_2000 p17c_mam3_1850 p17c_mam3_2000 p17c_mam7_2000
do
    echo $CASENAME
    rsync -av /glade/u/home/bgrandey/cesm1_2_2_1_cases/$CASENAME $ARCHIVE_DIR/$CASENAME/arch_case/ 
done

# Loop over timing cases
for CASENAME in p17c_t_marc_r2 p17c_t_marc_r1 p17c_t_mam3_r2 p17c_t_mam3_r1 p17c_t_mam7_r2 p17c_t_mam7_r1
do
    echo $CASENAME
    rsync -av /glade/u/home/bgrandey/cesm1_2_2_1_cases/$CASENAME $ARCHIVE_DIR/$CASENAME/arch_case/ 
done

echo "Finished"
