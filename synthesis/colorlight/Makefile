TARGET=taptempo
TOP=taptempo

OBJS += ../../hdl/verilog/taptempo.v\
		../../hdl/verilog/debounce.v\
		../../hdl/verilog/per2bpm.v\
		../../hdl/verilog/percount.v\
		../../hdl/verilog/pwmgen.v\
		../../hdl/verilog/rstgen.v\
		../../hdl/verilog/timepulse.v

TRELLIS=/usr/local/share/trellis

all: ${TARGET}.bit

$(TARGET).json: $(OBJS)
	yosys -p "synth_ecp5 -json $@" $(OBJS)

$(TARGET)_out.config: $(TARGET).json
	nextpnr-ecp5 --25k --package CABGA256 --speed 6\
		--json $< --textcfg $@ --lpf $(TARGET).lpf --freq 25 #--force

$(TARGET).bit: $(TARGET)_out.config
	ecppack --svf ${TARGET}.svf $< $@

${TARGET}.svf : ${TARGET}.bit

prog: ${TARGET}.svf
	openFPGALoader -c digilent_hs2 $(TARGET).bit

clean:
	rm -f *.svf *.bit *.config *.json *.ys

.PHONY: prog clean
