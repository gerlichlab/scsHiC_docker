#!/bin/sh

# enable conda env for jupyter
conda activate /srv/jupyter

# launch notebook or lab
exec $@

