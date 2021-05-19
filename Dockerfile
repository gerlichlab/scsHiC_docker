FROM docker.io/ubuntu:bionic as scshic_base

# ARG will prevent RUN from being cached, breaking basically all caching for the build
ENV DEBIAN_FRONTEND=noninteractive
# Can not use /temp on our cluster
WORKDIR /temp

ENV LANG C.UTF-8  
ENV LC_ALL C.UTF-8

# Update and create base image
RUN apt-get update -y &&\
    apt-get install apt-utils -y &&\
    apt-get install -y file bzip2 default-jre gcc g++ git make ssh unzip wget libz-dev iproute2 curl iputils-ping &&\
    apt-get clean

# Install Anaconda
SHELL ["/bin/bash", "-c"]
# ADD works for URLs too, will also check if changed
ADD https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh /temp
RUN chmod +x /temp/Anaconda3-2021.05-Linux-x86_64.sh && /temp/Anaconda3-2021.05-Linux-x86_64.sh -b -p /home/anaconda3
ENV PATH="/home/anaconda3/bin:${PATH}"
RUN conda update -y conda-build

# Install OnTAD
RUN cd /opt && git clone https://github.com/anlin00007/OnTAD.git &&\
    cd OnTAD &&\
    git checkout 3da5d9a4569b1f316d4508e60781f22f338f68b1
RUN              cd /opt/OnTAD/src && make clean && make
ENV PATH="/opt/OnTAD/src:${PATH}"

# Install fastqc
RUN cd /opt && wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip &&\
    unzip /opt/fastqc_v0.11.9.zip &&\
    chmod +x /opt/FastQC/fastqc
ENV PATH="/opt/FastQC:${PATH}"

# Install ngs_base environment
ADD ngs_base.yml /temp/install/
RUN conda env create -f /temp/install/ngs_base.yml 
# Install flask environment
ADD flask.yml /temp/install/
RUN conda env create -f /temp/install/flask.yml 

WORKDIR /home

# Install bioframe, cooltools and pairlib as well as our own tools
RUN source activate ngs_base &&\
    # Creates a file into the container that logs which version conda installs and all pip installs
    conda list > software_versions_conda.txt &&\
    # Install mirnylabtools
    # bioframe
    githash=`git ls-remote https://github.com/mirnylab/bioframe.git | grep HEAD | cut -f 1` &&\
    pip install git+git://github.com/mirnylab/bioframe@$githash &&\
    echo "# pip install git+git://github.com/mirnylab/bioframe@$githash" >> software_versions_git.txt &&\
    # cooltools
    githash=`git ls-remote https://github.com/mirnylab/cooltools.git | grep HEAD | cut -f 1` &&\
    pip install git+git://github.com/mirnylab/cooltools@$githash &&\
    echo "# pip install git+git://github.com/mirnylab/cooltools@$githash" >> software_versions_git.txt &&\
    # pairlib
    githash=`git ls-remote https://github.com/mirnylab/pairlib.git | grep HEAD | cut -f 1` &&\
    pip install git+git://github.com/mirnylab/pairlib@$githash &&\
    echo "# pip install git+git://github.com/mirnylab/pairlib@$githash" >> software_versions_git.txt &&\
    # Install gerlich repos and safe the latest git hash
    # ngs
    githash=`git ls-remote https://github.com/gerlichlab/ngs.git | grep HEAD | cut -f 1` &&\
    pip install git+git://github.com/gerlichlab/ngs@$githash &&\
    echo "# pip install git+git://github.com/gerlichlab/ngs@$githash" >> software_versions_git.txt &&\
    # cooler_ontad
    githash=`git ls-remote https://github.com/cchlanger/cooler_ontad.git | grep HEAD | cut -f 1` &&\
    pip install git+git://github.com/cchlanger/cooler_ontad@$githash &&\
    echo "# pip install git+git://github.com/cchlanger/cooler_ontad@$githash" >> software_versions_git.txt &&\
    # higlassup
    githash=`git ls-remote https://github.com/Mittmich/higlassupload.git | grep HEAD | cut -f 1` &&\
    pip install git+git://github.com/Mittmich/higlassupload.git@$githash &&\
    echo "# pip install git+git://github.com/Mittmich/higlassupload.git@$githash" >> software_versions_git.txt

ENV PATH="/home/anaconda3/envs/ngs_base/bin/:${PATH}"

CMD /bin/bash

# multistage build for the jupyter integration
FROM scshic_base as jupyter

ADD jupyter_entrypoint.sh /jupyter_entrypoint.sh
ADD jupyter_env.yml /home

ENV USER jovian
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

USER jovyan

RUN conda init
ENTRYPOINT ["/jupyter_entrypoint.sh"]

