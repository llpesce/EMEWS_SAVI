#!/bin/sh 
#NOTE:  the folders for temporary storage and the location of the tarballs for cactvs are passed received as parameters
#NOTES: for swift there will be three "locations":
#  persistent_directory: where the input files and the apps are stored before and after the swift run` 
#  Swift_directory: Where the results of a run will be stored and will persist after the run is completed
#  base_name: the storage where the computations will be performed (local storage or ramdisk, in general non persisent)
#cactvs_version="cactvs3.4.6.3" was the only version working at this time
cactvs_version=$1

base_name=$2 #Location where files will be staged before execution
cactvs_tar=$3 #Specific tar ball containing cactvs and modified files for the run (system dependent files)

file_index=$4
#local (or user) directory where the scripts,products and outputs directories are located 
#and from which files are copied to the /lscratch on compute nodes and copied back to once completed
persistent_directory=$5
#Note that we assume that the job management has put this script in the swift_directory
swift_directory=$(pwd)

#location of the building block file in a cactvs .bdb format
bb_file=$6

#name of the reactant list filename minus the index part
#if reactants are located in /dir1/dir2/reactant_list.infile_0001
#then the argument should be /dir1/dir2/reactant_list.infile_
reactant_list_filename=$7
reactant_list_basename=$(basename $reactant_list_filename)

#this will be used as "suffix" for file names (optional). 
#Instead of default outputs such as outputs/out_0000.txt and products/products_0000.infile 
#the files will be named outputs_suffix/out_suffix_000.txt and products_suffix/suffix_products_0000.infile
name_modifier=$8

if [[ -z $name_modifier ]]; then
    end_name_modifier=""
    beginning_name_modifier=""
else
    end_name_modifier="_${name_modifier}"
    beginning_name_modifier="${name_modifier}_"
fi

# Variables defined in the configuration file 
#base_name="/tmp/SAVI"
#cactvs_tar=cactvs${cactvs_version}"_Beagle.tar.gz"
mkdir -p $base_name
echo "basename: $base_name" $(ls -la $base_name)

#Create necessary directories on staging storage (local storage or ramdisk probably)
#Parts that are common between all runs
apps_directory="${base_name}/apps"
tcl_scripts_directory="${swift_directory}" #tcl scripts need to be where we run as far as I can tell
cactvs_home="$apps_directory/cactvs${cactvs_version}"

#Parts specific to this run (tiling runs might change this)
inputs_directory="${base_name}/inputs"
aux_files_directory="${base_name}/aux_files"
outputs_directory="${base_name}/outputs${end_name_modifier}"
products_directory="${base_name}/products${end_name_modifier}"

make_directories="mkdir -p $apps_directory && mkdir -p $inputs_directory && mkdir -p $aux_files_directory && mkdir -p $outputs_directory && mkdir -p $products_directory"

#create necessary local directories for output data
make_swift_directories="mkdir -p $swift_directory/outputs${end_name_modifier} && mkdir -p $swift_directory/products${end_name_modifier} && mkdir -p $tcl_scripts_directory"

#copy the cactvs toolkit to the staging storage if it isn't there yet
#change according to the location of cactvs installation archive
copy_apps_files="cp $persistent_directory/apps/${cactvs_tar} $apps_directory"
#copy_aux_dbs="cp $persistent_directory/aux_files/{ams_stereo_lookup.tch,pubchem_stereo_lookup.tch} $aux_files_directory"
copy_aux_dbs0="ln -s $persistent_directory/aux_files/ams_stereo_lookup.tch $aux_files_directory"
copy_aux_dbs1="ln -s $persistent_directory/aux_files/pubchem_stereo_lookup.tch $aux_files_directory"
copy_aux_dbs="$copy_aux_dbs0 && $copy_aux_dbs1"
#extract the cactvs installation on /lscratch
extract_apps_files="tar -C $apps_directory -xf $apps_directory/${cactvs_tar}"
rm_staged_tar="rm -rf $apps_directory/${cactvs_tar}"
stage_core_files="$copy_apps_files && $copy_aux_dbs && $extract_apps_files && $rm_staged_tar"
# Files that are needed for every run
copy_tcl_scripts="cp $persistent_directory/scripts/*.tcl $tcl_scripts_directory"
#copy input files (reactant lists) to staging location
copy_input_files="cp $reactant_list_filename${file_index} $inputs_directory"

#copy other necessary (such as building block file, pubchem and AMS) files to /lscratch
#LP copy_aux_files="cp $bb_file $aux_files_directory && cp $persistent_directory/aux_files/* $aux_files_directory" 
copy_aux_files="cp $bb_file $aux_files_directory" 

#LP copy_files="$copy_apps_files && $extract_apps_files && $copy_input_files && $copy_aux_files"
stage_run_files="$copy_aux_files && $copy_input_files && $copy_tcl_scripts"

# move  outputs and results from /lscratch to local persistent directory
copy_results_outputs="mv $outputs_directory/* $swift_directory/outputs${end_name_modifier}/"
copy_results_products="mv $products_directory/* $swift_directory/products${end_name_modifier}/"
copy_results="$copy_results_outputs && $copy_results_products"
clean_up_staged="rm $aux_files_directory/$bb_file && rm $inputs_directory/$reactant_list_filename${file_index} "

echo "$make_directories"
eval $make_directories
echo "$make_swift_directories"
eval $make_swift_directories
if [ ! -d "${apps_directory}/cactvs${cactvs_version}" ]; then
   echo $stage_core_files
   eval $stage_core_files
else
   echo "App files already on disk " $(ls -la $apps_directory)
   sleep 60 #To make sure that the files have time to unzip -- suboptimal
fi
echo "$stage_run_files"
eval "$stage_run_files"
ls -lrth $base_name
ls -lrth $apps_directory
ls -lrth $inputs_directory
ls -lrth $aux_files_directory

#launch the job by calling the starter tcl script
CMD="${cactvs_home}/csts_swift $cactvs_home -freact_chunk_all_nodb.tcl ${inputs_directory}/$reactant_list_basename $file_index $base_name $name_modifier > $outputs_directory/out_${beginning_name_modifier}${file_index}.txt"
echo $CMD
eval $CMD
#echo "CURRENT LOCATION: "$(pwd)
#eval $apps_directory/${cactvs_version}/csts_beagle -freact_chunk_all_nodb.tcl ${inputs_directory}/$reactant_list_basename $file_index $base_name $name_modifier > $outputs_directory/out_${beginning_name_modifier}${file_index}.txt

#execute copying of the outputs and results
echo "$copy_results"
eval $copy_results
echo "$clean_up_staged"
eval $clean_up_staged
sleep 100
