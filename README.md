# AU_comparison_software
Code for the comparison of FEX software on prediction of pain-specific Action Units

# RUN PREPROCESSING OF DATA WITH VARIOUS SOFTWARE
(assuming they are all installed - refer to their own documentation)

## ---> Libreface
(assumes data are in folders, one per participant, doesn't matter how many videos in each participant folder)

1. Create and activate the conda environment:

conda env create -f env_run_libreface.yml
conda activate env_libreface_new

might also need
conda install -c conda-forge parallel

2. Make a list of all folders you have

find path/to/data -mindepth 1 -maxdepth 1 -type d | sort > all_folders.txt

3. Make a master csv to track how many frames are processed/dropped per video

echo "name, total_frames, processed_frames" > frames_libreface.csv

4. Edit paths in all .sh files

5. Run processing in batches.

simple option - no log file:
bash run_batch.sh 1 10
- will run all videos in folders 1 to 10

option to copy all outputs into log file:
bash run_batch.sh 1 10 2>&1 | tee -a mylog_libreface.txt


