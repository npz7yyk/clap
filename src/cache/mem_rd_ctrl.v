`timescale 1ns / 1ps
module mem_rd_ctrl(
    input [3:0] bank_sel,
    input [2047:0] mem_dout,
    input [31:0] mem_din,
    input [3:0] hit,
    input [3:0] way_sel,
    input forwarding,
    output [31:0] r_data,
    output reg [511:0] w_data_AXI_all
    );
    parameter HIT0 = 4'b1;
    parameter HIT1 = 4'b10;
    parameter HIT2 = 4'b100;
    parameter HIT3 = 4'b1000;
    reg [511:0] mem_dout_way;
    reg [31:0] r_data_normal;
    always @(*) begin
        case(hit)
        HIT0: mem_dout_way = mem_dout[511:0];
        HIT1: mem_dout_way = mem_dout[1023:0];
        HIT2: mem_dout_way = mem_dout[1535:1024];
        HIT3: mem_dout_way = mem_dout[2047:1536];
        default: mem_dout_way = 0;
        endcase
    end
    always @(*) begin
        case(bank_sel)
        4'h0: r_data_normal = mem_dout_way[31:0];
        4'h1: r_data_normal = mem_dout_way[63:32];
        4'h2: r_data_normal = mem_dout_way[95:64];
        4'h3: r_data_normal = mem_dout_way[127:96];
        4'h4: r_data_normal = mem_dout_way[159:128];
        4'h5: r_data_normal = mem_dout_way[191:160];
        4'h6: r_data_normal = mem_dout_way[223:192];
        4'h7: r_data_normal = mem_dout_way[255:224];
        4'h8: r_data_normal = mem_dout_way[287:256];
        4'h9: r_data_normal = mem_dout_way[319:288];
        4'ha: r_data_normal = mem_dout_way[351:320];
        4'hb: r_data_normal = mem_dout_way[383:352];
        4'hc: r_data_normal = mem_dout_way[415:384];
        4'hd: r_data_normal = mem_dout_way[447:416];
        4'he: r_data_normal = mem_dout_way[479:448];
        4'hf: r_data_normal = mem_dout_way[511:480];
        endcase
    end
    assign r_data = forwarding ? mem_din : r_data_normal;
    always @(*) begin
        case(way_sel)
        HIT0: w_data_AXI_all = mem_dout[511:0];
        HIT1: w_data_AXI_all = mem_dout[1023:0];
        HIT2: w_data_AXI_all = mem_dout[1535:1024];
        HIT3: w_data_AXI_all = mem_dout[2047:1536];
        default: w_data_AXI_all = 0;
        endcase
    end
endmodule
