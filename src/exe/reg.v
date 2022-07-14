`include "../uop.vh"
module register_file(
    input [0:0]clk,
    input [0:0]rstn,
    //从exe2段后输入
    input [0:0]write_en_0,
    input [0:0]write_en_1,
    input [4:0]write_addr_0,
    input [4:0]write_addr_1,
    input [31:0]write_data_0,
    input [31:0]write_data_1,
    //从issue段后输入
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
    input[0:0]eu1_en_in,
    input[`WIDTH_UOP-1:0]eu1_uop_in,
    input [4:0]eu1_rd_in,
    input [4:0]eu1_rj_in,
    input [4:0]eu1_rk_in,
    input[31:0]eu1_pc_in,
    input[31:0]eu1_pc_next_in,
    input [6:0]eu1_exp_in,
    input[31:0]eu1_imm_in,
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
    output reg [31:0]eu1_imm_out
);



reg[31:0]register_file[31:0];

always @(posedge clk) begin
    if(!rstn)begin
        eu0_en_out<=0;
        eu0_uop_out<=0;
        eu0_rd_out<=0;
        eu0_rj_out<=0;
        eu0_rk_out<=0;
        eu0_pc_out<=0;
        eu0_pc_next_out<=0;
        eu0_exp_out<=0;
        read_data00<=0;
        read_data01<=0;
        eu0_imm_out<=0;
        eu1_en_out<=0;
        eu1_uop_out<=0;
        eu1_rd_out<=0;
        eu1_rj_out<=0;
        eu1_rk_out<=0;
        eu1_pc_out<=0;
        eu1_pc_next_out<=0;
        eu1_exp_out<=0;
        read_data10<=0;
        read_data11<=0;
        eu1_imm_out<=0;
    end else begin
    if (write_en_0) begin
        register_file[write_addr_0]<=write_data_0;
    end

    if (write_en_1) begin
        register_file[write_addr_1]<=write_data_1;
    end

    //if(eu0_en_in)begin
        eu0_en_out<=eu0_en_in;
        eu0_uop_out<=eu0_uop_in;
        eu0_rd_out<=eu0_rd_in;
        eu0_rj_out<=eu0_rj_in;
        eu0_rk_out<=eu0_rk_in;
        eu0_pc_out<=eu0_pc_in;
        eu0_pc_next_out<=eu0_pc_next_in;
        eu0_exp_out<=eu0_exp_in;
        eu0_imm_out<=eu0_imm_in;

        if(eu0_uop_in[`UOP_TYPE]==`ITYPE_IDX_ALU)begin
            case (eu0_uop_in[`UOP_SRC1])
                `CTRL_SRC1_RF:begin
                    if(eu0_rj_in==0)begin
                        read_data00<=0;
                    end else if (eu0_rj_in==write_addr_0) begin
                        read_data00<=write_data_0;
                    end else if (eu0_rj_in==write_addr_1) begin
                        read_data00<=write_data_1;
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
                    read_data00<=0;
                end
            endcase
        end else begin
            if(eu0_rj_in==0)begin
                read_data00<=0;
            end else   if (eu0_rj_in==write_addr_0) begin
                read_data00<=write_data_0;
            end else if (eu0_rj_in==write_addr_1) begin
                read_data00<=write_data_1;
            end else begin
                read_data00<=register_file[eu0_rj_in];
            end 
        end

        if(eu0_uop_in[`UOP_TYPE]==`ITYPE_IDX_ALU)begin
            case (eu0_uop_in[`UOP_SRC2])
                `CTRL_SRC2_RF:begin
                    if(eu0_rk_in==0)begin
                        read_data01<=0;
                    end else if (eu0_rk_in==write_addr_0) begin
                        read_data01<=write_data_0;
                    end else if (eu0_rk_in==write_addr_1) begin
                        read_data01<=write_data_1;
                    end else begin
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
                end else if (eu0_rk_in==write_addr_0) begin
                    read_data01<=write_data_0;
                end else if (eu0_rk_in==write_addr_1) begin
                    read_data01<=write_data_1;
                end else begin
                    read_data01<=register_file[eu0_rk_in];
                end 
        end
    //end

    //if(eu1_en_in)begin
        eu1_en_out<=eu1_en_in;
        eu1_uop_out<=eu1_uop_in;
        eu1_rd_out<=eu1_rd_in;
        eu1_rj_out<=eu1_rj_in;
        eu1_rk_out<=eu1_rk_in;
        eu1_pc_out<=eu1_pc_in;
        eu1_pc_next_out<=eu1_pc_next_in;
        eu1_exp_out<=eu1_exp_in;
        eu1_imm_out<=eu1_imm_in;

        case (eu1_uop_in[`UOP_SRC1])
            `CTRL_SRC1_RF:begin
                if(eu0_rj_in==0)begin
                        read_data10<=0;
                end else if (eu1_rj_in==write_addr_0) begin
                    read_data10<=write_data_0;
                end else if (eu1_rj_in==write_addr_1) begin
                    read_data10<=write_data_1;
                end else begin
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
                read_data10<=0;
            end
        endcase
        
        case (eu1_uop_in[`UOP_SRC2])
            `CTRL_SRC2_RF:begin
                if(eu0_rk_in==0)begin
                    read_data11<=0;
                end else if (eu1_rk_in==write_addr_0) begin
                    read_data11<=write_data_0;
                end else if (eu1_rk_in==write_addr_1) begin
                    read_data11<=write_data_1;
                end else begin
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
    //end 
end
end
endmodule