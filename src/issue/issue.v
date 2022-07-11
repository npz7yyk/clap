// SPDX-License-Identifier: Apache-2.0
// issue.v: 发射指令

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

`include "../uop.vh"

module is_stage
(
    input clk,rstn, //时钟, 复位
    ////控制信号////
    output reg [1:0] num_read,  //实际读取的指令条数 00: 不读取, 01: 读取一条, 11: 读取两条, 10:无效
    input flush,
    ////输入信号////
    input [`WIDTH_UOP-1:0] uop0, uop1,
    input [4:0] rd0,rj0,rk0,rd1,rj1,rk1,
    input [31:0] imm0,imm1,
    input [6:0] exception0,exception1,
    input [31:0] pc0,pc_next0,
    input [31:0] pc1,pc_next1,
    ////输出信号////
    //execute unit #0
    output reg eu0_en,
    input eu0_ready,
    input eu0_finish,
    output [`WIDTH_UOP-1:0] eu0_uop,
    output [4:0] eu0_rd,eu0_rj,eu0_rk,
    output [31:0] eu0_imm,
    output [31:0] eu0_pc,eu0_pc_next,
    output [6:0] eu0_exception,
    //execute unit #1 //ALU only
    output reg eu1_en,
    input eu1_ready,
    input eu1_finish,
    output [`WIDTH_UOP-1:0] eu1_uop,
    output [4:0] eu1_rd,eu1_rj,eu1_rk,
    output [31:0] eu1_imm,
    output [31:0] eu1_pc,eu1_pc_next,
    output [6:0] eu1_exception
);
    localparam RST_VAL = {32'd4,32'd0,1'd0,32'd0,15'd0,`INST_NOP};
    //pc_next,pc,invalid,imm,rd,rk,rj,uop
    reg [32+32+7+32+5+5+5+`WIDTH_UOP-1:0] fifo0,fifo1;
    reg [1:0] fifo_size;
    
    wire first_nop = uop0[`UOP_TYPE] == 0 && exception0==0;
    wire second_nop = uop1[`UOP_TYPE] == 0 && exception1==0;
    
    wire [32+32+7+32+5+5+5+`WIDTH_UOP-1:0] input0 = {pc_next0,pc0,exception0,imm0,rd0,rk0,rj0,uop0};
    wire [32+32+7+32+5+5+5+`WIDTH_UOP-1:0] input1 = {pc_next1,pc1,exception1,imm1,rd1,rk1,rj1,uop1};
    
    reg [4:0] size_after_out;
    reg [1:0] size_out;
    always @ *
        case({eu1_en,eu0_en})
        2'b10,2'b01: begin
            size_after_out = fifo_size<=1?0:fifo_size-1;
            size_out = 1;
        end
        2'b11: begin
            size_after_out = fifo_size<=2?0:fifo_size-2;
            size_out = 2;
        end
        2'b00: begin
            size_after_out = fifo_size;
            size_out = 0;
        end
        endcase
    always @*
        if(size_after_out==16)
            num_read = 2'b00;
        else if(size_after_out==15)
            num_read = 2'b01;
        else num_read = 2'b11;

    always @(posedge clk)
        if(~rstn || flush)
            fifo0 <= RST_VAL;
        else case({eu1_en,eu0_en})
            2'b10,2'b01: //一输出
                fifo0 <= fifo_size<=1?input0:fifo1;
            2'b11://两输出
                fifo0 <= input0;
            2'b00:
                if(fifo_size==0)fifo0 <= input0;
        endcase
    
    always @(posedge clk)
        if(~rstn || flush)
            fifo1 <= RST_VAL;
        else case({eu1_en,eu0_en})
            2'b10,2'b01: begin//一输出
                if(fifo_size==2)
                    fifo1 <= input0;
                else if(fifo_size<=1)
                    fifo1 <= input1;
                else fifo1 <= RST_VAL;
            end
            2'b11://两输出
                fifo1 <= input1;
            2'b00:
                if(fifo_size==1)
                    fifo1 <= input0;
                else if(fifo_size==0)
                    fifo1 <= input1;
        endcase

    wire [2:0] tmp_4WcsDb8esTV8xg = num_read[0] + num_read[1];
    always @(posedge clk)
        if(~rstn || flush)
            fifo_size <= 0;
        else case({eu1_en,eu0_en})
            2'b00: fifo_size <= fifo_size + tmp_4WcsDb8esTV8xg;
            2'b10,2'b01:
                fifo_size <= (fifo_size<=1?0:fifo_size-1)+tmp_4WcsDb8esTV8xg;
            2'b11:
                fifo_size <= (fifo_size<=2?0:fifo_size-2)+tmp_4WcsDb8esTV8xg;
       endcase
    
    reg [31:0] register_valid;
    reg [31:0] register_valid_next;
    reg [4:0] rd_of_instruction_executing_in_eu0,rd_of_instruction_executing_in_eu1;

    //当FIFO[0]的指令是ALU指令时，把FIFO[0]发射到执行单元 #1
    wire swap_fifo0_fifo1 = fifo0[`ITYPE_IDX_ALU];

    assign {eu0_pc_next,eu0_pc,eu0_exception,eu0_imm,eu0_rd,eu0_rk,eu0_rj,eu0_uop} = swap_fifo0_fifo1?fifo1:fifo0;
    assign {eu1_pc_next,eu1_pc,eu1_exception,eu1_imm,eu1_rd,eu1_rk,eu1_rj,eu1_uop} = swap_fifo0_fifo1?fifo0:fifo1;
    
    always @(posedge clk)
        if(~rstn || flush)
            register_valid <= {32{1'b1}};
        else register_valid <= register_valid_next;
    always @* begin
        register_valid_next = register_valid;
        if(eu0_finish) register_valid_next[rd_of_instruction_executing_in_eu0]=1;
        if(eu1_finish) register_valid_next[rd_of_instruction_executing_in_eu1]=1;
        eu1_en = 0;
        eu0_en = 0;
        //交换时，先尝试往eu1发射
        if(swap_fifo0_fifo1) begin
            if(register_valid_next[eu1_rj]&&register_valid_next[eu1_rk]&&eu1_ready) begin
                eu1_en = 1;
                if(eu1_rd)register_valid_next[eu1_rd] = 0;
                
                if(register_valid_next[eu0_rj]&&register_valid_next[eu0_rk]&&eu0_ready) begin
                    eu0_en = 1;
                    if(eu0_rd)register_valid_next[eu0_rd] = 0;
                end
            end
        //不交换时，先尝试往eu0发射
        end else begin
            if(register_valid_next[eu0_rj]&&register_valid_next[eu0_rk]&&eu0_ready) begin
                eu0_en = 1;
                if(eu0_rd)register_valid_next[eu0_rd] = 0;
                
                if(register_valid_next[eu1_rj]&&register_valid_next[eu1_rk]&&eu1_ready&&fifo1[`ITYPE_IDX_ALU]) begin
                    eu1_en = 1;
                    if(eu1_rd)register_valid_next[eu1_rd] = 0;
                end
            end
        end
    end

    always @(posedge clk)
        if(~rstn || flush)
            rd_of_instruction_executing_in_eu0 <= 0;
        else if(eu0_en)
            rd_of_instruction_executing_in_eu0 <= eu0_rd;
    
    always @(posedge clk)
        if(~rstn || flush)
            rd_of_instruction_executing_in_eu1 <= 0;
        else if(eu1_en)
            rd_of_instruction_executing_in_eu1 <= eu1_rd;
endmodule
