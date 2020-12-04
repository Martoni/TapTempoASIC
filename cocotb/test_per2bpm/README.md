# Simulate per2bpm

## VHDL

To simulate with ghdl :
```Shell
$ SIM=ghdl make
```

A trace named per2bpm.fst readable with gtkwave is generated.

## Verilog

To simulate with icarus:
```Shell
$ SIM=icarus make
```

A trace named per2bpm.vcd is generated.

To simulate with verilator:
```Shell
$ SIM=verilator make
```

There is to much warning to compile it (To be fixed).
A trace named dump.vcd should be generated.
