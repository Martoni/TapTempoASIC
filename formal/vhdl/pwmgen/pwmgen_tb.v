module pwmgen_tb;

    reg clk_i;
    reg rst_i;
    wire [7:0] bpm_i;
    wire bpm_valid;

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
    end

    // manage formal registers
    always @(posedge clk_i or posedge rst_i)
    begin
        if(rst_i) begin
            btn_reg_input <= 24'h000000;
            btn_reg_ready <= 1'b1;
            bpm_theory <= 8'd0;
        end else begin
            bpm_theory <= (1000*(MIN_US/TP_CYCLE)/btn_reg_input);
            if(btn_per_valid && btn_reg_ready)
            begin
                if(btn_per_i < BTN_PER_MIN)
                    btn_reg_input = BTN_PER_MIN;
                else
                    btn_reg_input <= btn_per_i;
                btn_reg_ready <= 1'b0;
            end
            if(bpm_valid && !btn_reg_ready)
                btn_reg_ready <= 1'b1;
        end
    end

    always @(posedge clk_i)
    begin
        /* reset conditions */
        past_valid <= 1'b1;
        if(rst_i) begin
            assert(bpm_valid == 1'b0);
            assume(btn_per_valid == 1'b0);
        end

        /* is result good ? */
        if(bpm_valid) begin
            if(btn_reg_input == 0)
                assert(bpm_o == BPM_MAX);
            else
                if(bpm_theory >= BPM_MAX)
                    assert(bpm_o == BPM_MAX)
                else
                    assert(bpm_o == bpm_theory);
        end

        /* see one result */
        cover(bpm_valid == 1);
    end

endmodule
