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

`include "clap_config.vh"
`include "uop.vh"
`include "exception.vh"

//纯组合逻辑，译码器
//【注意】load、br指令的原本位于rd段的源数据被放到了rk，而rd=0，这样可以保证读取寄存器堆时只需要读rk和rj
/* verilator lint_off DECLFILENAME */
module decoder
(
    input [136:0] nempty_unknown_badv_exception_pcnext_pc_inst,
    output [31:0] pc,pc_next, //从pcnext_pc_inst拆解出的pc和pc_next
    output [6:0] exception,
    output [31:0] badv,
    output unknown,
    output invalid_instruction,
    output is_syscall,
    output is_break,
    output is_priviledged,
    output [`WIDTH_UOP-1:0] uop,
    output [31:0] imm,
    output [4:0] rd,
    output [4:0] rj,
    output [4:0] rk
);
    wire uop_nempty = nempty_unknown_badv_exception_pcnext_pc_inst[136];
    assign uop[`UOP_NEMPTY] = uop_nempty;
    wire [31:0] inst = nempty_unknown_badv_exception_pcnext_pc_inst[31:0];
    assign pc=nempty_unknown_badv_exception_pcnext_pc_inst[63:32];
    assign pc_next=nempty_unknown_badv_exception_pcnext_pc_inst[95:64];
    assign exception=nempty_unknown_badv_exception_pcnext_pc_inst[102:96];
    assign badv=nempty_unknown_badv_exception_pcnext_pc_inst[134:103];
    assign unknown = nempty_unknown_badv_exception_pcnext_pc_inst[135];
    assign uop[`UOP_ORIGINAL_INST] = inst;
    /////////////////////////////
    //鉴别指令类型
    wire [`UOP_TYPE] type_;
    assign type_[`ITYPE_IDX_BR] = inst[30]=='b1;
    wire is_b_or_bl = inst[30:27]=='b1010;
    wire is_jilr = inst[30:26]=='b10011;
    assign type_[`ITYPE_IDX_BAR] = inst[30:16]=='b011100001110010;
    assign type_[`ITYPE_IDX_MEM] = inst[30:28]=='b010;
    wire is_preload = inst[30:22]=='b010101011;
    assign uop[`UOP_PRELOAD] = is_preload;
    wire is_pcadd = inst[30:25]=='b001110;
    wire is_lui = inst[30:25]=='b001010;
    assign type_[`ITYPE_IDX_CSR] = inst[30:24]=='b0000100;
    wire is_alu_imm = inst[30:25]=='b0000001;
    assign type_[`ITYPE_IDX_CACHE] = inst[30:22]=='b000011000;
    //这个invalid的含义是与众不同的，这里的invalid表示指令INVTLB，而其他地方的invalid表示unknown instruction
    wire is_invalid_tlb = inst[30:15]=='b0000110010010011;
    assign type_[`ITYPE_IDX_IDLE] = inst[30:15]=='b0000110010010001;
    assign type_[`ITYPE_IDX_ERET] = inst[30:10]=='b000011001001000001110;
    assign type_[`ITYPE_IDX_TLB] = is_invalid_tlb||
        inst[30:13]=='b000011001001000001&&inst[12:10]!='b110;
    wire is_ecall = inst[30:17]=='b00000000010101&&inst[15]=='b0;
    assign is_syscall = is_ecall&inst[16];
    assign is_break = is_ecall&~inst[16];
    assign type_[`ITYPE_IDX_MUL] = inst[30:17]=='b00000000001110;
    assign type_[`ITYPE_IDX_DIV] = inst[30:17]=='b00000000010000;
    wire is_alu_sfti = inst[30:20]=='b00000000100&&inst[17:15]=='b001;
    wire is_sra = inst[30:15]=='b0000000000110000;
    wire is_time = inst[30:11]=='b00000000000000001100;
    wire is_alu = inst[30:19]=='b000000000010;
    assign type_[`ITYPE_IDX_ALU]=is_alu||is_time||is_sra||is_alu_sfti||is_alu_imm||is_pcadd||is_lui;
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

    assign uop[`UOP_PRIVILEDGED] = type_[`ITYPE_IDX_CACHE] | type_[`ITYPE_IDX_TLB] | type_[`ITYPE_IDX_CSR] | type_[`ITYPE_IDX_ERET] | type_[`ITYPE_IDX_IDLE] | type_[`ITYPE_IDX_BAR];
    //Hit类的CACOP指令可以在用户态下执行
    assign is_priviledged = type_[`ITYPE_IDX_CACHE]&&inst[4:3]!=2 || type_[`ITYPE_IDX_TLB] || type_[`ITYPE_IDX_CSR] || type_[`ITYPE_IDX_ERET] || type_[`ITYPE_IDX_IDLE];
    
    reg [3:0] cond;
    reg br_invalid;
    always @* begin
        cond=0;
        br_invalid=0;
        if(type_[`ITYPE_IDX_BR]) begin
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
    
    assign uop[`UOP_TYPE]=(!uop_nempty||invalid_instruction)?0:type_;
    assign uop[`UOP_SRC1]=src1;
    assign uop[`UOP_SRC2]=src2;
    assign uop[`UOP_MEM_ATM]= ~inst[27];
    
    //符号域: 乘除的inst[16]、访存的inst[25]
    assign uop[`UOP_SIGN]=
        (type_[`ITYPE_IDX_MUL]|type_[`ITYPE_IDX_DIV])&~inst[16] |
        (type_[`ITYPE_IDX_MEM])&~inst[25];
    
    //各种指令格式的操作位（包括alu、mul、div、mem、br）
    assign uop[`UOP_COND]=
        {4{type_[`ITYPE_IDX_ALU]}}&alu_op |
        {3'b0,type_[`ITYPE_IDX_DIV]&inst[15]} |
        {3'b0,type_[`ITYPE_IDX_MUL]&(inst[15]|inst[16])} |
        //inst[27]==1时是保留取字和条件存字，宽度是32位
        {4{type_[`ITYPE_IDX_MEM]}}&{1'b0,inst[24],inst[27]?inst[23:22]:2'b10}|
        {4{type_[`ITYPE_IDX_BR]}}&cond;
    ////////////////////////////////////
    
    ///////////////////////////////////
    //非法指令检查
    wire type_invalid = type_==0&!is_ecall;

    wire invtlb_invalid = is_invalid_tlb && inst[4:0]>5'h6; //INVTLB指令的op无效
    
    assign invalid_instruction=alu_op_invalid||type_invalid||br_invalid||inst[31]||invtlb_invalid
    //当IF段出现异常时，认为指令错误
        ||exception!=0;
    //////////////////////////////////////
    
    /////////////////////////////////////
    //目标地址
    assign rd =
        (type_[`ITYPE_IDX_CACHE]||
        type_[`ITYPE_IDX_TLB]||
        type_[`ITYPE_IDX_IDLE]||
        is_preload||
        type_[`ITYPE_IDX_MEM]&&uop[`UOP_MEM_WRITE]&&!uop[`UOP_MEM_ATM]||
        //除了jilr和bl之外的分支
        type_[`ITYPE_IDX_BR]&&!is_jilr&&inst[29:26]!='b0101)?0:
            //bl 向r1写PC+4
            inst[30:26]==('b10101)?1:
            (inst[4:0]|{5{is_time}}&inst[9:5]);
    
    //源地址1
    assign rj =
        (type_[`ITYPE_IDX_TLB]&~is_invalid_tlb||
        type_[`ITYPE_IDX_IDLE]||
        is_pcadd||is_lui||is_b_or_bl||is_time)?0:
        inst[9:5];
    
    //源地址2
    assign rk = 
        (is_alu || is_sra ||
        type_[`ITYPE_IDX_MUL] ||
        type_[`ITYPE_IDX_DIV] || is_invalid_tlb)? inst[14:10]: 
            (type_[`ITYPE_IDX_MEM]&&uop[`UOP_MEM_WRITE] || type_[`ITYPE_IDX_BR]&&!(is_b_or_bl||is_jilr) || type_[`ITYPE_IDX_CSR])? inst[4:0]:0;
    /////////////////////////////////////
    
    ////////////////////////////////////////////
    //立即数 (参见 立即数.ods）
//    wire is_u5  = is_alu_sfti;    //u5按 i12处理（所以ALU单元必须截取imm[4:0]）
    wire is_i12 = type_[`ITYPE_IDX_CACHE] |
        is_alu_imm&~inst[24] |      //addi、slti、sltui的inst[24]都等于0
        type_[`ITYPE_IDX_MEM]&inst[27] |
        is_alu_sfti;
    wire is_u12 = is_alu_imm&inst[24];//andi、ori、xori的inst[24]都等于1
    wire is_i14 = type_[`ITYPE_IDX_CSR];
    wire is_i14_sll2 = type_[`ITYPE_IDX_MEM]&~inst[27];
    wire is_i16 = type_[`ITYPE_IDX_BR]&~is_b_or_bl;
    wire is_i26 = is_b_or_bl;
    wire is_i20 = is_pcadd|is_lui;
    
    wire [31:0] i12_result = {{20{inst[21]}},inst[21:10]};
    wire [31:0] u12_result = {20'b0,inst[21:10]};
    wire [31:0] i14_result = {{18{inst[23]}},inst[23:10]};
    wire [31:0] i16_result = {{16{inst[25]}},inst[25:10]};
    wire [31:0] i26_result = {{6{inst[9]}},{inst[9:0],inst[25:10]}};
    wire [31:0] i20_result = {inst[24:5],12'b0};
    wire [31:0] i14_sll2_result = {{16{inst[23]}},inst[23:10],2'b0};
    
    assign imm = 
        i12_result&{32{is_i12}} |
        u12_result&{32{is_u12}} |
        i14_result&{32{is_i14}} |
        i14_sll2_result&{32{is_i14_sll2}} |
        i16_result&{32{is_i16}} |
        i26_result&{32{is_i26}} |
        i20_result&{32{is_i20}};
    ////////////////////////////////////////////
endmodule
