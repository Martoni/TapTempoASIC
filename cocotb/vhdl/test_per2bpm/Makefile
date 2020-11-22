SIM=ghdl
SIM_ARGS= --wave=dump.ghw
export COCOTB_REDUCED_LOG_FMT=1
VHDL_SOURCES = $(PWD)/../../../hdl/vhdl/per2bpm.vhd\
			   $(PWD)/../../../hdl/vhdl/taptempo_pkg.vhd
TOPLEVEL=per2bpm
MODULE=test_$(TOPLEVEL)
include $(shell cocotb-config --makefile)/Makefile.sim
