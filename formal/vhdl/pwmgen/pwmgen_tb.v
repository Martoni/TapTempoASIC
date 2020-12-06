module pwmgen_tb;

    reg clk_i = 0;
    reg rst_i = 0;
    reg tp_i = 0;
    reg [7:0] bpm_i;
    reg [7:0] bpm_reg;
    reg pwm_o;
    reg bpm_valid = 0;

    localparam CLK_PER_NS = 40; // 25Mhz clock
    localparam TP_CYCLE = 5120; // Number of cycles per timepulse
    localparam BPM_MAX = 250;
    localparam MIN_NS = 60_000_000_000;
    localparam MIN_US = 60_000_000;
    localparam BTN_PER_MIN = 1000*(MIN_US/TP_CYCLE)/BPM_MAX;

    pwmgen DUT (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .tp_i (tp_i),
        .bpm_i (bpm_i),
        .bpm_valid (bpm_valid),
        .pwm_o (pwm_o)
    );

    reg past_valid;

    initial begin
        past_valid <= 1'b0;
        assume(rst_i);
        bpm_i <= 0;
    end

    always @(posedge clk_i or posedge rst_i)
    begin
        if(rst_i)
            bpm_reg <= 0;
        else
            if(bpm_valid)
                bpm_reg <= bpm_i;
    end


    always @(posedge clk_i)
    begin
        /* reset conditions */
        past_valid <= 1'b1;

        /* see one result */
        cover(pwm_o == 1);
    end

endmodule
