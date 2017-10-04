#!/bin/bash

set -eu

#export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
source "${EMEWS_PROJECT_ROOT}/EMEWS_SAVI.conf"

# Location of the base SAVI installation currently in "${EMEWS_PROJECT_ROOT}/EMEWS_SAVI.conf"
#SAVI_SRC_ROOT="/lustre/beagle2/lpBuild/CANDLE/SAVI/savi_trial_run"
# Note that the scripts are not part of the CACTVS installation see README
base_name_sub_script="${base_name}/$sub_script"
#Define the version of the package cactvus to use, the location of local storage for the run and the cactvs package

CMD="sh $base_name_sub_script $cactvs_version $base_name $cactvs_tar "

#Wait for the startup-hook to release the node
while [ ! -d $nodeUnLock ]; do
  sleep 2
done

echo $CMD

# Check for an optional timeout threshold in seconds. If the duration of the
# model run as executed below, takes longer that this threshhold
# then the run will be aborted. Note that the "timeout" command
# must be supported by executing OS.

# The timeout argument is optional. By default the "run_model" swift
# app fuction sends 3 arguments, and no timeout value is set. If there
# is a 4th (the TIMEOUT_ARG_INDEX) argument, we use that as the timeout value.

# !!! IF YOU CHANGE THE NUMBER OF ARGUMENTS PASSED TO THIS SCRIPT, YOU MUST
# CHANGE THE TIMEOUT_ARG_INDEX !!!
TIMEOUT_ARG_INDEX=4
TIMEOUT=""
if [[ $# ==  $TIMEOUT_ARG_INDEX ]]
then
	TIMEOUT=${!TIMEOUT_ARG_INDEX}
fi

TIMEOUT_CMD=""
if [ -n "$TIMEOUT" ]; then
  TIMEOUT_CMD="timeout $TIMEOUT"
fi

# Set param_line from the first argument to this script
# param_line is the string containing the model parameters for a run.
param_line=$1

# Set emews_root to the root directory of the project (i.e. the directory
# that contains the scripts, swift, etc. directories and files)
emews_root=$2

# Each model run, runs in its own "instance" directory
# Set instance_directory to that and cd into it.
instance_directory=$3
cd $instance_directory

#Performance Log files will be produced 5% of the time
# in the $instance_directory
sleep $((RANDOM % 11)) # wait some random amount of time between 0 and 10 seconds 
if ps ax | grep -v grep | grep top > /dev/null
then
 echo "top is already running on this node"
else
  MOD=20
  number=$(($RANDOM % $MOD))
  if [ "$number" -eq 0 ]; then
    #Performance logs
    top -b -d 600.00 -n 60 -u $(whoami) >${instance_directory}/top.log &
  fi
fi



# TODO: Define the command to run the model
MODEL_CMD="$CMD $param_line"

# Turn bash error checking off. This is
# required to properly handle the model execution return value
# the optional timeout.
set +e

failedlog="$instance_directory}/failed_run.log" #each run of the swarm will log its failure (if any)
[ -e "$failedlog" ] && rm $failedlog #If for any reason there is a failure log, remove it

$TIMEOUT_CMD $MODEL_CMD
# $? is the exit status of the most recently executed command (i.e the
# line above)
RES=$?
if [ "$RES" -ne 0 ]; then
	if [ "$RES" == 124 ]; then
    echo "---> Timeout error in $MODEL_CMD" >>$failedlog
  else
	   echo "---> Error in $MODEL_CMD" >>$failedlog
  fi
fi

exit 0 #never return an error exit value, let the rest of the swarm run
