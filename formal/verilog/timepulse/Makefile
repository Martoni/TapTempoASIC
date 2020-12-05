SBY = sby
SBY_CONFIG = timepulse.sby
HDL_DIR = ../../hdl/verilog
SOURCES =  $(HDL_DIR)/timepulse.v

timepulse: $(SBY_CONFIG) $(SOURCES)
	rm -rf timepulse
	$(SBY) $<

mrproper:
	rm -rf timepulse
