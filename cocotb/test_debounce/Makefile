#SIM=verilator
SIM=icarus

ifeq ($(SIM),verilator)
COMPILE_ARGS=-DCOCOTB_VERILATOR
export COCOTB_HDL_TIMEPRECISION=1ns
EXTRA_ARGS += --trace --trace-structs --coverage
endif

ifeq ($(SIM),icarus)
COMPILE_ARGS += -DCOCOTB_ICARUS
endif

export COCOTB_REDUCED_LOG_FMT=1
VERILOG_SOURCES = $(PWD)/../../hdl/debounce.v
TOPLEVEL=debounce
MODULE=test_$(TOPLEVEL)
include $(shell cocotb-config --makefile)/Makefile.sim

# Coverage
ifeq ($(SIM),verilator)
cover/debounce.v: coverage.dat
	verilator_coverage --annotate cover coverage.dat
endif

