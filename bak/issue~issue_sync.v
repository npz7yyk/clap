// SPDX-License-Identifier: Apache-2.0
// issue.v: 发射指令（不支持乱序，时序）

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
`ifdef __UNDEFINED_MACRO
`include "clap_config.vh"
`include "uop.vh"
`include "exception.vh"

/* verilator lint_off DECLFILENAME */
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
    input [31:0] badv0,badv1,
    input [31:0] pc0,pc_next0,
    input [31:0] pc1,pc_next1,
    input unknown0,unknown1,
    input has_interrupt,
    ////输出信号////
    //execute unit #0
    output eu0_en,
    input eu0_ready,
    output [`WIDTH_UOP-1:0] eu0_uop,
    output [4:0] eu0_rd,eu0_rj,eu0_rk,
    output [31:0] eu0_imm,
    output [31:0] eu0_pc,eu0_pc_next,
    output [6:0] eu0_exception,
    output [31:0] eu0_badv,
    output eu0_unknown,
    //execute unit #1 //ALU only
    output eu1_en,
    input eu1_ready,
    output [`WIDTH_UOP-1:0] eu1_uop,
    output [4:0] eu1_rd,eu1_rj,eu1_rk,
    output [31:0] eu1_imm,
    output [31:0] eu1_pc,eu1_pc_next,
    output [6:0] eu1_exception,
    output [31:0] eu1_badv,
    output eu1_unknown
);
    localparam RST_VAL = {1'd0,32'd4,32'd0,32'd0,7'd0,32'd0,15'd0,{`WIDTH_UOP{1'b0}}};
    //pc_next,pc,badv,exception,imm,rd,rk,rj,uop
    reg [1+32+32+32+7+32+5+5+5+`WIDTH_UOP-1:0] fifo0,fifo1;
    reg [1:0] fifo_size;
    
    //FIXME: 无效的指令也可能带上中断
    wire [6:0] exception0_Ustut79un = has_interrupt&&uop0[`UOP_NEMPTY]?`EXP_INT:exception0;
    wire [6:0] exception1_Ustut79un = exception1;

    wire [`UOP_TYPE] zero_TB2wQt8mmI = 0;

    wire [`WIDTH_UOP-1:0] uop0_5nCt64uroR = {uop0[`UOP_EXCEPT_TYPE],exception0_Ustut79un?zero_TB2wQt8mmI:uop0[`UOP_TYPE]};
    wire [`WIDTH_UOP-1:0] uop1_5nCt64uroR = {uop1[`UOP_EXCEPT_TYPE],exception1_Ustut79un?zero_TB2wQt8mmI:uop1[`UOP_TYPE]};

    wire first_nop = !uop0[`UOP_NEMPTY] && exception0_Ustut79un==0;
    wire second_nop = !uop1[`UOP_NEMPTY] && exception1_Ustut79un==0;
    
    wire [1+32+32+32+7+32+5+5+5+`WIDTH_UOP-1:0] input0_xqAzNDOaRK = {unknown0,pc_next0,pc0,badv0,exception0_Ustut79un,imm0,rd0,rk0,rj0,uop0_5nCt64uroR};
    wire [1+32+32+32+7+32+5+5+5+`WIDTH_UOP-1:0] input1_xqAzNDOaRK = {unknown1,pc_next1,pc1,badv1,exception1_Ustut79un,imm1,rd1,rk1,rj1,uop1_5nCt64uroR};

    wire [1+32+32+32+7+32+5+5+5+`WIDTH_UOP-1:0] input0 = first_nop?input1_xqAzNDOaRK:input0_xqAzNDOaRK;
    wire [1+32+32+32+7+32+5+5+5+`WIDTH_UOP-1:0] input1 = input1_xqAzNDOaRK;
    
    reg [1:0] size_after_out;
    reg eu1_en_0Ucym1r,eu0_en_0Ucym1r;
    always @ *
        case({eu1_en_0Ucym1r,eu0_en_0Ucym1r})
        2'b10,2'b01: begin
            size_after_out = fifo_size<=1?0:fifo_size-1;
        end
        2'b11: begin
            size_after_out = fifo_size<=2?0:fifo_size-2;
        end
        2'b00: begin
            size_after_out = fifo_size;
        end
        endcase
    always @*
        if(size_after_out==2)
            num_read = 2'b00;
        else if(size_after_out==1)
            num_read = 2'b01;
        else num_read = 2'b11;

    always @(posedge clk)
        if(~rstn || flush)
            fifo0 <= RST_VAL;
        else case({eu1_en_0Ucym1r,eu0_en_0Ucym1r})
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
        else case({eu1_en_0Ucym1r,eu0_en_0Ucym1r})
            2'b10,2'b01: begin//一输出
                fifo1 <= fifo_size<=1?input1:input0;
            end
            2'b11://两输出
                fifo1 <= input1;
            2'b00:
                if(fifo_size==1)
                    fifo1 <= input0;
                else if(fifo_size==0)
                    fifo1 <= input1;
        endcase

    always @(posedge clk)
        if(~rstn || flush)
            fifo_size <= 0;
        else case({first_nop,second_nop})
            2'b00: fifo_size <= 2;
            2'b10,2'b01:
                fifo_size <= size_after_out==0?1:2;
            2'b11:
                fifo_size <= size_after_out;
       endcase
    
    assign {eu0_unknown,eu0_pc_next,eu0_pc,eu0_badv,eu0_exception,eu0_imm,eu0_rd,eu0_rk,eu0_rj,eu0_uop} = fifo0;
    assign {eu1_unknown,eu1_pc_next,eu1_pc,eu1_badv,eu1_exception,eu1_imm,eu1_rd,eu1_rk,eu1_rj,eu1_uop} = fifo1;
    assign eu1_en = eu1_en_0Ucym1r;
    assign eu0_en = eu0_en_0Ucym1r && (eu0_uop[`UOP_TYPE]!=0 || eu0_exception!=0);
    
    always @* begin
        eu1_en_0Ucym1r = 0;
        eu0_en_0Ucym1r = 0;
        if(eu0_ready) begin
            eu0_en_0Ucym1r = 1;

            if(eu1_ready&&fifo1[`ITYPE_IDX_ALU]&&(eu0_rd==0||eu1_rj!=eu0_rd&&eu1_rk!=eu0_rd)) begin
                eu1_en_0Ucym1r = 1;
            end
        end
    end
endmodule
`endif
