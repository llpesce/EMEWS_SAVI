EMEWS project template
-----------------------

You have just created an EMEWS project.
The project consists of the following directories:

```
SAVI/
  data/
  ext/
  etc/
  python/
    test/
  R/
    test/
  scripts/
  swift/
  README.md
```
The directories are intended to contain the following:

 * `data` - model input etc. data
 * `etc` - additional code used by EMEWS
 * `ext` - swift-t extensions such as eqpy, eqr
 * `python` - python code (e.g. model exploration algorithms written in python)
 * `python/test` - tests of the python code
 * `R` - R code (e.g. model exploration algorithms written R)
 * `R/test` - tests of the R code
 * `scripts` - any necessary scripts (e.g. scripts to launch a model), excluding
    scripts used to run the workflow.
 * `swift` - swift code

USE and ISSUES
EMEWS_PROJECT_ROOT refers to the directory where this file is. It is set as a variable in
$EMEWS_PROJECT_ROOT/swift/swift_run_sweep.sh
swift_run_sweep.sh is the master program that initializes the swift-t sweep. it is generally called as

$EMEWS_PROJECT_ROOT/swift/swift_run_sweep.sh <run_ID>

The sweep will execute the runs specified in 

$EMEWS_PROJECT_ROOT/data/input.txt
That file contains inherently local information and need to be adapted to the local storage

It will use the wrapper 
$EMEWS_PROJECT_ROOT/scripts/product_run.sh
That wrapper has harcoded the location of the "savi_trial_run" folder:
SAVI_SRC_ROOT="/lustre/beagle2/lpBuild/CANDLE/SAVI/savi_trial_run"
which is more or less exactly what Yuri provided me. With two exceptions that are part of this repo:
SAVIscripts/launch_product_run_swift_beagle.sh
SAVIscripts/csts_beagle

the former should be dropped into the "savi_trial_run"/scripts folder, the latter into theapps/cactvs3.4.6.3 folder under "savi_trial_run"/apps

I haven't tests the main program because the staging tests of the wrappers failed. 


