// SPDX-License-Identifier: Apache-2.0

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

`timescale 1ns / 1ps
`include "../uop.vh"
`include "../exception.vh"

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
    ////传递信号////
    input [6:0]  exception_in,
    output [6:0] exception0_out,exception1_out,   //指令无效（此时保证uop.TYPE=0）
    input [31:0] pc_in,         //第一条指令的PC，当PC不是8的倍数时，认为第二条指令无效
    input [31:0] pc_next_in,    //下一条指令的PC
    output [31:0] pc0_out,pc1_out,
    output [31:0] pc_next0_out,pc_next1_out,
    ////反馈信号////
    //给预测器
    output feedback_valid,
    output [31:0] pc_for_predict,
    output [31:0] jmpdist0,jmpdist1,//跳转目标
    output [1:0] category0,category1,//指令种类 00: 非跳转, 01: 条件跳转, 10: b/bl, 11: jilr
    //给PC
    output reg [31:0] probably_right_destination,
    output wire set_pc
);
    wire valid0 = ~pc_in[2];   //输入的指令0有效
    wire valid1 = ~first_inst_jmp;//输入的指令1有效

    //预译码
    wire [31:0] pc_offset0,pc_offset1;
    pre_decoder pre_decoder0 (.inst(inst0),.category(category0),.pc_offset(pc_offset0));
    pre_decoder pre_decoder1 (.inst(inst1),.category(category1),.pc_offset(pc_offset1));
    assign pc_for_predict = pc_in;
    assign jmpdist0 = pc_in + pc_offset0;
    assign jmpdist1 = pc_in+4 + pc_offset1;
    assign feedback_valid = input_valid;
    wire should_jmp0 = category0=='b10 || category0=='b01&&pc_offset0[31];
    wire should_jmp1 = category1=='b10 || category1=='b01&&pc_offset1[31];
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
    reg [102:0] fetch_buffer0[0:3],fetch_buffer1[0:3];
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
    
    wire [102:0] real_0_concat = {exception_in,real_pc_next0,real_pc0,real_inst0};
    wire [102:0] real_1_concat = {exception_in,real_pc_next1,real_pc1,real_inst1};
    
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
    
    wire invalid0,invalid1;
    wire [6:0] exception0_ICQlsmuv,exception1_ICQlsmuv;
    decoder decoder0
    (
        .pcnext_pc_inst(pop_sel==0?
            empty0?{32'd4,32'd0,`INST_NOP}:fetch_buffer0[head0]:
            empty1?{32'd4,32'd0,`INST_NOP}:fetch_buffer1[head1]),
        .uop(uop0),.imm(imm0),.rd(rd0),.rj(rj0),.rk(rk0),
        .pc(pc0_out),.pc_next(pc_next0_out),
        .exception(exception0_ICQlsmuv),
        .invalid(invalid0)
    );
    assign exception0_out = exception0_ICQlsmuv==0? (invalid0?`EXP_INE:0):exception0_ICQlsmuv;
    decoder decoder1
    (
        .pcnext_pc_inst(pop_sel==1?
            empty0?{32'd4,32'd0,`INST_NOP}:fetch_buffer0[head0]:
            empty1?{32'd4,32'd0,`INST_NOP}:fetch_buffer1[head1]),
        .uop(uop1),.imm(imm1),.rd(rd1),.rj(rj1),.rk(rk1),
        .pc(pc1_out),.pc_next(pc_next1_out),
        .exception(exception1_ICQlsmuv),
        .invalid(invalid1)
    );
    assign exception1_out = exception1_ICQlsmuv==0? (invalid1?`EXP_INE:0):exception1_ICQlsmuv;
endmodule
