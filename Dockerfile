#################################################
## This Dockerfile installs minimal env for BigDL
##      - JDK8 (oracle)
##      - Spark
##      - BigDL
##      - Conda Python 3.6 environment
##      - Tensorflow and Tensorboard
##  All software installed in : /opt
#################################################

## pick latest or a specific version (to ensure predictability)
FROM jupyter/scipy-notebook:latest

MAINTAINER Elephant Scale <info@elephantscale.com>


## --- CONFIG for Docker ------
ARG SCALA_VERSION=2.11.8
ARG INSTALL_DIR=/opt
ARG BIGDL_VERSION=0.6.0
ARG ANALYTICS_ZOO_VERSION=0.3.0-SNAPSHOT
ARG SPARK_VERSION=2.3.1

## -- env variables to be used in the container -----
ENV BIGDL_HOME          ${INSTALL_DIR}/BigDL
ENV SPARK_HOME          ${INSTALL_DIR}/spark
ENV ANALYTICS_ZOO_HOME  ${INSTALL_DIR}/analytics-zoo
ENV JAVA_HOME           ${INSTALL_DIR}/jdk
ENV PATH                ${INSTALL_DIR}/spark/bin:${JAVA_HOME}/bin:$PATH
# working directory
ENV                     WORKING_DIR ${HOME}/work
## --- end CONFIG


## Do system updates first and then install our custom software (bigdl, spark ..etc)
## This way  we don't bust the cache when we experiment with different versions


## -------- system updates -------

USER root



## apt update
RUN apt-get update -yq && \
    apt-get -yq upgrade
    #apt-get -yq dist-upgrade

## basic utils
RUN apt-get install -yq  --no-install-recommends \
    atop \
    curl \
    git \
    less \
    jq \
    nano \
    rsync \
    vim \
    unzip \
    wget \
    zip

## cleanup apt
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*


## --- install/update conda python env ------
# now as a regular user
USER $NB_USER

## update conda - warn : this takes a while
#RUN conda update -n base conda
#RUN conda update --all

## universal install
#RUN  conda  install -y     jupyter   matplotlib   numpy   pandas   scikit-learn   scipy   seaborn    tensorflow   && conda clean -tipsy
# RUN pip install  tensorboard

## create a python 3.5 env and install packages
## py36 seems to be incompatible with some Spark functions
RUN conda create -y -n py35 python=3.5 \
    numpy \
    scipy \
    pandas \
    scikit-learn \
    matplotlib \
    seaborn \
    jupyter \
    #nltk \
    opencv \
    pillow \
    tensorflow \
    && conda clean -tipsy

# list envs
RUN conda info -e

## install tensorboard with pip for py35
RUN /bin/bash -c "source activate py35 && \
    pip install  tensorboard && \
    source deactivate"

## source python 3.5
RUN echo "source activate py35" >> ~/.bashrc

## ----- custom installs ----
USER root

RUN mkdir -p ${INSTALL_DIR}
## ---- install Oracle JDK -----
RUN wget 'http://ftp.osuosl.org/pub/funtoo/distfiles/oracle-java/jdk-8u152-linux-x64.tar.gz' && \
    gunzip jdk-8u152-linux-x64.tar.gz && \
    tar -xf jdk-8u152-linux-x64.tar -C ${INSTALL_DIR} && \
    rm jdk-8u152-linux-x64.tar && \
    ln -s ${INSTALL_DIR}/jdk1.8.0_152 ${JAVA_HOME}


## ----- install spark -------
RUN \
  curl -fsL "http://mirrors.sonic.net/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz"  | tar xfz - -C ${INSTALL_DIR} && \
  cd ${INSTALL_DIR} &&  rm -f spark && ln -s spark-${SPARK_VERSION}-bin-hadoop2.7  spark



## ----- install BigDL ----------
ARG BIGDL_URL=https://repo1.maven.org/maven2/com/intel/analytics/bigdl/dist-spark-${SPARK_VERSION}-scala-${SCALA_VERSION}-all/${BIGDL_VERSION}/dist-spark-${SPARK_VERSION}-scala-${SCALA_VERSION}-all-${BIGDL_VERSION}-dist.zip
RUN echo "BIGDL_URL=$BIGDL_URL"
RUN \
    mkdir -p ${BIGDL_HOME} && \
    cd ${BIGDL_HOME} && \
    wget --quiet "${BIGDL_URL}"  && \
    unzip *.zip && \
    rm -f *.zip

# ---- install analytics zoo ----
COPY ./download-analytics-zoo.sh ${INSTALL_DIR}
RUN chmod a+x ${INSTALL_DIR}/download-analytics-zoo.sh
RUN cd ${INSTALL_DIR} && ./download-analytics-zoo.sh


## -------- setup env ---------
## disable sudo password
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# this is where volumes will be mounted
RUN mkdir /work
## setup working directory to map with host OS
RUN rm -rf ${WORKING_DIR} && ln -s /work  ${WORKING_DIR}


## --- copy files last, so not to bust the cache ---
USER root
RUN mv /usr/local/bin/start-notebook.sh   /usr/local/bin/start-notebook-old.sh
COPY  start-notebook.sh  /usr/local/bin/
RUN chmod +x /usr/local/bin/start-notebook.sh

COPY ./run-jupyter-with-bigdl.sh  $HOME/
COPY ./run-jupyter-with-zoo.sh  $HOME/
RUN sudo chmod +x  $HOME/*.sh
RUN sudo chown $NB_USER  $HOME/*

## finally switch back to jovyan to avoid accidental container runs as root
USER $NB_USER
