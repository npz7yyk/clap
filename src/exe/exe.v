`include "../uop.vh"
module exe(
    input [0:0]clk,   
    input [0:0]rstn,
    //从rf段后输入
    input [0:0]eu0_en_in,
    input [`WIDTH_UOP-1:0]eu0_uop_in,
    input [4:0]eu0_rd_in,
    input [4:0]eu0_rj_in,
    input [4:0]eu0_rk_in,
    input [31:0]eu0_pc_in,
    input [31:0]eu0_pc_next_in,
    input [5:0]eu0_exp_in,
    input [31:0]data00,
    input [31:0]data01,
    input [0:0]eu1_en_in,
    input [`WIDTH_UOP-1:0]eu1_uop_in,
    input [4:0]eu1_rd_in,
    input [4:0]eu1_rj_in,
    input [4:0]eu1_rk_in,
    input [31:0]data10,
    input [31:0]data11,
    input [5:0]eu1_exp_in,
    //向exe2段后输出
    output reg [31:0]data_out0,
    output reg [4:0]addr_out0,
    output reg [31:0]data_out1,
    output reg [4:0]addr_out1,
    //向issue段输出
    output reg [0:0]eu0_ready,

);

assign eu0_alu=eu0_en_in&eu0_uop_in[`UOP_TYPE]==`ITYPE_ALU;
assign eu0_mul=eu0_en_in&eu0_uop_in[`UOP_TYPE]==`ITYPE_MUL;
assign eu0_div=eu0_en_in&eu0_uop_in[`UOP_TYPE]==`ITYPE_DIV;
assign eu0_br=eu0_en_in&eu0_uop_in[`UOP_TYPE]==`ITYPE_BR;
assign eu0_mem=eu0_en_in&eu0_uop_in[`UOP_TYPE]==`ITYPE_MEM;

forward  u_forward (
    .eu0_rj                  ( eu0_rj           ),
    .eu0_rk                  ( eu0_rk           ),
    .eu1_rj                  ( eu1_rj           ),
    .eu1_rk                  ( eu1_rk           ),
    .data00                  ( data00           ),
    .data01                  ( data01           ),
    .data10                  ( data10           ),
    .data11                  ( data11           ),
    .eu0_en_0                ( eu0_en_0         ),
    .eu1_en_0                ( eu1_en_0         ),
    .eu0_rd_0                ( eu0_rd_0         ),
    .eu1_rd_0                ( eu1_rd_0         ),
    .data_forward00          ( data_forward00   ),
    .data_forward10          ( data_forward10   ),
    .eu0_en_1                ( eu0_en_1         ),
    .eu1_en_1                ( eu1_en_1         ),
    .eu0_rd_1                ( eu0_rd_1         ),
    .eu1_rd_1                ( eu1_rd_1         ),
    .data_forward01          ( data_forward01   ),
    .data_forward11          ( data_forward11   ),

    .eu0_sr0                 ( eu0_sr0          ),
    .eu0_sr1                 ( eu0_sr1          ),
    .eu1_sr0                 ( eu1_sr0          ),
    .eu1_sr1                 ( eu1_sr1          )
);

alu  u_alu (
    .alu_en_in               ( alu_en_in     ),
    .alu_control             ( alu_control   ),
    .alu_rd_in               ( alu_rd_in     ),
    .alu_sr0                 ( alu_sr0       ),
    .alu_sr1                 ( alu_sr1       ),

    .alu_en_out              ( alu_en_out    ),
    .alu_rd_out              ( alu_rd_out    ),
    .alu_result              ( alu_result    )
);

mul_0  u_mul_0 (
    .mul_en_in               ( mul_en_in     ),
    .mul_rd_in               ( mul_rd_in     ),
    .mul_sel_in              ( mul_sel_in    ),
    .mul_usign               ( mul_usign     ),
    .mul_sr0                 ( mul_sr0       ),
    .mul_sr1                 ( mul_sr1       ),

    .mul_en_out              ( mul_en_out    ),
    .mul_rd_out              ( mul_rd_out    ),
    .mul_sel_out             ( mul_sel_out   ),
    .mul_mid_rs0             ( mul_mid_rs0   ),
    .mul_mid_rs1             ( mul_mid_rs1   ),
    .mul_mid_rs2             ( mul_mid_rs2   ),
    .mul_mid_rs3             ( mul_mid_rs3   )
);


mul_1  u_mul_1 (
    .mul_mid_sr0             ( mul_mid_sr0   ),
    .mul_mid_sr1             ( mul_mid_sr1   ),
    .mul_mid_sr2             ( mul_mid_sr2   ),
    .mul_mid_sr3             ( mul_mid_sr3   ),
    .mul_sel                 ( mul_sel       ),
    .mul_en_in               ( mul_en_in     ),
    .mul_rd_in               ( mul_rd_in     ),

    .mul_rd_out              ( mul_rd_out    ),
    .mul_en_out              ( mul_en_out    ),
    .result                  ( result        )
);






endmodule 