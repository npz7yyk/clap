`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module mem_rd_ctrl_d(
    input [31:0] addr_rbuf,
    input [31:0] w_data_CPU,
    input [3:0] r_way_sel,
    input [2047:0] mem_dout,
    input [511:0] r_data_AXI,
    input r_data_sel,
    input [3:0] read_type_rbuf,
    input uncache_rbuf,
    input signed_ext,
    input [3:0] miss_way_sel,
    input cacop_en_rbuf,
    input [1:0]cacop_code_rbuf,
    input llbit_rbuf,
    input is_atom_rbuf,
    input op_rbuf,
    output [511:0] miss_sel_data,
    output reg [31:0] r_data
    );
    
    parameter HIT0 = 4'b0001;
    parameter HIT1 = 4'b0010;
    parameter HIT2 = 4'b0100;
    parameter HIT3 = 4'b1000;

    parameter M_SEL0 = 4'b0001;
    parameter M_SEL1 = 4'b0010;
    parameter M_SEL2 = 4'b0100;
    parameter M_SEL3 = 4'b1000;

    parameter BYTE = 4'b0001;
    parameter HALF = 4'b0011;
    parameter WORD = 4'b1111;

    reg [31:0] r_data_mem, r_word_AXI;
    reg [511:0] way_data;

    reg [31:0] r_data_CPU;

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
        case(addr_rbuf[5:2])
        4'd0: r_data_mem = way_data[31:0];
        4'd1: r_data_mem = way_data[63:32];
        4'd2: r_data_mem = way_data[95:64];
        4'd3: r_data_mem = way_data[127:96];
        4'd4: r_data_mem = way_data[159:128];
        4'd5: r_data_mem = way_data[191:160];
        4'd6: r_data_mem = way_data[223:192];
        4'd7: r_data_mem = way_data[255:224];
        4'd8: r_data_mem = way_data[287:256];
        4'd9: r_data_mem = way_data[319:288];
        4'd10: r_data_mem = way_data[351:320];
        4'd11: r_data_mem = way_data[383:352];
        4'd12: r_data_mem = way_data[415:384];
        4'd13: r_data_mem = way_data[447:416];
        4'd14: r_data_mem = way_data[479:448];
        4'd15: r_data_mem = way_data[511:480];
        endcase
    end
    always @(*) begin
        if(uncache_rbuf) r_word_AXI = r_data_AXI[31:0];
        else begin
            case(addr_rbuf[5:2])
            4'd0: r_word_AXI = r_data_AXI[31:0];
            4'd1: r_word_AXI = r_data_AXI[63:32];
            4'd2: r_word_AXI = r_data_AXI[95:64];
            4'd3: r_word_AXI = r_data_AXI[127:96];
            4'd4: r_word_AXI = r_data_AXI[159:128];
            4'd5: r_word_AXI = r_data_AXI[191:160];
            4'd6: r_word_AXI = r_data_AXI[223:192];
            4'd7: r_word_AXI = r_data_AXI[255:224];
            4'd8: r_word_AXI = r_data_AXI[287:256];
            4'd9: r_word_AXI = r_data_AXI[319:288];
            4'd10: r_word_AXI = r_data_AXI[351:320];
            4'd11: r_word_AXI = r_data_AXI[383:352];
            4'd12: r_word_AXI = r_data_AXI[415:384];
            4'd13: r_word_AXI = r_data_AXI[447:416];
            4'd14: r_word_AXI = r_data_AXI[479:448];
            4'd15: r_word_AXI = r_data_AXI[511:480];
        endcase
        end
    end

    always @(*) begin
        case(r_data_sel)
        1'b0: r_data_CPU = r_word_AXI;
        1'b1: r_data_CPU = r_data_mem;
        endcase
    end

    always @(*) begin
        if(is_atom_rbuf && op_rbuf == 1'b1) r_data = {31'b0, llbit_rbuf};
        else begin
            case(read_type_rbuf)
            BYTE: begin
                case(addr_rbuf[1:0])
                2'd0: r_data = {{24{r_data_CPU[7]&signed_ext}}, r_data_CPU[7:0]};
                2'd1: r_data = {{24{r_data_CPU[15]&signed_ext}}, r_data_CPU[15:8]};
                2'd2: r_data = {{24{r_data_CPU[23]&signed_ext}}, r_data_CPU[23:16]};
                2'd3: r_data = {{24{r_data_CPU[31]&signed_ext}}, r_data_CPU[31:24]};
                endcase
            end
            HALF: begin
                case(addr_rbuf[1:0])
                2'd0: r_data = {{16{r_data_CPU[15]&signed_ext}}, r_data_CPU[15:0]};
                2'd2: r_data = {{16{r_data_CPU[31]&signed_ext}}, r_data_CPU[31:16]};
                default: r_data = 0;
                endcase
            end
            WORD: r_data = r_data_CPU;
            default: r_data = 0;
        endcase
        end
    end
    assign miss_sel_data = {480'b0, w_data_CPU};
endmodule
