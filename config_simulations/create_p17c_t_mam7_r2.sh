#!/bin/bash
CASENAME=p17c_t_mam7_r2

cd ~/models/cesm1_2_2_1/scripts/
./create_newcase -case ~/cesm1_2_2_1_cases/$CASENAME -res f19_g16 -compset FC5 -mach cheyenne -pes_file pes/p720n20.xml

cd ~/cesm1_2_2_1_cases/$CASENAME
./xmlchange CAM_CONFIG_OPTS="-phys cam5 -chem trop_mam7"
./cesm_setup
wget https://raw.githubusercontent.com/grandey/p17c-marc-comparison/master/user_nl_cam/user_nl_cam_$CASENAME
mv user_nl_cam_$CASENAME user_nl_cam
./$CASENAME.build
ln -s /glade/scratch/bgrandey/$CASENAME/run/ scratch_run
./xmlchange REST_OPTION="never"
./xmlchange STOP_N=20
./xmlchange RESUBMIT=4
./xmlchange COMP_RUN_BARRIERS="TRUE"
sed -i 's/regular/economy/g' $CASENAME.run
./$CASENAME.submit
