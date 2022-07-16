`include "exception.vh"
module TLB_found_signal#(
    parameter TLBNUM = 16
    )(
    input  [    TLBNUM*20-1:0]  all_pfn0,
    input  [     TLBNUM*2-1:0]  all_mat0,
    input  [     TLBNUM*2-1:0]  all_plv0,
    input  [       TLBNUM-1:0]  all_d0,
    input  [       TLBNUM-1:0]  all_v0,
    input  [       TLBNUM-1:0]  found0,
    input                       odd0_bit,
    input  [    TLBNUM*20-1:0]  all_pfn1,
    input  [     TLBNUM*2-1:0]  all_mat1,
    input  [     TLBNUM*2-1:0]  all_plv1,
    input  [       TLBNUM-1:0]  all_d1,
    input  [       TLBNUM-1:0]  all_v1,
    input  [       TLBNUM-1:0]  found1,
    input                       odd1_bit,

    output reg                  found_v0, 
    output reg                  found_v1,
    output reg                  found_d0, 
    output reg                  found_d1,
    output reg[            1:0] found_mat0, 
    output reg[            1:0] found_mat1,
    output reg[            1:0] found_plv0, 
    output reg[            1:0] found_plv1,
    output reg[           19:0] found_pfn0, 
    output reg[           19:0] found_pfn1

    );
    always @(*) begin
        found_v0 = 0;
        found_d0 = 0;
        found_mat0 = 0; 
        found_plv0 = 0; 
        found_pfn0 = 0;
        case(found0)
        16'h0001: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[0];
                found_d0   = all_d0[0];
                found_mat0 = all_mat0[1:0];
                found_plv0 = all_plv0[1:0];
                found_pfn0 = all_pfn0[19:0];
            end
            else begin
                found_v0   = all_v1[0];
                found_d0   = all_d1[0];
                found_mat0 = all_mat1[1:0];
                found_plv0 = all_plv1[1:0];
                found_pfn0 = all_pfn1[19:0];
            end
        end
        16'h0002: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[1];
                found_d0   = all_d0[1];
                found_mat0 = all_mat0[3:2];
                found_plv0 = all_plv0[3:2];
                found_pfn0 = all_pfn0[39:20];
            end
            else begin
                found_v0   = all_v1[1];
                found_d0   = all_d1[1];
                found_mat0 = all_mat1[3:2];
                found_plv0 = all_plv1[3:2];
                found_pfn0 = all_pfn1[39:20];
            end
        end
        16'h0004: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[2];
                found_d0   = all_d0[2];
                found_mat0 = all_mat0[5:4];
                found_plv0 = all_plv0[5:4];
                found_pfn0 = all_pfn0[59:40];
            end
            else begin
                found_v0   = all_v1[2];
                found_d0   = all_d1[2];
                found_mat0 = all_mat1[5:4];
                found_plv0 = all_plv1[5:4];
                found_pfn0 = all_pfn1[59:40];
            end
        end
        16'h0008: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[3];
                found_d0   = all_d0[3];
                found_mat0 = all_mat0[7:6];
                found_plv0 = all_plv0[7:6];
                found_pfn0 = all_pfn0[79:60];
            end
            else begin
                found_v0   = all_v1[3];
                found_d0   = all_d1[3];
                found_mat0 = all_mat1[7:6];
                found_plv0 = all_plv1[7:6];
                found_pfn0 = all_pfn1[79:60];
            end
        end
        16'h0010: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[4];
                found_d0   = all_d0[4];
                found_mat0 = all_mat0[9:8];
                found_plv0 = all_plv0[9:8];
                found_pfn0 = all_pfn0[99:80];
            end
            else begin
                found_v0   = all_v1[4];
                found_d0   = all_d1[4];
                found_mat0 = all_mat1[9:8];
                found_plv0 = all_plv1[9:8];
                found_pfn0 = all_pfn1[99:80];
            end
        end
        16'h0020: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[5];
                found_d0   = all_d0[5];
                found_mat0 = all_mat0[11:10];
                found_plv0 = all_plv0[11:10];
                found_pfn0 = all_pfn0[119:100];
            end
            else begin
                found_v0   = all_v1[5];
                found_d0   = all_d1[5];
                found_mat0 = all_mat1[11:10];
                found_plv0 = all_plv1[11:10];
                found_pfn0 = all_pfn1[119:100];
            end
        end
        16'h0040: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[6];
                found_d0   = all_d0[6];
                found_mat0 = all_mat0[13:12];
                found_plv0 = all_plv0[13:12];
                found_pfn0 = all_pfn0[139:120];
            end
            else begin
                found_v0   = all_v1[6];
                found_d0   = all_d1[6];
                found_mat0 = all_mat1[13:12];
                found_plv0 = all_plv1[13:12];
                found_pfn0 = all_pfn1[139:120];
            end
        end
        16'h0080: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[7];
                found_d0   = all_d0[7];
                found_mat0 = all_mat0[15:14];
                found_plv0 = all_plv0[15:14];
                found_pfn0 = all_pfn0[159:140];
            end
            else begin
                found_v0   = all_v1[7];
                found_d0   = all_d1[7];
                found_mat0 = all_mat1[15:14];
                found_plv0 = all_plv1[15:14];
                found_pfn0 = all_pfn1[159:140];
            end
        end
        16'h0100: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[8];
                found_d0   = all_d0[8];
                found_mat0 = all_mat0[17:16];
                found_plv0 = all_plv0[17:16];
                found_pfn0 = all_pfn0[179:160];
            end
            else begin
                found_v0   = all_v1[8];
                found_d0   = all_d1[8];
                found_mat0 = all_mat1[17:16];
                found_plv0 = all_plv1[17:16];
                found_pfn0 = all_pfn1[179:160];
            end
        end
        16'h0200: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[9];
                found_d0   = all_d0[9];
                found_mat0 = all_mat0[19:18];
                found_plv0 = all_plv0[19:18];
                found_pfn0 = all_pfn0[199:180];
            end
            else begin
                found_v0   = all_v1[9];
                found_d0   = all_d1[9];
                found_mat0 = all_mat1[19:18];
                found_plv0 = all_plv1[19:18];
                found_pfn0 = all_pfn1[199:180];
            end
        end
        16'h0400: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[10];
                found_d0   = all_d0[10];
                found_mat0 = all_mat0[21:20];
                found_plv0 = all_plv0[21:20];
                found_pfn0 = all_pfn0[219:200];
            end
            else begin
                found_v0   = all_v1[10];
                found_d0   = all_d1[10];
                found_mat0 = all_mat1[21:20];
                found_plv0 = all_plv1[21:20];
                found_pfn0 = all_pfn1[219:200];
            end
        end
        16'h0800: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[11];
                found_d0   = all_d0[11];
                found_mat0 = all_mat0[23:22];
                found_plv0 = all_plv0[23:22];
                found_pfn0 = all_pfn0[239:220];
            end
            else begin
                found_v0   = all_v1[11];
                found_d0   = all_d1[11];
                found_mat0 = all_mat1[23:22];
                found_plv0 = all_plv1[23:22];
                found_pfn0 = all_pfn1[239:200];
            end
        end
        16'h1000: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[12];
                found_d0   = all_d0[12];
                found_mat0 = all_mat0[25:24];
                found_plv0 = all_plv0[25:24];
                found_pfn0 = all_pfn0[259:240];
            end
            else begin
                found_v0   = all_v1[12];
                found_d0   = all_d1[12];
                found_mat0 = all_mat1[25:24];
                found_plv0 = all_plv1[25:24];
                found_pfn0 = all_pfn1[259:240];
            end
        end
        16'h2000: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[13];
                found_d0   = all_d0[13];
                found_mat0 = all_mat0[27:26];
                found_plv0 = all_plv0[27:26];
                found_pfn0 = all_pfn0[279:260];
            end
            else begin
                found_v0   = all_v1[13];
                found_d0   = all_d1[13];
                found_mat0 = all_mat1[27:26];
                found_plv0 = all_plv1[27:26];
                found_pfn0 = all_pfn1[279:260];
            end
        end
        16'h4000: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[14];
                found_d0   = all_d0[14];
                found_mat0 = all_mat0[29:28];
                found_plv0 = all_plv0[29:28];
                found_pfn0 = all_pfn0[299:280];
            end
            else begin
                found_v0   = all_v1[14];
                found_d0   = all_d1[14];
                found_mat0 = all_mat1[29:28];
                found_plv0 = all_plv1[29:28];
                found_pfn0 = all_pfn1[299:280];
            end
        end
        16'h8000: begin
            if(!odd0_bit) begin
                found_v0   = all_v0[15];
                found_d0   = all_d0[15];
                found_mat0 = all_mat0[31:30];
                found_plv0 = all_plv0[31:30];
                found_pfn0 = all_pfn0[319:300];
            end
            else begin
                found_v0   = all_v1[15];
                found_d0   = all_d1[15];
                found_mat0 = all_mat1[31:30];
                found_plv0 = all_plv1[31:30];
                found_pfn0 = all_pfn1[319:300];
            end
        end
        endcase
    end
    always @(*) begin
        found_v1 = 0;
        found_d1 = 0;
        found_mat1 = 0; 
        found_plv1 = 0; 
        found_pfn1 = 0;
        case(found1)
        16'h0001: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[0];
                found_d1   = all_d0[0];
                found_mat1 = all_mat0[1:0];
                found_plv1 = all_plv0[1:0];
                found_pfn1 = all_pfn0[19:0];
            end
            else begin
                found_v1   = all_v1[0];
                found_d1   = all_d1[0];
                found_mat1 = all_mat1[1:0];
                found_plv1 = all_plv1[1:0];
                found_pfn1 = all_pfn1[19:0];
            end
        end
        16'h0002: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[1];
                found_d1   = all_d0[1];
                found_mat1 = all_mat0[3:2];
                found_plv1 = all_plv0[3:2];
                found_pfn1 = all_pfn0[39:20];
            end
            else begin
                found_v1   = all_v1[1];
                found_d1   = all_d1[1];
                found_mat1 = all_mat1[3:2];
                found_plv1 = all_plv1[3:2];
                found_pfn1 = all_pfn1[39:20];
            end
        end
        16'h0004: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[2];
                found_d1   = all_d0[2];
                found_mat1 = all_mat0[5:4];
                found_plv1 = all_plv0[5:4];
                found_pfn1 = all_pfn0[59:40];
            end
            else begin
                found_v1   = all_v1[2];
                found_d1   = all_d1[2];
                found_mat1 = all_mat1[5:4];
                found_plv1 = all_plv1[5:4];
                found_pfn1 = all_pfn1[59:40];
            end
        end
        16'h0008: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[3];
                found_d1   = all_d0[3];
                found_mat1 = all_mat0[7:6];
                found_plv1 = all_plv0[7:6];
                found_pfn1 = all_pfn0[79:60];
            end
            else begin
                found_v1   = all_v1[3];
                found_d1   = all_d1[3];
                found_mat1 = all_mat1[7:6];
                found_plv1 = all_plv1[7:6];
                found_pfn1 = all_pfn1[79:60];
            end
        end
        16'h0010: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[4];
                found_d1   = all_d0[4];
                found_mat1 = all_mat0[9:8];
                found_plv1 = all_plv0[9:8];
                found_pfn1 = all_pfn0[99:80];
            end
            else begin
                found_v1   = all_v1[4];
                found_d1   = all_d1[4];
                found_mat1 = all_mat1[9:8];
                found_plv1 = all_plv1[9:8];
                found_pfn1 = all_pfn1[99:80];
            end
        end
        16'h0020: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[5];
                found_d1   = all_d0[5];
                found_mat1 = all_mat0[11:10];
                found_plv1 = all_plv0[11:10];
                found_pfn1 = all_pfn0[119:100];
            end
            else begin
                found_v1   = all_v1[5];
                found_d1   = all_d1[5];
                found_mat1 = all_mat1[11:10];
                found_plv1 = all_plv1[11:10];
                found_pfn1 = all_pfn1[119:100];
            end
        end
        16'h0040: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[6];
                found_d1   = all_d0[6];
                found_mat1 = all_mat0[13:12];
                found_plv1 = all_plv0[13:12];
                found_pfn1 = all_pfn0[139:120];
            end
            else begin
                found_v1   = all_v1[6];
                found_d1   = all_d1[6];
                found_mat1 = all_mat1[13:12];
                found_plv1 = all_plv1[13:12];
                found_pfn1 = all_pfn1[139:120];
            end
        end
        16'h0080: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[7];
                found_d1   = all_d0[7];
                found_mat1 = all_mat0[15:14];
                found_plv1 = all_plv0[15:14];
                found_pfn1 = all_pfn0[159:140];
            end
            else begin
                found_v1   = all_v1[7];
                found_d1   = all_d1[7];
                found_mat1 = all_mat1[15:14];
                found_plv1 = all_plv1[15:14];
                found_pfn1 = all_pfn1[159:140];
            end
        end
        16'h0100: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[8];
                found_d1   = all_d0[8];
                found_mat1 = all_mat0[17:16];
                found_plv1 = all_plv0[17:16];
                found_pfn1 = all_pfn0[179:160];
            end
            else begin
                found_v1   = all_v1[8];
                found_d1   = all_d1[8];
                found_mat1 = all_mat1[17:16];
                found_plv1 = all_plv1[17:16];
                found_pfn1 = all_pfn1[179:160];
            end
        end
        16'h0200: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[9];
                found_d1   = all_d0[9];
                found_mat1 = all_mat0[19:18];
                found_plv1 = all_plv0[19:18];
                found_pfn1 = all_pfn0[199:180];
            end
            else begin
                found_v1   = all_v1[9];
                found_d1   = all_d1[9];
                found_mat1 = all_mat1[19:18];
                found_plv1 = all_plv1[19:18];
                found_pfn1 = all_pfn1[199:180];
            end
        end
        16'h0400: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[10];
                found_d1   = all_d0[10];
                found_mat1 = all_mat0[21:20];
                found_plv1 = all_plv0[21:20];
                found_pfn1 = all_pfn0[219:200];
            end
            else begin
                found_v1   = all_v1[10];
                found_d1   = all_d1[10];
                found_mat1 = all_mat1[21:20];
                found_plv1 = all_plv1[21:20];
                found_pfn1 = all_pfn1[219:200];
            end
        end
        16'h0800: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[11];
                found_d1   = all_d0[11];
                found_mat1 = all_mat0[23:22];
                found_plv1 = all_plv0[23:22];
                found_pfn1 = all_pfn0[239:220];
            end
            else begin
                found_v1   = all_v1[11];
                found_d1   = all_d1[11];
                found_mat1 = all_mat1[23:22];
                found_plv1 = all_plv1[23:22];
                found_pfn1 = all_pfn1[239:200];
            end
        end
        16'h1000: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[12];
                found_d1   = all_d0[12];
                found_mat1 = all_mat0[25:24];
                found_plv1 = all_plv0[25:24];
                found_pfn1 = all_pfn0[259:240];
            end
            else begin
                found_v1   = all_v1[12];
                found_d1   = all_d1[12];
                found_mat1 = all_mat1[25:24];
                found_plv1 = all_plv1[25:24];
                found_pfn1 = all_pfn1[259:240];
            end
        end
        16'h2000: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[13];
                found_d1   = all_d0[13];
                found_mat1 = all_mat0[27:26];
                found_plv1 = all_plv0[27:26];
                found_pfn1 = all_pfn0[279:260];
            end
            else begin
                found_v1   = all_v1[13];
                found_d1   = all_d1[13];
                found_mat1 = all_mat1[27:26];
                found_plv1 = all_plv1[27:26];
                found_pfn1 = all_pfn1[279:260];
            end
        end
        16'h4000: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[14];
                found_d1   = all_d0[14];
                found_mat1 = all_mat0[29:28];
                found_plv1 = all_plv0[29:28];
                found_pfn1 = all_pfn0[299:280];
            end
            else begin
                found_v1   = all_v1[14];
                found_d1   = all_d1[14];
                found_mat1 = all_mat1[29:28];
                found_plv1 = all_plv1[29:28];
                found_pfn1 = all_pfn1[299:280];
            end
        end
        16'h8000: begin
            if(!odd0_bit) begin
                found_v1   = all_v0[15];
                found_d1   = all_d0[15];
                found_mat1 = all_mat0[31:30];
                found_plv1 = all_plv0[31:30];
                found_pfn1 = all_pfn0[319:300];
            end
            else begin
                found_v1   = all_v1[15];
                found_d1   = all_d1[15];
                found_mat1 = all_mat1[31:30];
                found_plv1 = all_plv1[31:30];
                found_pfn1 = all_pfn1[319:300];
            end
        end
        endcase
    end
endmodule 
 