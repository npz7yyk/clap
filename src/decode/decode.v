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

// 指令译码器: 将指令转换为微操作
// 输入缓冲: FIFO
// 输出: uop x2
// 传递: PC, PC-next
// 异常: 非法指令, 指令特权等级错误, 系统调用, 断点, FIFO满
module id_stage
(
    input clk,rstn, //时钟, 复位
    ////控制信号////
    input input_valid,
    input flush,
    input [1:0]read_en,         //读取使能，00: 不读取, 01: 读取一条, 11: 读取两条, 10:无效
    output full,                //full信号相当于stall
    ////输入信号////
    input [31:0] inst0, inst1,  //两条待解码指令
    input unknown0, unknown1,   //来自预测器，指令未知
    input first_inst_jmp,       //第一条指令发生了跳转（即inst1无效）
    ////输出信号////
    output [`WIDTH_UOP-1:0] uop0, uop1, //微操作
    output [31:0] imm0,imm1,    //微操作的立即数段
    output [4:0] rd0,rd1,       //微操作的rd段
    output [4:0] rj0,rj1,       //微操作的rj段
    output [4:0] rk0,rk1,       //微操作的rk段
    output invalid0,invalid1,   //指令无效（此时保证uop.TYPE=0）
    ////传递信号////
    input [31:0] pc_in,         //第一条指令的PC，当PC不是8的倍数时，认为第二条指令无效
    input [31:0] pc_next_in,    //下一条指令的PC
    output [31:0] pc0_out,pc1_out,
    output [31:0] pc_next0_out,pc_next1_out,
    ////反馈信号////
    //给预测器
    output feedback_valid,
    output [31:0] pc_for_predict0,pc_for_predict1,
    output [31:0] jmpdist0,jmpdist1,//跳转目标
    output [1:0] categroy0,categroy1,//指令种类 00: 非跳转, 01: 条件跳转, 10: b/bl, 11: jilr
    //给PC
    output reg [31:0] probably_right_destination,
    output wire set_pc
);
    wire valid0 = ~pc_in[2];   //输入的指令0有效
    wire valid1 = ~first_inst_jmp;//输入的指令1有效

    //预译码
    wire [31:0] pc_offset0,pc_offset1;
    pre_decoder pre_decoder0 (.inst(inst0),.categroy(categroy0),.pc_offset(pc_offset0));
    pre_decoder pre_decoder1 (.inst(inst1),.categroy(categroy1),.pc_offset(pc_offset1));
    assign pc_for_predict0 = pc_in;
    assign pc_for_predict1 = pc_in+4;
    assign jmpdist0 = pc_in + pc_offset0;
    assign jmpdist1 = pc_in+4 + pc_offset1;
    assign feedback_valid = input_valid;
    wire should_jmp0 = categroy0=='b10 || categroy0=='b01&&pc_offset0[31];
    wire should_jmp1 = categroy1=='b10 || categroy1=='b01&&pc_offset1[31];
    reg set_pc_due_to_inst0,set_pc_due_to_inst1;
    assign set_pc = set_pc_due_to_inst0|set_pc_due_to_inst1;
    always @* begin
        set_pc_due_to_inst0 = 0;
        set_pc_due_to_inst1 = 0;
        probably_right_destination = jmpdist0;
        if(valid0) begin
            if(unknown0&&should_jmp0) begin
                probably_right_destination = jmpdist0;
                set_pc_due_to_inst0 = 1;
            end
            else if(valid1&&unknown1&&should_jmp1) begin
                probably_right_destination = jmpdist1;
                set_pc_due_to_inst1 = 1;
            end
        end
        else if(valid1&&unknown1&&should_jmp1) begin
            probably_right_destination = jmpdist1;
            set_pc_due_to_inst1 = 1;
        end
    end

    wire empty;            //FIFO空
    
    //用交叠法实现伪双端口循环队列，浪费25%的空间，以简化push/pop逻辑
    //[31:0] 指令; [63:32] pc；[95:64] pc_next
    reg [95:0] fetch_buffer0[0:3],fetch_buffer1[0:3];
    reg [1:0] head0,head1;      //队头指针
    reg [1:0] tail0,tail1;      //队尾指针
    reg push_sel;   //进行push操作时，inst0被push到fetch_buffer0还是fetch_buffer1
    reg pop_sel;    //进行pop操作时，uop0来自fetch_buffer0还是fetch_buffer1
    
    wire empty0 = head0==tail0;
    wire empty1 = head1==tail1;
    wire full0 = tail0+1==head0;
    wire full1 = tail1+1==head1;
    assign empty = empty0&&empty1;
    assign full  = full0||full1;
    
    wire valid_either = valid0 ^ valid1;
    wire valid_both   = valid0 && valid1;
    
    //真正有效的第一条输入指令， 当valid0时，它就是inst0，否则它是inst1
    //TODO不把空指令放进FIFO
    wire [31:0] real_inst0 = input_valid? (valid0? inst0:(set_pc_due_to_inst0?`INST_NOP:inst1)) : `INST_NOP;
    wire [31:0] real_inst1 = input_valid&&!set_pc_due_to_inst0? inst1 : `INST_NOP;
    
    //真正有效的第一条输入指令的pc
    wire [31:0] real_pc0 = pc_in;
    wire [31:0] real_pc1 = pc_in+4;
    
    //真正有效的第一条输入指令的pc_next
    wire [31:0] real_pc_next0 = first_inst_jmp||pc_in[2]?pc_next_in:pc_in+4;
    wire [31:0] real_pc_next1 = pc_next_in;
    
    wire [95:0] real_0_concat = {real_pc_next0,real_pc0,real_inst0};
    wire [95:0] real_1_concat = {real_pc_next1,real_pc1,real_inst1};
    
    //fetch_buffer0需要进行push操作
    wire push0 = valid_both || push_sel==0&&valid_either;
    wire push1 = valid_both || push_sel==1&&valid_either;
    
    wire pop0 = read_en[1] || pop_sel==0&&read_en[0];
    wire pop1 = read_en[1] || pop_sel==1&&read_en[0];
    
    //FIFO
    always @(posedge clk)
        if(~rstn || flush)begin
