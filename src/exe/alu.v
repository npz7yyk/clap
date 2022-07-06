module alu (
    input clk,
    input[0:0]eu0_en_in,
    input[`WIDTH_UOP-1:0]eu0_uop_in,
    input [4:0]eu0_rd_in,
    input [5:0]eu0_exp_in,
    input [31:0]data00,
    input[31:0]data10,
);

    wire op_add;
    wire op_sub;
    wire op_slt;
    wire op_sltu;
    wire op_and;
    wire op_or;
    wire op_nor;
    wire op_xor;
    wire op_sll;
    wire op_srl;
    wire op_sra;
    assign op_add  = alu_control[ 0 ];
    assign op_sub  = alu_control[ 1 ];
    assign op_slt  = alu_control[ 2 ];
    assign op_sltu = alu_control[ 3 ];
    assign op_and  = alu_control[ 4 ];
    assign op_or   = alu_control[ 5 ];
    assign op_nor  = alu_control[ 6 ];
    assign op_xor  = alu_control[ 7 ];
    assign op_sll  = alu_control[ 8 ];
    assign op_srl  = alu_control[ 9 ];
    assign op_sra  = alu_control[ 10 ];
    wire[ 31:0 ]add_sub_result;
    wire[ 31:0 ]slt_result;
    wire[ 31:0 ]sltu_result;
    wire[ 31:0 ]and_result;
    wire[ 31:0 ]nor_result;
    wire[ 31:0 ]or_result;
    wire[ 31:0 ]xor_result;
    wire[ 31:0 ]sll_result;
    wire[ 31:0 ]srl_result;
    wire[ 31:0 ]sra_result;
    assign and_result = alu_sr0&alu_sr1;
    assign or_result  = alu_sr0|alu_sr1;
    assign nor_result = ~or_result;
    assign xor_result = alu_sr0^alu_sr1;
    wire [ 31:0 ]adder_a;
    wire [ 31:0 ]adder_b;
    wire adder_cin;
    wire [ 31:0 ]adder_result;
    wire adder_cout;
    assign adder_a                   = alu_sr0;
    assign adder_b                   = ( op_sub|op_slt|op_sltu )?~alu_sr1:alu_sr1;
    assign adder_cin                 = ( op_sub|op_slt|op_sltu )?1'b1:1'b0;
    assign {adder_cout,adder_result} = adder_a+adder_b+adder_cin;
    assign add_sub_result            = adder_result;
    assign slt_result[ 31:1 ]        = 31'b0;
    assign sll_result[ 0 ]           = ( alu_sr0[ 31 ]&~alu_sr1[ 31 ] )|( ~( alu_sr0[ 31 ]^alu_sr1[ 31 ] )&adder_result[ 31 ] );
    assign sltu_result[ 31:1 ]       = 31'b0;
    assign sltu_result[ 0 ]          = ~adder_cout;
    assign sll_result                = alu_sr1<<alu_sr0[ 4:0 ];
    assign srl_result                = alu_sr1>>alu_sr0[ 4:0 ];
    assign sra_result                = ( $signed ( alu_sr1 ) )>>>alu_sr0[ 4:0 ];
    assign alu_result_pre            = ( {32{op_add|op_sub}}&add_sub_result )|( {32{op_slt}}&slt_result )|( {32{op_sltu}}&sltu_result )|( {32{op_and}}&and_result )|( {32{op_nor}}&nor_result )|( {32{op_or}}&or_result )|( {32{op_xor}}&xor_result )|( {32{op_sll}}&sll_result )|( {32{op_srl}}&srl_result )|( {32{op_sra}}&sra_result );
    always @( posedge clk ) begin
        if ( !rstn )begin
            alu_result        <= 0;
            alu_from_addr_out <= 0;
            alu_from_chosen   <= 0;
            end else if ( alu_validn )begin
            alu_result        <= alu_result_pre;
            alu_from_addr_out <= alu_from_addr_in;
            alu_from_chosen   <= alu_to_chosen;
        end
    end
endmodule
