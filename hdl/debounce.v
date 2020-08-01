`timescale 1ns/1ps
/* Debouncer
* The TapTempo Project
* Fabien Marteau <mail@fabienm.eu>
*/

module debounce #(
//    parameter CLK_PER_NS = 40,
    parameter PULSE_PER_NS = 5120,
`ifdef COCOTB_SIM
    parameter DEBOUNCE_PER_NS = (5120*8)
`else
    parameter DEBOUNCE_PER_NS = 20_971_520
`endif
)(
    /* clock and reset */
    input clk_i,
    input rst_i,
    /* inputs */
    input tp_i,
    input btn_i,
    /* output */
    output btn_o
);

`define MAX_COUNT ((DEBOUNCE_PER_NS/PULSE_PER_NS)-1'b1)
`define MAX_COUNT_SIZE ($clog2(`MAX_COUNT))

/* Counter */
reg [`MAX_COUNT_SIZE-1:0] counter;

always@(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
        counter <= 0;
    else begin
        if(tp_i) begin
            if((state_reg == s_cnt_high) || (state_reg == s_cnt_low))
                counter <= counter + 1'b1;
            else
                counter <= 0;
        end
    end
end

/* State machine */
localparam [1:0] s_wait_low  = 2'h0,
                 s_wait_high = 2'h1,
                 s_cnt_high  = 2'h2,
                 s_cnt_low   = 2'h3;

reg [1:0] state_reg, state_next;

always@(posedge clk_i or posedge rst_i)
    if(rst_i)
        state_reg <= s_wait_low;
    else
        state_reg <= state_next;

always@*
begin
    case(state_reg)
        s_wait_low:
            if(btn_i)
                state_next = s_cnt_high;
            else
                state_next = s_wait_low;
        s_wait_high:
            if(!btn_i)
                state_next = s_cnt_low;
            else
                state_next = s_wait_high;
        s_cnt_high:
            /* verilator lint_off WIDTH */
            if(counter == `MAX_COUNT)
            /* verilator lint_on WIDTH */
                state_next = s_wait_high;
            else
                state_next = s_cnt_high;
        s_cnt_low:
            /* verilator lint_off WIDTH */
            if(counter == `MAX_COUNT)
            /* verilator lint_on WIDTH */
                state_next = s_wait_low;
            else
                state_next = s_cnt_low;
    endcase;
end

assign btn_o = (state_reg == s_cnt_high) || (state_reg == s_wait_high);

`ifdef COCOTB_ICARUS
initial begin
  $dumpfile ("debounce.vcd");
  $dumpvars (0, debounce);
  #1;
end
`endif

`ifdef FORMAL

initial
    counter <= 0;

always@*
begin
    assume(rst_i == 0);
    assert(counter < `MAX_COUNT);
end

always@(posedge clk_i) begin
    if(state_reg == s_wait_high)
        assert(counter == 0);
end
`endif

endmodule
