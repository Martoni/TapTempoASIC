`timescale 1ns/1ps
/* Debouncer
* The TapTempo Project
* Fabien Marteau <mail@fabienm.eu>
*/

`define BPM_PER_MAX 62_600


module percount #(
    parameter CLK_PER_NS = 40,
    parameter PULSE_PER_NS = 5120,
    parameter BPM_REG_SIZE = $clog2(`BPM_PER_MAX + 1)
)(
    /* clock and reset */
    input clk_i,
    input rst_i,
    /* time pulse */
    input tp_i,
    /* input button */
    input btn_i,
    /* output period */
    output [BPM_REG_SIZE:0] btn_per_o,
    output btn_per_valid);

/* Display parameters in simulation */
initial
begin
    $display("CLK_PER_NS   : %d", CLK_PER_NS );
    $display("PULSE_PER_NS : %d", PULSE_PER_NS);
    $display("BPM_PER_MAX  : %d", `BPM_PER_MAX);
    $display("BPM_REG_SIZE  : %d", BPM_REG_SIZE);
end

reg [BPM_REG_SIZE:0] counter = 0;

reg btn_old = 1'b0;
wire btn_rise = !btn_old & btn_i;

always@(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
        btn_old <= 0;
    else
    begin
        btn_old <= btn_i;     
    end
end


always@(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
    begin
        counter <= 0;
    end else begin
        if(btn_rise) 
        begin
            counter <= 0;
            btn_per_valid <= 1'b1;
        end else 
        begin
            btn_per_valid <= 1'b0;
            if(tp_i)
                counter <= counter + 1'b1;
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

end

`endif



endmodule
