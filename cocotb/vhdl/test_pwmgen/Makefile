SIM=ghdl
SIM_ARGS= --wave=dump.ghw
export COCOTB_REDUCED_LOG_FMT=1
VHDL_SOURCES = $(PWD)/../../../hdl/vhdl/pwmgen.vhd\
			   $(PWD)/../../../hdl/vhdl/taptempo_pkg.vhd
TOPLEVEL=pwmgen
MODULE=test_$(TOPLEVEL)
include $(shell cocotb-config --makefile)/Makefile.sim
