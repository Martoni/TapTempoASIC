#SIM=ghdl
SIM=verilator
#SIM=icarus

ifeq ($(SIM),verilator)
COMPILE_ARGS=-DCOCOTB_VERILATOR
export COCOTB_HDL_TIMEPRECISION=1ns
EXTRA_ARGS += --trace --trace-structs --coverage
VERILOG_SOURCES = $(PWD)/../../../hdl/verilog/per2bpm.v
endif

ifeq ($(SIM),icarus)
VERILOG_SOURCES = $(PWD)/../../../hdl/verilog/per2bpm.v
endif

ifeq ($(SIM),ghdl)
SIM_ARGS= --wave=dump.ghw
VHDL_SOURCES = $(PWD)/../../../hdl/vhdl/per2bpm.vhd\
			   $(PWD)/../../../hdl/vhdl/taptempo_pkg.vhd
endif

export COCOTB_REDUCED_LOG_FMT=1
TOPLEVEL=per2bpm
MODULE=test_$(TOPLEVEL)
include $(shell cocotb-config --makefile)/Makefile.sim
