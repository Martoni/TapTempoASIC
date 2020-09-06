`timescale 1ns/1ps
/* Debouncer
* The TapTempo Project
* Fabien Marteau <mail@fabienm.eu>
* bpm_o = (MIN_NS/PULSE_PER_NS)/btn_per_i
*/

`define BPMPER_MAX 62_600
`define BPM_MAX 250
`define MIN_NS 60_000_000_000

module timepulse #(
    parameter CLK_PER_NS = 40,
    parameter PULSE_PER_NS = 5120,
    parameter BPMPER_REG_SIZE = $clog2(`BPMPER_MAX + 1)
)(
    /* clock and reset */
    input clk_i,
    input rst_i,
    /* inputs */
    input [BPMPER_REG_SIZE:0] btn_per_i,
    input btn_per_ready,
    /* outputs */
    output [$clog2(`BPM_MAX + 1) - 1:0)] bpm_o,
    output bpm_valid
);

reg [30:0] divisor;
reg [30:0] remainder;



endmodule
