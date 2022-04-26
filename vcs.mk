#***************************************************************************************
# Copyright (c) 2020-2021 Institute of Computing Technology, Chinese Academy of Sciences
# Copyright (c) 2020-2021 Peng Cheng Laboratory
#
# XiangShan is licensed under Mulan PSL v2.
# You can use this software according to the terms and conditions of the Mulan PSL v2.
# You may obtain a copy of Mulan PSL v2 at:
#          http://license.coscl.org.cn/MulanPSL2
#
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
#
# See the Mulan PSL v2 for more details.
#***************************************************************************************

OUT_DIR ?= .
VCS_TARGET = $(OUT_DIR)/simv-$(NUM_CORES)

FLIST_NAME = /home51/yangye/projects/xs/nanhu_release/flist_vcs$(NUM_CORES).f

VCS_CSRC_DIR = $(abspath ./src/test/csrc/vcs)
VCS_CXXFILES = $(SIM_CXXFILES) $(DIFFTEST_CXXFILES) $(PLUGIN_CXXFILES) $(shell find $(VCS_CSRC_DIR) -name "*.cpp")
VCS_CXXFLAGS += -std=c++11 -static -Wall -I$(VCS_CSRC_DIR) -I$(SIM_CSRC_DIR) -I$(DIFFTEST_CSRC_DIR) -I$(PLUGIN_CHEAD_DIR)
VCS_CXXFLAGS += -DNUM_CORES=$(NUM_CORES)
VCS_LDFLAGS  += -lpthread -lSDL2 -ldl -lz -lsqlite3

ifeq ($(RELEASE),1)
VCS_CXXFLAGS += -DBASIC_DIFFTEST_ONLY
endif

ifeq ($(USE_FLASH), 1)
VCS_CXXFLAGS += -DFLASH_IMAGE=\\\"/home51/yangye/projects/xs/flash/build/flash.bin\\\"
endif

ifneq ($(NUM_CORES), 1)
VCS_CXXFLAGS += -DDEBUG_SMP
endif

VCS_VSRC_DIR = $(abspath ./src/test/vsrc/vcs)
VCS_VFILES   = $(SIM_VSRC) $(shell find $(VCS_VSRC_DIR) -name "*.v")

VCS_SEARCH_DIR = $(abspath $(BUILD_DIR))
VCS_BUILD_DIR  = $(abspath $(BUILD_DIR)/simv-compile)

VCS_FLAGS += -full64 +v2k -timescale=1ns/1ns -sverilog -debug_access+all +lint=TFIPC-L +define+MEM_CHECK_OFF
# randomize all undefined signals (instead of using X)
VCS_FLAGS += +vcs+initreg+random +define+MEM_CHECK_OFF+SNPS_FAST_SIM_FFV +define+USE_RF_DEBUG +define+SNPS_FAST_SIM_FFV
VCS_FLAGS += +define+RANDOMIZE_GARBAGE_ASSIGN+RANDOMIZE_MEM_INIT
# VCS_FLAGS += +define+RANDOMIZE_GARBAGE_ASSIGN +define+RANDOMIZE_INVALID_ASSIGN
VCS_FLAGS += +define+RANDOMIZE_MEM_INIT +define+RANDOMIZE_DELAY=0 +define+RANDOMIZE_REG_INIT
VCS_FLAGS += +vcs+initreg+random
# SRAM lib defines
# VCS_FLAGS += +define+UNIT_DELAY +define+no_warning
# C++ flags
VCS_FLAGS += -CFLAGS "$(VCS_CXXFLAGS)" -LDFLAGS "$(VCS_LDFLAGS)" -j200
# search build for other missing verilog files
VCS_FLAGS += -y $(VCS_SEARCH_DIR) +libext+.v
# build files put into $(VCS_BUILD_DIR)
VCS_FLAGS += -Mdir=$(VCS_BUILD_DIR) -o $(VCS_TARGET)

simv:   $(VCS_VFILES) $(FLIST_NAME)
	-@mkdir -p $(VCS_BUILD_DIR)
	vcs $(VCS_FLAGS) $(VCS_CXXFILES) -F $(FLIST_NAME) $(VCS_VFILES) -l $(OUT_DIR)/vcs_compile_$(NUM_CORES).log

vcs-clean:
	rm -rf $(VCS_TARGET) csrc DVEfiles simv.daidir stack.info.* ucli.key $(VCS_BUILD_DIR)

.PHONY=simv vcs-clean
