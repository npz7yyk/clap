module TLB#(
    parameter TLBNUM = 16
    )(
    input                       clk,
    input                       rstn,
    
    input  [               1:0] ad_mode,
    //search port pc
    input  [              31:0] s0_vaddr,
    input  [               9:0] s0_asid,
    input  [               1:0] s0_plv,
    input  [               1:0] s0_mem_type,
    input                       s0_en,
    output     [           31:0] s0_paddr,
    output     [            6:0] s0_exception,

    //search port data
    input  [              31:0] s1_vaddr,//
    input  [               9:0] s1_asid,//
    input  [               1:0] s1_plv,
    input  [               1:0] s1_mem_type,
    input                       s1_en,
    output     [          31:0] s1_paddr,
    output     [           6:0] s1_exception,

    //write & refill port
    input                       we,
    input                       fill_mode,
    input  [$clog2(TLBNUM)-1:0] w_index,//
    input  [              18:0] w_vpn2,//
    input  [               9:0] w_asid,//
    input  [               5:0] w_ps,//
    input                       w_e,//
    input                       w_g,//
    input  [              19:0] w_pfn0,//
    input  [               1:0] w_mat0,//
    input  [               1:0] w_plv0,//
    input                       w_d0,//
    input                       w_v0,//
    input  [              19:0] w_pfn1,//
    input  [               1:0] w_mat1,//
    input  [               1:0] w_plv1,//
    input                       w_d1,//
    input                       w_v1,//

    input  [$clog2(TLBNUM)-1:0] f_index,

    //read  & search port
    input  [$clog2(TLBNUM)-1:0] r_index,//
    input                       check_mode,

    output [              18:0] r_vpn2,//
    output [               9:0] r_asid,//
    output [               5:0] r_ps,//
    output                      r_g,//
    output [              19:0] r_pfn0,//
    output [               1:0] r_mat0,//
    output [               1:0] r_plv0,//
    output                      r_d0,//
    output                      r_v0,//
    output [              19:0] r_pfn1,//
    output [               1:0] r_mat1,//
    output [               1:0] r_plv1,//
    output                      r_d1,//
    output                      r_v1,//

    input  [              18:0] s_vpn2,//
    output [$clog2(TLBNUM)-1:0] s_index,//
    output                      rs_e,//

    input  [               2:0] clear_mem,
    input  [              31:0] clear_vaddr,
    input  [               9:0] clear_asid
    );
    wire [1:0] mode_mbuf;
    wire [31:0] s0_addr_buf, s1_addr_buf;
    wire s0_found, s1_found;

    wire [TLBNUM-1:0] found0, found1;
    wire [5:0] found_ps0, found_ps1;

    wire found_v0, found_v1;
    wire found_d0, found_d1;
    wire [1:0] found_mat0, found_mat1;
    wire [1:0] found_plv0, found_plv1;
    wire [19:0] found_pfn0, found_pfn1;
    wire [19:0] s0_pfn, s1_pfn;
    //wire [3:0] found_index0, found_index1;

    wire [19:0] s0_vpn_rbuf, s1_vpn_rbuf;
    wire [9:0] s0_asid_rbuf, s1_asid_rbuf;
    wire [1:0] s0_plv_rbuf, s1_plv_rbuf;
    wire [1:0] s0_mem_type_rbuf, s1_mem_type_rbuf; 

    wire r_e, s_e;
    assign rs_e = check_mode ? s_e : r_e;

    wire [    TLBNUM*19-1:0]  all_vpn2;
    wire [    TLBNUM*10-1:0]  all_asid;
    wire [     TLBNUM*6-1:0]  all_ps;
    wire [       TLBNUM-1:0]  all_g;
    wire [       TLBNUM-1:0]  all_e;
    wire [    TLBNUM*20-1:0]  all_pfn0;
    wire [     TLBNUM*2-1:0]  all_mat0;
    wire [     TLBNUM*2-1:0]  all_plv0;
    wire [       TLBNUM-1:0]  all_d0;
    wire [       TLBNUM-1:0]  all_v0;
    wire [    TLBNUM*20-1:0]  all_pfn1;
    wire [     TLBNUM*2-1:0]  all_mat1;
    wire [     TLBNUM*2-1:0]  all_plv1;
    wire [       TLBNUM-1:0]  all_d1;
    wire [       TLBNUM-1:0]  all_v1;

    register#(34) req0_buffer(
        .clk            (clk),
        .rstn           (rstn),
        .we             (s0_en),
        .din            ({s0_vaddr[31:12], s0_asid, s0_plv, s0_mem_type}),
        .dout           ({s0_vpn_rbuf, s0_asid_rbuf, s0_plv_rbuf, s0_mem_type_rbuf})
    );
    register#(34) req1_buffer(
        .clk            (clk),
        .rstn           (rstn),
        .we             (s1_en),
        .din            ({s1_vaddr[31:12], s1_asid, s1_plv, s1_mem_type}),
        .dout           ({s1_vpn_rbuf, s1_asid_rbuf, s1_plv_rbuf, s1_mem_type_rbuf})
    );
    register#(2) mode_buffer(
        .clk            (clk),
        .rstn           (rstn),
        .we             (1'b1),
        .din            (ad_mode),
        .dout           (mode_mbuf)
    );
    register#(32) vad0_buffer(
        .clk            (clk),
        .rstn           (rstn),
        .we             (1'b1),
        .din            (s0_vaddr),
        .dout           (s0_addr_buf)
    );
    register#(32) vad1_buffer(
        .clk            (clk),
        .rstn           (rstn),
        .we             (1'b1),
        .din            (s1_vaddr),
        .dout           (s1_addr_buf)
    );
    
    /* memory */
    TLB_memory memory(
        .clk            (clk),
        .all_vpn2       (all_vpn2),
        .all_asid       (all_asid),
        .all_ps         (all_ps),
        .all_g          (all_g),
        .all_e          (all_e),
        .all_pfn0       (all_pfn0),
        .all_mat0       (all_mat0),
        .all_plv0       (all_plv0),
        .all_d0         (all_d0),
        .all_v0         (all_v0),
        .all_pfn1       (all_pfn1),
        .all_mat1       (all_mat1),
        .all_plv1       (all_plv1),
        .all_d1         (all_d1),
        .all_v1         (all_v1),

        .r_index        (r_index),
        .r_vpn2         (r_vpn2),
        .r_asid         (r_asid),
        .r_ps           (r_ps),
        .r_e            (r_e),
        .r_g            (r_g),
        .r_pfn0         (r_pfn0),
        .r_mat0         (r_mat0),
        .r_plv0         (r_plv0),
        .r_d0           (r_d0),
        .r_v0           (r_v0),
        .r_pfn1         (r_pfn1),
        .r_mat1         (r_mat1),
        .r_plv1         (r_plv1),
        .r_d1           (r_d1),
        .r_v1           (r_v1),

        .we             (we),
        .w_index        (fill_mode ? f_index : w_index),
        .w_vpn2         (w_vpn2),
        .w_asid         (w_asid),
        .w_ps           (w_ps),
        .w_e            (w_e),
        .w_g            (w_g),
        .w_pfn0         (w_pfn0),
        .w_mat0         (w_mat0),
        .w_plv0         (w_plv0),
        .w_d0           (w_d0),
        .w_v0           (w_v0),
        .w_pfn1         (w_pfn1),
        .w_mat1         (w_mat1),
        .w_plv1         (w_plv1),
        .w_d1           (w_d1),
        .w_v1           (w_v1),

        .clear_mem      (clear_mem),
        .clear_vaddr    (clear_vaddr),
        .clear_asid     (clear_asid)
    );

    /* hit judge */
    TLB_found_compare compare(
        .all_e      (all_e),
        .all_g      (all_g),
        .all_asid   (all_asid),
        .all_vpn2   (all_vpn2),
        .s0_asid    (s0_asid_rbuf),
        .s1_asid    (s1_asid_rbuf),
        .s0_vpn2    (s0_vpn_rbuf[19:1]),
        .s1_vpn2    (s1_vpn_rbuf[19:1]),
        .found0     (found0),
        .found1     (found1),

        .s_vpn2     (s_vpn2),
        .s_e        (s_e),
        .s_index    (s_index)
    );
    /* TLB hit */
    assign s0_found = |found0;
    assign s1_found = |found1;
    assign s0_pfn   = found_pfn0;
    assign s1_pfn   = found_pfn1;
    //assign s0_mat   = found_mat0;
    //assign s1_mat   = found_mat1;
    // assign s0_index = found_index0;
    // assign s1_index = found_index1;

    TLB_found_signal found_signal(
        .all_ps         (all_ps),
        .all_pfn0       (all_pfn0),
        .all_mat0       (all_mat0),
        .all_plv0       (all_plv0),
        .all_d0         (all_d0),
        .all_v0         (all_v0),
        .found0         (found0),
        .odd0_bit       (s0_vpn_rbuf[0]),
        .all_pfn1       (all_pfn1),
        .all_mat1       (all_mat1),
        .all_plv1       (all_plv1),
        .all_d1         (all_d1),
        .all_v1         (all_v1),
        .found1         (found1),
        .odd1_bit       (s1_vpn_rbuf[0]),
        .found_v0       (found_v0), 
        .found_v1       (found_v1),
        .found_d0       (found_d0), 
        .found_d1       (found_d1),
        .found_mat0     (found_mat0), 
        .found_mat1     (found_mat1),
        .found_plv0     (found_plv0), 
        .found_plv1     (found_plv1),
        .found_pfn0     (found_pfn0), 
        .found_pfn1     (found_pfn1),
        // .found_index0   (found_index0),
        // .found_index1   (found_index1),
        .found_ps0      (found_ps0),
        .found_ps1      (found_ps1)
    );

    TLB_out addr_output(
        .ad_mode    (mode_mbuf),
        .s0_addr    (s0_addr_buf),
        .s1_addr    (s1_addr_buf),
        .s0_pfn     (s0_pfn),
        .s1_pfn     (s1_pfn),
        .found_ps0  (found_ps0),
        .found_ps1  (found_ps1),
        .s0_paddr   (s0_paddr),
        .s1_paddr   (s1_paddr)
    );

    /* exeption coping */
    TLB_exp_handler exp_handler(
        .s0_found       (s0_found),
        .s0_mem_type    (s0_mem_type_rbuf),
        .found_v0       (found_v0),
        .found_d0       (found_d0),
        .s0_plv         (s0_plv_rbuf),
        .found_plv0     (found_plv0),
        .s0_exception   (s0_exception),
        .s1_found       (s1_found),
        .s1_mem_type    (s1_mem_type_rbuf),
        .found_v1       (found_v1),
        .found_d1       (found_d1),
        .s1_plv         (s1_plv_rbuf),
        .found_plv1     (found_plv1),
        .s1_exception   (s1_exception)
    );
    

endmodule 
 