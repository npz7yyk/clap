// SPDX-License-Identifier: Apache-2.0
// id_stage/testbench.v: 指令解码测试

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

`timescale 1ns/100ps
`include "uop.vh"

//FIFO测试
module id_stage_tb1();
    reg clk,rstn;
    reg [1:0]read_en;
    wire full;
    reg [31:0] inst0,inst1;
    reg first_inst_jmp;
    wire [`WIDTH_UOP-1:0] uop0, uop1;
    wire [31:0] imm0,imm1;
    wire [4:0] rd0,rd1;
    wire [4:0] rj0,rj1;
    wire [4:0] rk0,rk1;
    reg [31:0] pc_in;
    reg [31:0] pc_next_in;
    
    //add.w r1,r2,r3
    localparam ADDW = 32'b00000000000100000_00011_00010_00001;
    //sub.w r4,r5,r6
    localparam SUBW = 32'b00000000000100010_00110_00101_00100;
    //or r7,r8,r9
    localparam OR = 32'b00000000000101010_01001_01000_00111;
    
    id_stage id_stage
    (
        .clk(clk),.rstn(rstn),
        .read_en(read_en),
        .full(full),
        .inst0(inst0),
        .inst1(inst1),
        .first_inst_jmp(first_inst_jmp),
        .uop0(uop0),.uop1(uop1),
        .imm0(imm0),.imm1(imm1),
        .rd0(rd0),.rd1(rd1),
        .rj0(rj0),.rj1(rj1),
        .rk0(rk0),.rk1(rk1),
        .pc_in(pc_in),
        .pc_next_in(pc_next_in)
    );
    
    initial begin
        clk<=1;
        forever
        begin
            #5 clk<=0;
            #5 clk<=1;
        end
    end
    
    initial begin
        rstn=0;
        #10 rstn=1;
    end
    
    initial begin;
        read_en=2'b11;
        first_inst_jmp=0;
        pc_in=0;
        pc_next_in=0;
        //in 2 out 2
        #11 //模拟组合延迟
        
        inst0 = ADDW;
        inst1 = SUBW;
        #10
        
        inst0 = SUBW;
        inst1 = OR;
        #10
        
        inst0 = ADDW;
        inst1 = SUBW;
        #10
        
        inst0 = SUBW;
        inst1 = OR;
        #10
        
        //in 2 out 1
        read_en=2'b01;
        inst0 = ADDW;
        inst1 = SUBW;
        #10
        
        //in 2 out 2
        read_en=2'b11;
        inst0 = SUBW;
        inst1 = OR;
        #10
        
        inst0 = ADDW;
        inst1 = ADDW;
        #10
        
        //in 1 out 2
        pc_in=4;
        inst0 = 'bx;
        inst1 = SUBW;
        #10
        
        //in 2 out 2
        pc_in=8;
        inst0 = ADDW;
        inst1 = OR;
        #10
        
        //in 2 out 1
        read_en=2'b01;
        inst0 = ADDW;
        inst1 = SUBW;
        #10
        
        inst0 = ADDW;
        inst1 = SUBW;
        #10
        
        inst0 = ADDW;
        inst1 = SUBW;
        #10
        
        inst0 = 0;
        inst1 = 1;
        #10
        
        inst0 = 0;
        inst1 = 1;
    end
endmodule