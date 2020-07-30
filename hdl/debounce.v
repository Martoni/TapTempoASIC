`timescale 1ns/1ps
/* Debouncer
* The TapTempo Project
* Fabien Marteau <mail@fabienm.eu>
*/

module Debounce #(
//    parameter CLK_PER_NS = 40,
    parameter PULSE_PER_NS = 4096,
    parameter DEBOUNCE_PER_NS = 16_777_216
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


`define MAX_COUNT (DEBOUNCE_PER_NS/PULSE_PER_NS)
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
                state_next <= s_cnt_high;
            else
                state_next <= s_wait_low;
        s_wait_high:
            if(!btn_i)
                state_next <= s_cnt_low;
            else
                state_next <= s_wait_high;
        s_cnt_high:
            if(counter == `MAX_COUNT)
                state_next <= s_wait_high;
            else
                state_next <= s_cnt_high;
        s_cnt_low:
            if(counter == `MAX_COUNT)
                state_next <= s_wait_low;
            else
                state_next <= s_cnt_low;
    endcase;
end

assign btn_o = (state_reg == s_cnt_high) || (state_reg == s_wait_high);

endmodule
