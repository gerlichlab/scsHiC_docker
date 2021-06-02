# scsHi-C Container
This container was created for the scsHi-C method developed by M. Mitter et al. (https://doi.org/10.1101/2020.03.10.978148)

Version 1.0 includes all the tools necessary to run the analysis of the original publication.
This container will be kept updated and future versions will include additional tools or new developments of the Gerlich Lab.

# Dockerhub and Version
This container can be found on [dockerhub](https://hub.docker.com/r/gerlichlab/scshic_docker).

## Version dev-1.0

Development container for [HiCognition](https://github.com/gerlichlab/HiCognition_flask) without cooltools, pairtools and ngs to allow more flexible building.
## Version 1.5

This version removes things not needed by our [scsHi-C pipeline](https://github.com/gerlichlab/scshic_pipeline) and tries to minimize container size.

## Version 1.3
This version is for our next project.
Adds all dependencies for a flask server, but not flask itself. Deprecated for development in favor of `dev-1.0`
## Version 1.2
Changes:
- Uses currently newest cooltools, bioframe and pairlib
- Minimum version for all conda packages 

## Version 1.1
last version with frozen cooltools, bioframe and pairlib
## Version 1.0  (used for publication)
Core components:
- The mirnylab [cooler](https://github.com/mirnylab/cooler) ecosystem including [pairtools](https://github.com/mirnylab/pairtools) and [cooltools](https://github.com/mirnylab/cooltools).
- A [collections of functions](https://github.com/gerlichlab/ngs) to facilitate analysis of HiC data based on the cooler and cooltools interfaces.
- [OnTAD](https://github.com/anlin00007/OnTAD) and a python [wrapper](https://github.com/cchlanger/cooler_ontad) to use it with coolers.
- [FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- [Chromosight](https://github.com/koszullab/chromosight)
- [Jupyter Lab](https://jupyterlab.readthedocs.io/en/latest/) to be able run the [notebooks of the paper](https://github.com/gerlichlab/scshic_analysis).
- last but not least an [upload wrapper](https://github.com/Mittmich/higlassupload) for [HiGlass](https://github.com/higlass/higlass).

# Software Versions:
If you built this container yourself, it will try to built with the newest versions of the softwares included.
However there is always a frozen snapshot on dockerhub. In those containers you will find a file called `software_versions.txt` - it will include all conda hashes and all hashes of git repositories that were installed via pip.

# Related projects
This container is used by our [scsHi-C pipeline](https://github.com/gerlichlab/scshic_pipeline).
