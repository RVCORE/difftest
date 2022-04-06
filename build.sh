#!/bin/bash
# author: yangye

if [ $# -lt 3 ]; then
  echo "Illegal number of parameters, please check again!"
  echo "Usage: ./build.sh [emu/simv] [NUM_CORES] [REF] [OPTIONS]"
  exit 1
fi

NUM_CORES=${2}
options=${4}
common_args="NUM_CORES=${NUM_CORES} USE_FLASH=1 RELEASE=1 -j32"

if test ${3} = "spike"
then
  common_args="${common_args} REF=spike"
fi

if test $1 = "emu"
then
  target=emu
  target_args="EMU_TRACE=1 EMU_THREADS=8"
  log_args="2>compile_emu_error.log | tee compile_emu.log"
elif test $1 = "simv"
then
  target=simv
  target_args=""
  log_args=""
else
  echo "Error: not support $1"
  exit 1
fi


set -x
#echo make ${target} ${common_args} ${target_args} ${options} ${log_args}
make ${target} ${common_args} ${target_args} ${options} ${log_args}
