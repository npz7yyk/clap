// -*- Verilog -*-
// SPDX-License-Identifier: Apache-2.0
// uop.vh: 微操作格式

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
// 2022-05-13: First edition.

//空指令 andi r0, r0, 0
`define INST_NOP 32'b0000001101_000000000000_00000_00000

`define UOP_TYPE 10:0
`define UOP_SRC1 12:11
`define UOP_SRC2 14:13
`define UOP_ALUOP 18:15
`define UOP_MD_SEL 15:15
`define UOP_MEM_WIDTH 16:15
`define UOP_MEM_WRITE 17:17
`define UOP_COND 18:15
`define UOP_SIGN 19:19
`define UOP_MEM_ATM 20:20
`define UOP_ORIGINAL_INST 52:21
`define WIDTH_UOP 53

`define ITYPE_ALU   11'b000000000001
`define ITYPE_MUL   11'b000000000010
`define ITYPE_DIV   11'b000000000100
`define ITYPE_ERET  11'b000000001000
`define ITYPE_CACHE 11'b000000010000
`define ITYPE_TLB   11'b000000100000
`define ITYPE_CSR   11'b000001000000
`define ITYPE_IDLE  11'b000010000000
`define ITYPE_MEM   11'b000100000000
`define ITYPE_BAR   11'b001000000000
`define ITYPE_BR    11'b010000000000

`define ITYPE_IDX_ALU   0
`define ITYPE_IDX_MUL   1
`define ITYPE_IDX_DIV   2
`define ITYPE_IDX_ERET  3
`define ITYPE_IDX_CACHE 4
`define ITYPE_IDX_TLB   5
`define ITYPE_IDX_CSR   6
`define ITYPE_IDX_IDLE  7
`define ITYPE_IDX_MEM   8
`define ITYPE_IDX_BAR   9
`define ITYPE_IDX_BR   10

`define CTRL_SRC1_RF 0
`define CTRL_SRC1_PC 1
`define CTRL_SRC1_ZERO 2
`define CTRL_SRC1_CNTID 3

`define CTRL_SRC2_RF 0
`define CTRL_SRC2_IMM 1
`define CTRL_SRC2_CNTL 2
`define CTRL_SRC2_CNTH 3

`define CTRL_ALU_ADD 0
`define CTRL_ALU_SUB 2
`define CTRL_ALU_SLT 4
`define CTRL_ALU_SLTU 5
`define CTRL_ALU_NOR 8
`define CTRL_ALU_AND 9
`define CTRL_ALU_OR 10
`define CTRL_ALU_XOR 11
`define CTRL_ALU_SLL 14
`define CTRL_ALU_SRL 15
`define CTRL_ALU_SRA 13
