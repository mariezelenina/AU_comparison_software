#!/bin/bash
# Usage: bash run_pyfeat_parallel.sh folder1 folder2 folder3 ...

# this will make the code exit fast if something is wrong (so that we don't waste time)
# -e: stop on any error; -u: stop on undefined variables; -o pipefail: stop on hidden pipeline failures
set -euo pipefail

PYFEAT_SCRIPT="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/mycode/AU_comparison_software/run_pyfeat/pyfeat_process_file.py"
export PYFEAT_SCRIPT

PYFEAT_DEBUG="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/mycode/AU_comparison_software/run_pyfeat/python_debug.py"
export PYFEAT_DEBUG

# take input params
folder_to_process="$1"
whichpyfeat="$2"
export whichpyfeat
framesmasterfile="$3"
input_root="$4"
path_out="$5"

path_temp="$path_out/temp/"
mkdir -p "$path_temp"
export path_out
export path_temp

# create out folder if it doesn't exist already
mkdir -p "$path_out"
mkdir -p "$path_temp"

# Count how many cores the laptop has. 
# Use total cores - 2 (just to be safe on the RAM usage side). Clamp to min on 1 core (can't run on 0 or -1)
total_cores=$(sysctl -n hw.ncpu)
cores=$(( total_cores - 1 ))
# make sure at least 1 core is used
cores=$(( cores < 1 ? 1 : cores ))

# start "timer"
SECONDS=0
start_time=$(date '+%Y-%m-%d %H:%M:%S')

# START
echo
echo "START pyfeat $whichpyfeat"
echo "Using $cores CPU cores"

# process folder
echo; echo; echo; echo
echo "PROCESSING FOLDER: $folder_to_process"
    
# count how many files are in my folder 
shopt -s nullglob # some magic that prevents errors when no files match the  pattern
files=( "$folder_to_process"/*.mp4 )
total=${#files[@]}
shopt -u nullglob

echo "Found $total mp4 video files in folder"

# if input dir is empty, say so and quit
if (( total == 0 )); then
	echo "No input files found in $folder_to_process - skipping"
	exit 0
fi

# make folder to save output
folder_name=$(basename "$folder_to_process")
out_dir="$path_out/$folder_name"
export out_dir 
mkdir -p "$out_dir"

# printf feeds all files in the folder as arguments to the parallel function
printf "%s\n" "${files[@]}" | parallel --jobs "$cores" --progress --halt soon,fail=1 \
'
  echo "DEBUG: starting parallel script"
	FILE="{}" # process current file
	echo
	echo "Starting file $FILE"
		
	# figure out the name to save my output real quick
 	base=$(basename "$FILE")
	stem="${base%.*}"
		
	out_name="$out_dir/output_pyfeat_$whichpyfeat_${stem}.csv"

	# actually run pyfeat

	echo
	echo "Starting pyfeat in python"
	echo "DEBUG: Trying to run: python"

	#python3 "$PYFEAT_DEBUG"

	python3 -u "$PYFEAT_SCRIPT" "$FILE" "$out_dir" "$out_name" "$path_temp" "$whichpyfeat"

	# file processed  
	echo; echo "Processed file $FILE"
	'

# concatinate all temp frames info from separate jobs (files) into master file
cat "$path_temp"/temp_frames_pyfeat_*.csv >> "$frames_file"
	
# done with this folder
echo; echo "Processed all files in folder $folder_to_process!"

# remove temp files, to save space
rm -rf "$path_temp"/*
	
# count how many files have been processed
out_files=( "$path_out"/"$folder_name"/output_pyfeat_"$whichpyfeat"*.csv )
out_total=${#out_files[@]}
echo; echo "OUTPUT FOLDER HAS $out_total FILES. INPUT FOLDER HAD  $total VIDEOS."
	
echo; echo "ALL DONE"; echo

# print how much time it took
echo
elapsed=$SECONDS
printf "Total runtime: %02dh:%02dm:%02ds\n" \
  $((elapsed/3600)) \
  $((elapsed%3600/60)) \
  $((elapsed%60))

# also print when exactly it finished
echo
echo "Started at: $start_time"
echo "Finished at: $(date '+%Y-%m-%d %H:%M:%S')"
