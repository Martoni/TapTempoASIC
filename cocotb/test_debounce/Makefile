#SIM=verilator
#SIM=icarus
#SIM=ghdl

ifeq ($(SIM),verilator)
COMPILE_ARGS=-DCOCOTB_VERILATOR
export COCOTB_HDL_TIMEPRECISION=1ns
EXTRA_ARGS += --trace --trace-structs --coverage
endif

ifeq ($(SIM),icarus)
COMPILE_ARGS += -DCOCOTB_ICARUS
endif

export COCOTB_REDUCED_LOG_FMT=1

ifeq ($(SIM),ghdl)
COMPILE_ARGS= --std=08
SIM_ARGS= --wave=dump.ghw
VHDL_SOURCES = $(PWD)/../../hdl/vhdl/debounce.vhd\
			   $(PWD)/../../hdl/vhdl/taptempo_pkg.vhd
else
VERILOG_SOURCES = $(PWD)/../../hdl/verilog/debounce.v
endif
TOPLEVEL=debounce
MODULE=test_$(TOPLEVEL)
include $(shell cocotb-config --makefile)/Makefile.sim

# Coverage
ifeq ($(SIM),verilator)
cover/debounce.v: coverage.dat
	verilator_coverage --annotate cover coverage.dat
endif

