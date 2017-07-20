#!/bin/csh
# Creates MITaer SO4 emission files by manipulating mam3 emissions.
# lz4ax 2014/02/05
# 2017-07-07 - modified by BSG to produce year-1850 sulphate emissions.
# 2017-07-20 - Deleting SO2 lines (previously commented out); & renaming output files.

#where MAM3 files live
set mam3dir = /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/trop_mozart_aero/emis/

#MAM3 emission files
set mam3SO4sfc1 = $mam3dir/ar5_mam3_so4_a1_surf_1850_c090726.nc
set mam3SO4sfc2 = $mam3dir/ar5_mam3_so4_a2_surf_1850_c090726.nc
set mam3SO4lev1 = $mam3dir/ar5_mam3_so4_a1_elev_1850_c090726.nc
set mam3SO4lev2 = $mam3dir/ar5_mam3_so4_a2_elev_1850_c090726.nc

#MITaer filenames
set SO4SFCFILE = so4_surf_p17c_marc_1850.nc
set SO4LEVFILE = so4_elev_p17c_marc_1850.nc

#paranoid
echo " "
echo "Removing all MITaer sulfur emission files ..."
rm -f $SO4SFCFILE $SO4LEVFILE

#SO4 surface emissions
echo "Preparing SO4 surface emissions ..."
echo "Copying $mam3SO4sfc1 $SO4SFCFILE"
cp -f $mam3SO4sfc1 $SO4SFCFILE

chmod +w $SO4SFCFILE

echo "Adding all variables from $mam3SO4sfc2 to $SO4SFCFILE"
ncks -A $mam3SO4sfc2 $SO4SFCFILE

echo "Deleting $SO4SFCFILE history global attribute"
ncatted -a history,global,d,c, $SO4SFCFILE

echo "Adding a comment to $SO4SFCFILE"
ncatted -a history,global,a,c,"  lz4ax: This file is created by simply combining the content of $mam3SO4sfc1 and $mam3SO4sfc2. \n" $SO4SFCFILE

echo "Done with SO4 surface emissions."
echo " "

#SO4 level emissions
echo "Preparing SO4 forcing ..."
echo "Copying $mam3SO4lev1 $SO4LEVFILE"
cp -f $mam3SO4lev1 $SO4LEVFILE

chmod +w $SO4LEVFILE

echo "Adding all variables from $mam3SO4lev2 to $SO4LEVFILE"
ncks -A $mam3SO4lev2 $SO4LEVFILE

echo "Deleting $SO4LEVFILE history global attribute"
ncatted -a history,global,d,c, $SO4LEVFILE

echo "Adding a comment to $SO4LEVFILE"
ncatted -a history,global,a,c,"  lz4ax: This file is created by simply combining the content of $mam3SO4lev1 and $mam3SO4lev2. \n" $SO4LEVFILE

echo "Done with SO4 emissions."
echo " "

exit 0
