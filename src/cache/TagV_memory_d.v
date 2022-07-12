`timescale 1ns / 1ps

module TagV_memory_d(
    input clk,
    input [31:0] r_addr,
    input [31:0] w_addr,
    input [3:0] we,
    input [3:0] way_sel,
    output [3:0] hit,
    output cache_hit,
    output reg [19:0] replace_tag,
    output reg replace_vld
    );
    parameter WAY0 = 4'b0001;
    parameter WAY1 = 4'b0010;
    parameter WAY2 = 4'b0100;
    parameter WAY3 = 4'b1000;
    wire [5:0] index, index_w;
    wire [19:0] tag;
    wire [19:0] tag_0, tag_1, tag_2, tag_3;
    wire vld_0, vld_1, vld_2, vld_3;

    assign index = r_addr[11:6];
    assign index_w = w_addr[11:6];
    assign tag = r_addr[31:12];

    assign hit[0] = (tag == tag_0) && vld_0;
    assign hit[1] = (tag == tag_1) && vld_1;
    assign hit[2] = (tag == tag_2) && vld_2;
    assign hit[3] = (tag == tag_3) && vld_3;

    assign cache_hit = |hit;

    always @(*) begin
        case(way_sel)
        WAY0: replace_tag = tag_0;
        WAY1: replace_tag = tag_1;
        WAY2: replace_tag = tag_2;
        WAY3: replace_tag = tag_3;
        default: replace_tag = 0;
        endcase
    end

    always @(*) begin
        case(way_sel)
        WAY0: replace_vld = vld_0;
        WAY1: replace_vld = vld_1;
        WAY2: replace_vld = vld_2;
        WAY3: replace_vld = vld_3;
        default: replace_vld = 0;
        endcase
    end
    TagV way0_TagV(
        .addra  (index_w),
        .clka   (clk),
        .dina   ({1'b1, w_addr[31:12]}),
        .wea    (we[0]),
        .addrb  (index),
        .doutb  ({vld_0, tag_0})
    );
    TagV way1_TagV(
        .addra  (index_w),
        .clka   (clk),
        .dina   ({1'b1, w_addr[31:12]}),
        .wea    (we[1]),
        .addrb  (index),
        .doutb  ({vld_1, tag_1})
    );
    TagV way2_TagV(
        .addra  (index_w),
        .clka   (clk),
        .dina   ({1'b1, w_addr[31:12]}),
        .wea    (we[2]),
        .addrb  (index),
        .doutb  ({vld_2, tag_2})
    );
    TagV way3_TagV(
        .addra  (index_w),
        .clka   (clk),
        .dina   ({1'b1, w_addr[31:12]}),
        .wea    (we[3]),
        .addrb  (index),
        .doutb  ({vld_3, tag_3})
    );

endmodule
