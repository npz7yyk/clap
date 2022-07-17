module TLB_found_compare#(
    parameter TLBNUM = 16
    )(
    input  [   TLBNUM-1:0] all_e,
    input  [   TLBNUM-1:0] all_g,
    input  [ TLBNUM*8-1:0] all_asid,
    input  [TLBNUM*19-1:0] all_vpn2,
    input  [          7:0] s0_asid,
    input  [          7:0] s1_asid,
    input  [         18:0] s0_vpn2,
    input  [         18:0] s1_vpn2,
    output [   TLBNUM-1:0] found0,
    output [   TLBNUM-1:0] found1
    );
    genvar i;
    for(i = 0; i < TLBNUM; i = i + 1) begin
        assign found0[i] = all_e[i] && 
                           (all_g[i] || (all_asid[8*i+7:8*i] == s0_asid)) && 
                           (all_vpn2[19*i+18:19*i] == s0_vpn2);
        
        assign found1[i] = all_e[i] && 
                           (all_g[i] || (all_asid[8*i+7:8*i] == s1_asid)) && 
                           (all_vpn2[19*i+18:19*i] == s1_vpn2);
    end 
endmodule
