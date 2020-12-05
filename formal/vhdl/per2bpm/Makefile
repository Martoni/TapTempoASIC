SBY=sby
TARGET=per2bpm

VHDL_SOURCES=	../../../hdl/vhdl/per2bpm.vhd\
				../../../hdl/vhdl/taptempo_pkg.vhd


$(TARGET): $(TARGET).sby $(TARGET)_tb.v $(VHDL_SOURCES) 
	$(SBY) --yosys "yosys -m ghdl" -f $(TARGET).sby 

clean:
	rm -rf $(TARGET)
