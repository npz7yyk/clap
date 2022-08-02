`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module TLB#(
    parameter TLBNUM = 32
    )(
    input                       clk,
    input                       rstn,
    
    input  [               1:0] ad_mode,
    //search port pc
    input  [              31:0] s0_vaddr,
    input  [               9:0] s0_asid,
    input  [               1:0] s0_plv,

    // 取指 = 2'd2;
    // LOAD = 2'd0;
    // STORE = 2'd1;
    input  [               1:0] s0_mem_type,
    input                       s0_en,
    output     [           31:0] s0_paddr,
    output     [            6:0] s0_exception,
    output [                1:0] s0_mat,

    //search port data
    input  [              31:0] s1_vaddr,
    input  [               9:0] s1_asid,
    input  [               1:0] s1_plv,
    input  [               1:0] s1_mem_type,
    input                       s1_en,
    output [              31:0] s1_paddr,
    output [               6:0] s1_exception,
    output [               1:0] s1_mat,

    //write & refill port
    input                       we,
    input                       fill_mode,
    input  [$clog2(TLBNUM)-1:0] w_index,
    input  [              18:0] w_vpn2,
    input  [               9:0] w_asid,
    input  [               5:0] w_ps,
    input                       w_e,
    input                       w_g,
    input  [              19:0] w_pfn0,
    input  [               1:0] w_mat0,
    input  [               1:0] w_plv0,
    input                       w_d0,
    input                       w_v0,
    input  [              19:0] w_pfn1,
    input  [               1:0] w_mat1,
    input  [               1:0] w_plv1,
    input                       w_d1,
    input                       w_v1,

    input  [$clog2(TLBNUM)-1:0] f_index,

    //read port
    input  [$clog2(TLBNUM)-1:0] r_index,
    input                       check_mode,

    output [              18:0] r_vpn2,
    output [               9:0] r_asid,
    output [               5:0] r_ps,
    output                      r_g,
    output [              19:0] r_pfn0,
    output [               1:0] r_mat0,
    output [               1:0] r_plv0,
    output                      r_d0,
    output                      r_v0,
    output [              19:0] r_pfn1,
    output [               1:0] r_mat1,
    output [               1:0] r_plv1,
    output                      r_d1,
    output                      r_v1,
    // tlbsearch
    input  [              18:0] s_vpn2,
    input  [               9:0] s_asid,
    output [$clog2(TLBNUM)-1:0] s_index,
    output                      rs_e,
    // invtlb
    input  [               2:0] clear_mem,
    input  [              31:0] clear_vaddr,
    input  [               9:0] clear_asid,
    //dmw
    input                       dmw0_plv0,
    input                       dmw0_plv3,
    input  [               1:0] dmw0_mat,
    input  [               2:0] dmw0_vseg,
    input  [               2:0] dmw0_pseg,
    input                       dmw1_plv0,
    input                       dmw1_plv3,
    input  [               1:0] dmw1_mat,
    input  [               2:0] dmw1_vseg,
    input  [               2:0] dmw1_pseg
    //excp
    // input                       cacop_en,
    // input  [               4:0] cacop_code,
    // output [               6:0] asmd_excp

    );
    wire s0_found, s1_found;

    wire [TLBNUM-1:0] found0, found1;
    wire [5:0] found_ps0, found_ps1;

    wire found_v0, found_v1;
    wire found_d0, found_d1;
    wire [1:0] found_mat0, found_mat1;
    wire [1:0] found_plv0, found_plv1;
    wire [19:0] found_pfn0, found_pfn1;
    wire [1:0] s0_dmw_mat, s1_dmw_mat;
    wire [1:0] s0_dmw_mat_obuf, s1_dmw_mat_obuf;
    wire [1:0] s0_tlb_mat_obuf, s1_tlb_mat_obuf;
    wire [31:0] s0_dmw_paddr, s1_dmw_paddr;
    wire [31:0] s0_dmw_paddr_obuf, s1_dmw_paddr_obuf;
    wire s0_dmw_hit, s1_dmw_hit;
    wire s0_dmw_hit_obuf, s1_dmw_hit_obuf;

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

    
    TLB_dmw dmw_cope(
        .dmw0_plv0          (dmw0_plv0),
        .dmw0_plv3          (dmw0_plv3),
        .dmw0_mat           (dmw0_mat ),
        .dmw0_vseg          (dmw0_vseg),
        .dmw0_pseg          (dmw0_pseg),
        .dmw1_plv0          (dmw1_plv0),
        .dmw1_plv3          (dmw1_plv3),
        .dmw1_mat           (dmw1_mat ),
        .dmw1_vseg          (dmw1_vseg),
        .dmw1_pseg          (dmw1_pseg),

        .s0_vaddr           (s0_vaddr    ),
        .s0_plv             (s0_plv      ),
        .s0_dmw_mat         (s0_dmw_mat  ),
        .s0_dmw_paddr       (s0_dmw_paddr),
        .s0_dmw_hit         (s0_dmw_hit  ),
        
        .s1_vaddr           (s1_vaddr    ),
        .s1_plv             (s1_plv      ),
        .s1_dmw_mat         (s1_dmw_mat  ),
        .s1_dmw_paddr       (s1_dmw_paddr),
        .s1_dmw_hit         (s1_dmw_hit  )
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
        .s0_asid    (s0_asid),
        .s1_asid    (s1_asid),
        .s0_vpn2    (s0_vaddr[31:13]),
        .s1_vpn2    (s1_vaddr[31:13]),
        .found0     (found0),
        .found1     (found1),

        .s_vpn2     (s_vpn2),
        .s_asid     (s_asid),
        .s_e        (s_e),
        .s_index    (s_index)
    );
    /* TLB hit */
    assign s0_found = |found0;
    assign s1_found = |found1;
    // assign s0_pfn   = found_pfn0;
    // assign s1_pfn   = found_pfn1;

    TLB_found_signal found_signal(
        .all_ps         (all_ps),
        .all_pfn0       (all_pfn0),
        .all_mat0       (all_mat0),
        .all_plv0       (all_plv0),
        .all_d0         (all_d0),
        .all_v0         (all_v0),
        .found0         (found0),
        .odd0_bit       (s0_vaddr[12]),
        .all_pfn1       (all_pfn1),
        .all_mat1       (all_mat1),
        .all_plv1       (all_plv1),
        .all_d1         (all_d1),
        .all_v1         (all_v1),
        .found1         (found1),
        .odd1_bit       (s1_vaddr[12]),
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
        .found_ps0      (found_ps0),
        .found_ps1      (found_ps1)
    );
    wire [1:0] ad_mode_buf;
    wire [31:0] s0_vaddr_obuf, s1_vaddr_obuf;
    wire [19:0] found_pfn0_obuf, found_pfn1_obuf;
    wire [5:0] found_ps0_obuf, found_ps1_obuf;
    wire s0_found_obuf, s1_found_obuf;
    wire [1:0] s0_mem_type_obuf, s1_mem_type_obuf;
    wire found_v0_obuf, found_v1_obuf;
    wire found_d0_obuf, found_d1_obuf;
    wire [1:0] s0_plv_obuf, s1_plv_obuf;
    wire [1:0] found_plv0_obuf, found_plv1_obuf;
    wire s0_en_obuf, s1_en_obuf;
    register#(2) output_ad_buffer(
        .clk            (clk),
        .rstn           (rstn),
        .we             (1'b1),
        .din            (ad_mode),
        .dout           (ad_mode_buf)
    );
    register#(20+6+1+2+1+1+2+2+2+2+32+1) output_s0_buffer(
        .clk            (clk),
        .rstn           (rstn),
        .we             (s0_en),
        .din            ({found_pfn0,        found_ps0,      s0_found,        s0_mem_type,      
                          found_v0,        found_d0,          s0_plv,         found_plv0,      found_mat0,
                          s0_dmw_mat,      s0_dmw_paddr,      s0_dmw_hit}),
        .dout           ({found_pfn0_obuf,   found_ps0_obuf, s0_found_obuf,   s0_mem_type_obuf, 
                          found_v0_obuf,   found_d0_obuf,     s0_plv_obuf,    found_plv0_obuf, s0_tlb_mat_obuf, 
                          s0_dmw_mat_obuf, s0_dmw_paddr_obuf, s0_dmw_hit_obuf})
    );
    register#(20+6+1+2+1+1+2+2+2+2+32+1) output_s1_buffer(
        .clk            (clk),
        .rstn           (rstn),
        .we             (s1_en),
        .din            ({found_pfn1,        found_ps1,      s1_found,        s1_mem_type,      
                          found_v1,        found_d1,          s1_plv,         found_plv1,      found_mat1,
                          s1_dmw_mat,      s1_dmw_paddr,      s1_dmw_hit}),
        .dout           ({found_pfn1_obuf,   found_ps1_obuf, s1_found_obuf,   s1_mem_type_obuf, 
                          found_v1_obuf,   found_d1_obuf,     s1_plv_obuf,    found_plv1_obuf, s1_tlb_mat_obuf,
                          s1_dmw_mat_obuf, s1_dmw_paddr_obuf, s1_dmw_hit_obuf})
    );
    register#(33) out_s0_vaddr(
        .clk            (clk),
        .rstn           (rstn),
        .we             (1'b1),
        .din            ({s0_vaddr, s0_en}),
        .dout           ({s0_vaddr_obuf, s0_en_obuf})
    );
    register#(33) out_s1_vaddr(
        .clk            (clk),
        .rstn           (rstn),
        .we             (1'b1),
        .din            ({s1_vaddr, s1_en}),
        .dout           ({s1_vaddr_obuf, s1_en_obuf})
    );

    TLB_out addr_output(
        .ad_mode            (ad_mode_buf),
        .s0_dmw_hit         (s0_dmw_hit),
        .s1_dmw_hit         (s1_dmw_hit),
        .s0_dmw_hit_obuf    (s0_dmw_hit_obuf),
        .s1_dmw_hit_obuf    (s1_dmw_hit_obuf),

        .s0_addr            (s0_vaddr_obuf),
        .s1_addr            (s1_vaddr_obuf),
        .s0_dmw_mat         (s0_dmw_mat),
        .s1_dmw_mat         (s1_dmw_mat),
        .s0_tlb_mat         (found_mat0),
        .s1_tlb_mat         (found_mat1),
        .s0_dmw_paddr       (s0_dmw_paddr_obuf),
        .s1_dmw_paddr       (s1_dmw_paddr_obuf),
        .s0_pfn             (found_pfn0_obuf),
        .s1_pfn             (found_pfn1_obuf),
        .found_ps0          (found_ps0_obuf),
        .found_ps1          (found_ps1_obuf),
        .s0_paddr           (s0_paddr),
        .s1_paddr           (s1_paddr),
        .s0_mat             (s0_mat),
        .s1_mat             (s1_mat)
    );

    /* exeption coping */
    TLB_exp_handler exp_handler(
        .s0_found       (s0_found_obuf),
        .s0_en          (s0_en_obuf),
        .s0_dmw_hit     (s0_dmw_hit_obuf),
        .s0_mem_type    (s0_mem_type_obuf),
        .found_v0       (found_v0_obuf),
        .found_d0       (found_d0_obuf),
        .s0_plv         (s0_plv_obuf),
        .found_plv0     (found_plv0_obuf),
        .s0_exception   (s0_exception),
        .s0_vaddr       (s0_vaddr_obuf),

        .s1_found       (s1_found_obuf),
        .s1_en          (s1_en_obuf),
        .s1_dmw_hit     (s1_dmw_hit_obuf),
        .s1_mem_type    (s1_mem_type_obuf),
        .found_v1       (found_v1_obuf),
        .found_d1       (found_d1_obuf),
        .s1_plv         (s1_plv_obuf),
        .found_plv1     (found_plv1_obuf),
        .s1_exception   (s1_exception),

        .s1_vaddr       (s1_vaddr_obuf)
    );
    

endmodule 
 