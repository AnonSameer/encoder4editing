# Use the official Nvidia CUDA runtime with Ubuntu 20.04 and CUDA 12.1
FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu20.04

# Set working directory
WORKDIR /workspace

# Set timezone:
RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    git \
    curl \
    wget \
    vim \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    zip \
    
    && rm -rf /var/lib/apt/lists/*

# Clone the e4e repository
RUN git clone https://github.com/AnonSameer/encoder4editing /workspace/encoder4editing
WORKDIR /workspace/encoder4editing

# Install Miniconda (for Conda environments)
RUN curl -sS https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh && \
    bash miniconda.sh -b -u -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda init bash

# Add Conda to PATH
ENV PATH=/opt/conda/bin:$PATH


# Create the Conda environment without the problematic dependencies
RUN conda env create -f /workspace/encoder4editing/environment/e4e_env.yaml && \
    conda clean --all --yes

# Activate the Conda environment by default
SHELL ["/bin/bash", "--login", "-c"]

# Manually install compatible versions of torch and torchvision
RUN conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia

# Optional: Expose a port for Jupyter Notebook (if needed)
EXPOSE 8888

# Set default command to bash
CMD ["bash"]
