# TapTempoASIC The TapTempoASIC project aim to construct a full component from
scratch in Verilog. TapTempo is a fun subject proposed in several programming
languages on [LinuxFR](https://linuxfr.org/tags/taptempo/public) french
website. But all languages proposed are for programming, what about hardware
constructs ?

# Languages

## Verilog

All TapTempo synthetisable Verilog code is stored in hdl/verilog/ directory. To
synthesize it for ECP5 colorlight board go to synthesize/colorlight/ directory
and do make: ``` make ```

All modules are tested once with cocotb in directory cocotb/test_MODULENAME. To
launch it simply type `make` in corresponding directory and icarus as simulator (some module can works with verilator too):

```
SIM=icarus make
```

It's possible to prove modules with yosys-smtbmc in formal/ directory. To
launch prove go to directory with the module name required and type make.

## VHDL

All TapTempo synthesizable VHDL code is stored in hdl/vhdl/ directory. To
synthesize it for ECP5 colorlight board go to synthesize/colorlight_vhdl/
directory and type make:
```
make
```

All modules are simulated with cocotb in directory cocotb/test_MODULENAME. To launch it set the `SIM` argument with ghdl simulator:

```
SIM=ghdl make
```

# Documentation

## Open source foundries

- [$100
  ASIC](https://hackaday.io/project/152709-itsy-chipsy-make-your-own-100-chip)
  !
- [SKY 130](https://github.com/google/skywater-pdk)

## Tutorial

- [Formal method Introduction by
  ZipCpu](http://zipcpu.com/blog/2017/10/19/formal-intro.html)
- [Verilog tutorial](http://asic-world.com/verilog/veritut.html)
