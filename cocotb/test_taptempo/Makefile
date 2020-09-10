#SIM=verilator
SIM=icarus

ifeq ($(SIM),icarus)
COMPILE_ARGS += -DCOCOTB_ICARUS
endif

export COCOTB_REDUCED_LOG_FMT=1
VERILOG_SOURCES = $(PWD)/../../hdl/debounce.v\
				  $(PWD)/../../hdl/per2bpm.v\
				  $(PWD)/../../hdl/percount.v\
				  $(PWD)/../../hdl/pwmgen.v\
				  $(PWD)/../../hdl/rstgen.v\
				  $(PWD)/../../hdl/timepulse.v\
				  $(PWD)/../../hdl/taptempo.v

TOPLEVEL=taptempo
MODULE=test_$(TOPLEVEL)
include $(shell cocotb-config --makefile)/Makefile.sim
