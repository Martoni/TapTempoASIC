`timescale 1ns/1ps
/* Debouncer
* The TapTempo Project
* Fabien Marteau <mail@fabienm.eu>
* bpm_o = (MIN_NS/TP_CYCLE)/btn_per_i
*/

`define BPM_SIZE ($clog2(BPM_MAX + 1))

`define MIN_NS 60_000_000_000
`define BTN_PER_MAX ((`MIN_NS/CLK_PER_NS)/TP_CYCLE)
`define BTN_PER_SIZE ($clog2(1 + `BTN_PER_MAX))
`define BTN_PER_MIN ((`MIN_NS/(TP_CYCLE*CLK_PER_NS))/BPM_MAX)

module per2bpm #(
    parameter CLK_PER_NS = 40,
    parameter TP_CYCLE = 5120,
    parameter BPM_MAX = 250
)(
    /* clock and reset */
    input clk_i,
    input rst_i,

    /* inputs */
    input [(`BTN_PER_SIZE-1):0] btn_per_i,
    input btn_per_valid,

    /* outputs */
    output [`BPM_SIZE - 1:0] bpm_o,
    output bpm_valid
);

`define DIVIDENTWITH ($clog2(1 + `MIN_NS/(TP_CYCLE*CLK_PER_NS)))
`define REGWIDTH (`BTN_PER_SIZE + `DIVIDENTWITH)

reg [(`REGWIDTH-1):0] divisor;
reg [(`REGWIDTH-1):0] remainder;
reg [(`REGWIDTH-1):0] quotient;
reg [($clog2(`REGWIDTH + 1)):0] ctrlcnt;

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
            if(btn_per_i < `BTN_PER_MIN)
                divisor <= {`BTN_PER_MIN, (`DIVIDENTWITH)'h0};
            else
                divisor <= {btn_per_i, (`DIVIDENTWITH)'h0};
            remainder <= `MIN_NS/(TP_CYCLE*CLK_PER_NS);
            quotient <= 0;
            ctrlcnt <= `DIVIDENTWITH;
        end else if(state_reg == s_compute)
        begin
            if(divisor <= remainder)
            begin
                remainder <= remainder - divisor;
                quotient <= {quotient[(`DIVIDENTWITH-2):0], 1'b1};
            end else begin
                quotient <= {quotient[(`DIVIDENTWITH-2):0], 1'b0};
            end
            divisor <= {1'b0, divisor[(`REGWIDTH-1):1]};
            ctrlcnt <= ctrlcnt - 1'b1;
        end
    end
end

assign bpm_o = quotient[(`BPM_SIZE-1):0];
assign bpm_valid = (state_reg == s_result);

/*********************/
/* Yosys formal part */
/*********************/
`ifdef FORMAL

reg past_valid;
reg [(`BTN_PER_SIZE - 1):0] fdivident;

initial begin
    past_valid <= 1'b0;
    assume(rst_i);
    fdivident <= 0;
end

always @(posedge clk_i)
begin
    past_valid <= 1'b1;
    if(past_valid)
        assume(!rst_i);

    if(rst_i)
        assert(ctrlcnt == `REGWIDTH);

    if(state_reg == s_init)
        fdivident <=  btn_per_i;

    /* verify division result */
    if(state_reg == s_result)
        if(fdivident < `BTN_PER_MIN)
            assert(bpm_o == BPM_MAX);
        else
            assert(bpm_o == (`MIN_NS/(TP_CYCLE*CLK_PER_NS))/fdivident);

    assert(state_reg  != 2'h3);
    assert(bpm_o <= BPM_MAX);
    cover(state_reg == s_init);
    cover(state_reg == s_compute);
    cover(state_reg == s_result);
end

`endif

endmodule
