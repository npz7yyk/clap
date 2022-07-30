`include "clap_config.vh"

/* for each way, there are 16 banks, whose width is 4bytes */
/* verilator lint_off DECLFILENAME */
module memory(
    input clk,
    input [31:0] r_addr,
    input [31:0] w_addr,
    input [511:0] mem_din,
    input [63:0] mem_we,
    input [3:0] mem_en,
    output [2047:0] mem_dout
    );
    wire [5:0] r_index, w_index;
    wire [511:0] mem_dout0, mem_dout1, mem_dout2, mem_dout3;

    assign r_index = r_addr[11:6];
    assign w_index = w_addr[11:6];
    assign mem_dout = {
        mem_dout3, mem_dout2, mem_dout1, mem_dout0
    };
    cache_memory way0(
        .addra  (w_index),
        .clka   (clk),
        .dina   (mem_din),
        .ena    (mem_en[0]),
        .wea    (mem_we),
        .addrb  (r_index),
        .doutb  (mem_dout0)
    );
    cache_memory way1(
        .addra  (w_index),
        .clka   (clk),
        .dina   (mem_din),
        .ena    (mem_en[1]),
        .wea    (mem_we),
        .addrb  (r_index),
        .doutb  (mem_dout1)
    );
    cache_memory way2(
        .addra  (w_index),
        .clka   (clk),
        .dina   (mem_din),
        .ena    (mem_en[2]),
        .wea    (mem_we),
        .addrb  (r_index),
        .doutb  (mem_dout2)
    );
    cache_memory way3(
        .addra  (w_index),
        .clka   (clk),
        .dina   (mem_din),
        .ena    (mem_en[3]),
        .wea    (mem_we),
        .addrb  (r_index),
        .doutb  (mem_dout3)
    );
endmodule
