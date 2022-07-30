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

`include "clap_config.vh"

//combine logic
//pre-decoder the instruction before pushing it to the FIFO, 
//to get feedback signals
/* verilator lint_off DECLFILENAME */
module pre_decoder
(
    input [31:0] inst,
    output [1:0] category,
    output reg [31:0] pc_offset
);
    assign category[1]=inst[31:27]=='b01010||inst[31:26]=='b010011;
    assign category[0]=inst[31:30]=='b01&&(
        inst[29:26]=='b0011 || inst[29:26]=='b0110 ||
        inst[29:26]=='b0111 || inst[29:26]=='b1000 ||
        inst[29:26]=='b1001 || inst[29:26]=='b1010 ||
        inst[29:26]=='b1011 );
    always @*
        case(category)
            2'b00,2'b11: pc_offset = 4;
            2'b01:       pc_offset = {{14{inst[25]}},inst[25:10],2'b00};
            2'b10:       pc_offset = {{4{inst[9]}},inst[9:0],inst[25:10],2'b00};
        endcase
endmodule
 
