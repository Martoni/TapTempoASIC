`timescale 1ns/1ps
/* Debouncer
* The TapTempo Project
* Fabien Marteau <mail@fabienm.eu>
* bpm_o = (MIN_NS/PULSE_PER_NS)/btn_per_i
*/

`define BPMPER_MAX 62_600
`define BPM_MAX 250
`define MIN_NS 60_000_000_000

module per2bpm #(
    parameter CLK_PER_NS = 40,
    parameter PULSE_PER_NS = 5120,
    parameter BPMPER_REG_SIZE = $clog2(1 + `BPMPER_MAX)
)(
    /* clock and reset */
    input clk_i,
    input rst_i,
    /* inputs */
    input [(BPMPER_REG_SIZE-1):0] btn_per_i,
    input btn_per_valid,
    /* outputs */
    output [$clog2(`BPM_MAX + 1) - 1:0] bpm_o,
    output bpm_valid
);

`define REGWIDTH (40)

reg [(`REGWIDTH-1):0] divisor;
reg [(`REGWIDTH-1):0] remainder;
reg [23:0] quotient;
reg [$clog2(`REGWIDTH + 1):0] ctrlcnt;

localparam [1:0] s_init    = 2'h0,
                 s_compute = 2'h1,
                 s_result  = 2'h2;

reg [1:0] state_reg, state_next;

always@(posedge clk_i or posedge rst_i)
    if(rst_i)
        state_reg <= s_init;
    else
        state_reg <= state_next;

always@*
begin
    case(state_reg)
        s_init:
            if(btn_per_valid)
                state_next = s_compute;
            else
                state_next = s_init;
        s_compute:
            if(ctrlcnt == 0)
                state_next = s_result;
            else
                state_next = s_compute;
        s_result:
            state_next = s_init;
        default:
            state_next = s_init;
    endcase
end


always@(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
    begin
        divisor <= 0;
        remainder <= 0;
        quotient <= 0;
        ctrlcnt <= `REGWIDTH;
    end else begin
        if(state_reg == s_init)
        begin
            divisor <= {btn_per_i, 23'h0};
            remainder <= `MIN_NS/PULSE_PER_NS;
            quotient <= 0;
            ctrlcnt <= `REGWIDTH;
        end else if(state_reg == s_compute)
        begin
            if(divisor < remainder)
            begin
                remainder <= divisor - remainder;
                quotient <= {quotient[22:0], 1'b1};
            end else begin
                quotient <= {quotient[22:0], 1'b0};
            end
            divisor <= {1'b0, divisor[(`REGWIDTH-1):1]};
            ctrlcnt <= ctrlcnt - 1'b1;
        end
    end
end

assign bpm_o = quotient[15:0];
assign bpm_valid = (state_reg == s_result);

/*********************/
/* Yosys formal part */
/*********************/
`ifdef FORMAL

reg past_valid;

initial begin
    past_valid <= 1'b0;
    assume(rst_i);
end

always @(posedge clk_i)
begin
    past_valid <= 1'b1;
    if(past_valid)
        assume(!rst_i);

    if(rst_i)
        assert(ctrlcnt == `REGWIDTH);

    assume(btn_per_i != 0);
    assume(btn_per_i <= `BPMPER_MAX);
    assert(state_reg  != 2'h3);
    cover(state_reg == s_init);
    cover(state_reg == s_compute);
    cover(state_reg == s_result);
end

`endif


endmodule
