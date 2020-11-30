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

class TestPer2Bpm(object):
    CLK_PER = (40, "ns")
    MIN_US = 60 * 1000 * 1000
    MIN_NS = MIN_US*1000
    TP_CYCLE = 5120

    def __init__(self, dut):
        self._dut = dut
        self.log = dut._log
        self.rst = dut.rst_i
        self.clk = dut.clk_i
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

    def display_config(self):
        self.log.info("Configuration :")
        self.log.info("Clock period given : {} {}".format(*self.CLK_PER))
        self.log.info("Freq : {}".format(self.freq(self.CLK_PER)))

    async def reset(self):
        self.rst <= 1
        self._dut.btn_per_valid <= 0
        self._dut.btn_per_i <= 0
        await Timer(100, units="ns")
        self.rst <= 0
        await RisingEdge(self.clk)


@cocotb.test()
async def simple_test(dut):
    tpg = TestPer2Bpm(dut)
    tpg.display_config()
    tpg.log.info("Running test!")
    await tpg.reset()
    await Timer(1, units="us")
    await RisingEdge(tpg.clk)
    #1
    btn_per = int(tpg.MIN_NS/(11*tpg.TP_CYCLE))
    #btn_per = 46875
    #btn_per = 46875
    dut.btn_per_i = btn_per
    dut.btn_per_valid = 1
    await RisingEdge(tpg.clk)
    dut.btn_per_valid = 0
    await RisingEdge(dut.bpm_valid)
    await RisingEdge(tpg.clk)
    result = dut.bpm_o.value.integer
    result_theory = int((tpg.MIN_NS/tpg.TP_CYCLE)/btn_per)
    tpg.log.info("Therorical result : {}".format(result_theory))
    tpg.log.info("Result : {}".format(result))
    if result != result_theory:
        msg = "Wrong value calculation {}, should be {}".format(result, result_theory)
        tpg.log.error(msg)
        raise TestError(msg)
    await Timer(10, units="us")
