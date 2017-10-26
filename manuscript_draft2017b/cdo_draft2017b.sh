#!/bin/bash

# Purpose:
#   Use CDO to do some post-processing of the p17c output data.
#
# Usage:
#   To be run on local machine:
#     ./cdo_draft2017b.sh
#
# Author and History:
#   Benjamin S. Grandey, 2017
#   Based on cdo_analysis_prelim_p17c.sh

date

# Input data directory
IN_DIR=$HOME/data/projects/p17c_marc_comparison/output_timeseries/
# The data in IN_DIR have been synced to the local machine (see data_management.org)
# These data will also be uploaded to figshare

# Output data directory
OUT_DIR=$HOME/data/projects/p17c_marc_comparison/cdo_draft2017b/

# 0. Delete all NetCDF files in output directory
rm -f $OUT_DIR/*.nc

# 1a. Calculate ANNUAL means for years 3-32 for all fields of interest
echo "Calculating ANNUAL means for years 3-32 for all fields of interest"

FIELD_LIST=" \
pSUL_LDG OC_LDG BC_LDG MOS_LDG MBS_LDG \
BURDENSO4 BURDENPOM BURDENBC \
TAU_tot AEROD_v \
CCN3 \
CDNUMC \
CLDTOT CLDLOW CLDMED CLDHGH \
TGCLDLWP TGCLDIWP TGCLDCWP \
FSNTOA FSNTOANOA FSNTOA_d1 \
FSNS FSNSNOA FSNS_s1 \
CRF SWCF_d1 LWCF \
FSNTOACNOA FSNTOAC_d1 \
FSNTOA \
FSNO SNOBCMSL \
"

for FIELD in $FIELD_LIST
do
    echo $FIELD
    for IN_FILE in $IN_DIR/p17c_????_????.*.$FIELD.nc
    do
	OUT_FILE="$OUT_DIR/s1.ym.${IN_FILE##*/}"
	# Select just field of interest to avoid multiple grids
	TEMP_FILE="$OUT_DIR/temp.nc"
        cdo selname,$FIELD, $IN_FILE $TEMP_FILE >/dev/null 2>/dev/null
	# Yearmean for years 3-32 - with year starting in December of previous year
	cdo yearmean -selyear,3/32 $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
	rm -f $TEMP_FILE
	echo ${OUT_FILE##*/}
    done
done

# 1b. Calculate DERIVED fields
echo "Calculating DERIVED fields"

# Net (SW + LW) RFP (marc, mam) - when 2000-1850 difference is calculated
echo "cFNTOA"
for IN_FILE1 in $OUT_DIR/s1.ym.p17c_marc_????.*.FSNTOA.nc $OUT_DIR/s1.*.p17c_mam?_????.*.FSNTOA.nc
do
    IN_FILE2=${IN_FILE1/FSNTOA/LWCF}  # Using LWCF, since clean-sky LWCF not available for MARC
    OUT_FILE=${IN_FILE1/FSNTOA/cFNTOA}
    TEMP_FILE="$OUT_DIR/temp.nc"
    cdo merge $IN_FILE1 $IN_FILE2 $TEMP_FILE >/dev/null 2>/dev/null
    cdo expr,'cFNTOA=FSNTOA+LWCF' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
    rm -f $TEMP_FILE
    echo ${OUT_FILE##*/}
done

# Direct radiative effect at TOA (mam)
echo "cDRE mam3 mam7"
for IN_FILE1 in $OUT_DIR/s1.ym.p17c_mam?_????.*.FSNTOA.nc
do
    IN_FILE2=${IN_FILE1/FSNTOA/FSNTOA_d1}
    OUT_FILE=${IN_FILE1/FSNTOA/cDRE}
    TEMP_FILE="$OUT_DIR/temp.nc"
    cdo merge $IN_FILE1 $IN_FILE2 $TEMP_FILE >/dev/null 2>/dev/null
    cdo expr,'cDRE=FSNTOA-FSNTOA_d1' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
    rm -f $TEMP_FILE
    echo ${OUT_FILE##*/}
done

# Direct radiative effect at TOA (marc) - should be same as DRF history field
echo "cDRE marc"
for IN_FILE1 in $OUT_DIR/s1.ym.p17c_marc_????.*.FSNTOA.nc
do
    IN_FILE2=${IN_FILE1/FSNTOA/FSNTOANOA}
    OUT_FILE=${IN_FILE1/FSNTOA/cDRE}
    TEMP_FILE="$OUT_DIR/temp.nc"
    cdo merge $IN_FILE1 $IN_FILE2 $TEMP_FILE >/dev/null 2>/dev/null
    cdo expr,'cDRE=FSNTOA-FSNTOANOA' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
    rm -f $TEMP_FILE
    echo ${OUT_FILE##*/}
done

# Direct radiative effect at surface (mam)
echo "cDREsurf mam3 mam7"
for IN_FILE1 in $OUT_DIR/s1.ym.p17c_mam?_????.*.FSNS.nc
do
    IN_FILE2=${IN_FILE1/FSNS/FSNS_d1}
    OUT_FILE=${IN_FILE1/FSNS/cDREsurf}
    TEMP_FILE="$OUT_DIR/temp.nc"
    cdo merge $IN_FILE1 $IN_FILE2 $TEMP_FILE >/dev/null 2>/dev/null
    cdo expr,'cDREsurf=FSNS-FSNS_d1' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
    rm -f $TEMP_FILE
    echo ${OUT_FILE##*/}
done

# Direct radiative effect at surface (marc)
echo "cDREsurf marc"
for IN_FILE1 in $OUT_DIR/s1.ym.p17c_marc_????.*.FSNS.nc
do
    IN_FILE2=${IN_FILE1/FSNS/FSNSNOA}
    OUT_FILE=${IN_FILE1/FSNS/cDREsurf}
    TEMP_FILE="$OUT_DIR/temp.nc"
    cdo merge $IN_FILE1 $IN_FILE2 $TEMP_FILE >/dev/null 2>/dev/null
    cdo expr,'cDREsurf=FSNS-FSNSNOA' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
    rm -f $TEMP_FILE
    echo ${OUT_FILE##*/}
done

# Direct effect atmospheric absorption (mam)
echo "cDREatm mam3 mam7"
for IN_FILE1 in $OUT_DIR/s1.*.p17c_mam?_????.*.FSNTOA.nc
do
    IN_FILE2=${IN_FILE1/FSNTOA/FSNS}
    IN_FILE3=${IN_FILE1/FSNTOA/FSNTOA_d1}
    IN_FILE4=${IN_FILE1/FSNTOA/FSNS_d1}
    OUT_FILE=${IN_FILE1/FSNTOA/cDREatm}
    TEMP_FILE="$OUT_DIR/temp.nc"
    cdo merge $IN_FILE1 $IN_FILE2 $IN_FILE3 $IN_FILE4 $TEMP_FILE >/dev/null 2>/dev/null
    cdo expr,'cDREatm=FSNTOA-FSNTOA_d1-FSNS+FSNS_d1' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
    rm -f $TEMP_FILE
    echo ${OUT_FILE##*/}
done

# Direct effect atmospheric absorption (marc)
echo "cDREatm marc"
for IN_FILE1 in $OUT_DIR/s1.*.p17c_marc_????.*.FSNTOA.nc
do
    IN_FILE2=${IN_FILE1/FSNTOA/FSNS}
    IN_FILE3=${IN_FILE1/FSNTOA/FSNTOANOA}
    IN_FILE4=${IN_FILE1/FSNTOA/FSNSNOA}
    OUT_FILE=${IN_FILE1/FSNTOA/cDREatm}
    TEMP_FILE="$OUT_DIR/temp.nc"
    cdo merge $IN_FILE1 $IN_FILE2 $IN_FILE3 $IN_FILE4 $TEMP_FILE >/dev/null 2>/dev/null
    cdo expr,'cDREatm=FSNTOA-FSNTOANOA-FSNS+FSNSNOA' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
    rm -f $TEMP_FILE
    echo ${OUT_FILE##*/}
done

# CCN in bottom model layer (marc, mam)
echo "cCCNml30"
for IN_FILE in $OUT_DIR/s1.ym.p17c_marc_????.*.CCN3.nc $OUT_DIR/s1.*.p17c_mam?_????.*.CCN3.nc
do
    OUT_FILE=${IN_FILE/CCN3/cCCNml30}
    TEMP_FILE="$OUT_DIR/temp.nc"
    cdo sellevidx,30 $IN_FILE $TEMP_FILE >/dev/null 2>/dev/null
    cdo expr,'cCCNml30=CCN3' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
    echo ${OUT_FILE##*/}
done

# CCN at level 19, approx 525hPa (marc, mam)
echo "cCCNml19"
for IN_FILE in $OUT_DIR/s1.ym.p17c_marc_????.*.CCN3.nc $OUT_DIR/s1.*.p17c_mam?_????.*.CCN3.nc
do
    OUT_FILE=${IN_FILE/CCN3/cCCNml19}
    cdo sellevidx,19 $IN_FILE $TEMP_FILE >/dev/null 2>/dev/null
    cdo expr,'cCCNml19=CCN3' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
    echo ${OUT_FILE##*/}
done

echo "Finished"

date
