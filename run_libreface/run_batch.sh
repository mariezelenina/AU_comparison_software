#!/bin/bash
# Usage: bash run_batch.sh START END
# Example: bash run_batch.sh 11 20

set -euo pipefail

# input: start and end folders id
START="$1"
END="$2"
 
# set path to where files are:
FOLDER_LIST="all_folders.txt"
SCRIPT="run_libreface_parallel.sh"

SERVER_PATH="/Volumes/Shares/NCCIH/LYA/LYA_Lab/FEX_Substudy1/BIDS_dataset/code/FEX_AU_comparison_Marie/FEX_AU_outputs/outputs_libreface/"
LOCAL_PATH_OUTPUTS="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/outputs/libreface/temp_outputs_to_rsync"
LOCAL_PATH_WEIGHTS="/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/mycode/AU_comparison_software/run_libreface/weights_libreface"

# basic checks
# basic checks
if [[ ! -f "$FOLDER_LIST" ]]; then
  echo "Folder list not found: $FOLDER_LIST"
  exit 1
fi

if (( START < 1 || END < START )); then
  echo "Invalid range: START=$START END=$END"
  exit 1
fi

# how many folders in batch
BATCH_SIZE=$(( END - START + 1 ))

# add selected folders to array
BATCH_FOLDERS=()
while IFS= read -r line; do
  BATCH_FOLDERS+=("$line")
done < <(sed -n "${START},${END}p" "$FOLDER_LIST")

# 1. Run libreface script:
echo
echo
echo "RUNNING $BATCH_SIZE FOLDERS $START TO $END FROM $FOLDER_LIST"
echo "STARTED AT: $(date)"
echo

caffeinate -dimsu bash -c '
i=1
total=$#

for folder in "$@"; do
  echo
  echo "=============================================="
  echo "Processing folder $i out of $total"
  echo "Folder: $folder"
  echo "=============================================="
  bash "'"$SCRIPT"'" "$folder"
  ((i++))
done
' bash "${BATCH_FOLDERS[@]}"

echo; echo; echo "DONE WITH FOLDERS $START TO $END"

# 2. Rsync:
echo; echo "START RSYNC"; echo

rsync -av --progress "$LOCAL_PATH_OUTPUTS"/sub* "$SERVER_PATH"
rsync -av --progress "$LOCAL_PATH_WEIGHTS" "$SERVER_PATH"

echo; echo "DONE RSYNC"; echo


# 3. Delete:
echo; echo "START DELETE"; echo
rm -rf "${LOCAL_PATH_OUTPUTS:?}"/*

echo; echo "DONE DELETE"; echo
echo; echo "ALL DONE: FOLDERS $START TO $END"; echo


