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

SIM = 'icarus'
#SIM = 'verilator'

class TestDebounce(object):
    CLK_PER = (40, "ns")

    def __init__(self, dut):
        self._dut = dut
        if SIM == 'icarus':
            self.PULSE_PER_NS = int(dut.PULSE_PER_NS)
            self.DEBOUNCE_PER_NS = int(dut.DEBOUNCE_PER_NS)
        else:
            self.PULSE_PER_NS = 4096
            self.DEBOUNCE_PER_NS = 16777216

        self.log = dut._log
        self.rst = dut.rst_i
        self.clk = dut.clk_i
        self.tp = dut.tp_i
        self.btn_i = dut.btn_i
        self._clock_thread = cocotb.fork(
                Clock(self.clk, 100, units="ns").start())
        self._tp_thread = cocotb.fork(self.time_pulse())

    def display_config(self):
        self.log.info("Configuration :")
        self.log.info("PULSE_PER_NS = {} ns".format(self.PULSE_PER_NS))
        self.log.info("DEBOUNCE_PER_NS = {} ns".format(self.DEBOUNCE_PER_NS))
    
    async def time_pulse(self):
        counter = 0
        while True:
            await RisingEdge(self.clk)
            if counter < (self.PULSE_PER_NS/self.CLK_PER[0]):
                self.tp <= 0
                counter = counter + 1
            else:
                self.tp <= 1
                counter = 0

    async def reset(self):
        self.rst <= 1
        self.btn_i <= 0
        await Timer(100, units="ns")
        self.rst <= 0
        await RisingEdge(self.clk)


@cocotb.test()
async def debounce_test(dut):
    td = TestDebounce(dut)
    td.display_config()
    td.log.info("Running test!")
    await td.reset()
    td.log.info("System reseted!")
    await Timer(1, units="us")
    td.btn_i <= 1
    await Timer(1, units="us")
    td.btn_i <= 0
    await Timer(2, units="us")
    td.btn_i <= 1
    await Timer(5, units="us")
    td.btn_i <= 0
    await Timer(7, units="us")
    td.btn_i <= 1
    await Timer(10, units="us")
    td.btn_i <= 0
    await Timer(10, units="us")
    td.btn_i <= 1
    await Timer(1, units="ms")
