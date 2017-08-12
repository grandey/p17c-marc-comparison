#!/bin/bash

# Purpose:
#   rsync copy of each p17c simulation directory in ~/scratch/archive/ to newton
#
# Usage:
#   To be run on Cheyenne:
#     ./rsync_archive_to_newton.sh
#
# Author:
#   Benjamin S. Grandey, 2017

ARCHIVE_DIR=/glade/scratch/bgrandey/archive

# Loop over cases
for CASENAME in p17c_marc_1850 p17c_marc_2000 p17c_mam3_1850 p17c_mam3_2000 p17c_mam7_2000
do
    echo $CASENAME
    rsync -avz --progress -e "ssh -p $NEWTON_PORT" $ARCHIVE_DIR/$CASENAME $NEWTON_USER@$NEWTON_IP:/orchard/grandey/data2/acrc/RUN/archive/
done

echo "Finished"
