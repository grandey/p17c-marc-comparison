#!/bin/bash
CASENAME=p17c_mam7_1850

cd ~/models/cesm1_2_2_1/scripts/
./create_newcase -case ~/cesm1_2_2_1_cases/$CASENAME -res f19_g16 -compset FC5 -mach cheyenne -pes_file pes/p720n20.xml

cd ~/cesm1_2_2_1_cases/$CASENAME
./xmlchange CAM_CONFIG_OPTS="-phys cam5 -chem trop_mam7 -cosp"
./cesm_setup
wget https://raw.githubusercontent.com/grandey/p17c-marc-comparison/master/user_nl_cam/user_nl_cam_$CASENAME
mv user_nl_cam_$CASENAME user_nl_cam
cp ~/models/mySourceMods/cospsimulator_intr.F90 SourceMods/src.cam/
./$CASENAME.build
ln -s /glade/scratch/bgrandey/$CASENAME/run/ scratch_run
./xmlchange STOP_OPTION=nyears
./xmlchange STOP_N=8
./xmlchange RESUBMIT=3
sed -i 's/regular/economy/g' $CASENAME.run
./$CASENAME.submit
