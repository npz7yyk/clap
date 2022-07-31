`include "clap_config.vh"
`include "uop.vh"

/* verilator lint_off DECLFILENAME */
module register_file(
    input [0:0]clk,
    input [0:0]rstn,
    input [0:0]stall,
    input [0:0]flush,
    //从exe2段后输入
    input [0:0]write_en_0,
    input [0:0]write_en_1,
    input [4:0]write_addr_0,
    input [4:0]write_addr_1,
    input [31:0]write_data_0,
    input [31:0]write_data_1,
    //从issue段后输入
    input [31:0]counter_id,
    input[63:0]stable_counter,
    input[0:0]eu0_en_in,
    input[`WIDTH_UOP-1:0]eu0_uop_in,
    input [4:0]eu0_rd_in,
    input [4:0]eu0_rj_in,
    input [4:0]eu0_rk_in,
    input[31:0]eu0_pc_in,
    input[31:0]eu0_pc_next_in,
    input [6:0]eu0_exp_in,
    input[31:0]eu0_imm_in,
    input[31:0]eu0_badv_in,
    input eu0_unknown_in,
    input[0:0]eu1_en_in,
    input[`WIDTH_UOP-1:0]eu1_uop_in,
    input [4:0]eu1_rd_in,
    input [4:0]eu1_rj_in,
    input [4:0]eu1_rk_in,
    input[31:0]eu1_pc_in,
    input[31:0]eu1_pc_next_in,
    input [6:0]eu1_exp_in,
    input[31:0]eu1_imm_in,
    input[31:0]eu1_badv_in,
    input eu1_unknown_in,
    //向rf段后输出
    output reg [0:0]eu0_en_out,
    output reg [`WIDTH_UOP-1:0]eu0_uop_out,
    output reg  [4:0]eu0_rd_out,
    output reg  [4:0]eu0_rj_out,
    output reg  [4:0]eu0_rk_out,
    output reg [31:0]eu0_pc_out,
    output reg [31:0]eu0_pc_next_out,
    output reg  [6:0]eu0_exp_out,
    output reg [31:0]read_data00,
    output reg [31:0]read_data01,
    output reg [31:0]eu0_imm_out,
    output reg [31:0]eu0_badv_out,
    output reg eu0_unknown_out,
    output reg [0:0]eu1_en_out,
    output reg [`WIDTH_UOP-1:0]eu1_uop_out,
    output reg  [4:0]eu1_rd_out,
    output reg  [4:0]eu1_rj_out,
    output reg  [4:0]eu1_rk_out,
    output reg [31:0]eu1_pc_out,
    output reg [31:0]eu1_pc_next_out,
    output reg  [6:0]eu1_exp_out,
    output reg [31:0]read_data10,
    output reg [31:0]read_data11,
    output reg [31:0]eu1_imm_out,
    output reg [31:0]eu1_badv_out,
    output reg eu1_unknown_out,
    //向前输出
    output [0:0] stall_by_conflict

    `ifdef CLAP_CONFIG_DIFFTEST
    ,output [31:0] reg_diff [31:0],
    output [63:0] stable_counter_diff
    `endif
);

reg[31:0]register_file[31:0];
reg[0:0]stall_by_conflict_old;

`ifdef CLAP_CONFIG_DIFFTEST
assign reg_diff = register_file;
always @(posedge clk) begin
    if(!stall) stable_counter_diff<=stable_counter;
end
`endif

