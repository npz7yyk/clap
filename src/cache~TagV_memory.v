`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module TagV_memory(
    input clk,
    input [31:0] r_addr,
    input [31:0] w_addr,
    input [31:0] addr_rbuf,
    input [19:0] tag,
    input [3:0] we,
    input tagv_clear,
    input ibar_clear,
    input [5:0] ibar_tagv_addr,
    output [3:0] hit,
    output cache_hit
    );
    wire [5:0] index, index_w, index_win;
   // wire [19:0] tag;
    wire [19:0] tag_0, tag_1, tag_2, tag_3;
    wire vld_0, vld_1, vld_2, vld_3;
    wire [20:0] tagv_din;

    assign index = r_addr[11:6];
    assign index_w = tagv_clear ? addr_rbuf[11:6] : w_addr[11:6];
    //assign tag = w_addr[31:12];
    assign tagv_din = tagv_clear ? 0 : {1'b1, w_addr[31:12]};
    assign index_win = ibar_clear ? ibar_tagv_addr : index_w;
    

    assign hit[0] = (tag == tag_0) && vld_0;
    assign hit[1] = (tag == tag_1) && vld_1;
    assign hit[2] = (tag == tag_2) && vld_2;
    assign hit[3] = (tag == tag_3) && vld_3;

    assign cache_hit = |hit;
    TagV way0_TagV(
        .addra  (index_win),
        .clka   (clk),
        .dina   (tagv_din),
        .wea    (we[0]),
        .addrb  (index),
        .doutb  ({vld_0, tag_0})
    );
    TagV way1_TagV(
        .addra  (index_win),
        .clka   (clk),
        .dina   (tagv_din),
        .wea    (we[1]),
        .addrb  (index),
        .doutb  ({vld_1, tag_1})
    );
    TagV way2_TagV(
        .addra  (index_win),
        .clka   (clk),
        .dina   (tagv_din),
        .wea    (we[2]),
        .addrb  (index),
        .doutb  ({vld_2, tag_2})
    );
    TagV way3_TagV(
        .addra  (index_win),
        .clka   (clk),
        .dina   (tagv_din),
        .wea    (we[3]),
        .addrb  (index),
        .doutb  ({vld_3, tag_3})
    );

endmodule
