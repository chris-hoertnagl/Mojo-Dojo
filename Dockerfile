FROM ubuntu:20.04

ARG MODULAR_HOME=/home/user/.modular
ENV MODULAR_HOME=$MODULAR_HOME

ARG DEFAUL_TZ=Europe/Germany
ENV DEFAULT_TZ=$DEFAULT_TZ

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive $DEFAULT_TZ apt-get install -y \
    tzdata \
    vim \
    sudo \
    curl \ 
    python3 \
    pip \
    python3-venv

RUN python3 -m pip install \
    jupyterlab \
    ipykernel \
    matplotlib \
    ipywidgets \
    gradio 

ARG AUTH_KEY=DEFAUL_TZ
ENV AUTH_KEY=$AUTH_KEY

RUN sudo curl https://get.modular.com | MODULAR_AUTH=$AUTH_KEY sh - \
    && modular auth $AUTH_KEY \
    && modular install mojo

ENV PATH="$PATH:$MODULAR_HOME/pkg/packages.modular.com_mojo/bin"

CMD ["sleep", "infinity"]