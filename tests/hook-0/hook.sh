#!/bin/bash
set -eu

# Simplest test of hook functionality

SWIFT_T=/soft/swift-t/compute/SAVI-2018-01-31
PATH=$SWIFT_T/stc/bin:$PATH
PATH=$SWIFT_T/turbine/bin:$PATH

# pt ~/FS/sfw/beagle/compute/swift-t/stc/bin
# pt ~/FS/sfw/beagle/compute/swift-t/turbine/bin

export TURBINE_OUTPUT=$(pwd)/OutPut
export PROJECT=CI-CCR000040
export QUEUE=batch
export TURBINE_DIRECTIVE='#PBS -l advres=stevens.4151'

# export QUEUE=development
# export PROJECT=CI-MCB000175 <- DEAD

export TURBINE_LEADER_HOOK_STARTUP=" puts [ exec ./hook-startup.sh ]"
export TURBINE_LEADER_HOOK_SHUTDOWN="puts [ exec ./hook-shutdown.sh ]"

stc -u hi.swift
turbine -m cray -i ./hook-init.sh hi.tic
