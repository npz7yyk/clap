`include "exception.vh"
module TLB_found_signal#(
    parameter TLBNUM = 16
    )(
    input  [    TLBNUM*20-1:0]  all_pfn0,
    input  [     TLBNUM*6-1:0]  all_ps,
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
    output reg                  found_d0, 
    output reg[            1:0] found_mat0, 
    output reg[            1:0] found_plv0, 
    output reg[           19:0] found_pfn0, 
    output reg[            5:0] found_ps0,
    //output reg[            3:0] found_index0,

    output reg                  found_v1,
    output reg                  found_d1,
    output reg[            1:0] found_mat1,
    output reg[            1:0] found_plv1,
    output reg[           19:0] found_pfn1,
    output reg[            5:0] found_ps1
    //output reg[            3:0] found_index1


    );
    // genvar i;
    // for(i = 0; i < 16; i = i + 1) begin
    //     assign found_v0     = found0[i] ? (!odd0_bit ? all_v0[i] : all_v1[i]) : 0;
    //     assign found_d0     = found0[i] ? (!odd0_bit ? all_d0[i] : all_d1[i]) : 0;
    //     assign found_mat0   = found0[i] ? (!odd0_bit ? all_mat0[2*i+1:2*i] : all_mat1[2*i+1:2*i]) : 0;
    //     assign found_plv0   = found0[i] ? (!odd0_bit ? all_plv0[2*i+1:2*i] : all_plv1[2*i+1:2*i]) : 0;
    //     assign found_pfn0   = found0[i] ? (!odd0_bit ? all_pfn0[20*i+19:20*i] : all_pfn1[20*i+19:20*i]) : 0;
    //     assign found_ps0    = found0[i] ? all_ps[i] : 0;

    //     assign found_v1     = found1[i] ? (!odd1_bit ? all_v0[i] : all_v1[i]) : 0;
    //     assign found_d1     = found1[i] ? (!odd1_bit ? all_d0[i] : all_d1[i]) : 0;
    //     assign found_mat1   = found1[i] ? (!odd1_bit ? all_mat0[2*i+1:2*i] : all_mat1[2*i+1:2*i]) : 0;
    //     assign found_plv1   = found1[i] ? (!odd1_bit ? all_plv0[2*i+1:2*i] : all_plv1[2*i+1:2*i]) : 0;
    //     assign found_pfn1   = found1[i] ? (!odd1_bit ? all_pfn0[20*i+19:20*i] : all_pfn1[20*i+19:20*i]) : 0;
    // end

    // always @(*) begin
    //     case(found0)
    //     16'h0001: found_index0 = 4'd0;
    //     16'h0002: found_index0 = 4'd1;
    //     16'h0004: found_index0 = 4'd2;
    //     16'h0008: found_index0 = 4'd3;
    //     16'h0010: found_index0 = 4'd4;
    //     16'h0020: found_index0 = 4'd5;
    //     16'h0040: found_index0 = 4'd6;
    //     16'h0080: found_index0 = 4'd7;
    //     16'h0100: found_index0 = 4'd8;
    //     16'h0200: found_index0 = 4'd9;
    //     16'h0400: found_index0 = 4'd10;
    //     16'h0800: found_index0 = 4'd11;
    //     16'h1000: found_index0 = 4'd12;
    //     16'h2000: found_index0 = 4'd13;
    //     16'h4000: found_index0 = 4'd14;
    //     16'h8000: found_index0 = 4'd15;
    //     default:  found_index0 = 0;
    //     endcase

    //     case(found1)
    //     16'h0001: found_index1 = 4'd0;
    //     16'h0002: found_index1 = 4'd1;
    //     16'h0004: found_index1 = 4'd2;
    //     16'h0008: found_index1 = 4'd3;
    //     16'h0010: found_index1 = 4'd4;
    //     16'h0020: found_index1 = 4'd5;
    //     16'h0040: found_index1 = 4'd6;
    //     16'h0080: found_index1 = 4'd7;
    //     16'h0100: found_index1 = 4'd8;
    //     16'h0200: found_index1 = 4'd9;
    //     16'h0400: found_index1 = 4'd10;
    //     16'h0800: found_index1 = 4'd11;
    //     16'h1000: found_index1 = 4'd12;
    //     16'h2000: found_index1 = 4'd13;
    //     16'h4000: found_index1 = 4'd14;
    //     16'h8000: found_index1 = 4'd15;
    //     default:  found_index1 = 0;
    //     endcase
    // end
    always @(*) begin
        found_v0 = 0;
        found_d0 = 0;
        found_mat0 = 0; 
        found_plv0 = 0; 
        found_pfn0 = 0;
        found_ps0 = 0;
        case(found0)
        16'h0001: begin
            found_ps0 = all_ps[5:0];
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
            found_ps0 = all_ps[11:6];
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
            found_ps0 = all_ps[17:12];
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
            found_ps0 = all_ps[23:18];
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
            found_ps0 = all_ps[29:24];
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
            found_ps0 = all_ps[35:30];
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
            found_ps0 = all_ps[41:36];
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
            found_ps0 = all_ps[47:42];
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
            found_ps0 = all_ps[53:48];
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
            found_ps0 = all_ps[59:54];
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
            found_ps0 = all_ps[65:60];
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
            found_ps0 = all_ps[71:66];
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
            found_ps0 = all_ps[77:72];
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
            found_ps0 = all_ps[83:78];
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
            found_ps0 = all_ps[89:84];
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
            found_ps0 = all_ps[95:90];
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
        found_ps1 = 0;
        case(found1)
        16'h0001: begin
            found_ps1 = all_ps[5:0];
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
            found_ps1 = all_ps[11:6];
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
            found_ps1 = all_ps[17:12];
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
            found_ps1 = all_ps[23:18];
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
            found_ps1 = all_ps[29:24];
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
            found_ps1 = all_ps[35:30];
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
            found_ps1 = all_ps[41:36];
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
            found_ps1 = all_ps[47:42];
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
            found_ps1 = all_ps[53:48];
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
            found_ps1 = all_ps[59:54];
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
            found_ps1 = all_ps[65:60];
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
            found_ps1 = all_ps[71:66];
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
            found_ps1 = all_ps[77:72];
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
            found_ps1 = all_ps[83:78];
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
            found_ps1 = all_ps[89:84];
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
            found_ps1 = all_ps[95:90];
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
 