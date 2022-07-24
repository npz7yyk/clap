`include "uop.vh"
module exe(
    input [0:0]clk,   
    input [0:0]rstn,
    //TODO: flush dcache or ignore data from dcache
    input flush_by_writeback,
    //从rf段后输入
    input [0:0]eu0_en_in,
    input [`WIDTH_UOP-1:0]eu0_uop_in,
    input [4:0]eu0_rd_in,
    input [4:0]eu0_rj_in,
    input [4:0]eu0_rk_in,
    input [31:0]eu0_imm_in,
    input [31:0]eu0_pc_in,
    input [31:0]eu0_pc_next_in,
    input [6:0]eu0_exp_in,
    input [31:0]eu0_badv_in,
    input [31:0]data00,
    input [31:0]data01,
    input [0:0]eu1_en_in,
    input [`WIDTH_UOP-1:0]eu1_uop_in,
    input [4:0]eu1_rd_in,
    input [4:0]eu1_rj_in,
    input [4:0]eu1_rk_in,
    input [31:0]eu1_imm_in,
    input [31:0]eu1_pc_in,
    input [31:0]data10,
    input [31:0]data11,
    //向exe1段后输出
    output reg [0:0]en_out0,
    output reg [0:0]en_out1,
    output reg [31:0]data_out0,
    output reg [4:0]addr_out0,
    output reg [31:0]data_out1,
    output reg [4:0]addr_out1,
    output reg[6:0]exp_out,
    output reg[31:0]badv_out,
    output reg [31:0]eu0_pc_out,
    output reg [31:0]eu0_inst,
    output reg [31:0]eu1_pc_out,
    output reg [31:0]eu1_inst,
    //向issue段输出
    output stall,
    output flush,
    // output empty,
    //向分支预测输出
    output [31:0]branch_pc,
    output [31:0]correct_pc_next,
    output reg branch_status,
    output reg branch_valid,
    output reg [1:0]category_out,
    output reg [31:0]ex_pc_tar,
    //向cache输出
    output [0:0] valid,                 //    valid request
    output [0:0] op,                    //    write: 1, read: 0
    output [31:0]addr,
    output [0:0]signed_ext,
    output [ 3:0 ] write_type,          //    byte write enable
    output [ 31:0 ] w_data_CPU,         //    write data
    //从cache输入
    input data_valid,                   //    read: data has returned; write: data has been written in
    input [ 31:0 ] r_data_CPU,           //    read data to CPU
    input [ 31:0 ] cache_badv,
    input [ 6:0 ]  cache_exception,

    //CSR
    output csr_software_query_en,
    output [13:0] csr_addr,
    input [31:0] csr_rdata,//read first
    output  [31:0] csr_wen,      //bit write enable
    output  [31:0] csr_wdata,
    input [31:0] era,
    output restore_state
);

wire stall2;

assign eu0_alu_en=eu0_en_in&eu0_uop_in[`ITYPE_IDX_ALU];
assign eu0_mul_en=eu0_en_in&eu0_uop_in[`ITYPE_IDX_MUL];
assign eu0_div_en=eu0_en_in&eu0_uop_in[`ITYPE_IDX_DIV];
assign eu0_br_en=eu0_en_in&eu0_uop_in[`ITYPE_IDX_BR];
assign eu0_mem_en=eu0_en_in&eu0_uop_in[`ITYPE_IDX_MEM];
assign eu0_priv_en=eu0_en_in&&eu0_uop_in[`UOP_PRIVILEDGED];
assign eu1_alu_en=eu1_en_in&eu1_uop_in[`ITYPE_IDX_ALU];

