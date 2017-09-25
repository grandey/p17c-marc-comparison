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

date

IN_DIR=$HOME/data/projects/p17c_marc_comparison/output_timeseries/
OUT_DIR=$HOME/data/projects/p17c_marc_comparison/cdo_analysis_prelim/

# 0. Delete all NetCDF files in output directory
rm -f $OUT_DIR/*.nc

# 1. ANNUAL means for years 3-32 for all fields of interest
echo "Getting ANNUAL means for years 3-32 for all fields of interest"
FIELD_LIST=" \
FSNTOA FSNTOANOA FSNTOACNOA SAF DRF CRF LWCF \
FSNTOA_d1 FSNTOAC_d1 SWCF_d1
pSUL_LDG OC_LDG BC_LDG MOS_LDG MBS_LDG \
BURDENSO4 BURDENPOM BURDENBC \
"
for FIELD in $FIELD_LIST
do
    echo $FIELD
    for IN_FILE in $IN_DIR/p17c_????_????.*.$FIELD.nc
    do
	OUT_FILE="$OUT_DIR/s1.ym.${IN_FILE##*/}"
	# Select just field of interest to avoid multiple grids (which leads to zonmean problems later)
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
# Net RFP (marc, mam3) - when 2000-1850 difference is calculated
for IN_FILE1 in $OUT_DIR/s1.ym.p17c_marc_????.*.FSNTOA.nc $OUT_DIR/s1.*.p17c_mam3_????.*.FSNTOA.nc
do
    echo "cFNTOA"
    IN_FILE2=${IN_FILE1/FSNTOA/LWCF}
    OUT_FILE=${IN_FILE1/FSNTOA/cFNTOA}
    TEMP_FILE="$OUT_DIR/temp.nc"
    cdo merge $IN_FILE1 $IN_FILE2 $TEMP_FILE >/dev/null 2>/dev/null
    cdo expr,'cFNTOA=FSNTOA+LWCF' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
    rm -f $TEMP_FILE
    echo ${OUT_FILE##*/}
done
# Direct effect (mam3)
for IN_FILE1 in $OUT_DIR/s1.ym.p17c_mam3_????.*.FSNTOA.nc
do
    echo "cDRE"
    IN_FILE2=${IN_FILE1/FSNTOA/FSNTOA_d1}
    OUT_FILE=${IN_FILE1/FSNTOA/cDRE}
    TEMP_FILE="$OUT_DIR/temp.nc"
    cdo merge $IN_FILE1 $IN_FILE2 $TEMP_FILE >/dev/null 2>/dev/null
    cdo expr,'cDRE=FSNTOA-FSNTOA_d1' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
    rm -f $TEMP_FILE
    echo ${OUT_FILE##*/}
done

# 2. Average across LONGITUDES (ie zonal mean)
echo "Averaging across LONGITUDES"
for IN_FILE in $OUT_DIR/s1.ym.*.nc
do
    OUT_FILE=${IN_FILE/s1/s2.zm}  # bash string replacement
    cdo zonmean $IN_FILE $OUT_FILE # >/dev/null 2>/dev/null
    echo ${OUT_FILE##*/}
done

# 3. Average across GLOBE (ie area-weighted mean)
echo "Averaging across GLOBE"
for IN_FILE in $OUT_DIR/s1.ym.*.nc
do
    OUT_FILE=${IN_FILE/s1/s3.fm}
    cdo fldmean $IN_FILE $OUT_FILE >/dev/null 2>/dev/null
    echo ${OUT_FILE##*/}
done

# 4. Average across TIME
echo "Averaging across TIME"
for IN_FILE in $OUT_DIR/s1.ym.*.nc
do
    OUT_FILE=${IN_FILE/s1/s4.tm}
    cdo timmean $IN_FILE $OUT_FILE >/dev/null 2>/dev/null
    echo ${OUT_FILE##*/}
done

# 5. Average across LONGITUDES & TIME
echo "Averaging across LONGITUDES & TIME"
for IN_FILE in $OUT_DIR/s1.ym.*.nc
do
    OUT_FILE=${IN_FILE/s1/s5.tm.zm}
    cdo timmean -zonmean $IN_FILE $OUT_FILE >/dev/null 2>/dev/null
    echo ${OUT_FILE##*/}
done

# 6. Average across GLOBE & TIME
echo "Averaging across GLOBE & TIME"
for IN_FILE in $OUT_DIR/s1.ym.*.nc
do
    OUT_FILE=${IN_FILE/s1/s6.tm.fm}
    cdo timmean -fldmean $IN_FILE $OUT_FILE >/dev/null 2>/dev/null
    echo ${OUT_FILE##*/}
done

# 7. 2000-1850 DIFFERENCES for means across time
echo "Calculating 2000-1850 DIFFERENCES"
for IN_FILE1 in $OUT_DIR/s[456].*.p17c_????_1850.*.nc
do
    IN_FILE2=${IN_FILE1/1850/2000}
    OUT_FILE=${IN_FILE1/1850/2000-1850}
    cdo sub $IN_FILE2 $IN_FILE1 $OUT_FILE >/dev/null 2>/dev/null
    echo ${OUT_FILE##*/}
done

# # 8. Calculate DERIVED fields
# echo "Calculating DERIVED fields"
# # Net RFP (marc, mam3)
# for IN_FILE1 in $OUT_DIR/s[456].*.p17c_????_2000-1850.*.FSNTOA.nc
# do
#     IN_FILE2=${IN_FILE1/FSNTOA/LWCF}
#     OUT_FILE=${IN_FILE1/FSNTOA/cFNTOA}
#     TEMP_FILE="$OUT_DIR/temp.nc"
#     cdo merge $IN_FILE1 $IN_FILE2 $TEMP_FILE >/dev/null 2>/dev/null
#     cdo expr,'cFNTOA=FSNTOA+LWCF' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
#     rm -f $TEMP_FILE
#     echo ${OUT_FILE##*/}
# done
# # Direct effect (mam3)
# for IN_FILE1 in $OUT_DIR/s[456].*.p17c_mam3_2000-1850.*.FSNTOA.nc
# do
#     IN_FILE2=${IN_FILE1/FSNTOA/FSNTOA_d1}
#     OUT_FILE=${IN_FILE1/FSNTOA/cDRE}
#     TEMP_FILE="$OUT_DIR/temp.nc"
#     cdo merge $IN_FILE1 $IN_FILE2 $TEMP_FILE >/dev/null 2>/dev/null
#     cdo expr,'cDRE=FSNTOA-FSNTOA_d1' $TEMP_FILE $OUT_FILE >/dev/null 2>/dev/null
#     rm -f $TEMP_FILE
#     echo ${OUT_FILE##*/}
# done

echo "Finished"

date
