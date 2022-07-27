module forward(
    //从rf段后输入
    input [4:0]       eu0_rj,
    input [4:0]       eu0_rk,
    input [4:0]       eu1_rj,
    input [4:0]       eu1_rk,  
    input [31:0]      data00,
    input [31:0]      data01,
    input [31:0]      data10,
    input [31:0]      data11,
    //从exe1段后输入
    input [0:0]       eu0_en_0,
    input [0:0]       eu1_en_0,
    input [4:0]       eu0_rd_0,//接入第1段间寄存器的rd
    input [4:0]       eu1_rd_0,//接入第1段间寄存器的rd 
    input [31:0]      data_forward00, 
    input [31:0]      data_forward10,
    //从exe2段后输入
    input [0:0]       eu0_en_1,
    input [0:0]       eu1_en_1,
    input [4:0]       eu0_rd_1,//接入第2段间寄存器的rd
    input [4:0]       eu1_rd_1,//接入第2段间寄存器的rd
    input [31:0]      data_forward01,   
    input [31:0]      data_forward11,
    //向exe1段输出
    output reg [31:0] eu0_sr0,
    output reg [31:0] eu0_sr1,
    output reg [31:0] eu1_sr0,
    output reg [31:0] eu1_sr1
    
);
  assign flag=  eu0_en_1&&eu0_rj==eu0_rd_1 ;
    always @(*) begin
        if(eu0_rj==0)begin
            eu0_sr0=data00;
        end else if(eu1_en_0&&eu0_rj==eu1_rd_0)begin
            eu0_sr0=data_forward10;
        end else if(eu0_en_0&&eu0_rj==eu0_rd_0)begin
            eu0_sr0=data_forward00;
        end else if (eu1_en_1&&eu0_rj==eu1_rd_1)begin
            eu0_sr0=data_forward11;
        end else if (eu0_en_1&&eu0_rj==eu0_rd_1)begin
            eu0_sr0=data_forward01;
        end else begin
            eu0_sr0=data00;
        end                      

        if(eu0_rk==0)begin
            eu0_sr1=data01;
        end else if(eu1_en_0&&eu0_rk==eu1_rd_0)begin
            eu0_sr1=data_forward10;
        end else if(eu0_en_0&&eu0_rk==eu0_rd_0)begin
            eu0_sr1=data_forward00;
        end else if (eu1_en_1&&eu0_rk==eu1_rd_1)begin
            eu0_sr1=data_forward11;
        end else if (eu0_en_1&&eu0_rk==eu0_rd_1)begin
            eu0_sr1=data_forward01;
        end else begin
            eu0_sr1=data01;
        end

        if(eu1_rj==0)begin
            eu1_sr0=data10;
        end else if(eu1_en_0&&eu1_rj==eu1_rd_0)begin
            eu1_sr0=data_forward10;
        end else if(eu0_en_0&&eu1_rj==eu0_rd_0)begin
            eu1_sr0=data_forward00;
        end else if (eu1_en_1&&eu1_rj==eu1_rd_1)begin
            eu1_sr0=data_forward11;
        end else if (eu0_en_1&&eu1_rj==eu0_rd_1)begin
            eu1_sr0=data_forward01;
        end  else begin
            eu1_sr0=data10;
        end

        if(eu1_rk==0)begin
            eu1_sr1=data11;
        end else if(eu1_en_0&&eu1_rk==eu1_rd_0)begin
            eu1_sr1=data_forward10;
        end else if(eu0_en_0&&eu1_rk==eu0_rd_0)begin
            eu1_sr1=data_forward00;
        end else if (eu1_en_1&&eu1_rk==eu1_rd_1)begin
            eu1_sr1=data_forward11;
        end else if (eu0_en_1&&eu1_rk==eu0_rd_1)begin
            eu1_sr1=data_forward01;
        end else begin
            eu1_sr1=data11;
        end
    end

endmodule