wire[31:0]eu0_sr0;
wire[31:0]eu0_sr1;
wire[31:0]eu1_sr0;
wire[31:0]eu1_sr1;
//exe0组合输出
wire[31:0]br_rd_data_mid;
wire[4:0]br_rd_addr_mid;
wire[0:0]br_en_mid;
wire[0:0]alu_en_mid;
wire[4:0]alu_rd_mid;
wire[31:0]alu_result_mid;
wire[0:0]mul_en_mid;
wire[4:0]mul_rd_mid;
wire[0:0]mul_sel_mid;
wire[31:0]mul_rs0_mid;
wire[31:0]mul_rs1_mid;
wire[31:0]mul_rs2_mid;
wire[31:0]mul_rs3_mid;
wire[6:0]mem_exp_mid;
wire[4:0]mem_rd_mid;
wire[0:0]mem_en_mid;
wire[1:0]mem_width_mid;
wire[0:0]eu1_alu_en_mid;
wire[4:0]eu1_alu_rd_mid;
wire[31:0]eu1_alu_result_mid;
wire[31:0]mul_ad_mid;
wire [31:0]branch_pc_mid;
wire [31:0]branch_addr_calculated_mid;
wire [0:0]branch_status_mid;
wire [0:0]branch_valid_mid;
wire [1:0]category_out_mid;
wire [31:0]ex_pc_tar_mid;
//中段寄存器
reg[0:0]eu0_en_0;
reg[0:0]eu0_mul_en_0;
reg [31:0]inst0_mid;
reg [31:0]inst1_mid;
// reg [0:0]mul_sign_exe1;
//reg[0:0]eu0_mem_en_0;
reg[0:0]eu1_en_0;
reg[4:0]eu0_rd_0;
reg[4:0]eu1_rd_0;
reg[31:0]data_mid00;
reg[31:0]data_mid10;
reg[31:0]eu1_pc_exe1;
reg[6:0]mem_exp_exe1;
reg[4:0]mem_rd_exe1;
reg[0:0]mem_en_exe1;
reg[1:0]mem_width_exe1;
reg[0:0]mul_sel_exe1;
reg[31:0]mul_sr0_exe1;
reg[31:0]mul_sr1_exe1;
reg[31:0]mul_sr2_exe1;
reg[31:0]mul_sr3_exe1;
reg[31:0]mul_ajustice_exe1;
reg[4:0]mul_rd_exe1;
reg[6:0]exp_exe1;
reg[31:0]badv_exe1;
reg[31:0]eu0_pc_exe1;
//exe1组合输出
wire[4:0]mul_rd_out;
wire[0:0]mul_en_out;
wire[31:0]mul_result;
wire[0:0]stall_because_cache;
wire[0:0]stall_because_div;
wire stall_because_priv;
wire[6:0]mem_exp_out;
wire[4:0]mem_rd_out;
wire[31:0]mem_data_out;
wire[0:0]mem_en_out;
wire[0:0]div_en_out;
wire[31:0]div_result;
wire[4:0]div_addr_out;
wire priv_en_out;
wire [31:0] priv_pc;
wire flush_mid;
reg flush_because_br;
wire flush_because_priv;
wire [31:0] priv_data_out;
wire [4:0] priv_addr_out;
reg [31:0] branch_addr_calculated;
//末段寄存器
reg [0:0]eu0_en_1_internal;
reg [0:0]eu1_en_1_internal;
assign correct_pc_next = flush_because_br?branch_addr_calculated:priv_pc;

assign branch_pc=eu0_pc_exe1;
assign flush = flush_because_br||flush_because_priv;

//中段寄存器更新
always @(posedge clk) begin
    //eu0
    if(!rstn||flush_by_writeback||stall2||flush)begin
        {eu0_en_0,
        eu0_mul_en_0,
        eu0_rd_0,
        data_mid00,
        mem_exp_exe1,
        mem_rd_exe1,
        mem_en_exe1,
        mem_width_exe1,
        mul_sel_exe1,
        mul_sr0_exe1,
        mul_sr1_exe1,
        mul_sr2_exe1,
        mul_sr3_exe1,
        exp_exe1,
        badv_exe1,
        eu0_pc_exe1,
        inst0_mid,
        branch_addr_calculated,
        branch_status,
        branch_valid,
        category_out,
        ex_pc_tar,
        flush_because_br,
        mul_ajustice_exe1}<=0;
    end else if(!stall)begin
        //在存在异常时，将eu0_en_0置位，否则异常会被丢弃
        eu0_en_0<=br_en_mid||alu_en_mid||eu0_en_in&&eu0_exp_in!=0;
        eu0_mul_en_0<=mul_en_mid;
        eu0_rd_0<=br_rd_addr_mid|alu_rd_mid;
        data_mid00<=br_rd_data_mid|alu_result_mid;
        mem_exp_exe1<=mem_exp_mid;
        mem_rd_exe1<=mem_rd_mid;
        mem_en_exe1<=mem_en_mid;
        mem_width_exe1<=mem_width_mid;
        mul_sel_exe1<=mul_sel_mid;
        mul_sr0_exe1<=mul_rs0_mid;
        mul_sr1_exe1<=mul_rs1_mid;
        mul_sr2_exe1<=mul_rs2_mid;
        mul_sr3_exe1<=mul_rs3_mid;
        mul_rd_exe1<=mul_rd_mid;
        exp_exe1<=eu0_exp_in;
        badv_exe1<=eu0_badv_in;
        eu0_pc_exe1<=eu0_pc_in;
        inst0_mid<=eu0_uop_in[`UOP_ORIGINAL_INST];
        branch_addr_calculated<=branch_addr_calculated_mid;
        branch_status<=branch_status_mid;
        branch_valid<=branch_valid_mid;
        category_out<=category_out_mid;
        ex_pc_tar<=ex_pc_tar_mid;
        flush_because_br<=flush_mid;
        mul_ajustice_exe1<=mul_ad_mid;
    end
    //eu1
    if(!rstn||flush_by_writeback||stall2||flush)begin
        eu1_en_0<=0;
        eu1_rd_0<=0;
        data_mid10<=0;
        inst1_mid<=0;
    end else if(!flush&&!stall)begin
        eu1_en_0<=eu1_alu_en_mid;
        eu1_rd_0<=eu1_alu_rd_mid;
        data_mid10<=eu1_alu_result_mid;
        eu1_pc_exe1<=eu1_pc_in;
        inst1_mid<=eu1_uop_in[`UOP_ORIGINAL_INST];
    end
