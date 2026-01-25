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

## Data organization

-- All code assumes data are in folders, one per participant, doesn't matter how many videos in each participant folder.

-- Make a list of all folders you have

`find path/to/data -mindepth 1 -maxdepth 1 -type d | sort > all_folders.txt`

## ---> Libreface

### Dependencies:
python=3.9.20, ffmpeg, cmake, jupyter, parallel

or create and activate the conda environment:

`conda env create -f env_run_libreface.yml`
`conda activate env_libreface_new`

(if there is a problem with parallel, install it separately: `conda install -c conda-forge parallel`)

### HOWTO:

0. Installation instructions here (by software authors): https://github.com/ihp-lab/LibreFace.
Paper: https://arxiv.org/pdf/2308.10713.

1. go to folder run_libreface

`cd run_libreface`

2. Make a master csv to track how many frames are processed/dropped per video

`echo "name, total_frames, processed_frames" > frames_libreface.csv`

3. Edit paths in all .sh files

4. Run processing in batches, using a bash script.

(a) simple option - no log file:

`bash run_batch.sh 1 10`
- will run all videos in folders 1 to 10
- calls another bash script, `run_libreface_parallel`, which used n-2 availale cores to process data

(b) option to copy all outputs into log file:

`bash run_batch.sh 1 10 2>&1 | tee -a mylog_libreface.txt` 


## ---> PyFeat

### Dependencies:
pytables, python=3.11, jupyter notebook, scipy=1.11.4, csv, sys, logging.

or create and activate conda env from yaml:

`conda env create -f env_pyfeat.yml`
`conda activate env_fer_pyfeat`

### HOWTO:
0. Installation instructions here (by software authors): https://py-feat.org/pages/installation.html
Paper: https://arxiv.org/pdf/2104.03509

1. go to folder run_pyfeat

`cd run_pyfeat`

2. Run pyfeat

open notebook `run_pyfeat_simple.ipynb`; change paths to where to save files; change path to the file that stores paths to all folders; then run the notebook











