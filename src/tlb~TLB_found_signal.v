`include "exception.vh"
module TLB_found_signal#(
    parameter TLBNUM = 16
    )(
    input  [    TLBNUM*20-1:0]  all_pfn0,
    input  [     TLBNUM*6-1:0]  all_ps,
    input  [     TLBNUM*2-1:0]  all_mat0,
    input  [     TLBNUM*2-1:0]  all_plv0,
    input  [       TLBNUM-1:0]  all_d0,
    input  [       TLBNUM-1:0]  all_v0,
    input  [       TLBNUM-1:0]  found0,
    input                       odd0_bit,

    input  [    TLBNUM*20-1:0]  all_pfn1,
    input  [     TLBNUM*2-1:0]  all_mat1,
    input  [     TLBNUM*2-1:0]  all_plv1,
    input  [       TLBNUM-1:0]  all_d1,
    input  [       TLBNUM-1:0]  all_v1,
    input  [       TLBNUM-1:0]  found1,
    input                       odd1_bit,

    output                   found_v0, 
    output                   found_d0, 
    output [            1:0] found_mat0, 
    output [            1:0] found_plv0, 
    output [           19:0] found_pfn0, 
    output [            5:0] found_ps0,
    output                   found_v1,
    output                   found_d1,
    output [            1:0] found_mat1,
    output [            1:0] found_plv1,
    output [           19:0] found_pfn1,
    output [            5:0] found_ps1


    );
    // v0
    assign found_v0 = found0[ 0] & (odd0_bit ? all_v1[ 0] : all_v0[ 0]) 
                    | found0[ 1] & (odd0_bit ? all_v1[ 1] : all_v0[ 1]) 
                    | found0[ 2] & (odd0_bit ? all_v1[ 2] : all_v0[ 2]) 
                    | found0[ 3] & (odd0_bit ? all_v1[ 3] : all_v0[ 3]) 
                    | found0[ 4] & (odd0_bit ? all_v1[ 4] : all_v0[ 4]) 
                    | found0[ 5] & (odd0_bit ? all_v1[ 5] : all_v0[ 5]) 
                    | found0[ 6] & (odd0_bit ? all_v1[ 6] : all_v0[ 6]) 
                    | found0[ 7] & (odd0_bit ? all_v1[ 7] : all_v0[ 7]) 
                    | found0[ 8] & (odd0_bit ? all_v1[ 8] : all_v0[ 8]) 
                    | found0[ 9] & (odd0_bit ? all_v1[ 9] : all_v0[ 9]) 
                    | found0[10] & (odd0_bit ? all_v1[10] : all_v0[10]) 
                    | found0[11] & (odd0_bit ? all_v1[11] : all_v0[11]) 
                    | found0[12] & (odd0_bit ? all_v1[12] : all_v0[12]) 
                    | found0[13] & (odd0_bit ? all_v1[13] : all_v0[13]) 
                    | found0[14] & (odd0_bit ? all_v1[14] : all_v0[14]) 
                    | found0[15] & (odd0_bit ? all_v1[15] : all_v0[15]);
    // d0
    assign found_d0 = found0[ 0] & (odd0_bit ? all_d1[ 0] : all_d0[ 0]) 
                    | found0[ 1] & (odd0_bit ? all_d1[ 1] : all_d0[ 1]) 
                    | found0[ 2] & (odd0_bit ? all_d1[ 2] : all_d0[ 2]) 
                    | found0[ 3] & (odd0_bit ? all_d1[ 3] : all_d0[ 3]) 
                    | found0[ 4] & (odd0_bit ? all_d1[ 4] : all_d0[ 4]) 
                    | found0[ 5] & (odd0_bit ? all_d1[ 5] : all_d0[ 5]) 
                    | found0[ 6] & (odd0_bit ? all_d1[ 6] : all_d0[ 6]) 
                    | found0[ 7] & (odd0_bit ? all_d1[ 7] : all_d0[ 7]) 
                    | found0[ 8] & (odd0_bit ? all_d1[ 8] : all_d0[ 8]) 
                    | found0[ 9] & (odd0_bit ? all_d1[ 9] : all_d0[ 9]) 
                    | found0[10] & (odd0_bit ? all_d1[10] : all_d0[10]) 
                    | found0[11] & (odd0_bit ? all_d1[11] : all_d0[11]) 
                    | found0[12] & (odd0_bit ? all_d1[12] : all_d0[12]) 
                    | found0[13] & (odd0_bit ? all_d1[13] : all_d0[13]) 
                    | found0[14] & (odd0_bit ? all_d1[14] : all_d0[14]) 
                    | found0[15] & (odd0_bit ? all_d1[15] : all_d0[15]);
    //mat0
    assign found_mat0 = {2{found0[ 0]}} & (odd0_bit ? all_mat1[ 1: 0] : all_mat0[ 1: 0]) 
                      | {2{found0[ 1]}} & (odd0_bit ? all_mat1[ 3: 2] : all_mat0[ 3: 2]) 
                      | {2{found0[ 2]}} & (odd0_bit ? all_mat1[ 5: 4] : all_mat0[ 5: 4]) 
                      | {2{found0[ 3]}} & (odd0_bit ? all_mat1[ 7: 6] : all_mat0[ 7: 6]) 
                      | {2{found0[ 4]}} & (odd0_bit ? all_mat1[ 9: 8] : all_mat0[ 9: 8]) 
                      | {2{found0[ 5]}} & (odd0_bit ? all_mat1[11:10] : all_mat0[11:10]) 
                      | {2{found0[ 6]}} & (odd0_bit ? all_mat1[13:12] : all_mat0[13:12]) 
                      | {2{found0[ 7]}} & (odd0_bit ? all_mat1[15:14] : all_mat0[15:14]) 
                      | {2{found0[ 8]}} & (odd0_bit ? all_mat1[17:16] : all_mat0[17:16]) 
                      | {2{found0[ 9]}} & (odd0_bit ? all_mat1[19:18] : all_mat0[19:18]) 
                      | {2{found0[10]}} & (odd0_bit ? all_mat1[21:20] : all_mat0[21:20]) 
                      | {2{found0[11]}} & (odd0_bit ? all_mat1[23:22] : all_mat0[23:22]) 
                      | {2{found0[12]}} & (odd0_bit ? all_mat1[25:24] : all_mat0[25:24]) 
                      | {2{found0[13]}} & (odd0_bit ? all_mat1[27:26] : all_mat0[27:26]) 
                      | {2{found0[14]}} & (odd0_bit ? all_mat1[29:28] : all_mat0[29:28]) 
                      | {2{found0[15]}} & (odd0_bit ? all_mat1[31:30] : all_mat0[31:30]);
    //plv0
    assign found_plv0 = {2{found0[ 0]}} & (odd0_bit ? all_plv1[ 1: 0] : all_plv0[ 1: 0]) 
                      | {2{found0[ 1]}} & (odd0_bit ? all_plv1[ 3: 2] : all_plv0[ 3: 2]) 
                      | {2{found0[ 2]}} & (odd0_bit ? all_plv1[ 5: 4] : all_plv0[ 5: 4]) 
                      | {2{found0[ 3]}} & (odd0_bit ? all_plv1[ 7: 6] : all_plv0[ 7: 6]) 
                      | {2{found0[ 4]}} & (odd0_bit ? all_plv1[ 9: 8] : all_plv0[ 9: 8]) 
                      | {2{found0[ 5]}} & (odd0_bit ? all_plv1[11:10] : all_plv0[11:10]) 
                      | {2{found0[ 6]}} & (odd0_bit ? all_plv1[13:12] : all_plv0[13:12]) 
                      | {2{found0[ 7]}} & (odd0_bit ? all_plv1[15:14] : all_plv0[15:14]) 
                      | {2{found0[ 8]}} & (odd0_bit ? all_plv1[17:16] : all_plv0[17:16]) 
                      | {2{found0[ 9]}} & (odd0_bit ? all_plv1[19:18] : all_plv0[19:18]) 
                      | {2{found0[10]}} & (odd0_bit ? all_plv1[21:20] : all_plv0[21:20]) 
                      | {2{found0[11]}} & (odd0_bit ? all_plv1[23:22] : all_plv0[23:22]) 
                      | {2{found0[12]}} & (odd0_bit ? all_plv1[25:24] : all_plv0[25:24]) 
                      | {2{found0[13]}} & (odd0_bit ? all_plv1[27:26] : all_plv0[27:26]) 
                      | {2{found0[14]}} & (odd0_bit ? all_plv1[29:28] : all_plv0[29:28]) 
                      | {2{found0[15]}} & (odd0_bit ? all_plv1[31:30] : all_plv0[31:30]);

    //pfn0
    assign found_pfn0 = {20{found0[ 0]}} & (odd0_bit ? all_pfn1[   19:0] : all_pfn0[   19:0]) 
                      | {20{found0[ 1]}} & (odd0_bit ? all_pfn1[  39:20] : all_pfn0[  39:20]) 
                      | {20{found0[ 2]}} & (odd0_bit ? all_pfn1[  59:40] : all_pfn0[  59:40]) 
                      | {20{found0[ 3]}} & (odd0_bit ? all_pfn1[  79:60] : all_pfn0[  79:60]) 
                      | {20{found0[ 4]}} & (odd0_bit ? all_pfn1[  99:80] : all_pfn0[  99:80]) 
                      | {20{found0[ 5]}} & (odd0_bit ? all_pfn1[119:100] : all_pfn0[119:100]) 
                      | {20{found0[ 6]}} & (odd0_bit ? all_pfn1[139:120] : all_pfn0[139:120]) 
                      | {20{found0[ 7]}} & (odd0_bit ? all_pfn1[159:140] : all_pfn0[159:140]) 
                      | {20{found0[ 8]}} & (odd0_bit ? all_pfn1[179:160] : all_pfn0[179:160]) 
                      | {20{found0[ 9]}} & (odd0_bit ? all_pfn1[199:180] : all_pfn0[199:180]) 
                      | {20{found0[10]}} & (odd0_bit ? all_pfn1[219:200] : all_pfn0[219:200]) 
                      | {20{found0[11]}} & (odd0_bit ? all_pfn1[239:220] : all_pfn0[239:220]) 
                      | {20{found0[12]}} & (odd0_bit ? all_pfn1[259:240] : all_pfn0[259:240]) 
                      | {20{found0[13]}} & (odd0_bit ? all_pfn1[279:260] : all_pfn0[279:260]) 
                      | {20{found0[14]}} & (odd0_bit ? all_pfn1[299:280] : all_pfn0[299:280]) 
                      | {20{found0[15]}} & (odd0_bit ? all_pfn1[319:300] : all_pfn0[319:300]);

    //ps0
    assign found_ps0 =  {6{found0[ 0]}} & all_ps[  5:0] 
                      | {6{found0[ 1]}} & all_ps[ 11:6] 
                      | {6{found0[ 2]}} & all_ps[17:12] 
                      | {6{found0[ 3]}} & all_ps[23:18] 
                      | {6{found0[ 4]}} & all_ps[29:24] 
                      | {6{found0[ 5]}} & all_ps[35:30] 
                      | {6{found0[ 6]}} & all_ps[41:36] 
                      | {6{found0[ 7]}} & all_ps[47:42] 
                      | {6{found0[ 8]}} & all_ps[53:48] 
                      | {6{found0[ 9]}} & all_ps[59:54] 
                      | {6{found0[10]}} & all_ps[65:60] 
                      | {6{found0[11]}} & all_ps[71:66] 
                      | {6{found0[12]}} & all_ps[77:72] 
                      | {6{found0[13]}} & all_ps[83:78] 
                      | {6{found0[14]}} & all_ps[89:84] 
                      | {6{found0[15]}} & all_ps[95:90];


   // v1
    assign found_v1 = found1[ 0] & (odd1_bit ? all_v1[ 0] : all_v0[ 0]) 
                    | found1[ 1] & (odd1_bit ? all_v1[ 1] : all_v0[ 1]) 
                    | found1[ 2] & (odd1_bit ? all_v1[ 2] : all_v0[ 2]) 
                    | found1[ 3] & (odd1_bit ? all_v1[ 3] : all_v0[ 3]) 
                    | found1[ 4] & (odd1_bit ? all_v1[ 4] : all_v0[ 4]) 
                    | found1[ 5] & (odd1_bit ? all_v1[ 5] : all_v0[ 5]) 
                    | found1[ 6] & (odd1_bit ? all_v1[ 6] : all_v0[ 6]) 
                    | found1[ 7] & (odd1_bit ? all_v1[ 7] : all_v0[ 7]) 
                    | found1[ 8] & (odd1_bit ? all_v1[ 8] : all_v0[ 8]) 
                    | found1[ 9] & (odd1_bit ? all_v1[ 9] : all_v0[ 9]) 
                    | found1[10] & (odd1_bit ? all_v1[10] : all_v0[10]) 
                    | found1[11] & (odd1_bit ? all_v1[11] : all_v0[11]) 
                    | found1[12] & (odd1_bit ? all_v1[12] : all_v0[12]) 
                    | found1[13] & (odd1_bit ? all_v1[13] : all_v0[13]) 
                    | found1[14] & (odd1_bit ? all_v1[14] : all_v0[14]) 
                    | found1[15] & (odd1_bit ? all_v1[15] : all_v0[15]);
    // d1
    assign found_d1 = found1[ 0] & (odd1_bit ? all_d1[ 0] : all_d0[ 0]) 
                    | found1[ 1] & (odd1_bit ? all_d1[ 1] : all_d0[ 1]) 
                    | found1[ 2] & (odd1_bit ? all_d1[ 2] : all_d0[ 2]) 
                    | found1[ 3] & (odd1_bit ? all_d1[ 3] : all_d0[ 3]) 
                    | found1[ 4] & (odd1_bit ? all_d1[ 4] : all_d0[ 4]) 
                    | found1[ 5] & (odd1_bit ? all_d1[ 5] : all_d0[ 5]) 
                    | found1[ 6] & (odd1_bit ? all_d1[ 6] : all_d0[ 6]) 
                    | found1[ 7] & (odd1_bit ? all_d1[ 7] : all_d0[ 7]) 
                    | found1[ 8] & (odd1_bit ? all_d1[ 8] : all_d0[ 8]) 
                    | found1[ 9] & (odd1_bit ? all_d1[ 9] : all_d0[ 9]) 
                    | found1[10] & (odd1_bit ? all_d1[10] : all_d0[10]) 
                    | found1[11] & (odd1_bit ? all_d1[11] : all_d0[11]) 
                    | found1[12] & (odd1_bit ? all_d1[12] : all_d0[12]) 
                    | found1[13] & (odd1_bit ? all_d1[13] : all_d0[13]) 
                    | found1[14] & (odd1_bit ? all_d1[14] : all_d0[14]) 
                    | found1[15] & (odd1_bit ? all_d1[15] : all_d0[15]);
    //mat1
    assign found_mat1 = {2{found1[ 0]}} & (odd1_bit ? all_mat1[ 1: 0] : all_mat0[ 1: 0]) 
                      | {2{found1[ 1]}} & (odd1_bit ? all_mat1[ 3: 2] : all_mat0[ 3: 2]) 
                      | {2{found1[ 2]}} & (odd1_bit ? all_mat1[ 5: 4] : all_mat0[ 5: 4]) 
                      | {2{found1[ 3]}} & (odd1_bit ? all_mat1[ 7: 6] : all_mat0[ 7: 6]) 
                      | {2{found1[ 4]}} & (odd1_bit ? all_mat1[ 9: 8] : all_mat0[ 9: 8]) 
                      | {2{found1[ 5]}} & (odd1_bit ? all_mat1[11:10] : all_mat0[11:10]) 
                      | {2{found1[ 6]}} & (odd1_bit ? all_mat1[13:12] : all_mat0[13:12]) 
                      | {2{found1[ 7]}} & (odd1_bit ? all_mat1[15:14] : all_mat0[15:14]) 
                      | {2{found1[ 8]}} & (odd1_bit ? all_mat1[17:16] : all_mat0[17:16]) 
                      | {2{found1[ 9]}} & (odd1_bit ? all_mat1[19:18] : all_mat0[19:18]) 
                      | {2{found1[10]}} & (odd1_bit ? all_mat1[21:20] : all_mat0[21:20]) 
                      | {2{found1[11]}} & (odd1_bit ? all_mat1[23:22] : all_mat0[23:22]) 
                      | {2{found1[12]}} & (odd1_bit ? all_mat1[25:24] : all_mat0[25:24]) 
                      | {2{found1[13]}} & (odd1_bit ? all_mat1[27:26] : all_mat0[27:26]) 
                      | {2{found1[14]}} & (odd1_bit ? all_mat1[29:28] : all_mat0[29:28]) 
                      | {2{found1[15]}} & (odd1_bit ? all_mat1[31:30] : all_mat0[31:30]);
    //plv1
    assign found_plv1 = {2{found1[ 0]}} & (odd1_bit ? all_plv1[ 1: 0] : all_plv0[ 1: 0]) 
                      | {2{found1[ 1]}} & (odd1_bit ? all_plv1[ 3: 2] : all_plv0[ 3: 2]) 
                      | {2{found1[ 2]}} & (odd1_bit ? all_plv1[ 5: 4] : all_plv0[ 5: 4]) 
                      | {2{found1[ 3]}} & (odd1_bit ? all_plv1[ 7: 6] : all_plv0[ 7: 6]) 
                      | {2{found1[ 4]}} & (odd1_bit ? all_plv1[ 9: 8] : all_plv0[ 9: 8]) 
                      | {2{found1[ 5]}} & (odd1_bit ? all_plv1[11:10] : all_plv0[11:10]) 
                      | {2{found1[ 6]}} & (odd1_bit ? all_plv1[13:12] : all_plv0[13:12]) 
                      | {2{found1[ 7]}} & (odd1_bit ? all_plv1[15:14] : all_plv0[15:14]) 
                      | {2{found1[ 8]}} & (odd1_bit ? all_plv1[17:16] : all_plv0[17:16]) 
                      | {2{found1[ 9]}} & (odd1_bit ? all_plv1[19:18] : all_plv0[19:18]) 
                      | {2{found1[10]}} & (odd1_bit ? all_plv1[21:20] : all_plv0[21:20]) 
                      | {2{found1[11]}} & (odd1_bit ? all_plv1[23:22] : all_plv0[23:22]) 
                      | {2{found1[12]}} & (odd1_bit ? all_plv1[25:24] : all_plv0[25:24]) 
                      | {2{found1[13]}} & (odd1_bit ? all_plv1[27:26] : all_plv0[27:26]) 
                      | {2{found1[14]}} & (odd1_bit ? all_plv1[29:28] : all_plv0[29:28]) 
                      | {2{found1[15]}} & (odd1_bit ? all_plv1[31:30] : all_plv0[31:30]);

    //pfn1
    assign found_pfn1 = {20{found1[ 0]}} & (odd1_bit ? all_pfn1[   19:0] : all_pfn0[   19:0]) 
                      | {20{found1[ 1]}} & (odd1_bit ? all_pfn1[  39:20] : all_pfn0[  39:20]) 
                      | {20{found1[ 2]}} & (odd1_bit ? all_pfn1[  59:40] : all_pfn0[  59:40]) 
                      | {20{found1[ 3]}} & (odd1_bit ? all_pfn1[  79:60] : all_pfn0[  79:60]) 
                      | {20{found1[ 4]}} & (odd1_bit ? all_pfn1[  99:80] : all_pfn0[  99:80]) 
                      | {20{found1[ 5]}} & (odd1_bit ? all_pfn1[119:100] : all_pfn0[119:100]) 
                      | {20{found1[ 6]}} & (odd1_bit ? all_pfn1[139:120] : all_pfn0[139:120]) 
                      | {20{found1[ 7]}} & (odd1_bit ? all_pfn1[159:140] : all_pfn0[159:140]) 
                      | {20{found1[ 8]}} & (odd1_bit ? all_pfn1[179:160] : all_pfn0[179:160]) 
                      | {20{found1[ 9]}} & (odd1_bit ? all_pfn1[199:180] : all_pfn0[199:180]) 
                      | {20{found1[10]}} & (odd1_bit ? all_pfn1[219:200] : all_pfn0[219:200]) 
                      | {20{found1[11]}} & (odd1_bit ? all_pfn1[239:220] : all_pfn0[239:220]) 
                      | {20{found1[12]}} & (odd1_bit ? all_pfn1[259:240] : all_pfn0[259:240]) 
                      | {20{found1[13]}} & (odd1_bit ? all_pfn1[279:260] : all_pfn0[279:260]) 
                      | {20{found1[14]}} & (odd1_bit ? all_pfn1[299:280] : all_pfn0[299:280]) 
                      | {20{found1[15]}} & (odd1_bit ? all_pfn1[319:300] : all_pfn0[319:300]);

    //ps1
    
    assign found_ps1 =  {6{found1[ 0]}} & all_ps[  5:0] 
                      | {6{found1[ 1]}} & all_ps[ 11:6] 
                      | {6{found1[ 2]}} & all_ps[17:12] 
                      | {6{found1[ 3]}} & all_ps[23:18] 
                      | {6{found1[ 4]}} & all_ps[29:24] 
                      | {6{found1[ 5]}} & all_ps[35:30] 
                      | {6{found1[ 6]}} & all_ps[41:36] 
                      | {6{found1[ 7]}} & all_ps[47:42] 
                      | {6{found1[ 8]}} & all_ps[53:48] 
                      | {6{found1[ 9]}} & all_ps[59:54] 
                      | {6{found1[10]}} & all_ps[65:60] 
                      | {6{found1[11]}} & all_ps[71:66] 
                      | {6{found1[12]}} & all_ps[77:72] 
                      | {6{found1[13]}} & all_ps[83:78] 
                      | {6{found1[14]}} & all_ps[89:84] 
                      | {6{found1[15]}} & all_ps[95:90];
endmodule