end
//末段寄存器更新
always @(posedge clk) begin
    //eu0
    if(!rstn||flush_by_writeback)begin
        eu0_en_1_internal<=0;
        en_out0<=0;
        data_out0<=0;
        addr_out0<=0;
        exp_out<=0;
        eu0_pc_out<=0;
        eu0_inst<=0;
    end else if(!stall_because_cache)begin
        eu0_en_1_internal<=eu0_en_0|mul_en_out|div_en_out|mem_en_out|priv_en_out;
        en_out0<=eu0_en_0|mul_en_out|div_en_out|mem_en_out|priv_en_out;
        data_out0<=data_mid00|mul_result|div_result|mem_data_out|priv_data_out;
        addr_out0<=eu0_rd_0|mul_rd_out|div_addr_out|mem_rd_out|priv_addr_out;
        exp_out<=exp_exe1|mem_exp_out;
        badv_out<=badv_exe1|cache_badv;
        eu0_pc_out<=eu0_pc_exe1;
        eu0_inst<=inst0_mid;
    end 
    else begin
        en_out0<=0;
    end
    //eu1
    if(!rstn||flush_by_writeback||flush_because_priv)begin
        eu1_en_1_internal<=0;
        en_out1<=0;
        data_out1<=0;
        addr_out1<=0;
        eu1_pc_out<=0;
        eu1_inst<=0;
    end else if(!stall_because_cache&&!flush)begin
        eu1_en_1_internal<=eu1_en_0;
        // en_out1<=eu1_en_0;
        en_out1<=eu1_en_0&&!stall_because_div&&!stall_because_priv;
        data_out1<=data_mid10;
        addr_out1<=eu1_rd_0;
        eu1_pc_out<=eu1_pc_exe1;
        eu1_inst<=inst1_mid;
    end
    else begin
        en_out1<=0;
    end
end

hazard  u_hazard (
    .eu0_en_in                ( eu0_en_in              ),
    .eu1_en_in                ( eu1_en_in              ),
    .eu0_rj                  ( eu0_rj_in              ),
    .eu0_rk                  ( eu0_rk_in              ),
    .eu1_rj                  ( eu1_rj_in              ),
    .eu1_rk                  ( eu1_rk_in              ),
    .eu0_mul_en_0                ( eu0_mul_en_0               ),
    .eu0_mem_en_0                ( mem_en_exe1               ),

    .eu0_exp_out              (exp_out),
    .eu0_exp_exe1            (exp_exe1),
    .eu0_rd                  ( mul_rd_exe1|mem_rd_exe1                ),
    .stall_because_cache     ( stall_because_cache   ),
    .stall_because_div       ( stall_because_div     ),
    .stall_because_priv      ( stall_because_priv    ),

    .stall                   ( stall                 ),
    .stall2                  ( stall2                ),
    .stall4                  ( stall4)
);

forward  u_forward (
    .eu0_rj                  ( eu0_rj_in           ),
    .eu0_rk                  ( eu0_rk_in           ),
    .eu1_rj                  ( eu1_rj_in           ),
    .eu1_rk                  ( eu1_rk_in           ),
    .data00                  ( data00           ),
    .data01                  ( data01           ),
    .data10                  ( data10           ),
    .data11                  ( data11           ),
    .eu0_en_0                ( eu0_en_0        ),
    .eu1_en_0                ( eu1_en_0         ),
    .eu0_rd_0                ( eu0_rd_0         ),
    .eu1_rd_0                ( eu1_rd_0         ),
    .data_forward00          ( data_mid00   ),
    .data_forward10          ( data_mid10   ),
    .eu0_en_1                ( eu0_en_1_internal|div_en_out         ),
    .eu1_en_1                ( eu1_en_1_internal         ),
    .eu0_rd_1                ( addr_out0|div_addr_out         ),
    .eu1_rd_1                ( addr_out1         ),
    .data_forward01          ( data_out0|div_result   ),
    .data_forward11          ( data_out1   ),

    .eu0_sr0                 ( eu0_sr0          ),
    .eu0_sr1                 ( eu0_sr1          ),
    .eu1_sr0                 ( eu1_sr0          ),
    .eu1_sr1                 ( eu1_sr1          )
);

