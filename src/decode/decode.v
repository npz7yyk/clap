// SPDX-License-Identifier: Apache-2.0
// decode.v: 指令解码

// Authors: 张子辰 <zichen350@gmail.com>

// Copyright (C) 2022 乐亦康, 张子辰, 郭耸霄 and 马子睿.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//      http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Revisions:
// 2022-05-13: Create module.
// 2022-05-17: fetch buffer and instruction decoder (without privileged instructions decoding)
// 2022-05-28: decoder: immediate number generator, signals used by branch prediction unit
// 2022-07-10: use predecoder module to generate feedback signals for branch prediction unit

`timescale 1ns / 1ps
`include "../uop.vh"
`include "../exception.vh"

//纯组合逻辑，译码器
//【注意】load、br指令的原本位于rd段的源数据被放到了rk，而rd=0，这样可以保证读取寄存器堆时只需要读rk和rj
module decoder
(
    input [102:0] pcnext_pc_inst,
    output [31:0] pc,pc_next, //从pcnext_pc_inst拆解出的pc和pc_next
    output [6:0] exception,
    output invalid,
    output [`WIDTH_UOP-1:0] uop,
    output [31:0] imm,
    output [4:0] rd,
    output [4:0] rj,
    output [4:0] rk
);
    wire [31:0] inst = pcnext_pc_inst[31:0];
    assign pc=pcnext_pc_inst[63:32];
    assign pc_next=pcnext_pc_inst[95:64];
    assign exception=pcnext_pc_inst[102:96];
    /////////////////////////////
    //鉴别指令类型
    wire [`UOP_TYPE] type;
    assign type[`ITYPE_IDX_BR] = inst[30]=='b1;
    wire is_b_or_bl = inst[30:27]=='b1010;
    wire is_jilr = inst[30:26]=='b10011;
    assign type[`ITYPE_IDX_BAR] = inst[30:16]=='b011100001110010;
    assign type[`ITYPE_IDX_MEM] = inst[30:28]=='b010;
    wire is_preload = inst[30:22]=='b010101011;
    wire is_pcadd = inst[30:25]=='b001110;
    wire is_lui = inst[30:25]=='b001010;
    assign type[`ITYPE_IDX_CSR] = inst[30:24]=='b0000100;
    wire is_alu_imm = inst[30:25]=='b0000001;
    assign type[`ITYPE_IDX_CACHE] = inst[30:22]=='b000011000;
    //这个invalid的含义是与众不同的，这里的invalid表示指令INVTLB，而其他地方的invalid表示unknown instruction
    wire tlb_invalid = inst[30:15]=='b0000110010010011;
    assign type[`ITYPE_IDX_IDLE] = inst[30:15]=='b0000110010010001;
    assign type[`ITYPE_IDX_ERET] = inst[30:10]=='b000011001001000001110;
    assign type[`ITYPE_IDX_TLB] = tlb_invalid||
        inst[30:13]=='b000011001001000001&&inst[12:10]!='b110;
    assign type[`ITYPE_IDX_ECALL] = inst[30:17]=='b00000000010101&&inst[15]=='b0;
    assign type[`ITYPE_IDX_DIV] = inst[30:17]=='b00000000010000;
    assign type[`ITYPE_IDX_MUL] = inst[30:17]=='b00000000010000;
    wire is_alu_sfti = inst[30:20]=='b00000000100&&inst[17:15]=='b001;
    wire is_sra = inst[30:15]=='b0000000000110000;
    wire is_time = inst[30:11]=='b00000000000000001100;
    wire is_alu = inst[30:19]=='b000000000010;
    assign type[`ITYPE_IDX_ALU]=is_alu||is_time||is_sra||is_alu_sfti||is_alu_imm||is_pcadd||is_lui;
    ///////////////////////////////////
    
    ///////////////////////////////////
    //其他控制信号
    reg [1:0]src1,src2;
    always @* begin
        if(is_lui)src1=`CTRL_SRC1_ZERO;
        else if(is_pcadd)src1=`CTRL_SRC1_PC;
        else if(is_time&&inst[10]==0&&inst[4:0]==0)src1=`CTRL_SRC1_CNTID;
        else src1=`CTRL_SRC1_RF;
    end
    always @* begin
        if(is_alu_imm||is_alu_sfti||is_lui||is_pcadd)src2=`CTRL_SRC2_IMM;
        else if(is_time) begin
            if(inst[10]==0&&inst[4:0]!=0)
                src2=`CTRL_SRC2_CNTL;
            else
                src2=`CTRL_SRC2_CNTH;
        end
        else src2=`CTRL_SRC2_RF;
    end
    
    reg [`UOP_ALUOP] alu_op;
    reg alu_op_invalid;
    wire is_unsigned_imm = inst[30:23]=='b00000110;
    always @* begin
        alu_op_invalid=0;
        alu_op=`CTRL_ALU_ADD;
        if(is_alu)
            alu_op=inst[18:15];
        else if(is_alu_imm) begin
            case(inst[24:22])
            3'b000: alu_op=`CTRL_ALU_SLT;
            3'b001: alu_op=`CTRL_ALU_SLTU;
            3'b010: alu_op=`CTRL_ALU_ADD;
            3'b101: alu_op=`CTRL_ALU_AND;
            3'b110: alu_op=`CTRL_ALU_OR;
            3'b111: alu_op=`CTRL_ALU_XOR;
            default: begin
                alu_op=0;
                alu_op_invalid=1;
            end
            endcase
        end
        else if(is_alu_sfti) begin
            case(inst[19:18])
            2'b00: alu_op=`CTRL_ALU_SLL;
            2'b01: alu_op=`CTRL_ALU_SRL;
            2'b10: alu_op=`CTRL_ALU_SRA;
            default: begin
                alu_op=0;
                alu_op_invalid=1;
            end
            endcase
        end
        else if(is_sra) alu_op=`CTRL_ALU_SRA;
    end
    
    reg [3:0] cond;
    reg br_invalid;
    always @* begin
        cond=0;
        br_invalid=0;
        if(type[`ITYPE_IDX_BR]) begin
            cond = inst[29:26];
            case(inst[29:26])
            //jirl, b, bl
            4'b0011, 4'b0100, 4'b0101,
            //beq
            4'b0110,
            //bne
            4'b0111,
            //blt
            4'b1000,
            //bge
            4'b1001,
            //bltu
            4'b1010,
            //bgeu
            4'b1011: ;
            default: br_invalid=1;
            endcase
        end
    end
    
    //为NOP指令分配专门的UOP_TYPE，方便后续处理
    assign uop[`UOP_TYPE]=(inst==`INST_NOP||invalid)?0:type;
    assign uop[`UOP_SRC1]=src1;
    assign uop[`UOP_SRC2]=src2;
    assign uop[`UOP_MEM_ATM]= ~inst[27];
    
    //符号域: 乘除的inst[16]、访存的inst[25]
    assign uop[`UOP_USIGN]=
        (type[`ITYPE_IDX_MUL]|type[`ITYPE_IDX_DIV])&inst[16] |
        (type[`ITYPE_IDX_MEM])&inst[25];
    
    //各种指令格式的操作位（包括alu、mul、div、mem、br）
    assign uop[`UOP_COND]=
        {4{type[`ITYPE_IDX_ALU]}}&alu_op |
        {3'b0,(type[`ITYPE_IDX_MUL]|type[`ITYPE_IDX_DIV])&inst[15]} |
        //inst[27]==1时是保留取字和条件存字，宽度是32位
        {4{type[`ITYPE_IDX_MEM]}}&{1'b0,inst[24],inst[27]?inst[23:22]:2'b10}|
        {4{type[`ITYPE_IDX_BR]}}&cond;
    ////////////////////////////////////
    
    ///////////////////////////////////
    //ATTENTION: 当UOP_TYPE改变时需要手动修改
    //非法指令检查
    //检查12位的type只含一个1
    wire [5:0] tmp_or0 = type[5:0]|type[11:6];
    wire [5:0] tmp_and0 = type[5:0]&type[11:6];
    wire [2:0] tmp_or1 = tmp_or0[2:0]|tmp_or0[5:3];
    wire [2:0] tmp_and1 = tmp_or0[2:0]&tmp_or0[5:3];
    wire [1:0] tmp_or2 = tmp_or1[1:0]|{1'b0,tmp_or1[2:2]};
    wire [1:0] tmp_and2 = tmp_or1[1:0]&{1'b0,tmp_or1[2:2]};
    wire [0:0] tmp_and3 = tmp_or2[0]&tmp_or2[1];
    wire type_invalid = tmp_and0!=0||tmp_and1!=0||tmp_and2!=0||tmp_and3!=0||type==0;
    
    assign invalid=alu_op_invalid||type_invalid||br_invalid||inst[31];
    //////////////////////////////////////
    
    /////////////////////////////////////
    //目标地址
    assign rd =
        (type[`ITYPE_IDX_ECALL]||
        type[`ITYPE_IDX_CACHE]||
        type[`ITYPE_IDX_TLB]||
        type[`ITYPE_IDX_IDLE]||
        type[`ITYPE_IDX_CSR]||
        is_preload||
        type[`ITYPE_IDX_MEM]&&uop[`UOP_MEM_WRITE]&&!uop[`UOP_MEM_ATM]||
        //除了jilr和bl之外的分支
        type[`ITYPE_IDX_BR]&&!is_jilr&&!inst[29:26]!='b0101)?0:
            //bl 向r1写PC+4
            inst[30:26]==('b10101)?1:
            inst[4:0];
    
    //源地址1
    assign rj =
        (type[`ITYPE_IDX_ECALL]||
        type[`ITYPE_IDX_CSR]||
        type[`ITYPE_IDX_TLB]||
        type[`ITYPE_IDX_IDLE]||
        is_pcadd||is_lui||is_b_or_bl)?0:
        inst[9:5];
    
    //源地址2
    assign rk = 
        (is_alu || is_sra ||
        type[`ITYPE_IDX_MUL] ||
        type[`ITYPE_IDX_DIV])? inst[14:10]: 
            (type[`ITYPE_IDX_MEM]&&uop[`UOP_MEM_WRITE] || type[`ITYPE_IDX_BR]&&!(is_b_or_bl||is_jilr))? inst[4:0]:0;
    /////////////////////////////////////
    
    ////////////////////////////////////////////
    //立即数 (参见 立即数.ods）
//    wire is_u5  = is_alu_sfti;    //u5按 i12处理（所以ALU单元必须截取imm[4:0]）
    wire is_i12 = type[`ITYPE_IDX_CACHE] |
        is_alu_imm&~inst[24] |      //addi、slti、sltui的inst[24]都等于0
        type[`ITYPE_IDX_MEM]&inst[27] |
        is_alu_sfti;
    wire is_u12 = is_alu_imm&inst[24];//andi、ori、xori的inst[24]都等于1
    wire is_i14 = type[`ITYPE_IDX_MEM]&~inst[27] |
        type[`ITYPE_IDX_CSR];
    wire is_i16 = type[`ITYPE_IDX_BR]&~is_b_or_bl;
    wire is_i26 = is_b_or_bl;
    wire is_i20 = is_pcadd|is_lui;
    
    wire [31:0] i12_result = $signed(inst[21:10]);
    wire [31:0] u12_result = inst[21:10];
    wire [31:0] i14_result = $signed(inst[23:10]);
    wire [31:0] i16_result = $signed(inst[25:10]);
    wire [31:0] i26_result = $signed({inst[9:0],inst[25:10]});
    wire [31:0] i20_result = $signed(inst[24:5]);
    
    assign imm = 
        i12_result&{32{is_i12}} |
        u12_result&{32{is_u12}} |
        i14_result&{32{is_i14}} |
        i16_result&{32{is_i16}} |
        i26_result&{32{is_i26}} |
        i20_result&{32{is_i20}};
    ////////////////////////////////////////////
endmodule
