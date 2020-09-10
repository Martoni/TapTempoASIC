#! /usr/bin/python3
# -*- coding: utf-8 -*-
#-----------------------------------------------------------------------------
# Author:   Fabien Marteau <mail@fabienm.eu>
# Created:  30/07/2020
#-----------------------------------------------------------------------------
""" test_debounce
"""

import cocotb
import logging
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.result import raise_error
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import ClockCycles

class TestTapTempo(object):
    CLK_PER = (40, "ns")

    def __init__(self, dut):
        self._dut = dut
        self.log = dut._log
        self.clk = dut.clk_i
        self.btn_i = dut.btn_i
        self._clock_thread = cocotb.fork(
                Clock(self.clk, *self.CLK_PER).start())

    @classmethod
    def freq(cls, clkper):
        units = {"ps": "GHz",
                 "ns": "MHz",
                 "us": "KHz",
                 "ms": " Hz",
                 "s" : "mHz"}
        return "{} {}".format(1000/float(clkper[0]), units[clkper[1]])

    async def bounce_up(self, bounce_num=10, bounce_per=(500, "us"), up=True):
        bounce_sum = bounce_num*(1+bounce_num)/2
        bounce_per_min = (bounce_per[0]/bounce_sum)/2
        for i in reversed(range(bounce_num)):
            if up:
                self.btn_i <= 1
            else:
                self.btn_i <= 0
            await Timer(int((i+1)*bounce_per_min), units=bounce_per[1])
            if up:
                self.btn_i <= 0
            else:
                self.btn_i <= 1
            await Timer(int((i+1)*bounce_per_min), units=bounce_per[1])
        if up:
            self.btn_i <= 1
        else:
            self.btn_i <= 0

    async def bounce_down(self, bounce_num=10, bounce_per=(500, "us")):
        await self.bounce_up(bounce_num, bounce_per, up=False)

    async def reset(self):
        self.rst <= 1
        self.btn_i <= 0
        await Timer(100, units="ns")
        self.rst <= 0
        await RisingEdge(self.clk)

@cocotb.test()
async def debounce_upanddown(dut):
    td = TestDebounce(dut)
    td.display_config()
    td.log.info("Running test!")
    await td.reset()
    td.log.info("System reseted!")
    for i in range(10):
        td.log.info("up")
        await td.bounce_up(10, bounce_per=(10000, "ns"))
        td.log.info("down")
        await td.bounce_down(10, bounce_per=(10000, "ns"))
