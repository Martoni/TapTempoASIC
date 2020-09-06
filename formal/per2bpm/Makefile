SBY = sby
SBY_CONFIG = per2bpm.sby
HDL_DIR = ../../hdl
SOURCES =  $(HDL_DIR)/per2bpm.v

per2bpm: $(SBY_CONFIG) $(SOURCES)
	rm -rf per2bpm
	$(SBY) $<

mrproper:
	rm -rf per2bpm
