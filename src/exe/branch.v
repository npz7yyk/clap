
module branch(
    input [0:0]br_en_in,
    input [ 31:0]pc,
    input [ 31:0]pc_next,
    input [ 5:0 ]branch_op,
    input [4:0]br_rd_addr_in,
    input [ 31:0 ]branch_sr0,
    input [ 31:0 ]branch_sr1,
    input [ 31:0 ]branch_imm,
    
    output[31:0]br_rd_data,
    output[4:0]br_rd_addr_out,
    output[0:0]br_en_out,
    output[0:0]flush,
    output[ 31:0 ]branch_addr_calculated
);

parameter  JIRL = 'b010011;
parameter  B    = 'b010100;
parameter  BL   = 'b010101;
parameter  BEQ  = 'b010110;
parameter  BNE  = 'b010111;
parameter  BLT  = 'b011000;
parameter  BGE  = 'b011001;
parameter  BLTU = 'b011010;
parameter  BGEU = 'b011011;

assign branch_status = branch_op == JIRL
                    ||branch_op == B
                    ||branch_op == BL
                    ||branch_op == BEQ&&branch_sr0 == branch_sr1
                    ||branch_op == BNE&&branch_sr0!= branch_sr1
                    ||branch_op == BLT&&$signed ( branch_sr0 ) <$signed ( branch_sr1 )
                    ||branch_op == BGE&&$signed ( branch_sr0 ) >= $signed ( branch_sr1 )
                    ||branch_op == BLTU&&branch_sr0<branch_sr1
                    ||branch_op == BGEU&&branch_sr0>= branch_sr1;

assign br_en_out=br_en_in&&(branch_op == JIRL||branch_op == BL);
assign br_rd_addr_out=branch_op==JIRL?br_rd_addr_in:branch_op==BL?1:0;
assign br_rd_data=pc+4;

assign branch_addr_calculated =branch_status? branch_op==JIRL?(branch_sr1+ (branch_imm<<2)):(pc+(branch_imm<<2)):pc+4;

assign flush=br_en_in&&(branch_addr_calculated==pc_next);

endmodule
