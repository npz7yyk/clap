`include "uop.vh"
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
    input [6:0] eu0_exp_out,
    input [6:0] eu0_exp_exe1,
    input [4:0]eu0_rd,
    //从exe1段内输入
    input stall_because_cache,
    input stall_because_div,
    input stall_because_priv,
    //stall1: 由特殊的计算单元（如div）在eu1的指令流到中间段寄存器时给出。
    //        首段寄存器和中间段寄存器阻滞，末段寄存器的对外输出的有效位清空，
    //        但保留数据以准备forwarding。
    //stall2: 通过中间段寄存器和首段寄存器的值简单组合算出。
    //        首段寄存器阻滞，中间段寄存器清空，末段寄存器正常更新。
    //stall3: 由中间段寄存器的值复杂组合算出，但为了优化时序，待到指令流到末段寄存器时，
    //        才能把它给CPU的执行模块的大部分组件使用。
    //        首段寄存器和中间寄存器阻滞，末段寄存器更新，但不置valid位；如果特殊执行
    //        单元在设置stall3期间完成计算，它们的结果会被保存到eu0_*_save寄存器中；
    //        当stall3撤销时，如果eu0_*_save中有值，则eu0_*_out会用eu0_*_save中的值更新。
    //stall4: 由exception引发。
    //        首段寄存器阻滞，中间段寄存器正常更新。
    output stall,stall1,stall2,stall3,stall4
);

assign stall_because_mul= eu0_rd!=0
                        &&eu0_mul_en_0
                        &&((eu0_rd==eu0_rj||eu0_rd==eu0_rk)&&eu0_en_in
                        ||(eu0_rd==eu1_rj||eu0_rd==eu1_rk)&&eu1_en_in)
                        && !stall_because_cache;

//一条指令可以同时引发stall because mem和stall because cache，这时stall because cache优先
assign stall_because_mem= eu0_rd!=0
                        &&eu0_mem_en_0
                        &&((eu0_rd==eu0_rj||eu0_rd==eu0_rk)&&eu0_en_in
                        ||(eu0_rd==eu1_rj||eu0_rd==eu1_rk)&&eu1_en_in)
                        && !stall_because_cache;

assign stall1=stall_because_div||stall_because_priv;
assign stall2=stall_because_mem||stall_because_mul;
assign stall3=stall_because_cache;
assign stall4=eu0_exp_out!=0||eu0_exp_exe1!=0;
assign stall=stall4||stall2||stall1||stall3;

endmodule
