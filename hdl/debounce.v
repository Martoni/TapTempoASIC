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

`ifdef FORMAL
    `define MAX_COUNT (20)
`else
    `define MAX_COUNT ((DEBOUNCE_PER_NS/PULSE_PER_NS)-1'b1)
`endif 
`define MAX_COUNT_SIZE ($clog2(`MAX_COUNT))

/* Counter */
reg [`MAX_COUNT_SIZE-1:0] counter = 0;

/* Display parameters in simulation */
initial
begin
    $display("DEBOUNCE_PER_NS : %d", DEBOUNCE_PER_NS);
    $display("PULSE_PER_NS    : %d", PULSE_PER_NS);
    $display("MAX_COUNT       : %x", `MAX_COUNT);
    $display("MAX_COUNT_SIZE  : %x", `MAX_COUNT_SIZE);
end

always@(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
        counter <= 0;
    else
    begin
        if((state_reg == s_cnt_high) || (state_reg == s_cnt_low))
        begin
            if(tp_i)
                counter <= counter + 1'b1;
        end else
            counter <= 0;
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

/****************************/
/* Cocotb icarus simulation */
/****************************/
`ifdef COCOTB_ICARUS
initial begin
  $dumpfile ("debounce.vcd");
  $dumpvars (0, debounce);
  #1;
end
`endif

/*********************/
/* Yosys formal part */
/*********************/
`ifdef FORMAL

initial begin
    past_valid <= 1'b0;
    rst_i <= 1'b1;
end

always @(posedge clk_i) begin
	past_valid <= 1'b1;
    assume(rst_i == 0);

    /* tp_i must be 1 cycle length */
    if(tp_i == 1 && past_valid)
        assume($past(tp_i, 1) == !tp_i);
end

always @(posedge clk_i) begin
    /* counter increase on tp_i */
    if(tp_i && counter > 0 && past_valid)
        assert($past(counter) + 1 == counter);

    /* btn_o is stable if counter count */
    if(counter > 0)
        assert($stable(btn_o));

    cover(counter == `MAX_COUNT);
    cover(counter == $past(counter) + 1);

//    cover(state_reg == s_cnt_high);
//    cover(state_reg == s_wait_low);
//    cover(state_reg == s_wait_highend);
//    cover(state_reg == s_cnt_high);
//    cover(state_reg == s_cnt_low);

end

`endif

endmodule
