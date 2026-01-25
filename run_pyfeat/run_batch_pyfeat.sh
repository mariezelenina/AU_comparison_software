#!/bin/bash
# Usage: bash run_batch.sh START END
# Example: bash run_batch.sh 11 20

set -euo pipefail

# input: start and end folders id
START="$1"
END="$2"
WHICHPYFEAT="$3"
export WHICHPYFEAT

# set path to where files are:
# SERVER_PATH_INPUTS="/Volumes/Shares/NCCIH/LYA/LYA_Lab/FEX_Substudy1/BIDS_dataset/derivatives/video/heat/Non_EMG"
SERVER_PATH_INPUTS='/Users/zeleninam2/Documents/1_projects/1_FACE_PAIN/proj_fex_software_comparison/mydata/testdata'
find $SERVER_PATH_INPUTS -mindepth 1 -maxdepth 1 -type d | sort > all_folders.txt
FOLDER_LIST="all_folders.txt"

# which script to run
SCRIPT="run_pyfeat_parallel_bash.sh"
export SCRIPT

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
echo "------- pyfeat algorithm: $WHICHPYFEAT --------"
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
  echo "SCRIPT=[$SCRIPT]"
  echo "folder=[$folder]"
  echo "WHICHPYFEAT=[$WHICHPYFEAT]"
  bash "$SCRIPT" "$folder" "$WHICHPYFEAT"
  ((i++))
done
' bash "${BATCH_FOLDERS[@]}"

echo; echo; echo "ALL DONE: FOLDERS $START TO $END"; echo