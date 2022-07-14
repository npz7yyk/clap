`include "../uop.vh"
module hazard (
    //从rf段后输入
    input eu0_en_in,
    input eu1_en_in,
    input [4:0]eu0_rj,
    input [4:0]eu0_rk,
    input [4:0]eu1_rj,
    input [4:0]eu1_rk,
    //从exe0段后输入
    input eu0_mul_en_0,
    input eu0_mem_en_0,
    //input [`UOP_TYPE]eu0_uop_type,
    input [4:0]eu0_rd,
    //从exe1段内输入
    input stall_because_cache,
    input stall_because_div,
    output stall
);

assign stall_because_mul= eu0_rd!=0
                        &&eu0_mul_en_0
                        &&((eu0_rd==eu0_rj||eu0_rd==eu0_rk)&&eu0_en_in
                        ||(eu0_rd==eu1_rj||eu0_rd==eu1_rk)&&eu1_en_in);

assign stall_because_mem= eu0_rd!=0
                        &&eu0_mem_en_0
                        &&((eu0_rd==eu0_rj||eu0_rd==eu0_rk)&&eu0_en_in
                        ||(eu0_rd==eu1_rj||eu0_rd==eu1_rk)&&eu1_en_in);


assign stall=stall_because_div
            ||stall_because_mem
            ||stall_because_mul
            ||stall_because_cache;
endmodule