//            fetch_buffer0[0]<=`INST_NOP;
//            fetch_buffer0[1]<=`INST_NOP;
//            fetch_buffer0[2]<=`INST_NOP;
//            fetch_buffer0[3]<=`INST_NOP;
//            fetch_buffer1[0]<=`INST_NOP;
//            fetch_buffer1[1]<=`INST_NOP;
//            fetch_buffer1[2]<=`INST_NOP;
//            fetch_buffer1[3]<=`INST_NOP;
            head0<=0; head1<=0;
            tail0<=0; tail1<=0;
            push_sel<=0;
            pop_sel<=0;
        end
        else begin
            if(pop0&~empty0)head0<=head0+1;
            if(pop1&~empty1)head1<=head1+1;
            if(push0&~full)begin
                tail0<=tail0+1;
                fetch_buffer0[tail0]<=push_sel==0?real_0_concat:real_1_concat;
            end
            if(push1&~full)begin
                tail1<=tail1+1;
                fetch_buffer1[tail1]<=push_sel==1?real_0_concat:real_1_concat;
            end
            if(valid_either&~full)push_sel<=~push_sel;
            if((pop0&~empty0)^(pop1&~empty1))pop_sel<=~pop_sel;
        end
    
    decoder decoder0
    (
        .pcnext_pc_inst(pop_sel==0?
            empty0?{32'd4,32'd0,`INST_NOP}:fetch_buffer0[head0]:
            empty1?{32'd4,32'd0,`INST_NOP}:fetch_buffer1[head1]),
        .uop(uop0),.imm(imm0),.rd(rd0),.rj(rj0),.rk(rk0),
        .pc(pc0_out),.pc_next(pc_next0_out),
        .invalid(invalid0)
    );
    assign pc_for_predict0 = pc0_out;
    assign feedback_valid0 = uop0!=0;
    decoder decoder1
    (
        .pcnext_pc_inst(pop_sel==1?
            empty0?{32'd4,32'd0,`INST_NOP}:fetch_buffer0[head0]:
            empty1?{32'd4,32'd0,`INST_NOP}:fetch_buffer1[head1]),
        .uop(uop1),.imm(imm1),.rd(rd1),.rj(rj1),.rk(rk1),
        .pc(pc1_out),.pc_next(pc_next1_out),
        .invalid(invalid1)
    );
    
endmodule

//纯组合逻辑，译码器
//【注意】load、br指令的原本位于rd段的源数据被放到了rk，而rd=0，这样可以保证读取寄存器堆时只需要读rk和rj
module decoder
(
    input [95:0] pcnext_pc_inst,
    output [31:0] pc,pc_next,//从pcnext_pc_inst拆解出的pc和pc_next
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
        if(is_alu_imm||is_alu_sfti)src2=`CTRL_SRC2_IMM;
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
        {4{type[`ITYPE_IDX_MEM]}}&{inst[24],1'b1,inst[27]?2'b10:inst[23:22]}|
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
        is_preload||
        type[`ITYPE_IDX_MEM]&&uop[`UOP_MEM_WRITE]||
        //b
        inst[30:26]=='b10100)?0:
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
        type[`ITYPE_IDX_DIV])? inst[14:10]: 0;
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

//combine logic
//pre-decoder the instruction before pushing it to the FIFO, 
//to get feedback signals
module pre_decoder
(
    input [31:0] inst,
    output [1:0] categroy,
    output reg [31:0] pc_offset
);
    assign categroy[1]=inst[30:27]=='b1010|inst[30:26]=='b10011;
    assign categroy[0]=inst[30]&~(inst[29:27]=='b010);
    always @*
        case(categroy)
            2'b00,2'b11: pc_offset = 4;
            2'b01:       pc_offset = {{14{inst[25]}},inst[25:10],2'b00};
            2'b10:       pc_offset = {{4{inst[25]}},inst[9:0],inst[25:10],2'b00};
        endcase
endmodule
