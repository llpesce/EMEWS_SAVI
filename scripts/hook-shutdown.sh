#!/bin/bash
set -eu
#export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
source "${EMEWS_PROJECT_ROOT}/EMEWS_SAVI.conf"

# Location of the base SAVI installation currently in "${EMEWS_PROJECT_ROOT}/EMEWS_SAVI.conf"
#SAVI_SRC_ROOT="/lustre/beagle2/lpBuild/CANDLE/SAVI/savi_trial_run"
# Note that the scripts are not part of the CACTVS installation see README

echo "%%%START OF SHUTDOWN HOOK " $(date +%F" "%T) "%%%"

if chmod -R +rwX $base_name && rm -rf $base_name; then
echo "tmpdir on $HOSTNAME cleaned up"
else
echo "ERROR: tmpdir on $HOSTNAME FAILED to get cleaned "
fi

echo "%%%END OF SHUTDOWN HOOK " $(date +%F" "%T) "%%%"


