#!/bin/bash
set -eu
#export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
source "${EMEWS_PROJECT_ROOT}/EMEWS_SAVI.conf"

# Location of the base SAVI installation currently in "${EMEWS_PROJECT_ROOT}/EMEWS_SAVI.conf"
#SAVI_SRC_ROOT="/lustre/beagle2/lpBuild/CANDLE/SAVI/savi_trial_run"
# Note that the scripts are not part of the CACTVS installation see README

echo "%%%START OF STARTUP HOOK " $(date +%F" "%T) "%%%"
echo "EMEWS_PROJECT_ROOT=${EMEWS_PROJECT_ROOT}"

#Make main directory from where the jobs will be run
mkdir -p $base_name
echo "base_name: $base_name" $(ls -la $base_name)

sub_script='scripts/launch_product_run_swift.sh'
base_name_sub_script="${base_name}/$sub_script"
mkdir -p $(dirname $base_name_sub_script)
#Define the version of the package cactvus to use, the location of local storage for the run and the cactvs package

#Copy the master script
echo Copying $sub_script to $base_name
cp ${SAVI_SRC_ROOT}/$sub_script $base_name_sub_script

#Create necessary directories on staging storage (local storage or ramdisk probably)
#Parts that are common between all runs
apps_directory="${base_name}/apps"
tcl_scripts_directory="${base_name}/scripts" #tcl scripts need to be where we run as far as I can tell
cactvs_home="$apps_directory/cactvs${cactvs_version}"
aux_files_directory="${base_name}/aux_files"
make_directories="mkdir -p $apps_directory && mkdir -p $tcl_scripts_directory && mkdir -p $aux_files_directory"

#copy the cactvs toolkit to the staging storage if it isn't there yet
#change according to the location of cactvs installation archive
copy_apps_files="cp $persistent_directory/apps/${cactvs_tar} $apps_directory"
#copy_aux_dbs="cp $persistent_directory/aux_files/{ams_stereo_lookup.tch,pubchem_stereo_lookup.tch} $aux_files_directory"
copy_aux_dbs0="cp $persistent_directory/aux_files/ams_stereo_lookup.tch $aux_files_directory"
copy_aux_dbs1="cp $persistent_directory/aux_files/pubchem_stereo_lookup.tch $aux_files_directory"
copy_bb_file="cp $bb_file $aux_files_directory"
copy_aux_files="$copy_aux_dbs0 && $copy_aux_dbs1 && $copy_bb_file"
copy_tcl_scripts="cp $persistent_directory/scripts/*.tcl $tcl_scripts_directory"
protect_apps_files="chmod -R -w $apps_directory" #Needed on Beagle where the shared libraries are removed if not
#copy other necessary (such as building block file, pubchem and AMS) files to /lscratch
#LP copy_aux_files="cp $bb_file $aux_files_directory && cp $persistent_directory/aux_files/* $aux_files_directory" 

#LP copy_aux_files="cp $bb_file $aux_files_directory && cp $persistent_directory/aux_files/* $aux_files_directory" 
#extract the cactvs installation on /lscratch
extract_apps_files="tar -C $apps_directory -xf $apps_directory/${cactvs_tar}"
rm_staged_tar="rm -rf $apps_directory/${cactvs_tar}"
stage_core_files="$copy_apps_files && $copy_aux_files  && $copy_tcl_scripts && $extract_apps_files && $rm_staged_tar && $protect_apps_files"

echo $make_directories
eval $make_directories

echo $stage_core_files
eval $stage_core_files

ls -la  $base_name
#Wait a little bit to make that the filesystem isn't letting anything slip by
sleep 10

mkdir $nodeUnLock # set a lock to make sure no process on that node can start

echo "%%%END OF STARTUP HOOK " $(date +%F" "%T) "%%%"


