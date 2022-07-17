module ret_buf_i(
    input clk,
    input[31:0] r_data_AXI,
    input ret_valid, ret_last,
    output reg [511:0] mem_din,
    output reg fill_finish
    );
    reg ret_valid_pos;
    always @(posedge clk) begin
        ret_vlaid_pos <= ret_valid;
    end

    always @(posedge clk) begin
        if(ret_valid)begin
            mem_din = (mem_din >> 32) | {r_data_AXI, 480'b0};
        end
        if(!ret_valid_pos & ret_valid) fill_finish = 1;
        else fill_finish = 0;
    end
endmodule
