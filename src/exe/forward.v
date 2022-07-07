module forward(
    //从rf段后输入
    input [4:0]eu0_rj,
    input [4:0]eu0_rk,
    input [4:0]eu1_rj,
    input [4:0]eu1_rk,  
    input [31:0]data00,
    input [31:0]data01,
    input [31:0]data10,
    input [31:0]data11,
    //从exe1段后输入
    input [0:0]eu0_en_0,
    input [0:0]eu1_en_0,
    input [4:0]eu0_rd_0,//接入第1段间寄存器的rd
    input [4:0]eu1_rd_0,//接入第1段间寄存器的rd 
    input [31:0]data_forward00, 
    input [31:0]data_forward10,
    //从exe2段后输入
    input [0:0]eu0_en_1,
    input [0:0]eu1_en_1,
    input [4:0]eu0_rd_1,//接入第2段间寄存器的rd
    input [4:0]eu1_rd_1,//接入第2段间寄存器的rd
    input [31:0]data_forward01,   
    input [31:0]data_forward11,
    //向exe1段输出
    output [31:0]eu0_sr0,
    output [31:0]eu0_sr1,
    output [31:0]eu1_sr0,
    output [31:0]eu1_sr1
    
);
endmodule
