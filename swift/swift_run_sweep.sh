#! /usr/bin/env bash
# Expected name of experiment (AKA, the current campaign, swift run, SAVI db run...)
# All the configuration that is system specific is in ../EMEWS_SAVI.conf

set -eu

if [ "$#" -ne 1 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} EXPERIMENT_ID (e.g. ${script_name} experiment_1)"
  exit 1
fi


# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
#export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
# source some utility functions used by EMEWS in this script
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"
source "${EMEWS_PROJECT_ROOT}/EMEWS_SAVI.conf" #Machine or system and SAVI installation configuration
source "${EMEWS_PROJECT_ROOT}/EMEWS_SAVI.run.conf" #Configuration of this specific run

export EXPID=$1
export TURBINE_OUTPUT=$EMEWS_PROJECT_ROOT/experiments/$EXPID
check_directory_exists

# All the following variables have been moved to config file in $EMEWS_PROJECT_ROOT
# TODO edit the number of processes as required.
#export PROCS=2

# TODO edit QUEUE, WALLTIME, PPN, AND TURNBINE_JOBNAME
# as required. Note that QUEUE, WALLTIME, PPN, AND TURNBINE_JOBNAME will
# be ignored if the MACHINE variable (see below) is not set.
#export QUEUE=batch
#export WALLTIME=05:00:00
#export PPN=2
export TURBINE_JOBNAME="${EXPID}_job"

# if R cannot be found, then these will need to be
# uncommented and set correctly.
# export R_HOME=/path/to/R
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R_HOME/lib
# if python packages can't be found, then uncommited and set this
# export PYTHONPATH=/path/to/python/packages


# TODO edit command line arguments as appropriate
# for your run. Note that the default $* will pass all of this script's
# command line arguments to the swift script.
CMD_LINE_ARGS="$*"

# set machine to your schedule type (e.g. pbs, slurm, cobalt, cray etc.),
# or empty for an immediate non-queued unscheduled run
#MACHINE="cray"

if [ -n "$MACHINE" ]; then
  MACHINE="-m $MACHINE"
fi

# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=("VAR_1" "VAR_2")
USER_VARS=()
# log variables and script to to TURBINE_OUTPUT directory
log_script

#Introduce the two hooks that allow swift to run one preparation and clean up function per node
#export TURBINE_LEADER_HOOK_STARTUP=" puts [ exec ${EMEWS_PROJECT_ROOT}/scripts/hook-startup.sh ]"
export TURBINE_LEADER_HOOK_STARTUP="c::sync_exec {} {} {} ${EMEWS_PROJECT_ROOT}/scripts/hook-startup.sh"
#export TURBINE_LEADER_HOOK_SHUTDOWN=" puts [ exec ${EMEWS_PROJECT_ROOT}/scripts/hook-shutdown.sh ]"
export TURBINE_LEADER_HOOK_SHUTDOWN="c::sync_exec {} {} {} ${EMEWS_PROJECT_ROOT}/scripts/hook-shutdown.sh"

#write out what is being used.
echo "Swift/T PATH entries:"
which stc turbine


# echo's anything following this standard out
set -x

stc -u  $EMEWS_PROJECT_ROOT/swift/swift_run_sweep.swift

# We do not need to use 'turbine -e' on Cray:
#   Swift/T now uses qsub -V
turbine -m cray           \
        -i ${EMEWS_PROJECT_ROOT}/scripts/hook-init.sh \
        $EMEWS_PROJECT_ROOT/swift/swift_run_sweep.tic \
        -f="$EMEWS_PROJECT_ROOT/data/input.txt" \
        $CMD_LINE_ARGS 

#        -f="$EMEWS_PROJECT_ROOT/data/new.input" \

#swift-t -n $PROCS $MACHINE \
#    -e EMEWS_PROJECT_ROOT="$EMEWS_PROJECT_ROOT" \
#    -e TURBINE_LEADER_HOOK_STARTUP -e TURBINE_LEADER_HOOK_SHUTDOWN \
#    -e TURBINE_OUTPUT="$TURBINE_OUTPUT" \
#    -p $EMEWS_PROJECT_ROOT/swift/swift_run_sweep.swift \
#    -f="$EMEWS_PROJECT_ROOT/data/input.txt" $CMD_LINE_ARGS 
