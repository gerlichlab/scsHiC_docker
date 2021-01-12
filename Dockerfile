FROM docker.io/ubuntu:bionic
ARG DEBIAN_FRONTEND=noninteractive
# Can not use /temp on our cluster
WORKDIR /temp
COPY . /temp/install/
ENV LANG C.UTF-8  
ENV LC_ALL C.UTF-8

# Update and create base image
RUN apt-get update -y &&\
    apt-get install apt-utils -y &&\
    apt-get install -y file bzip2 default-jre gcc g++ git make ssh unzip wget libz-dev iproute2 curl iputils-ping &&\
    apt-get clean

# Install Anaconda
SHELL ["/bin/bash", "-c"]
RUN wget -q https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh &&\
    bash Anaconda3-2019.10-Linux-x86_64.sh -b -p /home/anaconda3
ENV PATH="/home/anaconda3/bin:${PATH}"
RUN conda update -y conda &&\
    conda update -y conda-build

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
RUN conda env create -f /temp/install/ngs_base.yml 
# Install flask environment
RUN conda env create -f /temp/install/flask.yml 

WORKDIR /home

ENV PATH="/home/anaconda3/envs/ngs_base/bin/:${PATH}"

CMD /bin/bash