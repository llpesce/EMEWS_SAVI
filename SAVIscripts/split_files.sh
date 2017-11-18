#!/usr/bin/bash

# Configuration stuff

fspec=$1
num_files=$2

# Work out lines per file.

total_lines=$(wc -l <${fspec})
echo $total_lines
((lines_per_file = (total_lines + num_files - 1) / num_files))
echo $lines_per_file

# Split the actual file, maintaining lines.
outPref="savi_scale_up_inputs_by10/"$(basename $fspec)

split --lines=${lines_per_file} ${fspec} -d ${outPref}

# Debug information

echo "Total lines     = ${total_lines}"
echo "Lines  per file = ${lines_per_file}"    
wc -l savi_scale_up_inputs_by10/*
