#!/bin/bash
# Usage: bash run_pyfeat_parallel.sh folder1 folder2 folder3 ...

# this will make the code exit fast if something is wrong (so that we don't waste time)
# -e: stop on any error; -u: stop on undefined variables; -o pipefail: stop on hidden pipeline failures
set -euo pipefail
 
# specify paths to where data is and where to save it

# specify paths on server
#input_root="/Volumes/Shares/NCCIH/LYA/LYA_Lab/FEX_Substudy1/BIDS_dataset/derivatives/video/heat/Non_EMG"
#path_out="/Volumes/Shares/NCCIH/LYA/LYA_Lab/FEX_Substudy1/BIDS_dataset/code/FEX_AU_comparison_Marie/FEX_AU_outputs/outputs_pyfeat_$WHICHPYFEAT/"

# specify local paths
input_root="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/mydata/testdata"
path_out="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/outputs/outputs_pyfeat_svm/"

# take input params
folder_to_process="$1"
whichpyfeat="$2"
export whichpyfeat

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

# csv file to keep track of frames
frames_file="$path_out/frames_pyfeat_$whichpyfeat.csv"

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
	continue
fi

# make folder to save output
folder_name=$(basename "$folder_to_process")
out_dir="$path_out/$folder_name"
export out_dir 
mkdir -p "$out_dir"
	
# printf feeds all files in the folder as arguments to the parallel function
printf "%s\n" "${files[@]}" | parallel --jobs "$cores" --bar --halt soon,fail=1  \
'
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
	frames_result=$(python pyfeat_process_file.py "$FILE" "$out_name" "$whichpyfeat")
	frames_tot=$(echo "$frames_result" | cut -f1)
	frames_done=$(echo "$frames_result" | cut -f2)

	# temp save frames data
		
	# --> define path to temp frames file
	frames_temp_file="$path_temp/temp_frames_${stem}.csv"
		
	# --> write frame info of this file into temp file
	echo "$stem, $frames_tot, $frames_done" > "$frames_temp_file"

	# file processed  
	echo; echo "Processed file $FILE"
	'

# concatinate all temp frames info from separate jobs (files) into master file
cat "$path_temp"/temp_frames_*.csv >> "$frames_file"
	
# done with this folder
echo; echo "Processed all files in folder $folder_to_process!"

# remove temp files, to save space
rm -rf "$path_temp"/*
	
# count how many files have been processed
out_files=( "$path_out"/"$folder_name"/output_pyfeat_"$whichpyfeat"*.csv )
out_total=${#out_files[@]}
echo; echo "OUTPUT FOLDER HAS $out_total FILES. INPUT FOLDER HAD  $total VIDEOS."

# remove temp folder 
rm -rf path_temp
	
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
