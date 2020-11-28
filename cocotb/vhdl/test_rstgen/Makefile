SIM=ghdl
#SIM=verilator
#SIM=icarus

TOPLEVEL=rstgen
VSOURCE=$(PWD)/../../../hdl/verilog/$(TOPLEVEL).v

ifeq ($(SIM),verilator)
COMPILE_ARGS=-DCOCOTB_VERILATOR
export COCOTB_HDL_TIMEPRECISION=1ns
EXTRA_ARGS += --trace --trace-structs --coverage
VERILOG_SOURCES = $(TOPLEVEL).v
endif

ifeq ($(SIM),icarus)
VERILOG_SOURCES = $(TOPLEVEL)_cocotb.v
endif

ifeq ($(SIM),ghdl)
SIM_ARGS= --fst=$(TOPLEVEL).fst
VHDL_SOURCES = $(PWD)/../../../hdl/vhdl/$(TOPLEVEL).vhd\
			   $(PWD)/../../../hdl/vhdl/taptempo_pkg.vhd
endif

export COCOTB_REDUCED_LOG_FMT=1
MODULE=test_$(TOPLEVEL)
include $(shell cocotb-config --makefile)/Makefile.sim


$(TOPLEVEL).v: $(VSOURCE)
	echo  "convert verilog source in more binary version"
	yosys -p "read_verilog $(VSOURCE); hierarchy -check -top $(TOPLEVEL); proc; opt; fsm; opt; memory; opt; write_verilog $@"


$(TOPLEVEL)_cocotb.v: $(TOPLEVEL).v
	cocotbify -v $(TOPLEVEL).v -o $@


mrproper:
	rm -f $(TOPLEVEL).v
	rm -f $(TOPLEVEL)_cocotb.v
