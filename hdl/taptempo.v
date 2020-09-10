`timescale 1ns/1ps
/* 
* The TapTempo Project
* Fabien Marteau <mail@fabienm.eu>
*/

module taptempo #(
    CLK_PER_NS = 40,     // 25Mhz clock
    TP_CYCLE = 5120, // Number of cycles per timepulse
    BPM_MAX = 250
)(
    input clk_i,
    input btn_i,
    output pwm_o
);

/* generate reset internally */
reg rst;
rstgen inst_rstgen (
    .clk_i(clk_i),
    .rst_o(rst));

/* TimePulse generation */
reg tp;
timepulse #(
    .CLK_PER_NS(CLK_PER_NS),
    .PULSE_PER_NS(TP_CYCLE)
) inst_timepulse (
    .clk_i(clk_i),
    .rst_i(rst),
    .tp_o(tp));

/* Synchronize btn_i to avoid metastability*/
reg btn_old, btn_s;
always@(posedge clk_i)
begin
    btn_old <= btn_i;
    btn_s <= btn_old;
end

/* then debounce */
reg btn_d;
debounce #(
    .PULSE_PER_NS(TP_CYCLE),
    .DEBOUNCE_PER_NS(20_971_520) // 20ms
    ) inst_debounce (
    .clk_i(clk_i),
    .rst_i(rst),
    .tp_i(tp),
    .btn_i(btn_s),
    .btn_o(btn_d));

/* count tap period */
`define BPM_PER_MAX 62_600
`define BPMPER_REG_SIZE ($clog2(`BPM_PER_MAX + 1))
reg [BPMPER_REG_SIZE:0] btn_per;
reg btn_per_valid;
percount #(
    .CLK_PER_NS(CLK_PER_NS),
    .PULSE_PER_NS(TP_CYCLE),
    .BPMPER_REG_SIZE(`BPMPER_REG_SIZE)
) inst_percount (
    .clk_i(clk_i),
    .rst_i(rst),
    .tp_i(tp),
    .btn_i(btn_d),
    .btn_per_o(btn_per),
    .btn_per_valid(btn_per_valid));

/* convert period in bpm */
`define BPM_SIZE ($clog2(BPM_MAX + 1))
reg [(`BPM_SIZE -1):0] bpm;
reg bpm_valid;
per2bpm #(
    .CLK_PER_NS(CLK_PER_NS),
    .TP_CYCLE(TP_CYCLE),
    .BPM_MAX(BPM_MAX)
) inst_per2bpm (
    .clk_i(clk_i),
    .rst_i(rst),
    .btn_per_i(btn_per),
    .btn_per_valid(btn_per_valid),
    .bpm_o(bpm),
    .bpm_valid(bpm_valid)
);

/* output pwm */
pwmgen #(.BPM_MAX(BPM_MAX)) inst_pwmgen (
    .clk_i(clk_i),
    .rst_i(rst),
    .tp_i(tp),
    .bpm_i(bpm),
    .bpm_valid(bpm_valid),
    .pwm_o(pwm_o));

endmodule
