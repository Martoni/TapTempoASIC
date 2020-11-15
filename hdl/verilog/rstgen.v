`timescale 1ns/1ps
/* Debouncer
* The TapTempo Project
* Fabien Marteau <mail@fabienm.eu>
*/

module rstgen (
    input clk_i,
    output rst_o
);


reg [2:0] rst_count;

initial
    rst_count <= 3'b000;

always @(posedge clk_i) begin
    if (rst_count != 3'b100)
        rst_count = rst_count + 3'b1;
end

assign rst_o = !rst_count[2];

/*********************/
/* Yosys formal part */
/*********************/
`ifdef FORMAL

reg past_valid;
reg [7:0] cycle_count = 0;

initial begin
    past_valid <= 1'b0;
    assert(rst_o);
end

always@(posedge clk_i)
begin
    cover(!rst_o);
    if(rst_count >= 3'b100)
        assert(!rst_o);
end

`endif

endmodule

