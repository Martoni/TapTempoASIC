#SIM=verilator
SIM=icarus

ifeq ($(SIM),icarus)
COMPILE_ARGS += -DCOCOTB_ICARUS
endif

export COCOTB_REDUCED_LOG_FMT=1
VERILOG_SOURCES = $(PWD)/../../synthesis/colorlight/taptemposynth.v
YOSYS_SOURCES = $(PWD)/../../hdl/debounce.v\
				  $(PWD)/../../hdl/per2bpm.v\
				  $(PWD)/../../hdl/percount.v\
				  $(PWD)/../../hdl/pwmgen.v\
				  $(PWD)/../../hdl/rstgen.v\
				  $(PWD)/../../hdl/timepulse.v\
				  $(PWD)/../../hdl/taptempo.v

VERILOG_SOURCES = taptemposynth.v

TOPLEVEL=taptempo
MODULE=test_$(TOPLEVEL)
include $(shell cocotb-config --makefile)/Makefile.sim

$(VERILOG_SOURCES): $(YOSYS_SOURCES)
	yosys -p "read_verilog $(YOSYS_SOURCES);\
			hierarchy -check -top $(TOPLEVEL);\
			proc; opt; fsm; opt; memory; opt;\
			techmap; opt; clean; write_verilog synth.v"
	cocotbify -vsynth.v -o$(VERILOG_SOURCES)

