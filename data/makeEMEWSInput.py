# script to generate input for an EMEWS SAVI run

import sys
import os
import re

#Location of SAVI files on this specific system
SAVIRoot="/lustre/beagle2/lpBuild/CANDLE/SAVI/savi_trial_run"
bdbFile="/lustre/beagle2/lpBuild/CANDLE/SAVI/savi_trial_run/inputs/building_block_file/sial_bb_20160407.bdb"

inputsDir = sys.argv[1]
EMEWSInput = sys.argv[2]

print "Executing script ", sys.argv[0]
print "Current working directory ", os.getcwd()
print "Content of sys.argv ",sys.argv
print "length of sys.argv ", len(sys.argv)
print "location of SAVI installation", SAVIRoot
print "location of bdbfile", bdbFile
print "Location of input file", inputsDir
print "Name of EMEWS input file that will be created", EMEWSInput 

p = re.compile(r"(reactant_list.*\.infile_)([0-9]+$)")

EM = open(EMEWSInput,"w")

for f in os.listdir(inputsDir):
    m = p.match(f)
    if m:
        root_name = inputsDir+"/"+m.group(1)
        id=m.group(2)
        EM.write(id+" "+SAVIRoot+" "+bdbFile+" "+root_name+" "+id+"\n")


EM.close()
