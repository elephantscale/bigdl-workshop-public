#!/bin/bash

# activate py35 environment
#source activate py35
#conda info -e

# run tensorboard
tensorboard --logdir=${TENSORBOARD_DIR} >> ~/tensorboard.out  2>&1 &



## ---- run time config -----
RUNTIME_DRIVER_CORES=4
RUNTIME_DRIVER_MEMORY=20g
RUNTIME_EXECUTOR_CORES=4
RUNTIME_EXECUTOR_MEMORY=20g
RUNTIME_TOTAL_EXECUTOR_CORES=4
## ----end : run time config ----


# Check environment variables
[ -z "${ANALYTICS_ZOO_HOME}" ] && echo "Please set ANALYTICS_ZOO_HOME environment variable" && exit 1
[ -z "${BIGDL_HOME}" ] && echo "Please set BIGDL_HOME environment variable" && exit 1
[ -z "${SPARK_HOME}" ] && echo "Please set SPARK_HOME environment variable" && exit 1

export ZOO_JAR_NAME=`ls ${ANALYTICS_ZOO_HOME}/lib/ | grep jar-with-dependencies.jar`
export ZOO_JAR="${ANALYTICS_ZOO_HOME}/lib/${ZOO_JAR_NAME}"

export ZOO_PY_ZIP_NAME=`ls ${ANALYTICS_ZOO_HOME}/lib/ | grep python-api.zip`
export ZOO_PY_ZIP="${ANALYTICS_ZOO_HOME}/lib/${ZOO_PY_ZIP_NAME}"
export ZOO_CONF=${ANALYTICS_ZOO_HOME}/conf/spark-analytics-zoo.conf


# Check files

[ ! -f ${ZOO_CONF} ] && echo "Can not find ${ZOO_CONF}" && exit 1
[ ! -f ${ZOO_PY_ZIP} ] && echo "Can not find ${ZOO_PY_ZIP}" && exit 1
[ ! -f ${ZOO_JAR} ] && echo "Can not find ${ZOO_JAR}" && exit 1
[ ! -f ${ZOO_CONF} ] && echo "Can not find ${ZOO_CONF}" && exit 1

# activate py35 environment
source activate py35
# activate py27 environment
#source activate py27
conda info -e

#setup paths
export PYSPARK_PYTHON=$(which python)
export PYSPARK_DRIVER_PYTHON=$(which jupyter)
echo "### PYSPARK_PYTHON=$PYSPARK_PYTHON"
echo "### PYSPARK_DRIVER_PYTHON=$PYSPARK_DRIVER_PYTHON"
# this starts the notebook without a security token
#export PYSPARK_DRIVER_PYTHON_OPTS="notebook --notebook-dir=./ --ip=* --no-browser --NotebookApp.token=''"
export PYSPARK_DRIVER_PYTHON_OPTS="notebook --notebook-dir=./ --ip='0.0.0.0' --no-browser"

${SPARK_HOME}/bin/pyspark \
  --master local[*] \
  --driver-cores ${RUNTIME_DRIVER_CORES} \
  --driver-memory ${RUNTIME_DRIVER_MEMORY} \
  --executor-cores ${RUNTIME_EXECUTOR_CORES} \
  --executor-memory ${RUNTIME_EXECUTOR_MEMORY} \
  --total-executor-cores ${RUNTIME_TOTAL_EXECUTOR_CORES} \
  --properties-file ${ZOO_CONF} \
  --py-files ${ZOO_PY_ZIP} \
  --jars ${ZOO_JAR} \
  --conf spark.driver.extraClassPath=${ZOO_JAR} \
  --conf spark.executor.extraClassPath=${ZOO_JAR} \
  --conf spark.driver.extraJavaOptions=-Dderby.stream.error.file=/tmp
