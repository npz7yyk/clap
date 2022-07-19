`include "uop.vh"

module mul_0(

    input[0:0]mul_en_in,
    input[4:0]mul_rd_in,
    input[0:0]mul_sel_in,
    input[0:0]mul_sign,
    
    input[31:0]mul_sr0,
    input[31:0]mul_sr1,

    output[0:0]mul_en_out,
    output[4:0]mul_rd_out,
    output[0:0]mul_sel_out,
    output[0:0]mul_sign_out,
    
    output[35:0]mul_mid_rs0,
    output[35:0]mul_mid_rs1,
    output[35:0]mul_mid_rs2,
    output[35:0]mul_mid_rs3

);
    wire [ 35:0 ]mul_mid_sr0;
    wire [ 35:0 ]mul_mid_sr1;
    assign mul_mid_sr0 = mul_sign?{{4{mul_sr0[ 31 ]}},mul_sr0}:{4'b0,mul_sr0};
    assign mul_mid_sr1 = mul_sign?{{4{mul_sr1[ 31 ]}},mul_sr1}:{4'b0,mul_sr1};
    assign mul_mid_rs0 = mul_mid_sr0[ 35:18 ]*mul_mid_sr1[ 35:18 ];
    assign mul_mid_rs1 = mul_mid_sr0[ 35:18 ]*mul_mid_sr1[ 17:0 ];
    assign mul_mid_rs2 = mul_mid_sr0[ 17:0 ]*mul_mid_sr1[ 35:18 ];
    assign mul_mid_rs3 = mul_mid_sr0[ 17:0 ]*mul_mid_sr1[ 17:0 ];

    assign mul_en_out=mul_en_in;
    assign mul_rd_out=mul_en_in?mul_rd_in:0;
    assign mul_sel_out=mul_sel_in;
    assign mul_sign_out=mul_sign;
endmodule

module mul_1 (
    input [35:0]mul_mid_sr0,
    input [35:0]mul_mid_sr1,
    input [35:0]mul_mid_sr2,
    input [35:0]mul_mid_sr3,
    input [0:0]mul_sel,
    input[0:0]mul_en_in,
    input[4:0]mul_rd_in,
    input[0:0]mul_sign,

    output[4:0]mul_rd_out,
    output[0:0]mul_en_out,
    output[31:0]result
);
    wire[71:0]result_full;
    assign result_full={mul_mid_sr0,36'b0}+{{18{mul_mid_sr1[35]&mul_sign}},mul_mid_sr1,18'b0}+{{18{mul_mid_sr2[35]&mul_sign}},mul_mid_sr2,18'b0}+{{36{mul_mid_sr3[35]&mul_sign}},mul_mid_sr3};
    assign result=mul_en_out?(mul_sel?result_full[63:32]:result_full[31:0]):0;
    assign mul_en_out=mul_en_in;
    assign mul_rd_out=mul_en_out?mul_rd_in:0;
endmodule
