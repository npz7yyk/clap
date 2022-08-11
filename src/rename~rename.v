// SPDX-License-Identifier: Apache-2.0
// rename.v: 寄存器重命名

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

//About Checkpoint
//1. Build checkpoint for branch inst and ld/st inst.
//2. Every instruction will get a checkpoint number, which is the same as the
// checkpoint number of the first br/ld/st inst after this inst, so when branch
// prediction failed or an exception occurs during ld/st, instrutions that have
// the same checkpoint number as the br/ld/st instruction should be preserved, while
// other instrucions should be flushed.

//输出必须被立即取走，而不能被stall，所以ROB在剩余容量是2时
//就发出stall信号
module register_rename
#(
    LOG_PREGS = 6,
    LOG_CHECKPOINTS = 2
)(
    input clk,rstn,stall,
    input restore_en,
    input [LOG_CHECKPOINTS-1:0] restore_checkpoint,
    output [1:0] num_read, //实际读取的指令条数 00: 不读取, 01: 读取一条, 11: 读取两条, 10:无效
    //input signals
    input [4:0] lrd0,lrj0,lrk0,
    input [4:0] lrd1,lrj1,lrk1,
    //output signals
    output reg inst0_valid,
    output reg [LOG_PREGS-1:0] prd0,prj0,prk0,prr0, //rr: register that will be released 
    output reg prd0_v,prj0_v,prk0_v,prr0_v,         //    after the retirement of the instruction
    output reg [LOG_CHECKPOINTS-1:0] checkpoint0,   //v:  true if the instruction used this field
    output reg inst1_valid,
    output reg [LOG_PREGS-1:0] prd1,prj1,prk1,prr1, //
    output reg prd1_v,prj1_v,prk1_v,prr1_v,         //
    output reg [LOG_CHECKPOINTS-1:0] checkpoint1,   //
    //pass signals
    input [`WIDTH_UOP-1:0] uop0_in       , uop1_in       ,
    input [31:0]           imm0_in       , imm1_in       ,
    input [31:0]           pc0_in        , pc1_in        ,
    input [31:0]           pc_next0_in   , pc_next1_in   ,
    input [6:0]            exception0_in , exception1_in ,
    input [31:0]           badv0_in      , badv1_in      ,
    input                  pd_known0_in  , pd_known1_in  ,
    output reg [`WIDTH_UOP-1:0]uop0_out      , uop1_out      ,
    output reg [31:0]          imm0_out      , imm1_out      ,
    output reg [31:0]          pc0_out       , pc1_out       ,
    output reg [31:0]          pc_next0_out  , pc_next1_out  ,
    output reg [6:0]           exception0_out, exception1_out,
    output reg [31:0]          badv0_out     , badv1_out     ,
    output reg                 pd_known0_out , pd_known1_out ,
    //retire
    input [LOG_PREGS-1:0] rt0_prr,
    input rt0_prr_v,
    input rt0_release_checkpoint,
    input [LOG_PREGS-1:0] rt1_prr,
    input rt1_prr_v,
    input rt1_release_checkpoint,

    /* verilator lint_off UNUSED */
    input __dummy
    /* verilator lint_on UNUSED */
);
    reg [LOG_PREGS*32-1:0] logic2physic;
    reg [2**LOG_PREGS-1:0] free_physic;
    reg [LOG_PREGS-1:0] n_free_physic;

    reg [2**LOG_PREGS+LOG_PREGS*32+LOG_PREGS:0] checkpoints[0:2**LOG_CHECKPOINTS-1];
    reg [LOG_CHECKPOINTS:0] n_free_checkpoints;
    reg [LOG_CHECKPOINTS-1:0] checkpoint_index;
    wire [LOG_CHECKPOINTS:0] n_free_checkpoints_after_retire = n_free_checkpoints+rt0_release_checkpoint+rt1_release_checkpoint;

    wire require_checkpoint = !stall && (uop0_in[`UOP_CHEKCPOINT]||uop1_in[`UOP_CHEKCPOINT]);
    assign num_read[0] = !stall && n_free_physic>=1 && (!require_checkpoint||n_free_checkpoints>=1);
    assign num_read[1] = !stall && n_free_physic>=2 && !uop0_in[`UOP_CHEKCPOINT];
    
    //update checkpoint
    always @(posedge clk)
        if(!rstn||restore_en) begin
            n_free_checkpoints<=2**LOG_CHECKPOINTS;
            checkpoint_index<=0;
        end else if(require_checkpoint)begin
            checkpoints[checkpoint_index] <= {logic2physic,free_physic,n_free_physic};
            n_free_checkpoints <= n_free_checkpoints_after_retire-1;
            checkpoint_index <= checkpoint_index+1;
        end else begin
            n_free_checkpoints <= n_free_checkpoints_after_retire;
        end
    
    always @(posedge clk)
        if(~rstn) begin
            checkpoint0 <= 0;
            checkpoint1 <= 0;
        end else begin
            checkpoint0 <= checkpoint_index;
            checkpoint1 <= checkpoint_index;
        end
    
    reg [LOG_PREGS*32-1:0] logic2physic_next;
    reg [2**LOG_PREGS-1:0] free_physic_next;
    reg [LOG_PREGS-1:0] n_free_physic_next;

    wire [2**LOG_PREGS-1:0] free_physic_reversed;

    utility_reverse_bits #(2**LOG_PREGS) utility_reverse_bits(free_physic,free_physic_reversed);

    wire [LOG_PREGS-1:0] free_preg0;
    wire [LOG_PREGS-1:0] free_preg1;
    
    wire [2**LOG_PREGS-1:0] pow_free_preg0 = free_physic_reversed&-free_physic_reversed;
    wire [2**LOG_PREGS-1:0] pow_free_preg1 = free_physic&-free_physic;

    utility_log2 #(LOG_PREGS) utility_log2_0 (free_physic,free_preg0);
    utility_log2 #(LOG_PREGS) utility_log2_1 (free_physic_reversed,free_preg1);

    always @* begin
        logic2physic_next = logic2physic;
        if(num_read[0]&&lrd0!=0)
            logic2physic_next[lrd0*LOG_PREGS +: LOG_PREGS] = free_preg0;
        if(num_read[1]&&lrd1!=0)
            logic2physic_next[lrd1*LOG_PREGS +: LOG_PREGS] = free_preg1;
    end

    always @* begin
        free_physic_next = free_physic;
        if(rt0_prr_v) free_physic_next = free_physic_next | 1<<rt0_prr;
        if(rt1_prr_v) free_physic_next = free_physic_next | 1<<rt1_prr;
        if(num_read[0]&&lrd0!=0)free_physic_next = free_physic_next &~ pow_free_preg0;
        if(num_read[1]&&lrd1!=0)free_physic_next = free_physic_next &~ pow_free_preg1;
    end

    always @* begin
        n_free_physic_next = n_free_physic + rt0_prr_v + rt1_prr_v - (num_read[0]&&lrd0!=0) - (num_read[1]&&lrd1!=0);
    end

    //update mapping
    always @(posedge clk)
        if(!rstn) begin
            logic2physic[ 0*LOG_PREGS +: LOG_PREGS] <= 0;
            logic2physic[ 1*LOG_PREGS +: LOG_PREGS] <= 0;
            logic2physic[ 2*LOG_PREGS +: LOG_PREGS] <= 1;
            logic2physic[ 3*LOG_PREGS +: LOG_PREGS] <= 2;
            logic2physic[ 4*LOG_PREGS +: LOG_PREGS] <= 3;
            logic2physic[ 5*LOG_PREGS +: LOG_PREGS] <= 4;
            logic2physic[ 6*LOG_PREGS +: LOG_PREGS] <= 5;
            logic2physic[ 7*LOG_PREGS +: LOG_PREGS] <= 6;
            logic2physic[ 8*LOG_PREGS +: LOG_PREGS] <= 7;
            logic2physic[ 9*LOG_PREGS +: LOG_PREGS] <= 8;
            logic2physic[10*LOG_PREGS +: LOG_PREGS] <= 9;
            logic2physic[11*LOG_PREGS +: LOG_PREGS] <=10;
            logic2physic[12*LOG_PREGS +: LOG_PREGS] <=11;
            logic2physic[13*LOG_PREGS +: LOG_PREGS] <=12;
            logic2physic[14*LOG_PREGS +: LOG_PREGS] <=13;
            logic2physic[15*LOG_PREGS +: LOG_PREGS] <=14;
            logic2physic[16*LOG_PREGS +: LOG_PREGS] <=15;
            logic2physic[17*LOG_PREGS +: LOG_PREGS] <=16;
            logic2physic[18*LOG_PREGS +: LOG_PREGS] <=17;
            logic2physic[19*LOG_PREGS +: LOG_PREGS] <=18;
            logic2physic[20*LOG_PREGS +: LOG_PREGS] <=19;
            logic2physic[21*LOG_PREGS +: LOG_PREGS] <=20;
            logic2physic[22*LOG_PREGS +: LOG_PREGS] <=21;
            logic2physic[23*LOG_PREGS +: LOG_PREGS] <=22;
            logic2physic[24*LOG_PREGS +: LOG_PREGS] <=23;
            logic2physic[25*LOG_PREGS +: LOG_PREGS] <=24;
            logic2physic[26*LOG_PREGS +: LOG_PREGS] <=25;
            logic2physic[27*LOG_PREGS +: LOG_PREGS] <=26;
            logic2physic[28*LOG_PREGS +: LOG_PREGS] <=27;
            logic2physic[29*LOG_PREGS +: LOG_PREGS] <=28;
            logic2physic[30*LOG_PREGS +: LOG_PREGS] <=29;
            logic2physic[31*LOG_PREGS +: LOG_PREGS] <=30;
            free_physic <= {{2**LOG_PREGS-30{1'b1}},{31{1'b0}}};
            n_free_physic <= 2**LOG_PREGS-31;
        end else if(restore_en)begin
            {logic2physic,free_physic,n_free_physic} <= checkpoints[restore_checkpoint];
        end else begin
            logic2physic <= logic2physic_next;
            free_physic <= free_physic_next;
            n_free_physic <= n_free_physic_next;
        end
    
    //perform renaming
    always @(posedge clk) begin
        prd0 <= logic2physic_next[lrd0*LOG_PREGS +: LOG_PREGS];
        prj0 <= logic2physic[lrj0*LOG_PREGS +: LOG_PREGS];
        prk0 <= logic2physic[lrk0*LOG_PREGS +: LOG_PREGS];
        prr0 <= logic2physic[lrd0*LOG_PREGS +: LOG_PREGS];
        prj1 <= lrj1==lrd0?logic2physic_next[lrd0*LOG_PREGS +: LOG_PREGS]:logic2physic[lrj1*LOG_PREGS +: LOG_PREGS];
        prk1 <= lrk1==lrd0?logic2physic_next[lrd0*LOG_PREGS +: LOG_PREGS]:logic2physic[lrk1*LOG_PREGS +: LOG_PREGS];
        prd1 <= logic2physic_next[lrd1*LOG_PREGS +: LOG_PREGS];
        prr1 <= logic2physic[lrd1*LOG_PREGS +: LOG_PREGS];
    end

    //valid signals
    always @(posedge clk) 
        if(~rstn)begin
            prd0_v <= 0;
            prj0_v <= 0;
            prk0_v <= 0;
            prd1_v <= 0;
            prj1_v <= 0;
            prk1_v <= 0;
        end else begin
            prd0_v <= num_read[0] && lrd0!=0;
            prj0_v <= num_read[0] && lrj0!=0;
            prk0_v <= num_read[0] && lrk0!=0;
            prd1_v <= num_read[1] && lrd1!=0;
            prj1_v <= num_read[1] && lrj1!=0;
            prk1_v <= num_read[1] && lrk1!=0;
        end
    
    always @(posedge clk)
        if(~rstn) begin
            inst0_valid <= 0;
            inst1_valid <= 0;
        end else begin
            inst0_valid <= num_read[0];
            inst1_valid <= num_read[1];
        end
    
    //pass signals
    always @(posedge clk) begin
        uop0_out      <= uop0_in      ; uop1_out       <= uop1_in      ;
        imm0_out      <= imm0_in      ; imm1_out       <= imm1_in      ;
        pc0_out       <= pc0_in       ; pc1_out        <= pc1_in       ;
        pc_next0_out  <= pc_next0_in  ; pc_next1_out   <= pc_next1_in  ;
        exception0_out<= exception0_in; exception1_out <= exception1_in;
        badv0_out     <= badv0_in     ; badv1_out      <= badv1_in     ;
        pd_known0_out <= pd_known0_in ; pd_known1_out  <= pd_known1_in ;
    end
endmodule
