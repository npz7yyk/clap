`include "exception.vh"
module TLB_found_signal#(
    parameter TLBNUM = 32
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
                    | found0[15] & (odd0_bit ? all_v1[15] : all_v0[15])
                    | found0[16] & (odd0_bit ? all_v1[16] : all_v0[16]) 
                    | found0[17] & (odd0_bit ? all_v1[17] : all_v0[17]) 
                    | found0[18] & (odd0_bit ? all_v1[18] : all_v0[18]) 
                    | found0[19] & (odd0_bit ? all_v1[19] : all_v0[19]) 
                    | found0[20] & (odd0_bit ? all_v1[20] : all_v0[20]) 
                    | found0[21] & (odd0_bit ? all_v1[21] : all_v0[21]) 
                    | found0[22] & (odd0_bit ? all_v1[22] : all_v0[22]) 
                    | found0[23] & (odd0_bit ? all_v1[23] : all_v0[23]) 
                    | found0[24] & (odd0_bit ? all_v1[24] : all_v0[24]) 
                    | found0[25] & (odd0_bit ? all_v1[25] : all_v0[25]) 
                    | found0[26] & (odd0_bit ? all_v1[26] : all_v0[26]) 
                    | found0[27] & (odd0_bit ? all_v1[27] : all_v0[27]) 
                    | found0[28] & (odd0_bit ? all_v1[28] : all_v0[28]) 
                    | found0[29] & (odd0_bit ? all_v1[29] : all_v0[29]) 
                    | found0[30] & (odd0_bit ? all_v1[30] : all_v0[30]) 
                    | found0[31] & (odd0_bit ? all_v1[31] : all_v0[31]);
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
                    | found0[15] & (odd0_bit ? all_d1[15] : all_d0[15])
                    | found0[16] & (odd0_bit ? all_d1[16] : all_d0[16]) 
                    | found0[17] & (odd0_bit ? all_d1[17] : all_d0[17]) 
                    | found0[18] & (odd0_bit ? all_d1[18] : all_d0[18]) 
                    | found0[19] & (odd0_bit ? all_d1[19] : all_d0[19]) 
                    | found0[20] & (odd0_bit ? all_d1[20] : all_d0[20]) 
                    | found0[21] & (odd0_bit ? all_d1[21] : all_d0[21]) 
                    | found0[22] & (odd0_bit ? all_d1[22] : all_d0[22]) 
                    | found0[23] & (odd0_bit ? all_d1[23] : all_d0[23]) 
                    | found0[24] & (odd0_bit ? all_d1[24] : all_d0[24]) 
                    | found0[25] & (odd0_bit ? all_d1[25] : all_d0[25]) 
                    | found0[26] & (odd0_bit ? all_d1[26] : all_d0[26]) 
                    | found0[27] & (odd0_bit ? all_d1[27] : all_d0[27]) 
                    | found0[28] & (odd0_bit ? all_d1[28] : all_d0[28]) 
                    | found0[29] & (odd0_bit ? all_d1[29] : all_d0[29]) 
                    | found0[30] & (odd0_bit ? all_d1[30] : all_d0[30]) 
                    | found0[31] & (odd0_bit ? all_d1[31] : all_d0[31]);
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
                      | {2{found0[15]}} & (odd0_bit ? all_mat1[31:30] : all_mat0[31:30])
                      | {2{found0[16]}} & (odd0_bit ? all_mat1[33:32] : all_mat0[33:32]) 
                      | {2{found0[17]}} & (odd0_bit ? all_mat1[35:34] : all_mat0[35:34]) 
                      | {2{found0[18]}} & (odd0_bit ? all_mat1[37:36] : all_mat0[37:36]) 
                      | {2{found0[19]}} & (odd0_bit ? all_mat1[39:38] : all_mat0[39:38]) 
                      | {2{found0[20]}} & (odd0_bit ? all_mat1[41:40] : all_mat0[41:40]) 
                      | {2{found0[21]}} & (odd0_bit ? all_mat1[43:42] : all_mat0[43:42]) 
                      | {2{found0[22]}} & (odd0_bit ? all_mat1[45:44] : all_mat0[45:44]) 
                      | {2{found0[23]}} & (odd0_bit ? all_mat1[47:46] : all_mat0[47:46]) 
                      | {2{found0[24]}} & (odd0_bit ? all_mat1[49:48] : all_mat0[49:48]) 
                      | {2{found0[25]}} & (odd0_bit ? all_mat1[51:50] : all_mat0[51:50]) 
                      | {2{found0[26]}} & (odd0_bit ? all_mat1[53:52] : all_mat0[53:52]) 
                      | {2{found0[27]}} & (odd0_bit ? all_mat1[55:54] : all_mat0[55:54]) 
                      | {2{found0[28]}} & (odd0_bit ? all_mat1[57:56] : all_mat0[57:56]) 
                      | {2{found0[29]}} & (odd0_bit ? all_mat1[59:58] : all_mat0[59:58]) 
                      | {2{found0[30]}} & (odd0_bit ? all_mat1[61:60] : all_mat0[61:60]) 
                      | {2{found0[31]}} & (odd0_bit ? all_mat1[63:62] : all_mat0[63:62]);
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
                      | {2{found0[15]}} & (odd0_bit ? all_plv1[31:30] : all_plv0[31:30])
                      | {2{found0[16]}} & (odd0_bit ? all_plv1[33:32] : all_plv0[33:32]) 
                      | {2{found0[17]}} & (odd0_bit ? all_plv1[35:34] : all_plv0[35:34]) 
                      | {2{found0[18]}} & (odd0_bit ? all_plv1[37:36] : all_plv0[37:36]) 
                      | {2{found0[19]}} & (odd0_bit ? all_plv1[39:38] : all_plv0[39:38]) 
                      | {2{found0[20]}} & (odd0_bit ? all_plv1[41:40] : all_plv0[41:40]) 
                      | {2{found0[21]}} & (odd0_bit ? all_plv1[43:42] : all_plv0[43:42]) 
                      | {2{found0[22]}} & (odd0_bit ? all_plv1[45:44] : all_plv0[45:44]) 
                      | {2{found0[23]}} & (odd0_bit ? all_plv1[47:46] : all_plv0[47:46]) 
                      | {2{found0[24]}} & (odd0_bit ? all_plv1[49:48] : all_plv0[49:48]) 
                      | {2{found0[25]}} & (odd0_bit ? all_plv1[51:50] : all_plv0[51:50]) 
                      | {2{found0[26]}} & (odd0_bit ? all_plv1[53:52] : all_plv0[53:52]) 
                      | {2{found0[27]}} & (odd0_bit ? all_plv1[55:54] : all_plv0[55:54]) 
                      | {2{found0[28]}} & (odd0_bit ? all_plv1[57:56] : all_plv0[57:56]) 
                      | {2{found0[29]}} & (odd0_bit ? all_plv1[59:58] : all_plv0[59:58]) 
                      | {2{found0[30]}} & (odd0_bit ? all_plv1[61:60] : all_plv0[61:60]) 
                      | {2{found0[31]}} & (odd0_bit ? all_plv1[63:62] : all_plv0[63:62]);

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
                      | {20{found0[15]}} & (odd0_bit ? all_pfn1[319:300] : all_pfn0[319:300])
                      | {20{found0[16]}} & (odd0_bit ? all_pfn1[339:320] : all_pfn0[339:320]) 
                      | {20{found0[17]}} & (odd0_bit ? all_pfn1[359:340] : all_pfn0[359:340]) 
                      | {20{found0[18]}} & (odd0_bit ? all_pfn1[379:360] : all_pfn0[379:360]) 
                      | {20{found0[19]}} & (odd0_bit ? all_pfn1[399:380] : all_pfn0[399:380]) 
                      | {20{found0[20]}} & (odd0_bit ? all_pfn1[419:400] : all_pfn0[419:400]) 
                      | {20{found0[21]}} & (odd0_bit ? all_pfn1[439:420] : all_pfn0[439:420]) 
                      | {20{found0[22]}} & (odd0_bit ? all_pfn1[459:440] : all_pfn0[459:440]) 
                      | {20{found0[23]}} & (odd0_bit ? all_pfn1[479:460] : all_pfn0[479:460]) 
                      | {20{found0[24]}} & (odd0_bit ? all_pfn1[499:480] : all_pfn0[499:480]) 
                      | {20{found0[25]}} & (odd0_bit ? all_pfn1[519:500] : all_pfn0[519:500]) 
                      | {20{found0[26]}} & (odd0_bit ? all_pfn1[539:520] : all_pfn0[539:520]) 
                      | {20{found0[27]}} & (odd0_bit ? all_pfn1[559:540] : all_pfn0[559:540]) 
                      | {20{found0[28]}} & (odd0_bit ? all_pfn1[579:560] : all_pfn0[579:560]) 
                      | {20{found0[29]}} & (odd0_bit ? all_pfn1[599:580] : all_pfn0[599:580]) 
                      | {20{found0[30]}} & (odd0_bit ? all_pfn1[619:600] : all_pfn0[619:600]) 
                      | {20{found0[31]}} & (odd0_bit ? all_pfn1[639:620] : all_pfn0[639:620]);

    //ps0
    assign found_ps0 =  {6{found0[ 0]}} & all_ps[    5:0] 
                      | {6{found0[ 1]}} & all_ps[   11:6] 
                      | {6{found0[ 2]}} & all_ps[  17:12] 
                      | {6{found0[ 3]}} & all_ps[  23:18] 
                      | {6{found0[ 4]}} & all_ps[  29:24] 
                      | {6{found0[ 5]}} & all_ps[  35:30] 
                      | {6{found0[ 6]}} & all_ps[  41:36] 
                      | {6{found0[ 7]}} & all_ps[  47:42] 
                      | {6{found0[ 8]}} & all_ps[  53:48] 
                      | {6{found0[ 9]}} & all_ps[  59:54] 
                      | {6{found0[10]}} & all_ps[  65:60] 
                      | {6{found0[11]}} & all_ps[  71:66] 
                      | {6{found0[12]}} & all_ps[  77:72] 
                      | {6{found0[13]}} & all_ps[  83:78] 
                      | {6{found0[14]}} & all_ps[  89:84] 
                      | {6{found0[15]}} & all_ps[  95:90]
                      | {6{found0[16]}} & all_ps[ 101:96] 
                      | {6{found0[17]}} & all_ps[107:102] 
                      | {6{found0[18]}} & all_ps[113:108] 
                      | {6{found0[19]}} & all_ps[119:114] 
                      | {6{found0[20]}} & all_ps[125:120] 
                      | {6{found0[21]}} & all_ps[131:126] 
                      | {6{found0[22]}} & all_ps[137:132] 
                      | {6{found0[23]}} & all_ps[143:138] 
                      | {6{found0[24]}} & all_ps[149:144] 
                      | {6{found0[25]}} & all_ps[155:150] 
                      | {6{found0[26]}} & all_ps[161:156] 
                      | {6{found0[27]}} & all_ps[167:162] 
                      | {6{found0[28]}} & all_ps[173:168] 
                      | {6{found0[29]}} & all_ps[179:174] 
                      | {6{found0[30]}} & all_ps[185:180] 
                      | {6{found0[31]}} & all_ps[191:186];
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
                    | found1[15] & (odd1_bit ? all_v1[15] : all_v0[15])
                    | found1[16] & (odd1_bit ? all_v1[16] : all_v0[16]) 
                    | found1[17] & (odd1_bit ? all_v1[17] : all_v0[17]) 
                    | found1[18] & (odd1_bit ? all_v1[18] : all_v0[18]) 
                    | found1[19] & (odd1_bit ? all_v1[19] : all_v0[19]) 
                    | found1[20] & (odd1_bit ? all_v1[20] : all_v0[20]) 
                    | found1[21] & (odd1_bit ? all_v1[21] : all_v0[21]) 
                    | found1[22] & (odd1_bit ? all_v1[22] : all_v0[22]) 
                    | found1[23] & (odd1_bit ? all_v1[23] : all_v0[23]) 
                    | found1[24] & (odd1_bit ? all_v1[24] : all_v0[24]) 
                    | found1[25] & (odd1_bit ? all_v1[25] : all_v0[25]) 
                    | found1[26] & (odd1_bit ? all_v1[26] : all_v0[26]) 
                    | found1[27] & (odd1_bit ? all_v1[27] : all_v0[27]) 
                    | found1[28] & (odd1_bit ? all_v1[28] : all_v0[28]) 
                    | found1[29] & (odd1_bit ? all_v1[29] : all_v0[29]) 
                    | found1[30] & (odd1_bit ? all_v1[30] : all_v0[30]) 
                    | found1[31] & (odd1_bit ? all_v1[31] : all_v0[31]);
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
                    | found1[15] & (odd1_bit ? all_d1[15] : all_d0[15])
                    | found1[16] & (odd1_bit ? all_d1[16] : all_d0[16]) 
                    | found1[17] & (odd1_bit ? all_d1[17] : all_d0[17]) 
                    | found1[18] & (odd1_bit ? all_d1[18] : all_d0[18]) 
                    | found1[19] & (odd1_bit ? all_d1[19] : all_d0[19]) 
                    | found1[20] & (odd1_bit ? all_d1[20] : all_d0[20]) 
                    | found1[21] & (odd1_bit ? all_d1[21] : all_d0[21]) 
                    | found1[22] & (odd1_bit ? all_d1[22] : all_d0[22]) 
                    | found1[23] & (odd1_bit ? all_d1[23] : all_d0[23]) 
                    | found1[24] & (odd1_bit ? all_d1[24] : all_d0[24]) 
                    | found1[25] & (odd1_bit ? all_d1[25] : all_d0[25]) 
                    | found1[26] & (odd1_bit ? all_d1[26] : all_d0[26]) 
                    | found1[27] & (odd1_bit ? all_d1[27] : all_d0[27]) 
                    | found1[28] & (odd1_bit ? all_d1[28] : all_d0[28]) 
                    | found1[29] & (odd1_bit ? all_d1[29] : all_d0[29]) 
                    | found1[30] & (odd1_bit ? all_d1[30] : all_d0[30]) 
                    | found1[31] & (odd1_bit ? all_d1[31] : all_d0[31]);
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
                      | {2{found1[15]}} & (odd1_bit ? all_mat1[31:30] : all_mat0[31:30])
                      | {2{found1[16]}} & (odd1_bit ? all_mat1[33:32] : all_mat0[33:32]) 
                      | {2{found1[17]}} & (odd1_bit ? all_mat1[35:34] : all_mat0[35:34]) 
                      | {2{found1[18]}} & (odd1_bit ? all_mat1[37:36] : all_mat0[37:36]) 
                      | {2{found1[19]}} & (odd1_bit ? all_mat1[39:38] : all_mat0[39:38]) 
                      | {2{found1[20]}} & (odd1_bit ? all_mat1[41:40] : all_mat0[41:40]) 
                      | {2{found1[21]}} & (odd1_bit ? all_mat1[43:42] : all_mat0[43:42]) 
                      | {2{found1[22]}} & (odd1_bit ? all_mat1[45:44] : all_mat0[45:44]) 
                      | {2{found1[23]}} & (odd1_bit ? all_mat1[47:46] : all_mat0[47:46]) 
                      | {2{found1[24]}} & (odd1_bit ? all_mat1[49:48] : all_mat0[49:48]) 
                      | {2{found1[25]}} & (odd1_bit ? all_mat1[51:50] : all_mat0[51:50]) 
                      | {2{found1[26]}} & (odd1_bit ? all_mat1[53:52] : all_mat0[53:52]) 
                      | {2{found1[27]}} & (odd1_bit ? all_mat1[55:54] : all_mat0[55:54]) 
                      | {2{found1[28]}} & (odd1_bit ? all_mat1[57:56] : all_mat0[57:56]) 
                      | {2{found1[29]}} & (odd1_bit ? all_mat1[59:58] : all_mat0[59:58]) 
                      | {2{found1[30]}} & (odd1_bit ? all_mat1[61:60] : all_mat0[61:60]) 
                      | {2{found1[31]}} & (odd1_bit ? all_mat1[63:62] : all_mat0[63:62]);
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
                      | {2{found1[15]}} & (odd1_bit ? all_plv1[31:30] : all_plv0[31:30])
                      | {2{found1[16]}} & (odd1_bit ? all_plv1[33:32] : all_plv0[33:32]) 
                      | {2{found1[17]}} & (odd1_bit ? all_plv1[35:34] : all_plv0[35:34]) 
                      | {2{found1[18]}} & (odd1_bit ? all_plv1[37:36] : all_plv0[37:36]) 
                      | {2{found1[19]}} & (odd1_bit ? all_plv1[39:38] : all_plv0[39:38]) 
                      | {2{found1[20]}} & (odd1_bit ? all_plv1[41:40] : all_plv0[41:40]) 
                      | {2{found1[21]}} & (odd1_bit ? all_plv1[43:42] : all_plv0[43:42]) 
                      | {2{found1[22]}} & (odd1_bit ? all_plv1[45:44] : all_plv0[45:44]) 
                      | {2{found1[23]}} & (odd1_bit ? all_plv1[47:46] : all_plv0[47:46]) 
                      | {2{found1[24]}} & (odd1_bit ? all_plv1[49:48] : all_plv0[49:48]) 
                      | {2{found1[25]}} & (odd1_bit ? all_plv1[51:50] : all_plv0[51:50]) 
                      | {2{found1[26]}} & (odd1_bit ? all_plv1[53:52] : all_plv0[53:52]) 
                      | {2{found1[27]}} & (odd1_bit ? all_plv1[55:54] : all_plv0[55:54]) 
                      | {2{found1[28]}} & (odd1_bit ? all_plv1[57:56] : all_plv0[57:56]) 
                      | {2{found1[29]}} & (odd1_bit ? all_plv1[59:58] : all_plv0[59:58]) 
                      | {2{found1[30]}} & (odd1_bit ? all_plv1[61:60] : all_plv0[61:60]) 
                      | {2{found1[31]}} & (odd1_bit ? all_plv1[63:62] : all_plv0[63:62]);

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
                      | {20{found1[15]}} & (odd1_bit ? all_pfn1[319:300] : all_pfn0[319:300])
                      | {20{found1[16]}} & (odd1_bit ? all_pfn1[339:320] : all_pfn0[339:320]) 
                      | {20{found1[17]}} & (odd1_bit ? all_pfn1[359:340] : all_pfn0[359:340]) 
                      | {20{found1[18]}} & (odd1_bit ? all_pfn1[379:360] : all_pfn0[379:360]) 
                      | {20{found1[19]}} & (odd1_bit ? all_pfn1[399:380] : all_pfn0[399:380]) 
                      | {20{found1[20]}} & (odd1_bit ? all_pfn1[419:400] : all_pfn0[419:400]) 
                      | {20{found1[21]}} & (odd1_bit ? all_pfn1[439:420] : all_pfn0[439:420]) 
                      | {20{found1[22]}} & (odd1_bit ? all_pfn1[459:440] : all_pfn0[459:440]) 
                      | {20{found1[23]}} & (odd1_bit ? all_pfn1[479:460] : all_pfn0[479:460]) 
                      | {20{found1[24]}} & (odd1_bit ? all_pfn1[499:480] : all_pfn0[499:480]) 
                      | {20{found1[25]}} & (odd1_bit ? all_pfn1[519:500] : all_pfn0[519:500]) 
                      | {20{found1[26]}} & (odd1_bit ? all_pfn1[539:520] : all_pfn0[539:520]) 
                      | {20{found1[27]}} & (odd1_bit ? all_pfn1[559:540] : all_pfn0[559:540]) 
                      | {20{found1[28]}} & (odd1_bit ? all_pfn1[579:560] : all_pfn0[579:560]) 
                      | {20{found1[29]}} & (odd1_bit ? all_pfn1[599:580] : all_pfn0[599:580]) 
                      | {20{found1[30]}} & (odd1_bit ? all_pfn1[619:600] : all_pfn0[619:600]) 
                      | {20{found1[31]}} & (odd1_bit ? all_pfn1[639:620] : all_pfn0[639:620]);

    //ps1
    assign found_ps1 =  {6{found1[ 0]}} & all_ps[    5:0] 
                      | {6{found1[ 1]}} & all_ps[   11:6] 
                      | {6{found1[ 2]}} & all_ps[  17:12] 
                      | {6{found1[ 3]}} & all_ps[  23:18] 
                      | {6{found1[ 4]}} & all_ps[  29:24] 
                      | {6{found1[ 5]}} & all_ps[  35:30] 
                      | {6{found1[ 6]}} & all_ps[  41:36] 
                      | {6{found1[ 7]}} & all_ps[  47:42] 
                      | {6{found1[ 8]}} & all_ps[  53:48] 
                      | {6{found1[ 9]}} & all_ps[  59:54] 
                      | {6{found1[10]}} & all_ps[  65:60] 
                      | {6{found1[11]}} & all_ps[  71:66] 
                      | {6{found1[12]}} & all_ps[  77:72] 
                      | {6{found1[13]}} & all_ps[  83:78] 
                      | {6{found1[14]}} & all_ps[  89:84] 
                      | {6{found1[15]}} & all_ps[  95:90]
                      | {6{found1[16]}} & all_ps[ 101:96] 
                      | {6{found1[17]}} & all_ps[107:102] 
                      | {6{found1[18]}} & all_ps[113:108] 
                      | {6{found1[19]}} & all_ps[119:114] 
                      | {6{found1[20]}} & all_ps[125:120] 
                      | {6{found1[21]}} & all_ps[131:126] 
                      | {6{found1[22]}} & all_ps[137:132] 
                      | {6{found1[23]}} & all_ps[143:138] 
                      | {6{found1[24]}} & all_ps[149:144] 
                      | {6{found1[25]}} & all_ps[155:150] 
                      | {6{found1[26]}} & all_ps[161:156] 
                      | {6{found1[27]}} & all_ps[167:162] 
                      | {6{found1[28]}} & all_ps[173:168] 
                      | {6{found1[29]}} & all_ps[179:174] 
                      | {6{found1[30]}} & all_ps[185:180] 
                      | {6{found1[31]}} & all_ps[191:186];
endmodule