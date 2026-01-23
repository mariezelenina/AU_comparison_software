# AU_comparison_software
Code for the comparison of FEX software on prediction of pain-specific Action Units.

THIS ALL MAY BE ALSO USEFUL IF WE WANT TO PROCESS ALL COLD AND/OR SHOCK VIDEOS (I now have only processed heat).

All of this is tested on MacOS. It shouldn't be too different for Linux. No idea about Windows.

# RUN PREPROCESSING OF DATA WITH VARIOUS SOFTWARE
(assuming they are all installed - refer to their own documentation)

## First steps

-- Make sure conda is installed

I like using miniconda, it gets everything done and is simple

installation instructions: https://www.anaconda.com/docs/getting-started/miniconda/install


## ---> Libreface
(assumes data are in folders, one per participant, doesn't matter how many videos in each participant folder)

0. Installation instructions here (by software authors): https://github.com/ihp-lab/LibreFace.
Paper: https://arxiv.org/pdf/2308.10713.

1. go to folder run_libreface

cd run_libreface

2. Create and activate the conda environment:

conda env create -f env_run_libreface.yml
conda activate env_libreface_new

might also need
conda install -c conda-forge parallel

3. Make a list of all folders you have

find path/to/data -mindepth 1 -maxdepth 1 -type d | sort > all_folders.txt

4. Make a master csv to track how many frames are processed/dropped per video

echo "name, total_frames, processed_frames" > frames_libreface.csv

5. Edit paths in all .sh files

6. Run processing in batches, using a bash script.\

(a) simple option - no log file:
bash run_batch.sh 1 10
- will run all videos in folders 1 to 10

(b) option to copy all outputs into log file:
bash run_batch.sh 1 10 2>&1 | tee -a mylog_libreface.txt


## ---> PyFeat

0. Installation instructions here (by software authors): https://py-feat.org/pages/installation.html
Paper: https://arxiv.org/pdf/2104.03509

2. go to folder run_pyfeat

cd run_pyfeat

3. Create and activate the conda environment:

(prior to doing that, make sure you deactivate the libreface one if you'd had it activated: conda deactivate)

conda env create -f env_pyfeat.yml
conda activate env_fer_pyfeat

4. 








