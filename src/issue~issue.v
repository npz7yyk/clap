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

`include "clap_config.vh"
`include "uop.vh"
`include "exception.vh"

/* verilator lint_off DECLFILENAME */
//暂时不允许br/ld/st指令重排
module is_stage
#(
    LOG_PREGS = 6,
    LOG_CHECKPOINTS = 2,
    SIZE = 8,
    INSTID_WIDHT = 5
)(
    input clk,rstn,
    input flush,
    input [LOG_CHECKPOINTS-1:0] flush_chekpoint,
    output read,
    ////输入信号////
    input inst0_valid,
    input [INSTID_WIDHT-1:0] instid0,
    input [LOG_PREGS-1:0] prd0,prj0,prk0,prr0,
    input prd0_v,prj0_v,prk0_v,prr0_v,
    input [LOG_CHECKPOINTS-1:0] checkpoint0,
    input [`WIDTH_UOP-1:0] uop0,
    input [31:0] imm0,
    input [31:0] pc0,pc_next0,
    input [6:0] exception0,
    input [31:0] badv0,
    input pd_known0,
    input inst1_valid,
    input [INSTID_WIDHT-1:0] instid1,
    input [LOG_PREGS-1:0] prd1,prj1,prk1,prr1,
    input prd1_v,prj1_v,prk1_v,prr1_v,
    input [LOG_CHECKPOINTS-1:0] checkpoint1,
    input [`WIDTH_UOP-1:0] uop1,
    input [31:0] imm1,
    input [31:0] pc1,pc_next1,
    input [6:0] exception1,
    input [31:0] badv1,
    input pd_known1,
    ////输出信号////
    //execute unit #0 //ALU+DIV+PRIV+BR
    output eu0_en,
    input eu0_ready,eu0_finish,//只有div和priv发出finish信号
    input [LOG_PREGS-1:0] eu0_finish_prd,
    output eu0_instid,
    output [`WIDTH_UOP-1:0] eu0_uop,
    output [LOG_PREGS-1:0] eu0_prd,eu0_prj,eu0_prk,eu0_prr,
    output eu0_prd_v,eu0_prj_v,eu0_prk_v,eu0_prr_v,
    output [31:0] eu0_imm,
    output [31:0] eu0_pc,eu0_pc_next,
    output [LOG_CHECKPOINTS-1:0] eu0_checkpoint,
    output [6:0] eu0_exception,
    output [31:0] eu0_badv,
    output eu0_pdknown,
    //execute unit #1 //ALU+MUL
    output eu1_en,
    input eu1_ready,
    output eu1_instid,
    output [`WIDTH_UOP-1:0] eu1_uop,
    output [LOG_PREGS-1:0] eu1_prd,eu1_prj,eu1_prk,eu1_prr,
    output eu1_prd_v,eu1_prj_v,eu1_prk_v,eu1_prr_v,
    output [31:0] eu1_imm,
    output [31:0] eu1_pc,
    //execute unit #2 //MEM
    output eu2_en,
    input eu2_ready,eu2_finish,
    input [LOG_PREGS-1:0] eu2_finish_prd,
    output eu2_instid,
    output [`WIDTH_UOP-1:0] eu2_uop,
    output [LOG_PREGS-1:0] eu2_prd,eu2_prj,eu2_prk,eu2_prr,
    output eu2_prd_v,eu2_prj_v,eu2_prk_v,eu2_prr_v,
    output [31:0] eu2_imm,
    output [31:0] eu2_pc
);
    //free physic registers
    reg [2**LOG_PREGS-1:0] preg_free,preg_free_next;
    reg [2**LOG_PREGS-1:0] eu1_free_delay;//乘法延迟一个周期出结果

    always @(posedge clk)
        if(~rstn) eu1_free_delay <= 0;
        else if(eu1_en&&eu1_uop[`ITYPE_IDX_MUL]&&eu1_prd_v)
            eu1_free_delay <= 1<<eu1_prd;
        else eu1_free_delay <= 0;

    always @* begin
        preg_free_next = preg_free|eu1_free_delay;
        if(eu0_en&&eu0_prd_v&&(eu0_uop[`ITYPE_IDX_ALU]||eu0_uop[`ITYPE_IDX_BR]))
            preg_free_next[eu0_prd] = 1;
        if(eu1_en&&eu1_prd_v&&eu1_uop[`ITYPE_IDX_ALU])
            preg_free_next[eu1_prd] = 1;
        if(eu0_finish)
            preg_free_next[eu0_finish_prd] = 1;
        if(eu2_finish)
            preg_free_next[eu2_finish_prd] = 1;
    end

    always @(posedge clk)
        if(~rstn||flush) preg_free <= {2**LOG_PREGS{1'b1}};
        else preg_free <= preg_free_next;

    localparam DATA_WIDHT = 1+32+32+32+7+32+LOG_CHECKPOINTS+(LOG_PREGS+1)*4+`WIDTH_UOP+1+INSTID_WIDHT;
    //packed input
    wire [DATA_WIDHT-1:0] input0 = {pd_known0,pc_next0,pc0,badv0,exception0,imm0,checkpoint0,prd0_v,prk0_v,prj0_v,prr0_v,prd0,prk0,prj0,prr0,uop0,inst0_valid,instid0};
    wire [DATA_WIDHT-1:0] input1 = {pd_known1,pc_next1,pc1,badv1,exception1,imm1,checkpoint1,prd1_v,prk1_v,prj1_v,prr1_v,prd1,prk1,prj1,prr1,uop1,inst1_valid,instid1};

    //issue buffer
    reg [DATA_WIDHT-1:0] fifo[0:SIZE-1];
    wire fifo_data_ready[0:SIZE-1];
    wire fifo_issue[0:SIZE-1];
    wire fifo_valid[0:SIZE-1];
    wire [LOG_PREGS-1:0] fifo_prd[0:SIZE-1],fifo_prj[0:SIZE-1],fifo_prk[0:SIZE-1],fifo_prr[0:SIZE-1];
    wire fifo_prd_v[0:SIZE-1],fifo_prj_v[0:SIZE-1],fifo_prk_v[0:SIZE-1],fifo_prr_v[0:SIZE-1];
    wire [LOG_CHECKPOINTS-1:0] fifo_checkpoint[0:SIZE-1];
    wire [`WIDTH_UOP-1:0] fifo_uop[0:SIZE-1];
    wire [31:0] fifo_imm[0:SIZE-1];
    wire [31:0] fifo_pc[0:SIZE-1],fifo_pc_next[0:SIZE-1];
    wire [6:0] fifo_exception[0:SIZE-1];
    wire [31:0] fifo_badv[0:SIZE-1];
    wire fifo_pdknown[0:SIZE-1];
    wire fifo_instid[0:SIZE-1];

    generate
        for(genvar i=0;i<SIZE;i=i+1) begin: unpack_fifo
            assign {
                fifo_pdknown[i],
                fifo_pc_next[i],
                fifo_pc[i],
                fifo_badv[i],
                fifo_exception[i],
                fifo_imm[i],
                fifo_checkpoint[i],
                fifo_prd_v[i],
                fifo_prk_v[i],
                fifo_prj_v[i],
                fifo_prr_v[i],
                fifo_prd[i],
                fifo_prk[i],
                fifo_prj[i],
                fifo_prr[i],
                fifo_uop[i],
                fifo_valid[i],
                fifo_instid[i]} = fifo[i];
        end
        for(genvar i=0;i<SIZE;i=i+1) begin: data_ready
            assign fifo_data_ready[i] = (!fifo_prj_v[i]||preg_free[fifo_prj[i]])&&(!fifo_prk_v[i]||preg_free[fifo_prk[i]])
                //确保br/ld/st指令不会被重排
                &&fifo_checkpoint[i]==fifo_checkpoint[0];
        end
    endgenerate

    wire [3:0] output_cnt = eu0_en+eu1_en+eu2_en;
    reg [3:0] fifo_size;
    assign read = fifo_size<=6;
    always @(posedge clk)
        if(~rstn) fifo_size <= 0;
        else if(read) fifo_size <= fifo_size+2 - output_cnt;
        else fifo_size <= fifo_size - output_cnt;
    
    always @(posedge clk)
        if(~rstn) fifo[0]<=0;
endmodule
