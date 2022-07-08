`include "../uop.vh"
module hazard (
    //从rf段后输入
    input eu0_en_0,
    input eu1_en_0,
    input [4:0]eu0_rj,
    input [4:0]eu0_rk,
    input [4:0]eu1_rj,
    input [4:0]eu1_rk,
    //从exe1段后输入
    input eu0_en_1,
    input [11:0]eu0_uop_type,
    input [4:0]eu0_rd,
    //从exe2段内输入
    input stall_because_cache,
    input stall_because_div,
    output stall
);

assign stall_because_mul= eu0_en_0
                        &&eu0_en_1
                        &&eu0_rd!=0
                        &&eu0_uop_type==`ITYPE_MUL
                        &&(eu0_rd==eu0_rj
                        ||eu0_rd==eu0_rk
                        ||eu0_rd==eu1_rj
                        ||eu0_rd==eu1_rk);

assign stall_because_mem= eu0_en_0
                        &&eu0_en_1
                        &&eu0_rd!=0
                        &&eu0_uop_type==`ITYPE_MEM
                        &&(eu0_rd==eu0_rj
                        ||eu0_rd==eu0_rk
                        ||eu0_rd==eu1_rj
                        ||eu0_rd==eu1_rk);

assign stall=stall_because_div
            ||stall_because_mem
            ||stall_because_mul
            ||stall_because_cache;
endmodule