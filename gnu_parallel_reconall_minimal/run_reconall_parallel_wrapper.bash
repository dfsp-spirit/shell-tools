#!/bin/bash
# run_reconall_parallel_wrapper.bash -- run stuff in parallel over a number of subjects
#
# Written by Tim Schaefer, http://rcmd.org/ts/
#
# You must adapt the settings below for this script to work.
#
# I would suggest to run it from within a GNU screen session. That way it will
# continue running in the background if you lose connection to the host (when
# stated via ssh) or accidentely reboot your machine or close the terminal window.


APPTAG="[RUN_RECONALL_PAR]"

##### General settings - adapt these to your needs #####

# Number of consecutive GNU Parallel jobs. Note that 0 for 'as many as possible'. Maybe set something a little bit less than the number of cores of your machine if you want to do something else while it runs.
# See 'man parallel' for details.
NUM_CONSECUTIVE_JOBS=8
SUBJECTS="subject1 subject2 subject3 subject4 subject5 subject6 subject7 subject8 subject9 subject10 subject11 subject12 subject13 subject14 subject15 subject16"
PER_SUBJECT_SCRIPT="${HOME}/bin/recon_per_subject.bash"
###### End of settings #####

NUM_SUBJECTS=$(echo ${SUBJECTS} | wc -w  | tr -d '[:space:]')
echo "${APPTAG} Running in parallel for $NUM_SUBJECTS subjects, using $NUM_CONSECUTIVE_JOBS CPU cores."



## Just to be sure: check some essential stuff

# SUBJECTS_DIR must be set
if [ -z "${SUBJECTS_DIR}" ]; then
    echo "${APPTAG} ERROR: Environment variable SUBJECTS_DIR not set. Exiting."
    exit 1
fi

# The inner script must exist and be executable
if [ ! -x "${PER_SUBJECT_SCRIPT}" ]; then
    echo "${APPTAG} ERROR: Inner script not found at configured path '${PER_SUBJECT_SCRIPT}', or it is not executable. Check path and/or run 'chmod +x <file>' on it to make it executable. Exiting."
    exit
fi


echo ${SUBJECTS} | tr ' ' '\n' | parallel --jobs ${NUM_CONSECUTIVE_JOBS} --workdir . --joblog logfile_parallel_run.txt "${PER_SUBJECT_SCRIPT} {}"
