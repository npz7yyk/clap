module TLB_found_compare#(
    parameter TLBNUM = 8
    )(
    input  [   TLBNUM-1:0] all_e,
    input  [   TLBNUM-1:0] all_g,
    input  [TLBNUM*10-1:0] all_asid,
    input  [TLBNUM*19-1:0] all_vpn2,
    input  [          9:0] s0_asid,
    input  [          9:0] s1_asid,
    input  [         18:0] s0_vpn2,
    input  [         18:0] s1_vpn2,
    output [   TLBNUM-1:0] found0,
    output [   TLBNUM-1:0] found1,

    input  [         18:0] s_vpn2,
    output                 s_e,
    output reg [$clog2(TLBNUM)-1:0] s_index
    );
    wire [   TLBNUM-1:0] found_search;
    genvar i;
    for(i = 0; i < TLBNUM; i = i + 1) begin
        assign found0[i] = all_e[i] && 
                           (all_g[i] || (all_asid[10*i+9:10*i] == s0_asid)) && 
                           (all_vpn2[19*i+18:19*i] == s0_vpn2);
        
        assign found1[i] = all_e[i] && 
                           (all_g[i] || (all_asid[10*i+9:10*i] == s1_asid)) && 
                           (all_vpn2[19*i+18:19*i] == s1_vpn2);
        assign found_search[i] = all_e[i] && 
                           (all_g[i] || (all_asid[10*i+9:10*i] == s0_asid)) && 
                           (all_vpn2[19*i+18:19*i] == s_vpn2);
    end 
    assign s_e = !found_search;
    always @(*) begin
        case(found_search)
        8'h01: s_index = 4'd0;
        8'h02: s_index = 4'd1;
        8'h04: s_index = 4'd2;
        8'h08: s_index = 4'd3;
        8'h10: s_index = 4'd4;
        8'h20: s_index = 4'd5;
        8'h40: s_index = 4'd6;
        8'h80: s_index = 4'd7;
        // 16'h0100: s_index = 4'd8;
        // 16'h0200: s_index = 4'd9;
        // 16'h0400: s_index = 4'd10;
        // 16'h0800: s_index = 4'd11;
        // 16'h1000: s_index = 4'd12;
        // 16'h2000: s_index = 4'd13;
        // 16'h4000: s_index = 4'd14;
        // 16'h8000: s_index = 4'd15;
        default:  s_index = 0;
        endcase
    end
endmodule
