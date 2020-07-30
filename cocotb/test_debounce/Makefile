SIM=icarus                                 # Nom du simulateur
export COCOTB_REDUCED_LOG_FMT=1            # Pour avoir des traces de log qui rentre dans l’écran
VERILOG_SOURCES = $(PWD)/../../hdl/debounce.v # Inclusion des fichiers HDL
TOPLEVEL=debounce                          # Nom de l’entité 
MODULE=test_$(TOPLEVEL)                    # Nom du script Python de test
include $(shell cocotb-config --makefile)/Makefile.sim
