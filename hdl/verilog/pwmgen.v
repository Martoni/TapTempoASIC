`timescale 1ns/1ps
/* Debouncer
* The TapTempo Project
* Fabien Marteau <mail@fabienm.eu>
*/

module pwmgen #(
`ifdef FORMAL
    parameter BPM_MAX = 20
`else
    parameter BPM_MAX = 250
`endif
)(
    /* clock and reset */
    input clk_i,
    input rst_i,
    /* timepulse */
    input tp_i,
    /* input value */
    input [($clog2(BPM_MAX+1)-1):0] bpm_i,
    input bpm_valid,
    /* output */
    output pwm_o);

reg [($clog2(BPM_MAX+1)-1):0] bpm_reg;
reg [($clog2(BPM_MAX+1)-1):0] pwmthreshold;
reg [($clog2(BPM_MAX+1)-1):0] count;

/* Latching bpm_i on bpm_valid */
always@(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
    begin
        bpm_reg <= 0;
        pwmthreshold <= 0;
    end else begin
        if(bpm_valid)
            bpm_reg <= bpm_i;
        if(count == BPM_MAX)
            pwmthreshold <= bpm_reg;
    end
end

/* count */
always@(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
        count <= BPM_MAX;
    else begin
        if(tp_i)
        begin
            if (count == 0)
                count <= BPM_MAX;
            else
                count <= count - 1'b1;
        end
    end
end

assign pwm_o = (count <= pwmthreshold);

/*********************/
/* Yosys formal part */
/*********************/
`ifdef FORMAL

reg past_valid;
reg [7:0] cycle_count = 0;

initial begin
    past_valid <= 1'b0;
    assume(rst_i);
end

always @(posedge clk_i)
begin
	past_valid <= 1'b1;


    if(past_valid)
        assume(!rst_i);

    /* send one valid */
    if(past_valid && $past(rst_i))
        assume(bpm_valid);

    /* timepulse is 1 clock width */
    if(past_valid && $past(tp_i) && !rst_i)
        assume(tp_i == 0);

    /* prove that bpm_reg is latched on bpm_valid signal */
    if(!$past(rst_i) && $past(bpm_valid) && past_valid)
        assert($past(bpm_i) == bpm_reg);

    if(past_valid && $past(pwmthreshold) == BPM_MAX)
        assert(pwm_o);

    if(count == 0 && tp_i)
        cycle_count <= cycle_count + 1'b1;

    assume(bpm_i == BPM_MAX/2);
    cover(cycle_count == 2);
end
`endif

endmodule
