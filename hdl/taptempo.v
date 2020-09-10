`timescale 1ns/1ps
/* 
* The TapTempo Project
* Fabien Marteau <mail@fabienm.eu>
*/

module taptempo #(
    parameter CLK_PER_NS = 40,     // 25Mhz clock
    parameter TP_CYCLE = 5120, // Number of cycles per timepulse
    parameter BPM_MAX = 250
)(
    input clk_i,
    input btn_i,
    output pwm_o
);

/* generate reset internally */
wire rst;
rstgen inst_rstgen (
    .clk_i(clk_i),
    .rst_o(rst));

/* TimePulse generation */
wire tp;
timepulse #(
    .CLK_PER_NS(CLK_PER_NS),
    .PULSE_PER_NS(TP_CYCLE)
) inst_timepulse (
    .clk_i(clk_i),
    .rst_i(rst),
    .tp_o(tp));

/* Synchronize btn_i to avoid metastability*/
reg btn_old, btn_s;
always@(posedge clk_i or posedge rst)
begin
    if(rst) begin
        btn_old <= 1'b0;
        btn_s <= 1'b0;
    end else begin
        btn_old <= btn_i;
        btn_s <= btn_old;
    end
end

/* then debounce */
wire btn_d;
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
wire [16:0] btn_per;
wire btn_per_valid;
percount #(
    .CLK_PER_NS(CLK_PER_NS),
    .PULSE_PER_NS(TP_CYCLE),
    .BPMPER_REG_SIZE(16)
) inst_percount (
    .clk_i(clk_i),
    .rst_i(rst),
    .tp_i(tp),
    .btn_i(btn_d),
    .btn_per_o(btn_per),
    .btn_per_valid(btn_per_valid));

/* convert period in bpm */
`define BPM_SIZE ($clog2(BPM_MAX + 1))
wire [(`BPM_SIZE -1):0] bpm;
wire bpm_valid;
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