assign stall_by_conflict = eu0_en_out
                        &&(eu0_en_in
                        &&eu0_rd_out!=0
                        &&(eu0_rj_in==eu0_rd_out
                        ||eu0_rk_in==eu0_rd_out)
                        ||eu1_en_in
                        &&eu0_rd_out!=0
                        &&(eu1_rj_in==eu0_rd_out
                        ||eu1_rk_in==eu0_rd_out))
                        &&(eu0_uop_out[`ITYPE_IDX_MUL]
                        ||eu0_uop_out[`ITYPE_IDX_BR]
                        ||eu0_uop_out[`ITYPE_IDX_CSR]
                        ||eu0_uop_out[`ITYPE_IDX_DIV]
                        ||eu0_uop_out[`ITYPE_IDX_MEM])
                        ||eu0_uop_in[`ITYPE_IDX_DIV]&&eu0_uop_out[`ITYPE_IDX_DIV];

always @(posedge clk) begin
    if (!stall) begin
        stall_by_conflict_old<=stall_by_conflict;
end
    end
    
always @(posedge clk) begin
    if (write_en_0&&(write_addr_0!=write_addr_1||write_en_1==0)) begin
        register_file[write_addr_0]<=write_addr_0==0?0:write_data_0;
    end
    if (write_en_1) begin
        register_file[write_addr_1]<=write_addr_1==0?0:write_data_1;
    end
    if(!rstn||flush)begin
        {eu0_en_out,
        eu0_uop_out,
        eu0_rd_out,
        eu0_rj_out,
        eu0_rk_out,
        eu0_pc_out,
        eu0_pc_next_out,
        eu0_exp_out,
        eu0_badv_out,
        eu0_unknown_out,
        read_data00,
        read_data01,
        eu0_imm_out,
        eu1_en_out,
        eu1_uop_out,
        eu1_rd_out,
        eu1_rj_out,
        eu1_rk_out,
        eu1_pc_out,
        eu1_pc_next_out,
        eu1_exp_out,
        eu1_badv_out,
        eu1_unknown_out,
        read_data10,
        read_data11,
        eu1_imm_out}<=0;
    end else if(!stall)begin
        eu0_en_out<=eu0_en_in&&(!stall_by_conflict||stall_by_conflict_old);
        eu0_uop_out<=eu0_uop_in;
        eu0_rd_out<=eu0_rd_in;
        eu0_rj_out<=eu0_rj_in;
        eu0_rk_out<=eu0_rk_in;
        eu0_pc_out<=eu0_pc_in;
        eu0_pc_next_out<=eu0_pc_next_in;
        eu0_exp_out<=eu0_exp_in;
        eu0_badv_out<=eu0_badv_in;
        eu0_unknown_out<=eu0_unknown_in;
        eu0_imm_out<=eu0_imm_in;
        if(eu0_uop_in[`ITYPE_IDX_ALU])begin
            case (eu0_uop_in[`UOP_SRC1])
                `CTRL_SRC1_RF:begin
                    if(eu0_rj_in==0)begin
                        read_data00<=0;
                    end else if (eu0_rj_in==write_addr_1&&write_en_1) begin
                        read_data00<=write_data_1;
                    end else if (eu0_rj_in==write_addr_0&&write_en_0) begin
                        read_data00<=write_data_0;
                    end else begin
                        read_data00<=register_file[eu0_rj_in];
                    end 
                end
                `CTRL_SRC1_PC: begin
                    read_data00<=eu0_pc_in;
                end
                `CTRL_SRC1_ZERO:begin
                    read_data00<=0;
                end
                `CTRL_SRC1_CNTID:begin
                    read_data00<=counter_id;
                end
            endcase
        end else begin
            if(eu0_rj_in==0)begin
                read_data00<=0;
            end else if (eu0_rj_in==write_addr_1&&write_en_1) begin
                read_data00<=write_data_1;
            end else if (eu0_rj_in==write_addr_0&&write_en_0) begin
                read_data00<=write_data_0;
            end  else begin
                read_data00<=register_file[eu0_rj_in];
            end 
        end
        if(eu0_uop_in[`ITYPE_IDX_ALU])begin
            case (eu0_uop_in[`UOP_SRC2])
                `CTRL_SRC2_RF:begin
                    if(eu0_rk_in==0)begin
                        read_data01<=0;
                    end else if (eu0_rk_in==write_addr_1&&write_en_1) begin
                        read_data01<=write_data_1;
                    end else if (eu0_rk_in==write_addr_0&&write_en_0) begin
                        read_data01<=write_data_0;
                    end  else begin
                        read_data01<=register_file[eu0_rk_in];
                    end 
                end
                `CTRL_SRC2_IMM: begin
                    read_data01<=eu0_imm_in;
                end
                `CTRL_SRC2_CNTL:begin
                    read_data01<=stable_counter[31:0];
                end
                `CTRL_SRC2_CNTH:begin
                    read_data01<=stable_counter[63:32];
                end
            endcase
        end else begin
                if(eu0_rk_in==0)begin
                    read_data01<=0;
                end else if (eu0_rk_in==write_addr_1&&write_en_1) begin
                    read_data01<=write_data_1;
                end else if (eu0_rk_in==write_addr_0&&write_en_0) begin
                    read_data01<=write_data_0;
                end  else begin
                    read_data01<=register_file[eu0_rk_in];
                end 
        end
        eu1_en_out<=eu1_en_in&&(!stall_by_conflict||stall_by_conflict_old);
        eu1_uop_out<=eu1_uop_in;
        eu1_rd_out<=eu1_rd_in;
        eu1_rj_out<=eu1_rj_in;
        eu1_rk_out<=eu1_rk_in;
        eu1_pc_out<=eu1_pc_in;
        eu1_pc_next_out<=eu1_pc_next_in;
        eu1_exp_out<=eu1_exp_in;
        eu1_badv_out<=eu1_badv_in;
        eu1_unknown_out<=eu1_unknown_in;
        eu1_imm_out<=eu1_imm_in;
        case (eu1_uop_in[`UOP_SRC1])
            `CTRL_SRC1_RF:begin
                if(eu1_rj_in==0)begin
                        read_data10<=0;
                end else if (eu1_rj_in==write_addr_1&&write_en_1) begin
                    read_data10<=write_data_1;
                end else if (eu1_rj_in==write_addr_0&&write_en_0) begin
                    read_data10<=write_data_0;
                end  else begin
                    read_data10<=register_file[eu1_rj_in];
                end 
            end
            `CTRL_SRC1_PC: begin
                read_data10<=eu1_pc_in;
            end
            `CTRL_SRC1_ZERO:begin
                read_data10<=0;
            end
            `CTRL_SRC1_CNTID:begin
                read_data10<=counter_id;
            end
        endcase
        case (eu1_uop_in[`UOP_SRC2])
            `CTRL_SRC2_RF:begin
                if(eu1_rk_in==0)begin
                    read_data11<=0;
                end else if (eu1_rk_in==write_addr_1&&write_en_1) begin
                    read_data11<=write_data_1;
                end else if (eu1_rk_in==write_addr_0&&write_en_0) begin
                    read_data11<=write_data_0;
                end  else begin
                    read_data11<=register_file[eu1_rk_in];
                end 
            end
            `CTRL_SRC2_IMM: begin
                read_data11<=eu1_imm_in;
            end
            `CTRL_SRC2_CNTL:begin
                read_data11<=stable_counter[31:0];
            end
            `CTRL_SRC2_CNTH:begin
                read_data11<=stable_counter[63:32];
            end
        endcase
    end 
end
endmodule
