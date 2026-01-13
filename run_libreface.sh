#!/bin/bash

# paths to where data is and where to save it - obviously change it to where you store the data (or to path on server)
 
path_to_inputfiles="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/mydata/random_10_vids"
path_out="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/outputs/libreface/experiments"

# create out folder if it doesn't exist already
mkdir -p "$path_out"

# this will make the code exit fast if something is wrong (so that we don't waste time)
# -e: stop on any error; -u: stop on undefined variables; -o pipefail: stop on hidden pipeline failures

set -euo pipefail


# count how many files are in my folder (for future iterations counts)

files=( "$path_to_inputfiles"/* )
total=${#files[@]}

echo
echo "START"
echo "Found $total files to process"

# if input dir is empty, say so and quit

if (( total == 0 )); then
  echo "No input files found in $path_to_inputfiles"
  exit 1
fi

# start "timer" - to later print how much time it took to run the whole thing
SECONDS=0


# run libreface on every file in the folder we specified above. Save all results to the dir in path_out

i=0
for filename in "${files[@]}"; do  
    # figure out the name to save my output real quick
    base=$(basename "$filename")
    stem="${base%.*}"
    output_file="$path_out/output_libreface_${stem}.csv"
    
    # iterate through files in the input folder
    ((i++))
    echo; echo "Processing file $i out of $total: $base"
    libreface --input_path="$filename" --output_path="$output_file"
done

echo; echo "ALL DONE"; echo

# count how many files have been processed

out_files=( "$path_out"/output_libreface_*.csv* )
out_total=${#out_files[@]}
echo "Output folder has $out_total files. Input folder had $total videos."

# print how much time it took
echo
elapsed=$SECONDS
printf "Total runtime: %02dh:%02dm:%02ds\n" \
  $((elapsed/3600)) \
  $((elapsed%3600/60)) \
  $((elapsed%60))
