`timescale 1ns/1ps
/* Debouncer
* The TapTempo Project
* Fabien Marteau <mail@fabienm.eu>
*/

`define BPM_PER_MAX 62_600


module percount #(
    parameter CLK_PER_NS = 40,
    parameter PULSE_PER_NS = 5120,
    parameter BPMPER_REG_SIZE = $clog2(`BPM_PER_MAX + 1)
)(
    /* clock and reset */
    input clk_i,
    input rst_i,
    /* time pulse */
    input tp_i,
    /* input button */
    input btn_i,
    /* output period */
    output [BPMPER_REG_SIZE:0] btn_per_o,
    output btn_per_valid);

/* Display parameters in simulation */
initial
begin
    $display("CLK_PER_NS   : %d", CLK_PER_NS );
    $display("PULSE_PER_NS : %d", PULSE_PER_NS);
    $display("BPM_PER_MAX  : %d", `BPM_PER_MAX);
    $display("BPMPER_REG_SIZE  : %d", BPMPER_REG_SIZE);
end

reg [BPMPER_REG_SIZE:0] counter = 0;
reg counter_valid = 0;

assign btn_per_valid = counter_valid;
assign btn_per_o = counter;

reg btn_old;
wire btn_rise = (!btn_old) & btn_i;

always@(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
        btn_old <= btn_i;
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
            counter_valid <= 1'b1;
        end else 
        begin
            counter_valid <= 1'b0;
            /* stop counting if max, count tp_i */
            if(tp_i && counter < `BPM_PER_MAX)
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
        /* push reset at begin */
        assume(rst_i);
    end

always @(posedge clk_i) begin
	past_valid <= 1'b1;

    /* tp_i is one cycle length */
    if(tp_i && !rst_i && past_valid)
        assume(!$past(tp_i));

    /* btn_rise is one cycle length */
    if(btn_rise && !rst_i && past_valid)
        assert(!$past(btn_rise));

    /* When tp_i==1, counter increase if btn_o not rising and counter less
    * than `BPM_PER_MAX*/
    if(past_valid && !rst_i && $past(tp_i) &&
        !$past(btn_rise) && counter!=0 && (counter < `BPM_PER_MAX))
        assert(counter == $past(counter) + 1'b1);

    /* when btn_i rose, counter is reset and valid is 1 */
    if(past_valid && !rst_i && $past(btn_rise))
    begin
        assert(counter == 1'b0);
        assert(counter_valid == 1'b1);
    end

    if(past_valid)
        assert(counter <= `BPM_PER_MAX);

    cover(counter_valid);
end
`endif

endmodule
