`include "uop.vh"

/*
About mul.w and mulh.w:
1. x<0 and y<0.
    $(2^{32}-x)\times(2^{32}-y)$ should equals to $p=xy$,
    but treating the input as unsigned numbers, the
    calcucated result $q=2^{64}-2^{32}*(x+y)+xy$.
    Apparently, the lower 32 bits of $p$ and $q$ are the same.
    For the higher 32 bits, the correct result $p_h = \lfloor xy/2^{32} \rfloor$,
    while the calculated result $q_h = 2^{32}-(x+y)+\lfloor xy/2^{32} \rfloor$.
    Therefore, $p_h \equiv q_h - [(2^{32}-x) + (2^{32}-y)] \pmod{2^{32}}$.
2. x<0 and y>=0.
    $(2^{32}-x)\times y$
    $p=2^64-xy$
    $q=2^{32}y-xy$
    lower 32 bits --- same
    higher 32 bits
        $p_h = $2^{32}-\lfloor xy/2^{32} \rfloor$
        $q_h = $y-\lfloor xy/2^{32} \rfloor$
        $p_h \equiv q_h - y \pmod{2^{32}}$
3. x>=0 and y<0
    lower 32 bits --- same
    higher 32 bits
        $p_h \equiv q_h - x \pmod{2^{32}}$
4. x>=0 and y>=0
    lower 32 bits --- same
    higher 32 bits --- same
*/
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
    
    output[31:0]mul_mid_rs_hh,
    output[31:0]mul_mid_rs_hl,
    output[31:0]mul_mid_rs_lh,
    output[31:0]mul_mid_rs_ll,
    output[31:0]mul_mid_rs_ad

);
    reg [31:0] adjustice;
    always @*
        if(mul_sign)
            case({mul_sr0[31],mul_sr1[31]})
            2'b11: adjustice = -(mul_sr0+mul_sr1);//case 1
            2'b10: adjustice = -mul_sr1;          //case 2
            2'b01: adjustice = -mul_sr0;          //case 3
            2'b00: adjustice = 0;                 //case 4
            endcase
        else adjustice = 0;
    assign mul_mid_rs_hh = mul_sr0[ 31:16 ] * mul_sr1[ 31:16 ];
    assign mul_mid_rs_hl = mul_sr0[ 31:16 ] * mul_sr1[ 15:0 ];
    assign mul_mid_rs_lh = mul_sr0[ 15:0 ]  * mul_sr1[ 31:16 ];
    assign mul_mid_rs_ll = mul_sr0[ 15:0 ]  * mul_sr1[ 15:0 ];
    assign mul_mid_rs_ad = adjustice;

    assign mul_en_out  = mul_en_in;
    assign mul_rd_out  = {5{mul_en_in}}&mul_rd_in;
    assign mul_sel_out = mul_sel_in;
endmodule

module mul_1 (
    input [31:0]mul_mid_sr_hh,
    input [31:0]mul_mid_sr_hl,
    input [31:0]mul_mid_sr_lh,
    input [31:0]mul_mid_sr_ll,
    input [31:0]mul_mid_rs_ad,
    input [0:0]mul_sel,
    input[0:0]mul_en_in,
    input[4:0]mul_rd_in,

    output[4:0]mul_rd_out,
    output[0:0]mul_en_out,
    output[31:0]result
);
    wire [63:0] result_full;
    wire [32:0] mul_sr1_plus_sr2 = mul_mid_sr_hl + mul_mid_sr_lh;
    assign result_full = {mul_mid_sr_hh,mul_mid_sr_ll} + {15'b0,mul_sr1_plus_sr2,16'b0};
    assign result = {32{mul_en_out}}&(mul_sel?result_full[63:32]+mul_mid_rs_ad:result_full[31:0]);
    assign mul_en_out = mul_en_in;
    assign mul_rd_out = {5{mul_en_out}}&mul_rd_in;
endmodule
