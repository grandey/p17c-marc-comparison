#!/bin/bash

# Purpose:
#   Use CDO to do some quick preliminary analysis of the p17c comparison simulations
#
# Usage:
#   To be run on local machine:
#     ./cdo_analysis_prelim_p17c.sh
#
# Author:
#   Benjamin S. Grandey, 2017

IN_DIR=$HOME/data/projects/p17c_marc_comparison/output_timeseries/
OUT_DIR=$HOME/data/projects/p17c_marc_comparison/cdo_analysis_prelim/

# 0. Delete all NetCDF files in output directory
rm -f $OUT_DIR/*.nc

# 1. Calculatime means across time for years 3-32 for all input files
for IN_FILE in $IN_DIR/*.nc
do
    OUT_FILE="$OUT_DIR/s1.tm.${IN_FILE##*/}"
    cdo timmean -selyear,3/32 $IN_FILE $OUT_FILE
done

# 2. 2000-1850 differences
# 2a. MARC 2D fields
CASENAME1="p17c_marc_2000"
CASENAME2="p17c_marc_1850"
VARIABLE_LIST="FSNTOA FSNTOANOA FSNTOACNOA SAF DRF CRF LWCF"

for VARIABLE in $VARIABLE_LIST
do
    IN_FILE1="$OUT_DIR/s1.tm.$CASENAME1.cam.h0.$VARIABLE.nc"
    IN_FILE2="$OUT_DIR/s1.tm.$CASENAME2.cam.h0.$VARIABLE.nc"
    OUT_FILE="$OUT_DIR/s2.tm.$CASENAME1-$CASENAME2.cam.h0.$VARIABLE.nc"
    cdo sub $IN_FILE1 $IN_FILE2 $OUT_FILE
done

# 2b. MAM3 2D fields
CASENAME1="p17c_mam3_2000"
CASENAME2="p17c_mam3_1850"
VARIABLE_LIST="FSNTOA FSNTOA_d1 FSNTOAC_d1 SWCF_d1 LWCF LWCF_d1"

for VARIABLE in $VARIABLE_LIST
do
    IN_FILE1="$OUT_DIR/s1.tm.$CASENAME1.cam.h0.$VARIABLE.nc"
    IN_FILE2="$OUT_DIR/s1.tm.$CASENAME2.cam.h0.$VARIABLE.nc"
    OUT_FILE="$OUT_DIR/s2.tm.$CASENAME1-$CASENAME2.cam.h0.$VARIABLE.nc"
    cdo sub $IN_FILE1 $IN_FILE2 $OUT_FILE
done

# 2c. Derived fields
# Net RFP
for MODEL in marc mam3
do
    IN_FILE1="$OUT_DIR/s2.tm.p17c_${MODEL}_2000-p17c_${MODEL}_1850.cam.h0.FSNTOA.nc"
    IN_FILE2="$OUT_DIR/s2.tm.p17c_${MODEL}_2000-p17c_${MODEL}_1850.cam.h0.LWCF.nc"
    TEMP_FILE="$OUT_DIR/temp.nc"
    OUT_FILE="$OUT_DIR/s2.tm.p17c_${MODEL}_2000-p17c_${MODEL}_1850.cam.h0.cFNTOA.nc"
    cdo merge $IN_FILE1 $IN_FILE2 $TEMP_FILE
    cdo expr,'cFNTOA=FSNTOA+LWCF' $TEMP_FILE $OUT_FILE
    rm -f $TEMP_FILE
done

# Direct effect - MAM3
MODEL="mam3"
IN_FILE1="$OUT_DIR/s2.tm.p17c_${MODEL}_2000-p17c_${MODEL}_1850.cam.h0.FSNTOA.nc"
IN_FILE2="$OUT_DIR/s2.tm.p17c_${MODEL}_2000-p17c_${MODEL}_1850.cam.h0.FSNTOA_d1.nc"
TEMP_FILE="$OUT_DIR/temp.nc"
OUT_FILE="$OUT_DIR/s2.tm.p17c_${MODEL}_2000-p17c_${MODEL}_1850.cam.h0.cDRE.nc"
cdo merge $IN_FILE1 $IN_FILE2 $TEMP_FILE
cdo expr,'cDRE=FSNTOA-FSNTOA_d1' $TEMP_FILE $OUT_FILE
rm -f $TEMP_FILE

# 2d. Area-weighted means
for IN_FILE in $OUT_DIR/s2.*.nc
do
    OUT_FILE=${IN_FILE%nc}fm.nc
    cdo fldmean $IN_FILE $OUT_FILE
done

echo "Finished analysis"

# Print area-weighted means
for IN_FILE in $OUT_DIR/*.fm.nc
do
    echo ${IN_FILE##*/}
    cdo infov $IN_FILE 2>/dev/null | grep -v '0.0000\|nan\|2.1475\|Mean'
done

echo "Finished"
