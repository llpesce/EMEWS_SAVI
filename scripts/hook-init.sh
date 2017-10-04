#!/bin/sh

# HOOK INIT
# This script is triggered by turbine -i
# It runs after TURBINE_OUTPUT is determined
# We need to copy these scripts to /lustre so they can be
#    accessed at run time on the compute nodes

cp -v ${EMEWS_PROJECT_ROOT}/scripts/hook-startup.sh ${EMEWS_PROJECT_ROOT}/scripts/hook-shutdown.sh $TURBINE_OUTPUT
