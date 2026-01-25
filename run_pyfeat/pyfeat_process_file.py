import sys
import pandas as pd
from pathlib import Path
import csv
import sys
from feat import Detector

# bash command that calls this: 
# frames_result=$(python pyfeat_process_file.py "$FILE" "$out_name" "$whichpyfeat")

def run_pyfeat_file(pyfeat_alg, path_to_pyfeatinputfile, path_to_savefile):

    # load the appropriate pyfeat detector module
    detector = Detector(au_model=which_algorithm) 

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
    # whatever we print here will go back into bash             
    total_frames_vid = video_prediction.shape[0]
    processed_frames_vid = video_prediction.FaceScore.isna().value_counts()[False]

    print(f"{total_frames_vid}\t{processed_frames_vid}")

if __name__ == "__main__":
    path_to_file = str(sys.argv[1])
    path_to_save = str(sys.argv[2])
    which_algorithm = str(sys.argv[3])
    run_pyfeat_file(which_algorithm, path_to_file, path_to_save)