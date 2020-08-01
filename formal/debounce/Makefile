SBY = sby
SBY_CONFIG = debounce.sby
HDL_DIR = ../../hdl
SOURCES =  $(HDL_DIR)/debounce.v

debounce: $(SBY_CONFIG) $(SOURCES)
	rm -rf debounce
	$(SBY) $<

mrproper:
	rm -rf debounce
