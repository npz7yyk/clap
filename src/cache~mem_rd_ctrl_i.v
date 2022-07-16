module mem_rd_ctrl_i(
    input [31:0] addr_rbuf,
    input [3:0] r_way_sel,
    input [2047:0] mem_dout,
    input [511:0] r_data_AXI,
    input rdata_sel,
    output reg [63:0] r_data
    );
    parameter HIT0 = 4'b0001;
    parameter HIT1 = 4'b0010;
    parameter HIT2 = 4'b0100;
    parameter HIT3 = 4'b1000;
    reg [511:0] way_data;
    reg [63:0] r_data_mem, r_word_AXI;
    always @(*)begin
        case(r_way_sel)
        HIT0: way_data = mem_dout[511:0];
        HIT1: way_data = mem_dout[1023:512];
        HIT2: way_data = mem_dout[1535:1024];
        HIT3: way_data = mem_dout[2047:1536];
        default: way_data = 0;
        endcase
    end
    always @(*) begin
        case(addr_rbuf[5:3])
        3'd0: r_data_mem = way_data[63:0];
        3'd1: r_data_mem = way_data[127:64];
        3'd2: r_data_mem = way_data[191:128];
        3'd3: r_data_mem = way_data[255:192];
        3'd4: r_data_mem = way_data[319:256];
        3'd5: r_data_mem = way_data[383:320];
        3'd6: r_data_mem = way_data[447:384];
        3'd7: r_data_mem = way_data[511:448];
        endcase
    end
    always @(*) begin
        case(addr_rbuf[5:3])
        3'd0: r_word_AXI = r_data_AXI[63:0];
        3'd1: r_word_AXI = r_data_AXI[127:64];
        3'd2: r_word_AXI = r_data_AXI[191:128];
        3'd3: r_word_AXI = r_data_AXI[255:192];
        3'd4: r_word_AXI = r_data_AXI[319:256];
        3'd5: r_word_AXI = r_data_AXI[383:320];
        3'd6: r_word_AXI = r_data_AXI[447:384];
        3'd7: r_word_AXI = r_data_AXI[511:448];
        endcase
    end
    always @(*)begin
        case(rdata_sel)
        1'b0: r_data = r_word_AXI;
        1'b1: r_data = r_data_mem;
        endcase
    end
endmodule