branch #(
    .JIRL ( 'b0011 ),
    .B    ( 'b0100 ),
    .BL   ( 'b0101 ),
    .BEQ  ( 'b0110 ),
    .BNE  ( 'b0111 ),
    .BLT  ( 'b1000 ),
    .BGE  ( 'b1001 ),
    .BLTU ( 'b1010 ),
    .BGEU ( 'b1011 ))
 u_branch (
    .br_en_in                ( eu0_br_en                ),
    .pc                      ( eu0_pc_in                ),
    .pc_next                 ( eu0_pc_next_in           ),
    .branch_op               ( eu0_uop_in[`UOP_COND]    ),
    .br_rd_addr_in           ( eu0_rd_in            ),
    .branch_sr0              ( eu0_sr0               ),
    .branch_sr1              ( eu0_sr1               ),
    .branch_imm              ( eu0_imm_in               ),
    

    .br_rd_data              ( br_rd_data_mid           ),
    .br_rd_addr_out          ( br_rd_addr_mid           ),
    .br_en_out               ( br_en_mid                ),
    .flush                   ( flush_mid         ),
    .branch_addr_calculated  ( branch_addr_calculated_mid   ),
    .ex_pc_tar               (ex_pc_tar_mid),
    .branch_valid            (branch_valid_mid),
    .branch_status           (branch_status_mid),
    .category_out            (category_out_mid)
);
wire[31:0]eu0_alu_sr1;
assign eu0_alu_sr1=eu0_uop_in[`UOP_SRC2]==`CTRL_SRC2_IMM?eu0_imm_in:eu0_sr1;

alu  u_alu0 (
    .alu_en_in               ( eu0_alu_en    ),
    .alu_control             ( eu0_uop_in[`UOP_ALUOP]   ),
    .alu_rd_in               ( eu0_rd_in     ),
    .alu_sr0                 ( eu0_sr0       ),
    .alu_sr1                 ( eu0_alu_sr1       ),

    .alu_en_out              ( alu_en_mid    ),
    .alu_rd_out              ( alu_rd_mid    ),
    .alu_result              ( alu_result_mid    )
);

mul_0  u_mul_0 (
    .mul_en_in               ( eu0_mul_en     ),
    .mul_rd_in               ( eu0_rd_in     ),
    .mul_sel_in              ( eu0_uop_in[`UOP_MD_SEL]    ),
    .mul_sign                ( eu0_uop_in[`UOP_SIGN]     ),
    .mul_sr0                 ( eu0_sr0       ),
    .mul_sr1                 ( eu0_sr1       ),


    .mul_en_out              ( mul_en_mid    ),
    .mul_rd_out              ( mul_rd_mid    ),
    .mul_sel_out             ( mul_sel_mid   ),
    .mul_mid_rs_hh           ( mul_rs0_mid   ),
    .mul_mid_rs_hl           ( mul_rs1_mid   ),
    .mul_mid_rs_lh           ( mul_rs2_mid   ),
    .mul_mid_rs_ll           ( mul_rs3_mid   ),
    .mul_mid_rs_ad           ( mul_ad_mid    )
);

mul_1  u_mul_1 (
    .mul_mid_sr_hh           ( mul_sr0_exe1   ),
    .mul_mid_sr_hl           ( mul_sr1_exe1   ),
    .mul_mid_sr_lh           ( mul_sr2_exe1   ),
    .mul_mid_sr_ll           ( mul_sr3_exe1   ),
    .mul_mid_rs_ad           ( mul_ajustice_exe1),
    .mul_sel                 ( mul_sel_exe1   ),
    .mul_en_in               ( eu0_mul_en_0   ),
    .mul_rd_in               ( mul_rd_exe1    ),

    .mul_rd_out              ( mul_rd_out    ),
    .mul_en_out              ( mul_en_out    ),
    .result                  ( mul_result        )
);


mem0  u_mem0 (
    .mem_rd_in               ( eu0_rd_in             ),
    .mem_data_in             ( eu0_sr1           ),
    .mem_en_in               ( eu0_mem_en&&!stall&&!flush ),
    .mem_sr                  ( eu0_sr0                ),
    .mem_imm                 ( eu0_imm_in               ),
    .mem_write               ( eu0_uop_in[`UOP_MEM_WRITE]             ),
    .mem_width_in            ( eu0_uop_in[`UOP_MEM_WIDTH]            ),
    .mem_exp_in              (eu0_exp_in),
    .mem_sign                ( eu0_uop_in[`UOP_SIGN]),

    .valid                   ( valid           ),
    .op                      ( op              ),
    .addr(addr),
    .signed_ext(signed_ext),
    .write_type              ( write_type      ),
    .w_data_CPU              ( w_data_CPU      ),
    .mem_exp_out             ( mem_exp_mid     ),
    .mem_rd_out              ( mem_rd_mid      ),
    .mem_en_out              ( mem_en_mid      ),
    .mem_width_out           ( mem_width_mid   )
);

mem1  u_mem1 (
    .mem_exp_in              ( mem_exp_exe1            ),
    .mem_rd_in               ( mem_rd_exe1             ),
    .mem_en_in               ( mem_en_exe1             ),
    .mem_width_in            ( mem_width_exe1          ),
    .data_valid              ( data_valid            ),
    .r_data_CPU              ( r_data_CPU            ),

    .mem_exp_out             ( mem_exp_out           ),
    .mem_rd_out              ( mem_rd_out            ),
    .mem_data_out            ( mem_data_out          ),
    .mem_en_out              ( mem_en_out            ),
    .stall_because_cache     ( stall_because_cache   )
);

div  u_div (
    .clk                     ( clk                      ),
    .rstn                    ( rstn&&!flush_by_writeback ),
    .div_en_in               ( eu0_div_en&&!stall&&!flush        ),
    .div_op                  ( eu0_uop_in[`UOP_MD_SEL]                   ),
    .div_sign                ( eu0_uop_in[`UOP_SIGN]                 ),
    .div_sr0                 ( eu0_sr0                  ),
    .div_sr1                 ( eu0_sr1                  ),
    .div_addr_in             ( eu0_rd_in              ),

    .div_en_out              ( div_en_out               ),
    .stall_because_div       ( stall_because_div        ),
    .div_result              ( div_result               ),
    .div_addr_out            ( div_addr_out   )
);

//特权指令
exe_privliedged exe_privliedged
(
    .clk(clk),.rstn(rstn&&!flush_by_writeback),
    
    .en_in(eu0_priv_en&&!stall&&!flush),
    .pc_next(eu0_pc_next_in),
    .addr_in(eu0_rd_in),
    .imm(eu0_imm_in),
    .is_csr(eu0_uop_in[`ITYPE_IDX_CSR]),
    .is_tlb(eu0_uop_in[`ITYPE_IDX_TLB]),
    .is_cache(eu0_uop_in[`ITYPE_IDX_CACHE]),
    .is_idle(eu0_uop_in[`ITYPE_IDX_IDLE]),
    .is_ertn(eu0_uop_in[`ITYPE_IDX_ERET]),
    .inst(eu0_uop_in[`UOP_ORIGINAL_INST]),
    .sr0(eu0_sr0),
    .sr1(eu0_sr1),

    .en_out (priv_en_out),
    .pc_target(priv_pc),
    .flush(flush_because_priv),
    .stall_because_priv(stall_because_priv),
    .result(priv_data_out),
    .addr_out(priv_addr_out),

    .csr_software_query_en(csr_software_query_en),
    .csr_addr(csr_addr),
    .csr_rdata(csr_rdata),
    .csr_wen(csr_wen),
    .csr_wdata(csr_wdata),

    .era(era),
    .restore_state(restore_state)
);

wire[31:0]eu1_alu_sr1;
assign eu1_alu_sr1=eu1_uop_in[`UOP_SRC2]==`CTRL_SRC2_IMM?eu1_imm_in:eu1_sr1;
alu  u_alu1 (
    .alu_en_in               ( eu1_alu_en     ),
    .alu_control             ( eu1_uop_in[`UOP_ALUOP]   ),
    .alu_rd_in               ( eu1_rd_in     ),
    .alu_sr0                 ( eu1_sr0       ),
    .alu_sr1                 ( eu1_alu_sr1       ),

    .alu_en_out              ( eu1_alu_en_mid    ),
    .alu_rd_out              ( eu1_alu_rd_mid    ),
    .alu_result              ( eu1_alu_result_mid    )
);

endmodule 
