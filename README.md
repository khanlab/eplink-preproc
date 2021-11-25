# eplink-preproc
Snakemake workflow for running BIDS Apps on EpLink MRI data. In this workflow, BIDS Apps are run on a per-subject basis, to enable subject-level parallelization using Snakemake, even if the underlying app only processes subjects serially. 

## Prerequisites:

- Linux system with Singularity installed

## Instructions:

1. Clone this repository and install with `pip install <path_to_cloned_repo>`

2. Update the config file to change the `tmp` folder to a local disk with large enough space, and update the `bids_dir` to point to the locations of bids directories from each site/

3. Update the `config/subjects_{site}.txt` files with the subjects you want to include from the BIDS dataset.

4. If you are running on a Compute Canada SLURM cluster, you can install the `cc-slurm` Snakemake profile to enable job-submission: https://github.com/khanlab/cc-slurm

5. Run snakemake with a dry-run first:
```
snakemake -np
```

5. If everything looks fine, run with the specified number of parallel cores, or with an execution profile such as `cc-slurm`
```
snakemake --cores 4
```
--or--
```
snakemake --profile cc-slurm
```

 

## Adding new bids apps:

You can add new bids apps by creating new config file entries in `apps:` and `containers:`. The `rsync_maps` variable is used to map app outputs for subjects to the corresponding subject folder.



