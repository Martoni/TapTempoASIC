TARGET=taptempo
TOP=$(TARGET)

OBJS =	$(PWD)/../../hdl/vhdl/taptempo_pkg.vhd\
		$(PWD)/../../hdl/vhdl/$(TOP).vhd\
		$(PWD)/../../hdl/vhdl/debounce.vhd\
		$(PWD)/../../hdl/vhdl/per2bpm.vhd\
		$(PWD)/../../hdl/vhdl/percount.vhd\
		$(PWD)/../../hdl/vhdl/pwmgen.vhd\
		$(PWD)/../../hdl/vhdl/rstgen.vhd\
		$(PWD)/../../hdl/vhdl/timepulse.vhd\

TRELLIS=/usr/local/share/trellis

all: ${TARGET}.bit

$(TARGET).json: $(OBJS)
	yosys -m ghdl -p 'ghdl $(OBJS) -e $(TOP); synth_ecp5 -json $(TOP).json'

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
