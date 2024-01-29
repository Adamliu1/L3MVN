FROM nvcr.io/nvidia/cudagl:11.3.0-devel-ubuntu20.04

RUN mkdir -p /home/app
WORKDIR /home/app
RUN apt-key del 7fa2af80
RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends build-essential git curl vim \
  ca-certificates libjpeg-dev libglm-dev libegl1-mesa-dev xorg-dev freeglut3-dev pkg-config wget zip unzip \
  && rm -rf /var/lib/apt/lists/*

# Install miniconda

RUN curl -L -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  &&\
    chmod +x ~/miniconda.sh &&\
    ~/miniconda.sh -b -p /opt/conda &&\
    rm ~/miniconda.sh &&\
    /opt/conda/bin/conda install numpy pyyaml scipy ipython mkl mkl-include &&\
    /opt/conda/bin/conda clean -ya

ENV PATH="/opt/conda/bin:$PATH"

# create habitat env
RUN conda create -n habitat python=3.7 cmake=3.14.0 -y
RUN conda install pytorch==1.10.0 torchvision==0.11.0 torchaudio==0.10.0 cudatoolkit=11.3 -c pytorch -c conda-forge -n habitat -y
RUN conda install habitat-sim-challenge-2022 headless -c conda-forge -c aihabitat -n habitat -y
RUN git clone --branch challenge-2022 https://github.com/facebookresearch/habitat-lab.git
RUN conda run -n habitat /bin/bash -c \
  "cd habitat-lab; pip install -r requirements.txt; python setup.py develop --all"
RUN conda run -n habitat /bin/bash -c \
  "python -m pip install detectron2 -f \
  https://dl.fbaipublicfiles.com/detectron2/wheels/cu113/torch1.10/index.html"
COPY ./requirements.txt /home
RUN conda run -n habitat /bin/bash -c \
  "pip install -r /home/requirements.txt"
ENV LD_LIBRARY_PATH="/opt/conda/lib:$LD_LIBRARY_PATH"
