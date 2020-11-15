#! /usr/bin/python3
# -*- coding: utf-8 -*-
#-----------------------------------------------------------------------------
# Author:   Fabien Marteau <mail@fabienm.eu>
# Created:  15/11/2020
#-----------------------------------------------------------------------------
""" test_pwmgen
"""

import cocotb
import logging
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.result import raise_error
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import ClockCycles

class TestPwmGen(object):
    CLK_PER = (40, "ns")

    def __init__(self, dut):
        self._dut = dut
        self.PULSE_PER_NS = 5120 # XXX
        self.log = dut._log
        self.rst = dut.rst_i
        self.clk = dut.clk_i
        self.tp = dut.tp_i
        self.bpm = dut.bpm_i
        self._clock_thread = cocotb.fork(
                Clock(self.clk, *self.CLK_PER).start())
        self._tp_thread = cocotb.fork(self.time_pulse())

    @classmethod
    def freq(cls, clkper):
        units = {"ps": "GHz",
                 "ns": "MHz",
                 "us": "KHz",
                 "ms": " Hz",
                 "s" : "mHz"}
        return "{} {}".format(1000/float(clkper[0]), units[clkper[1]])

    def display_config(self):
        self.log.info("Configuration :")
        self.log.info("Clock period given : {} {}".format(*self.CLK_PER))
        self.log.info("Freq : {}".format(self.freq(self.CLK_PER)))

    async def time_pulse(self):
        counter = 0
        maxcount = self.PULSE_PER_NS/self.CLK_PER[0]
        self.log.info("time_pulse launched {}".format(maxcount))
        while True:
            await RisingEdge(self.clk)
            if counter < (maxcount):
                self.tp <= 0
                counter = counter + 1
            else:
                self.tp <= 1
                counter = 0

    async def reset(self):
        self.rst <= 1
        self.bpm <= 125
        self._dut.bpm_valid <= 0
        await Timer(100, units="ns")
        self.rst <= 0
        await RisingEdge(self.clk)


@cocotb.test()
async def debounce_test(dut):
    tpg = TestPwmGen(dut)
    tpg.display_config()
    tpg.log.info("Running test!")
    await tpg.reset()
    await RisingEdge(tpg.clk)
    tpg._dut.bpm_valid <= 1
    await RisingEdge(tpg.clk)
    tpg._dut.bpm_valid <= 0
    await Timer(10, units="us")
