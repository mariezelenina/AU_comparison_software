#!/bin/bash
# Usage: bash run_libreface_parallel.sh folder1 folder2 folder3 ...

# this will make the code exit fast if something is wrong (so that we don't waste time)
# -e: stop on any error; -u: stop on undefined variables; -o pipefail: stop on hidden pipeline failures
set -euo pipefail
 
# ways to specify paths to where data is and where to save it

# option 1: manually, for random testing vids:
#path_to_inputfiles="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/mydata/random_10_vids_1"
#path_out="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/outputs/libreface/experiments"

# option 2: coded to take them from command line
# path_to_inputfiles="$1"
# path_out="$2"

# option 3 - FINAL TO MAKE EVERYTHING RUN - specify paths on server (in) and local temp folder (out)
input_root="/Volumes/Shares/NCCIH/LYA/LYA_Lab/FEX_Substudy1/BIDS_dataset/derivatives/video/heat/Non_EMG"
path_out="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/outputs/libreface/temp_outputs_to_rsync"
path_temp="$path_out/temp"
mkdir -p "$path_temp"
export path_out
export path_temp

# create out folder if it doesn't exist already
mkdir -p "$path_out"
mkdir -p "$path_temp"

# Count how many cores the laptop has. 
# Use total cores - 2 (just to be safe on the RAM usage side). Clamp to min on 1 core (can't run on 0 or -1)
total_cores=$(sysctl -n hw.ncpu)
cores=$(( total_cores / 2 ))
# make sure at least 1 core is used
cores=$(( cores < 1 ? 1 : cores ))

# csv file to keep track of frames
frames_file="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/outputs/libreface/frames_libreface.csv"

# start "timer"
SECONDS=0
start_time=$(date '+%Y-%m-%d %H:%M:%S')

# START
echo
echo "START"
echo "Using $cores CPU cores"

# process each folder
for FOLDER in "$@"; do
    echo; echo; echo; echo
    echo "PROCESSING FOLDER: $FOLDER"
    
	# count how many files are in my folder 
    shopt -s nullglob # some magic that prevents errors when no files match the  pattern
    files=( "$FOLDER"/*.mp4 )
    total=${#files[@]}
    shopt -u nullglob

    echo "Found $total mp4 video files in folder"

	# if input dir is empty, say so and quit
	if (( total == 0 )); then
	  echo "No input files found in $FOLDER - skipping"
	  exit 0
	fi

	# make local temp folder to save output
	folder_name=$(basename "$FOLDER")
	local_out_dir="$path_out/$folder_name"
	export local_out_dir 
	mkdir -p "$local_out_dir"
	
	# printf feeds all files in the folder as arguments to the parallel function
	printf "%s\n" "${files[@]}" | parallel --jobs "$cores" --bar --halt soon,fail=1  \
	'
		FILE="{}" # process current file
		echo
		echo "Starting file $FILE"
		
	    # figure out the name to save my output real quick
 	    base=$(basename "$FILE")
	    stem="${base%.*}"
		
		out_name="$local_out_dir/output_libreface_${stem}.csv"

		# actually run libreface
		libreface --input_path="$FILE" --output_path="$out_name" --temp="$path_temp" 

		# temp save frames data
		
		# --> define path to temp frames file
		frames_temp_file="$path_temp/temp_frames_${stem}.csv"

		# --> total frames in the file = how many .png images are in the corresponding temp folder
		frames_tot=$(find "$path_temp/$stem" -maxdepth 1 -type f -name "frame_*.png" ! -name "*aligned*" | wc -l)

		# --> frames processed = data rows in the output file 
		frames_done=$(tail -n +2 "$out_name" | wc -l)
		
		# --> write frame info of this file into temp file
		echo "$stem, $frames_tot, $frames_done" > "$frames_temp_file"

		# file processed  
		echo; echo "Processed file $FILE"
		'

	# concatinate all temp frames info from separate jobs (files) into master file
	cat "$path_temp"/temp_frames_*.csv >> "$frames_file"
	
	# done with this folder
	echo; echo "Processed all files in folder $FOLDER!"

	# remove temp files, to save space
	rm -rf "$path_temp"/*
	
	# count how many files have been processed
	out_files=( "$path_out/$folder_name"/output_libreface_*.csv )
	out_total=${#out_files[@]}
	echo; echo "OUTPUT FOLDER HAS $out_total FILES. INPUT FOLDER HAD  $total VIDEOS."
	
done 

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
