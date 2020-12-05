module per2bpm_tb;

    per2bpm DUT (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .btn_per_i(btn_per_i),
        .btn_per_valid(btn_per_valid),
        .bpm_o(bpm_o),
        .bpm_valid(bpm_valid));


    reg past_valid;
    
    initial begin
        past_valid <= 1'b0;
        assume(rst_i);
    end

    always @(posedge clk_i)
    begin
        if(rst_i)
            assert(bpm_o == 1'b0);
    end

endmodule
