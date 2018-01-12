#!/bin/bash
set -eu
#export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/../ ; /bin/pwd )
source "${EMEWS_PROJECT_ROOT}/EMEWS_SAVI.conf"
nodeid=$(hostname)

# Location of the base SAVI installation currently in "${EMEWS_PROJECT_ROOT}/EMEWS_SAVI.conf"
#SAVI_SRC_ROOT="/lustre/beagle2/lpBuild/CANDLE/SAVI/savi_trial_run"
# Note that the scripts are not part of the CACTVS installation see README

echo "%%%SHUTDOWN_HOOK: START ON $nodeid AT " $(date +%F" "%T) "%%%"

if chmod -R +rwX $base_name && rm -rf $base_name; then
echo "%%%SHUTDOWN_HOOK: ON $nodeid : tmpdir on $nodeid cleaned up"
else
echo "%%%SHUTDOWN_HOOK: ERROR ON $nodeid : tmpdir on $nodeid FAILED to get cleaned"
fi

echo "%%%SHUTDOWN_HOOK: END ON $nodeid AT " $(date +%F" "%T) "%%%"

exit 0


