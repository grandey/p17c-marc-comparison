#!/bin/csh
# Creates MITaer SO2/SO4 emission files by manipulating mam3 emissions.
# lz4ax 2014/02/05
# 2017-07-07 - modified by BSG to produce year-1850 sulphate emissions.

#where MAM3 files live
set mam3dir = /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/trop_mozart_aero/emis/

#MAM3 emission files
#set mam3SO2sfc  = $mam3dir/ar5_mam3_so2_surf_1850_c090726.nc
#set mam3SO2lev  = $mam3dir/ar5_mam3_so2_elev_1850_c090726.nc
set mam3SO4sfc1 = $mam3dir/ar5_mam3_so4_a1_surf_1850_c090726.nc
set mam3SO4sfc2 = $mam3dir/ar5_mam3_so4_a2_surf_1850_c090726.nc
set mam3SO4lev1 = $mam3dir/ar5_mam3_so4_a1_elev_1850_c090726.nc
set mam3SO4lev2 = $mam3dir/ar5_mam3_so4_a2_elev_1850_c090726.nc

#MITaer filenames
#set SO2SFCFILE = mit_aero_1850_so2_surf_1.9x2.5.nc
#set SO2LEVFILE = mit_aero_1850_so2_elev_1.9x2.5.nc
set SO4SFCFILE = mit_aero_1850_so4_surf_1.9x2.5.nc
set SO4LEVFILE = mit_aero_1850_so4_elev_1.9x2.5.nc

#paranoid
echo " "
echo "Removing all MITaer sulfur emission files ..."
#rm -f $SO2SFCFILE $SO2LEVFILE $SO4SFCFILE $SO4LEVFILE
rm -f $SO4SFCFILE $SO4LEVFILE

# #SO2 surface emissions
# echo "Preparing SO2 surface emissions ..."
# echo "Copying $mam3SO2sfc to $SO2SFCFILE "
# cp -f $mam3SO2sfc $SO2SFCFILE

# chmod +w $SO2SFCFILE

# echo "Adding a comment to $SO2SFCFILE"
# ncatted -a history,global,a,c,"  lz4ax: This is just $mam3SO2sfc file renamed for use with MITaer.  \n" $SO2SFCFILE

# echo "Done with SO2 surface emissions."
# echo " "


# #SO2 level emissions
# echo "Preparing SO2 forcings ..."
# echo "Copying $mam3SO2lev to $SO2LEVFILE "
# cp -f $mam3SO2lev $SO2LEVFILE

# chmod +w $SO2LEVFILE

# echo "Adding a comment to $SO2LEVFILE"
# ncatted -a history,global,a,c,"  lz4ax: This is just $mam3SO2lev file renamed for use with MITaer.  \n" $SO2LEVFILE

# echo "Done with SO2 forcings."
# echo " "


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
