SBY = sby
SBY_CONFIG = rstgen.sby
HDL_DIR = ../../hdl
SOURCES =  $(HDL_DIR)/rstgen.v

rstgen: $(SBY_CONFIG) $(SOURCES)
	rm -rf rstgen
	$(SBY) $<

mrproper:
	rm -rf rstgen
