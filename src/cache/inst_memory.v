`timescale 1ns / 1ps
/* for each way, there are 16 banks, whose width is 4bytes */
module inst_memory(
    input clk,
    input [31:0] r_addr,
    input [31:0] w_addr,
    input [511:0] mem_din,
    input [3:0] mem_we,
    output [2047:0] mem_dout
    );
    wire [5:0] r_index, w_index;
    wire [511:0] mem_dout0, mem_dout1, mem_dout2, mem_dout3;

    assign r_index = r_addr[11:6];
    assign w_index = w_addr[11:6];
    assign mem_dout = {
        mem_dout3, mem_dout2, mem_dout1, mem_dout0
    };
    inst_cache_memory way0(
        .addra  (w_index),
        .clka   (clk),
        .dina   (mem_din),
        .wea    (mem_we[0]),
        .addrb  (r_index),
        .doutb  (mem_dout0)
    );
    inst_cache_memory way1(
        .addra  (w_index),
        .clka   (clk),
        .dina   (mem_din),
        .wea    (mem_we[1]),
        .addrb  (r_index),
        .doutb  (mem_dout1)
    );
    inst_cache_memory way2(
        .addra  (w_index),
        .clka   (clk),
        .dina   (mem_din),
        .wea    (mem_we[2]),
        .addrb  (r_index),
        .doutb  (mem_dout2)
    );
    inst_cache_memory way3(
        .addra  (w_index),
        .clka   (clk),
        .dina   (mem_din),
        .wea    (mem_we[3]),
        .addrb  (r_index),
        .doutb  (mem_dout3)
    );
endmodule