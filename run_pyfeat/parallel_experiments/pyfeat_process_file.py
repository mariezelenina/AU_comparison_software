import sys
import pandas as pd
from pathlib import Path
import csv
import sys
from feat import Detector

# bash command that calls this: 
# frames_result=$(python pyfeat_process_file.py "$FILE" "$out_name" "$whichpyfeat")

def run_pyfeat_file(pyfeat_alg, path_to_pyfeatinputfile, path_to_save_dir, path_to_savefile, path_temp):

    print("DEBUG MESSAGE 2: pyfeat function started running")

    # load the appropriate pyfeat detector module
    detector = Detector(au_model=pyfeat_alg, n_workers=1) 

    # parse filename 
    path_to_file = Path(path_to_pyfeatinputfile.strip())
    filename_stem = path_to_file.stem
    filename = path_to_file.name
                            
    # for this file:
                        
    # 1. Do pyfeat processing                 
    video_prediction = detector.detect_video(path_to_pyfeatinputfile, data_type="video")
        
    # 2. Save pyfeat output                       
    video_prediction.to_csv(Path(path_to_savefile), index=True)
                            
    # 3. Calculate and print frames stats 
    total_frames_vid = video_prediction.shape[0]
    processed_frames_vid = video_prediction.FaceScore.isna().value_counts()[False]

    # 4. Prep temp frames file and save there
    temp_frames_file = f"{path_temp}/temp_frames_pyfeat_{which_algorithm}_{filename_stem}.csv"
    with open(temp_frames_file, "a", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([
        filename,
        total_frames_vid,
        processed_frames_vid
        ])
    return (0)

if __name__ == "__main__":
    print("DEBUG MESSAGE 1: python started running", file=sys.stderr)
    path_to_file = str(sys.argv[1])
    pathdir_to_save = str(sys.argv[2])
    pathfile_to_save = str(sys.argv[3])
    pathtemp = str(sys.argv[4])
    which_algorithm = str(sys.argv[5])
    run_pyfeat_file(which_algorithm, path_to_file, pathdir_to_save, pathfile_to_save, pathtemp)
    print("DEBUG MESSAGE 3: python finished running")
