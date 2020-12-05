SBY = sby
SBY_CONFIG = pwmgen.sby
HDL_DIR = ../../hdl/verilog
SOURCES =  $(HDL_DIR)/pwmgen.v

pwmgen: $(SBY_CONFIG) $(SOURCES)
	rm -rf pwmgen
	$(SBY) $<

mrproper:
	rm -rf pwmgen
