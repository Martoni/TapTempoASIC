module per2bpm_tb;

    per2bpm DUT (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .btn_per_i(btn_per_i),
        .btn_per_valid(btn_per_valid),
        .bpm_o(bpm_o),
        .bpm_valid(bpm_valid));


  assert property (
    @(posedge clk_i) $rose(rst_i) |-> DUT.divisor == 0);

endmodule
