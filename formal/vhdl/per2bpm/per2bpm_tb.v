module per2bpm_tb;

    wire clk_i;
    wire rst_i;
    wire [23:0] btn_per_i;
    wire btn_per_valid;
    wire [7:0] bpm_o;
    wire bpm_valid;

    per2bpm DUT (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .btn_per_i(btn_per_i),
        .btn_per_valid(btn_per_valid),
        .bpm_o(bpm_o),
        .bpm_valid(bpm_valid));


    reg past_valid;
    
    initial begin
        assume(btn_per_i == 0);
        assume(btn_per_valid == 0);
        past_valid <= 1'b0;
        assume(rst_i);
    end

    always @(posedge clk_i)
    begin
        cover(bpm_valid == 1);
        if(rst_i)
            assert(bpm_o == 1'b0);
    end

    
endmodule
