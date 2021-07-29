# Shell scripts to run the FreeSurfer recon-all pipeline in parallel

These 2 scripts server to run recon all in parallel using the Linux 'GNU parallel' software.

The parallelization happens on the subject level: there is no speedup for running a single subject,
but on a machine with 24 cores, you can run 24 subjects in parallel at any given time and expect roughly linear speedup.
