`timescale 1ns / 1ps
module ret_buf_i(
    input clk,
    input[31:0] r_data_AXI,
    input ret_valid, ret_last,
    output reg [511:0] mem_din,
    output reg fill_finish
    );
    always @(posedge clk) begin
        if(ret_valid)begin
            mem_din = (mem_din >> 32) | {r_data_AXI, 480'b0};
        end
        if(ret_last) fill_finish = 1;
        else fill_finish = 0;
    end
endmodule
