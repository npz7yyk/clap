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

module register_rename
#(
    LOG_PREGS = 6,
    LOG_CHECKPOINTS = 2
)(
    input clk,rstn,
    output [1:0] num_read,
    //input signals
    input [4:0] lrd0,lrj0,lrk0,
    input may_flush0,   //indication an instrucion may flush pipeline, eg. beq
    input [4:0] lrd1,lrj1,lrk1,
    input may_flush1,
    //output signals
    output inst0_valid,
    output [LOG_PREGS-1:0] prd0,prj0,prk0,prr0, //rr: register that will be released 
    output prd0_v,prj0_v,prk0_v,prr0_v,         //    after the retirement of the instruction
    output [LOG_CHECKPOINTS-1:0] checkpoint0,   //v:  true if the instruction used this field
    output checkpoint0_v,
    output inst1_valid,
    output [LOG_PREGS-1:0] prd1,prj1,prk1,prr1, //
    output prd1_v,prj1_v,prk1_v,prr1_v,         //
    output [LOG_CHECKPOINTS-1:0] checkpoint1,   //
    output checkpoint1_v,
    //pass signals
    input [`WIDTH_UOP-1:0] uop0_in       , uop1_in       ,
    input [31:0]           imm0_in       , imm1_in       ,
    input [31:0]           pc0_in        , pc1_in        ,
    input [31:0]           pc_next0_in   , pc_next1_in   ,
    input [6:0]            exception0_in , exception1_in ,
    input [31:0]           badv0_in      , badv1_in      ,
    input                  pd_known0_in  , pd_known1_in  ,
    output [`WIDTH_UOP-1:0]uop0_out      , uop1_out      ,
    output [31:0]          imm0_out      , imm1_out      ,
    output [31:0]          pc0_out       , pc1_out       ,
    output [31:0]          pc_next0_out  , pc_next1_out  ,
    output [6:0]           exception0_out, exception1_out,
    output [31:0]          badv0_out     , badv1_out     ,
    output                 pd_known0_out , pd_known1_out ,

    /* verilator lint_off UNUSED */
    input __dummy
    /* verilator lint_on UNUSED */
);
    localparam REG_WIDTH = 1+7+32*4+`WIDTH_UOP+1+5*3;
    //input registers
    wire [REG_WIDTH-1:0] input0 = {pd_known0_in,badv0_in,exception0_in,pc_next0_in,pc0_in,imm0_in,uop0_in,may_flush0,lrd0,lrj0,lrk0};
    wire [REG_WIDTH-1:0] input1 = {pd_known1_in,badv1_in,exception1_in,pc_next1_in,pc1_in,imm1_in,uop1_in,may_flush1,lrd1,lrj1,lrk1};
    reg [REG_WIDTH-1:0] input_reg0,input_reg1;

    reg [LOG_PREGS*32-1:0] logic2physic;
    reg [2**LOG_PREGS-1:0] free_physic;

    reg [2**LOG_PREGS+LOG_PREGS*32:0] checkpoints[0:2**LOG_CHECKPOINTS-1];

    wire require_checkpoint = uop0_in[`UOP_CHEKCPOINT] || uop1_in[`UOP_CHEKCPOINT];
    
endmodule
