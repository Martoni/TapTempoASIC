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
from cocotb.result import TestError
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import ClockCycles

class TestTimePulse(object):
    CLK_PER = (40, "ns")
    MIN_US = 60 * 1000 * 1000
    MIN_NS = MIN_US*1000
    TP_CYCLE = 5120

    def __init__(self, dut):
        self._dut = dut
        self.log = dut._log
        self.clk = dut.clk_i
        self.rst = dut.rst_i
        self._clock_thread = cocotb.fork(
                Clock(self.clk, *self.CLK_PER).start())
        self._dsptime = cocotb.fork(self.display_time())

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

    async def display_time(self, tstep=(100, "us")):
            passtime = 0
            while True:
                await Timer(tstep[0], units=tstep[1])
                passtime += 1
                self.log.info("{} {}".format(passtime*tstep[0], tstep[1]))

    async def reset(self):
        self.rst <= 1
        await Timer(100, units="ns")
        self.rst <= 0
        await RisingEdge(self.clk)

@cocotb.test()
async def double_push_test(dut):
    trg = TestTimePulse(dut)
    trg.display_config()
    trg.log.info("Running test!")
    await trg.reset()
    await Timer(1, units="ms")
