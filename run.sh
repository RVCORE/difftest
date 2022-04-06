#!/bin/bash
# author: yangye

if [ $# -lt 4 ]; then
  echo "Illegal number of parameters, please check again!"
  echo "Usage: ./run [emu/simv] [NUM_CORES] [BIN_FILE] [REF] [OPTIONS]"
  exit 1
fi

bin_file=${3}
NUM_CORES=${2}
options=${5}

if test ${4} = "spike"
then
  ref=${SPIKE_HOME}/difftest/build/riscv64-spike-so
else
  ref=../../ready-ref/riscv64-nemu-interpreter-so-${NUM_CORES}
fi

# sanity check
if [ ! -f ${ref} ]; then
  echo "[Error]: can not found the ${ref}"
fi

if [[ $1 =~ "emu" ]]
then
  Binary="${NOOP_HOME}/build/${1}-${NUM_CORES}"
  bin_args="--image=${bin_file}"
  diff_args="--diff=${ref}"
  log_args="emu${NUM_CORES}_run.log"
elif [[ $1 =~ "simv" ]]
then
  Binary=./${1}-${NUM_CORES}
  bin_args="+workload=$bin_file"
  diff_args="+diff=${ref}"
  log_args="simv${NUM_CORES}_run.log"
else
  echo "[Error]: not support $1"
  exit 1
fi


set -x
#echo "${Binary} ${bin_args} ${diff_args} ${options} | tee ${log_args}"
(${Binary} ${bin_args} ${diff_args} ${options}) | tee ${log_args}


