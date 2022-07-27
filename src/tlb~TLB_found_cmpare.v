/* verilator lint_off DECLFILENAME */
module TLB_found_compare#(
    parameter TLBNUM = 32
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
    input  [          9:0] s_asid,
    output                 s_e,
    output [$clog2(TLBNUM)-1:0] s_index
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
                           (all_g[i] || (all_asid[10*i+9:10*i] == s_asid)) && 
                           (all_vpn2[19*i+18:19*i] == s_vpn2);
    end 
    assign s_e = |found_search;
    assign s_index = {5{found_search[0]}} & 5'h0 
                   | {5{found_search[1]}} & 5'h1
                   | {5{found_search[2]}} & 5'h2 
                   | {5{found_search[3]}} & 5'h3
                   | {5{found_search[4]}} & 5'h4 
                   | {5{found_search[5]}} & 5'h5
                   | {5{found_search[6]}} & 5'h6 
                   | {5{found_search[7]}} & 5'h7
                   | {5{found_search[8]}} & 5'h8 
                   | {5{found_search[9]}} & 5'h9
                   | {5{found_search[10]}} & 5'ha
                   | {5{found_search[11]}} & 5'hb 
                   | {5{found_search[12]}} & 5'hc
                   | {5{found_search[13]}} & 5'hd
                   | {5{found_search[14]}} & 5'he
                   | {5{found_search[15]}} & 5'hf
                   | {5{found_search[16]}} & 5'h10
                   | {5{found_search[17]}} & 5'h11
                   | {5{found_search[18]}} & 5'h12
                   | {5{found_search[19]}} & 5'h13
                   | {5{found_search[20]}} & 5'h14
                   | {5{found_search[21]}} & 5'h15
                   | {5{found_search[22]}} & 5'h16
                   | {5{found_search[23]}} & 5'h17
                   | {5{found_search[24]}} & 5'h18
                   | {5{found_search[25]}} & 5'h19
                   | {5{found_search[26]}} & 5'h1a
                   | {5{found_search[27]}} & 5'h1b
                   | {5{found_search[28]}} & 5'h1c
                   | {5{found_search[29]}} & 5'h1d
                   | {5{found_search[30]}} & 5'h1e
                   | {5{found_search[31]}} & 5'h1f;
endmodule
