#SIM=verilator
SIM=icarus

ifeq (SIM, verilator)
export COCOTB_VERILATOR=1
export COCOTB_HDL_TIMEPRECISION=1ns
endif

#XXX does not works
ifeq (SIM, icarus)
export COCOTB_ICARUS=1
endif

export COCOTB_REDUCED_LOG_FMT=1
VERILOG_SOURCES = $(PWD)/../../hdl/debounce.v
TOPLEVEL=debounce
MODULE=test_$(TOPLEVEL)
include $(shell cocotb-config --makefile)/Makefile.sim
