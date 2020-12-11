#SIM=verilator
#SIM=icarus
#SIM=ghdl

TOPLEVEL=taptempo

ifeq ($(SIM),icarus)
COMPILE_ARGS += -DCOCOTB_ICARUS

export COCOTB_REDUCED_LOG_FMT=1
VERILOG_SOURCES = $(PWD)/../../synthesis/colorlight/taptemposynth.v
YOSYS_SOURCES =   $(PWD)/../../hdl/verilog/debounce.v\
				  $(PWD)/../../hdl/verilog/per2bpm.v\
				  $(PWD)/../../hdl/verilog/percount.v\
				  $(PWD)/../../hdl/verilog/pwmgen.v\
				  $(PWD)/../../hdl/verilog/rstgen.v\
				  $(PWD)/../../hdl/verilog/timepulse.v\
				  $(PWD)/../../hdl/verilog/taptempo.v

VERILOG_SOURCES = taptemposynth.v

endif

ifeq ($(SIM),ghdl)
SIM_ARGS= --fst=$(TOPLEVEL).fst
VHDL_SOURCES = $(PWD)/../../hdl/vhdl/$(TOPLEVEL).vhd\
			   $(PWD)/../../hdl/vhdl/debounce.vhd\
			   $(PWD)/../../hdl/vhdl/per2bpm.vhd\
			   $(PWD)/../../hdl/vhdl/percount.vhd\
			   $(PWD)/../../hdl/vhdl/pwmgen.vhd\
			   $(PWD)/../../hdl/vhdl/rstgen.vhd\
			   $(PWD)/../../hdl/vhdl/timepulse.vhd\
			   $(PWD)/../../hdl/vhdl/taptempo_pkg.vhd
endif

MODULE=test_$(TOPLEVEL)
include $(shell cocotb-config --makefile)/Makefile.sim

$(VERILOG_SOURCES): $(YOSYS_SOURCES)
	yosys -p "read_verilog $(YOSYS_SOURCES);\
			hierarchy -check -top $(TOPLEVEL);\
			proc; opt; fsm; opt; memory; opt;\
			techmap; opt; clean; write_verilog synth.v"
	cocotbify -vsynth.v -o$(VERILOG_SOURCES)

