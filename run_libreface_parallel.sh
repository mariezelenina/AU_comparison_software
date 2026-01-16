#!/bin/bash
# this will make the code exit fast if something is wrong (so that we don't waste time)
# -e: stop on any error; -u: stop on undefined variables; -o pipefail: stop on hidden pipeline failures
set -euo pipefail
 
# paths to where data is and where to save it - obviously change it to where you store the data (or to path on server)
 
#path_to_inputfiles="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/mydata/random_10_vids_1"
#path_out="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/outputs/libreface/experiments"

# coded to take them from command line
# TODO code them for default, after I decide whether to access files locally or on the server

path_to_inputfiles="$1"
path_out="$2"

# check if input dir  exists
if [[ ! -d "$path_to_inputfiles" ]]; then
  echo "Input directory $input_dir does not exist!"
  exit 1
fi

# create out folder if it doesn't exist already
mkdir -p "$path_out"

# this will make the code exit fast if something is wrong (so that we don't waste time)
# -e: stop on any error; -u: stop on undefined variables; -o pipefail: stop on

# count how many files are in my folder 
files=( "$path_to_inputfiles"/* )
total=${#files[@]}

# Count how many cores the laptop has. 
# Use total cores - 2 (just to be safe on the RAM usage side). Clamp to min on 1 core (can't run on 0 or -1)
total_cores=$(sysctl -n hw.ncpu)
cores=$(( total_cores > 2 ? total_cores - 2 : 1 ))

# START

echo
echo "START"
echo "Found $total files to process"
echo "Using $cores CPU cores"


# if input dir is empty, say so and quit
if (( total == 0 )); then
  echo "No input files found in $path_to_inputfiles"
  exit 1
fi

# start "timer" - to later print how much time it took to run the whole thing
SECONDS=0

# IN PARALLEL, run libreface on every file in the folder we specified above. Save all results to the dir in path_out

# tutorial on GNU parallel here: https://www.gnu.org/software/parallel/
# an alternative (simpler?) way would be to use xargs. It is simpler - it feeds arguments to the command line in parallel -
# but it doesn't "truly" manage parallel jobs.
# I couldn't find a way to realistically track progress with xargs (it can output what file it's working on now, but not how much stuff is left).
# it was important for me to track progress because tasks are long, so GNU parallel it is.
# install thorugh homebrew, brew install parallel

parallel \
  --jobs "$cores" \
  --bar \
  --line-buffer \
  --halt soon,fail=1 \
  '
    echo
    echo "Starting {}"

    # figure out the name to save my output real quick
    base=$(basename {})
    stem="${base%.*}"
    output_file="$path_out/output_libreface_${stem}.csv"

    # actually run libreface 
    libreface --input_path="{}" --output_path="$output_file"

    echo "Finished {}"
    echo

  ' ::: "${files[@]}"


echo; echo "ALL DONE"; echo

# count how many files have been processed
out_files=( "$path_out"/output_libreface_*.csv )
out_total=${#out_files[@]}
echo "Output folder has $out_total files. Input folder had $total videos."

# print how much time it took
echo
elapsed=$SECONDS
printf "Total runtime: %02dh:%02dm:%02ds\n" \
  $((elapsed/3600)) \
  $((elapsed%3600/60)) \
  $((elapsed%60))
