SBY = sby
SBY_CONFIG = percount.sby
HDL_DIR = ../../hdl/verilog
SOURCES =  $(HDL_DIR)/percount.v

percount: $(SBY_CONFIG) $(SOURCES)
	rm -rf percount
	$(SBY) $<

mrproper:
	rm -rf percount
