`timescale 1ns / 1ps
/* for each way, there are 16 banks, whose width is 4bytes */
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
    // cache_memory way4(
    //     .addra  (w_index),
    //     .clka   (clk),
    //     .dina   (mem_din),
    //     .ena    (mem_en[4]),
    //     .wea    (mem_we),
    //     .addrb  (r_index),
    //     .clkb   (clk),
    //     .doutb  (mem_dout4)
    // );
    // cache_memory way5(
    //     .addra  (w_index),
    //     .clka   (clk),
    //     .dina   (mem_din),
    //     .ena    (mem_en[5]),
    //     .wea    (mem_we),
    //     .addrb  (r_index),
    //     .clkb   (clk),
    //     .doutb  (mem_dout5)
    // );
    // cache_memory way6(
    //     .addra  (w_index),
    //     .clka   (clk),
    //     .dina   (mem_din),
    //     .ena    (mem_en[6]),
    //     .wea    (mem_we),
    //     .addrb  (r_index),
    //     .clkb   (clk),
    //     .doutb  (mem_dout6)
    // );
    // cache_memory way7(
    //     .addra  (w_index),
    //     .clka   (clk),
    //     .dina   (mem_din),
    //     .ena    (mem_en[7]),
    //     .wea    (mem_we),
    //     .addrb  (r_index),
    //     .clkb   (clk),
    //     .doutb  (mem_dout7)
    // );

endmodule
    // mem_wr_ctrl mw_ctrl(
    //     .write_type (write_type),
    //     .w_data     (w_data),
    //     .bank_sel   (addr[5:2]),
    //     .hit        (hit),
    //     .we_sel0    (we_sel0),
    //     .we_sel1    (we_sel1),
    //     .we_sel2    (we_sel2),
    //     .we_sel3    (we_sel3),
    //     .we_sel4    (we_sel4),
    //     .we_sel5    (we_sel5),
    //     .we_sel6    (we_sel6),
    //     .we_sel7    (we_sel7),
    //     .mem_din    (mem_din)
    // );
    // mem_rd_ctrl mr_ctrl(
    //     .hit        (hit),
    //     .bank_sel   (addr[5:2]),
    //     .mem_dout0  (mem_dout0),
    //     .mem_dout1  (mem_dout1),
    //     .mem_dout2  (mem_dout2),
    //     .mem_dout3  (mem_dout3),
    //     .mem_dout4  (mem_dout4),
    //     .mem_dout5  (mem_dout5),
    //     .mem_dout6  (mem_dout6),
    //     .mem_dout7  (mem_dout7),
    //     .r_data     (r_data)
    // );
