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

class TestPerCount(object):
    CLK_PER = (40, "ns")
    MIN_US = 60 * 1000 * 1000
    MIN_NS = MIN_US*1000
    TP_CYCLE = 5120

    def __init__(self, dut):
        self._dut = dut
        self.log = dut._log
        self.rst = dut.rst_i
        self.clk = dut.clk_i
        self.tp = dut.tp_i
        self.btn_i = dut.btn_i
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

    async def time_pulse(self):
        counter = 0
        maxcount = self.TP_CYCLE/self.CLK_PER[0]
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
        self._dut.btn_i <= 0
        self._tpthread = cocotb.fork(self.time_pulse())
        await Timer(100, units="ns")
        self.rst <= 0
        await RisingEdge(self.clk)


@cocotb.test()
async def double_push_test(dut):
    tpc = TestPerCount(dut)
    tpc.display_config()
    tpc.log.info("Running test!")
    await tpc.reset()
    await Timer(1, units="us")
    # raise button
    await Timer(1)
    tpc.btn_i <= 1;
    tpc.log.info("raise button")
    await Timer(1, units="ms")
    # fall button
    await Timer(1)
    tpc.btn_i <= 0;
    tpc.log.info("fall button")
    await Timer(1, units="ms")
    # raise button
    await Timer(1)
    tpc.btn_i <= 1;
    tpc.log.info("raise button")
    await Timer(1, units="ms")
    # fall button
    await Timer(1)
    tpc.btn_i <= 0;
    tpc.log.info("fall button")
    await Timer(1, units="ms")


