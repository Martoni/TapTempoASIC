`timescale 1ns/1ps
/* Debouncer
* The TapTempo Project
* Fabien Marteau <mail@fabienm.eu>
*/

module timepulse #(
    parameter CLK_PER_NS = 40,
    parameter PULSE_PER_NS = 5120
)(
    /* clock and reset */
    input clk_i,
    input rst_i,
    /* output */
    output reg tp_o);

`define MAX_COUNT (PULSE_PER_NS/CLK_PER_NS)
`define MAX_COUNT_SIZE ($clog2(`MAX_COUNT))

/* Display parameters in simulation */
initial
begin
    $display("CLK_PER_NS     : %d", CLK_PER_NS );
    $display("PULSE_PER_NS   : %d", PULSE_PER_NS);
    $display("MAX_COUNT      : %x", `MAX_COUNT);
    $display("MAX_COUNT_SIZE : %x", `MAX_COUNT_SIZE);
end


reg [`MAX_COUNT_SIZE-1:0] counter = 0;

always@(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
    begin
        counter <= 0;
        tp_o <= 0;
    end else begin
        if (counter < `MAX_COUNT)
        begin
            counter <= counter + 1'b1;
            tp_o <= 0;
        end else begin
            tp_o <= 1;
            counter <= 0;
        end
    end
end

/*********************/
/* Yosys formal part */
/*********************/
`ifdef FORMAL

    reg past_valid;

    initial begin
        past_valid <= 1'b0;
    end

always @(posedge clk_i) begin
	past_valid <= 1'b1;

    /* tp_o must be 1 cycle length */
    if(tp_o == 1'b1 && past_valid)
        assert($past(tp_o, 1) == !tp_o);

    /* counter should increase by 1 */
    if((counter != 0) && (counter != `MAX_COUNT) && past_valid && !rst_i)
        assert($past(counter) + 1'b1 == counter);

    cover(tp_o);
//    cover(counter == `MAX_COUNT);
end

`endif

endmodule
