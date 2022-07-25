`include "exception.vh"
module TLB_found_signal#(
    parameter TLBNUM = 8
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
    always @(*) begin
        found_v0 = 0;
        found_d0 = 0;
        found_mat0 = 0; 
        found_plv0 = 0; 
        found_pfn0 = 0;
        found_ps0 = 0;
        case(found0)
        8'h01: begin
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
        8'h02: begin
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
        8'h04: begin
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
        8'h08: begin
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
        8'h10: begin
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
        8'h20: begin
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
        8'h40: begin
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
        8'h80: begin
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
        8'h01: begin
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
        8'h02: begin
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
        8'h04: begin
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
        8'h08: begin
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
        8'h10: begin
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
        8'h20: begin
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
        8'h40: begin
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
        8'h80: begin
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
        endcase
    end
endmodule 
 