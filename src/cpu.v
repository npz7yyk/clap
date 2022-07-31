`include "clap_config.vh"
`include "uop.vh"
`include "exception.vh"
`include "csr.vh"

/* verilator lint_off DECLFILENAME */
module core_top(
    input           aclk,
    input           aresetn,
    input    [ 7:0] intrpt,
    //AXI interface
    //read request
    output   [ 3:0] arid,
    output   [31:0] araddr,
    output   [ 7:0] arlen,
    output   [ 2:0] arsize,
    output   [ 1:0] arburst,
    output   [ 1:0] arlock,
    output   [ 3:0] arcache,
    output   [ 2:0] arprot,
    output          arvalid,
    input           arready,
    //read back
    input    [ 3:0] rid,
    input    [31:0] rdata,
    input    [ 1:0] rresp,
    input           rlast,
    input           rvalid,
    output          rready,
    //write request
    output   [ 3:0] awid,
    output   [31:0] awaddr,
    output   [ 7:0] awlen,
    output   [ 2:0] awsize,
    output   [ 1:0] awburst,
    output   [ 1:0] awlock,
    output   [ 3:0] awcache,
    output   [ 2:0] awprot,
    output          awvalid,
    input           awready,
    //write data
    output   [ 3:0] wid,
    output   [31:0] wdata,
    output   [ 3:0] wstrb,
    output          wlast,
    output          wvalid,
    input           wready,
    //write back
    input    [ 3:0] bid,
    input    [ 1:0] bresp,
    input           bvalid,
    output          bready,

    output [31:0] debug0_wb_pc,
    output [ 3:0] debug0_wb_rf_wen,
    output [ 4:0] debug0_wb_rf_wnum,
    output [31:0] debug0_wb_rf_wdata,
    output [31:0] debug0_wb_inst,

    output [31:0] debug1_wb_pc,
    output [ 3:0] debug1_wb_rf_wen,
    output [ 4:0] debug1_wb_rf_wnum,
    output [31:0] debug1_wb_rf_wdata,
    output [31:0] debug1_wb_inst
);
    wire clk;
    wire clear_clock_gate,set_clock_gate;
    wire clear_clock_gate_require;
    clock_gate clock_gate
    (
        .aclk(aclk),
        .resetn(aresetn),
        .clk(clk),
        .clear_clock_gate(clear_clock_gate),
        .set_clock_gate(set_clock_gate)
    );
    assign wid = awid;
    assign arlock[1] = 0;
    assign awlock[1] = 0;
    wire [6:0] itlb_exp,dtlb_exp;
    wire [3:0]  i_axi_awid;         wire [3:0]  d_axi_awid;
    wire [31:0] i_axi_awaddr;       wire [31:0] d_axi_awaddr;
    wire [7:0]  i_axi_awlen;        wire [7:0]  d_axi_awlen;
    wire [2:0]  i_axi_awsize;       wire [2:0]  d_axi_awsize;
    wire [1:0]  i_axi_awburst;      wire [1:0]  d_axi_awburst;
    wire [0:0]  i_axi_awlock;       wire [0:0]  d_axi_awlock;
    wire [3:0]  i_axi_awcache;      wire [3:0]  d_axi_awcache;
    wire [2:0]  i_axi_awprot;       wire [2:0]  d_axi_awprot;
    wire [3:0]  i_axi_awqos;        wire [3:0]  d_axi_awqos;
    wire [3:0]  i_axi_awregion;     wire [3:0]  d_axi_awregion;
    wire [0:0]  i_axi_awvalid;      wire [0:0]  d_axi_awvalid;
    wire [0:0]  i_axi_awready;      wire [0:0]  d_axi_awready;
    wire [31:0] i_axi_wdata;        wire [31:0] d_axi_wdata;
    wire [3:0]  i_axi_wstrb;        wire [3:0]  d_axi_wstrb;
    wire [0:0]  i_axi_wlast;        wire [0:0]  d_axi_wlast;
    wire [0:0]  i_axi_wvalid;       wire [0:0]  d_axi_wvalid;
    wire [0:0]  i_axi_wready;       wire [0:0]  d_axi_wready;
    wire [3:0]  i_axi_bid;          wire [3:0]  d_axi_bid;
    wire [1:0]  i_axi_bresp;        wire [1:0]  d_axi_bresp;
    wire [0:0]  i_axi_bvalid;       wire [0:0]  d_axi_bvalid;
    wire [0:0]  i_axi_bready;       wire [0:0]  d_axi_bready;
    wire [3:0]  i_axi_arid;         wire [3:0]  d_axi_arid;
    wire [31:0] i_axi_araddr;       wire [31:0] d_axi_araddr;
    wire [7:0]  i_axi_arlen;        wire [7:0]  d_axi_arlen;
    wire [2:0]  i_axi_arsize;       wire [2:0]  d_axi_arsize;
    wire [1:0]  i_axi_arburst;      wire [1:0]  d_axi_arburst;
    wire [0:0]  i_axi_arlock;       wire [0:0]  d_axi_arlock;
    wire [3:0]  i_axi_arcache;      wire [3:0]  d_axi_arcache;
    wire [2:0]  i_axi_arprot;       wire [2:0]  d_axi_arprot;
    wire [3:0]  i_axi_arqos;        wire [3:0]  d_axi_arqos;
    wire [3:0]  i_axi_arregion;     wire [3:0]  d_axi_arregion;
    wire [0:0]  i_axi_arvalid;      wire [0:0]  d_axi_arvalid;
    wire [0:0]  i_axi_arready;      wire [0:0]  d_axi_arready;
    wire [3:0]  i_axi_rid;          wire [3:0]  d_axi_rid;
    wire [31:0] i_axi_rdata;        wire [31:0] d_axi_rdata;
    wire [1:0]  i_axi_rresp;        wire [1:0]  d_axi_rresp;
    wire [0:0]  i_axi_rlast;        wire [0:0]  d_axi_rlast;
    wire [0:0]  i_axi_rvalid;       wire [0:0]  d_axi_rvalid;
    wire [0:0]  i_axi_rready;       wire [0:0]  d_axi_rready;
    axi_interconnect #(
        .S_COUNT(2),
        .M_COUNT(1),
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .ID_WIDTH(4)
    )
    the_axi_interconnect(
        .clk(clk),.rst(~aresetn),

        //master
        .m_axi_awid(awid),
        .m_axi_awaddr(awaddr),
        .m_axi_awlen(awlen),
        .m_axi_awsize(awsize),
        .m_axi_awburst(awburst),
        .m_axi_awlock(awlock[0]),
        .m_axi_awcache(awcache),
        .m_axi_awprot(awprot),
        //https://developer.arm.com/documentation/ihi0022/e/AMBA-AXI3-and-AXI4-Protocol-Specification/AXI4-Additional-Signaling/QoS-signaling/QoS-interface-signals?lang=en
        .m_axi_awqos(),
        .m_axi_awregion(),
        .m_axi_awvalid(awvalid),
        .m_axi_awready(awready),

        //wid was removed in AXI4
        .m_axi_wdata(wdata),
        .m_axi_wstrb(wstrb),
        .m_axi_wlast(wlast),
        .m_axi_wvalid(wvalid),
        .m_axi_wready(wready),

        .m_axi_bid(bid),
        .m_axi_bresp(bresp),
        .m_axi_bvalid(bvalid),
        .m_axi_bready(bready),

        .m_axi_arid(arid),
        .m_axi_araddr(araddr),
        .m_axi_arlen(arlen),
        .m_axi_arsize(arsize),
        .m_axi_arburst(arburst),
        .m_axi_arlock(arlock[0]),
        .m_axi_arcache(arcache),
        .m_axi_arprot(arprot),
        .m_axi_arqos(),
        .m_axi_arregion(),
        .m_axi_arvalid(arvalid),
        .m_axi_arready(arready),

        .m_axi_rid(rid),
        .m_axi_rdata(rdata),
        .m_axi_rresp(rresp),
        .m_axi_rlast(rlast),
        .m_axi_rvalid(rvalid),
        .m_axi_rready(rready),

        //slave
        .s_axi_awid     ({ i_axi_awid     ,  d_axi_awid     }),
        .s_axi_awaddr   ({ i_axi_awaddr   ,  d_axi_awaddr   }),
        .s_axi_awlen    ({ i_axi_awlen    ,  d_axi_awlen    }),
        .s_axi_awsize   ({ i_axi_awsize   ,  d_axi_awsize   }),
        .s_axi_awburst  ({ i_axi_awburst  ,  d_axi_awburst  }),
        .s_axi_awlock   ({ i_axi_awlock   ,  d_axi_awlock   }),
        .s_axi_awcache  ({ i_axi_awcache  ,  d_axi_awcache  }),
        .s_axi_awprot   ({ i_axi_awprot   ,  d_axi_awprot   }),
        .s_axi_awqos    (0),
        .s_axi_awvalid  ({ i_axi_awvalid  ,  d_axi_awvalid  }),
        .s_axi_awready  ({ i_axi_awready  ,  d_axi_awready  }),
        .s_axi_wdata    ({ i_axi_wdata    ,  d_axi_wdata    }),
        .s_axi_wstrb    ({ i_axi_wstrb    ,  d_axi_wstrb    }),
        .s_axi_wlast    ({ i_axi_wlast    ,  d_axi_wlast    }),
        .s_axi_wvalid   ({ i_axi_wvalid   ,  d_axi_wvalid   }),
        .s_axi_wready   ({ i_axi_wready   ,  d_axi_wready   }),
        .s_axi_bid      ({ i_axi_bid      ,  d_axi_bid      }),
        .s_axi_bresp    ({ i_axi_bresp    ,  d_axi_bresp    }),
        .s_axi_bvalid   ({ i_axi_bvalid   ,  d_axi_bvalid   }),
        .s_axi_bready   ({ i_axi_bready   ,  d_axi_bready   }),
        .s_axi_arid     ({ i_axi_arid     ,  d_axi_arid     }),
        .s_axi_araddr   ({ i_axi_araddr   ,  d_axi_araddr   }),
        .s_axi_arlen    ({ i_axi_arlen    ,  d_axi_arlen    }),
        .s_axi_arsize   ({ i_axi_arsize   ,  d_axi_arsize   }),
        .s_axi_arburst  ({ i_axi_arburst  ,  d_axi_arburst  }),
        .s_axi_arlock   ({ i_axi_arlock   ,  d_axi_arlock   }),
        .s_axi_arcache  ({ i_axi_arcache  ,  d_axi_arcache  }),
        .s_axi_arprot   ({ i_axi_arprot   ,  d_axi_arprot   }),
        .s_axi_arqos    (0),
        .s_axi_arvalid  ({ i_axi_arvalid  ,  d_axi_arvalid  }),
        .s_axi_arready  ({ i_axi_arready  ,  d_axi_arready  }),
        .s_axi_rid      ({ i_axi_rid      ,  d_axi_rid      }),
        .s_axi_rdata    ({ i_axi_rdata    ,  d_axi_rdata    }),
        .s_axi_rresp    ({ i_axi_rresp    ,  d_axi_rresp    }),
        .s_axi_rlast    ({ i_axi_rlast    ,  d_axi_rlast    }),
        .s_axi_rvalid   ({ i_axi_rvalid   ,  d_axi_rvalid   }),
        .s_axi_rready   ({ i_axi_rready   ,  d_axi_rready   })
    );

    localparam TLBIDX_WIDTH = 5;
    //CSR
    wire  csr_store_state;
    wire  csr_restore_state;
    wire csr_back_to_direct_translate;
    wire  [6:0]  csr_expcode_in;
    wire  csr_expcode_wen;
    wire [18:0] csr_exp_vppn_in;
    wire csr_exp_vppn_we;
    wire  [31:0]  csr_era_in;
    wire  csr_era_wen;
    wire  [31:0]  csr_badv_in;
    wire  csr_badv_wen;

    wire  [`PGD_BASE]  csr_pgd_in;
    wire  csr_pgd_wen;
    wire  [`PGD_BASE]  pgdl_out;
    wire  [`PGD_BASE]  pgdh_out;

    wire  [TLBIDX_WIDTH-1:0]  tlb_index_in;
    wire  tlb_index_we;
    wire  [5:0]  tlb_ps_in;
    wire  tlb_ps_we;
    wire  tlb_ne_in;
    wire  tlb_ne_we;
    wire  [18:0]  tlb_vppn_in;
    wire  tlb_vppn_we;
    wire  tlb_valid_0_in;
    wire  tlb_valid_1_in;
    wire  tlb_valid_0_wen;
    wire  tlb_valid_1_wen;
    wire  tlb_dirty_0_in;
    wire  tlb_dirty_1_in;
    wire  tlb_dirty_0_wen;
    wire  tlb_dirty_1_wen;
    wire  [1:0]  tlb_priviledge_0_in;
    wire  [1:0]  tlb_priviledge_1_in;
    wire  tlb_priviledge_0_wen;
    wire  tlb_priviledge_1_wen;
    wire  [1:0] tlb_mat_0_in;
    wire  [1:0] tlb_mat_1_in;
    wire  tlb_mat_0_wen;
    wire  tlb_mat_1_wen;
    wire  tlb_global_0_in;
    wire  tlb_global_1_in;
    wire  tlb_global_0_wen;
    wire  tlb_global_1_wen;
    wire  [23:0]  tlb_ppn_0_in;
    wire  [23:0]  tlb_ppn_1_in;
    wire  tlb_ppn_0_wen;
    wire  tlb_ppn_1_wen;
    wire  [9:0]  asid_in;
    wire  asid_wen;
    wire  [1:0]  privilege;
    wire  [31:0]  csr_era_out;
    wire  [31:0]  csr_eentry;
    wire  [31:0]  csr_tlbrentry;
    wire  has_interrupt_cpu;
    wire  has_interrupt_idle;
    assign set_clock_gate = has_interrupt_idle;
    wire  [1:0]  translate_mode;
    wire  [1:0] direct_i_mat;
    wire  [1:0] direct_d_mat;
    wire  dmw0_plv0;
    wire  dmw0_plv3;
    wire  [1:0] dmw0_mat;
    wire  [31:29]  dmw0_vseg;
    wire  [31:29]  dmw0_pseg;
    wire  dmw1_plv0;
    wire  dmw1_plv3;
    wire  [1:0] dmw1_mat;
    wire  [31:29]  dmw1_vseg;
    wire  [31:29]  dmw1_pseg;
    wire  [TLBIDX_WIDTH-1:0]  tlb_index_out;
    wire  [5:0]  tlb_ps_out;
    wire  tlb_ne_out;
    wire  [18:0]  tlb_vppn_out;
    wire  tlb_valid_0_out;
    wire  tlb_valid_1_out;
    wire  tlb_dirty_0_out;
    wire  tlb_dirty_1_out;
    wire  [1:0]  tlb_priviledge_0_out;
    wire  [1:0]  tlb_priviledge_1_out;
    wire  [1:0] tlb_mat_0_out;
    wire  [1:0] tlb_mat_1_out;
    wire  tlb_global_0_out;
    wire  tlb_global_1_out;
    /* verilator lint_off UNUSED */ //([23:20] is useless)
    wire  [23:0]  tlb_ppn_0_out;
    wire  [23:0]  tlb_ppn_1_out;
    // verilator lint_on UNUSED
    wire  [9:0]  asid_out;
    wire  [31:0]  tid;

    wire  llbit_set;
    wire  llbit_clear_by_eret;
    wire  llbit_clear_by_other;
    wire  llbit;

    wire csr_software_query_en;
    wire [13:0] csr_addr;
    wire [31:0] csr_rdata;
    wire [31:0] csr_wen;
    wire [31:0] csr_wdata;
    wire [5:0] csr_ecode;

`ifdef CLAP_CONFIG_DIFFTEST
    wire [31:0] csr_crmd_diff     ;
    wire [31:0] csr_prmd_diff     ;
    wire [31:0] csr_ectl_diff     ;
    wire [31:0] csr_estat_diff    ;
    wire [31:0] csr_era_diff      ;
    wire [31:0] csr_badv_diff     ;
    wire [31:0] csr_eentry_diff   ;
    wire [31:0] csr_tlbidx_diff   ;
    wire [31:0] csr_tlbehi_diff   ;
    wire [31:0] csr_tlbelo0_diff  ;
    wire [31:0] csr_tlbelo1_diff  ;
    wire [31:0] csr_asid_diff     ;
    wire [31:0] csr_pgdl_diff     ;
    wire [31:0] csr_pgdh_diff     ;
    wire [31:0] csr_save0_diff    ;
    wire [31:0] csr_save1_diff    ;
    wire [31:0] csr_save2_diff    ;
    wire [31:0] csr_save3_diff    ;
    wire [31:0] csr_tid_diff      ;
    wire [31:0] csr_tcfg_diff     ;
    wire [31:0] csr_tval_diff     ;
    wire [31:0] csr_ticlr_diff    ;
    wire [31:0] csr_llbctl_diff   ;
    wire [31:0] csr_tlbrentry_diff;
    wire [31:0] csr_dmw0_diff     ;
    wire [31:0] csr_dmw1_diff     ;
    wire [63:0] rf_stable_counter ;
    wire [63:0] ex_stable_counter ;
`endif

    csr  #(
        .TLBIDX_WIDTH(TLBIDX_WIDTH)
    )
    the_csr (
        .clk                     ( clk                    ),
        .stable_clk              ( aclk                   ),
        .rstn                    ( aresetn                ),

        .privilege               ( privilege              ),
        .ecode                   ( csr_ecode              ),

        //software query port (exe stage)
        .software_query_en       ( csr_software_query_en  ),
        .addr                    ( csr_addr               ),
        .rdata                   ( csr_rdata              ),
        .wen                     ( csr_wen                ),
        .wdata                   ( csr_wdata              ),

        //exception
        .store_state             ( csr_store_state        ),
        .restore_state           ( csr_restore_state      ),
        .back_to_direct_translate( csr_back_to_direct_translate ),
        .expcode_in              ( csr_expcode_in         ),
        .expcode_wen             ( csr_expcode_wen        ),
        .exp_vppn_in             ( csr_exp_vppn_in        ),
        .exp_vppn_we             ( csr_exp_vppn_we        ),
        .era_out                 ( csr_era_out            ),
        .era_in                  ( csr_era_in             ),
        .era_wen                 ( csr_era_wen            ),
        .badv_in                 ( csr_badv_in            ),
        .badv_wen                ( csr_badv_wen           ),
        .eentry                  ( csr_eentry             ),
        .tlbrentry               ( csr_tlbrentry          ),
        .pgd_base_in             ( csr_pgd_in             ),
        .pgd_base_wen            ( csr_pgd_wen            ),
        .pgdl_base_out           ( pgdl_out               ),
        .pgdh_base_out           ( pgdh_out               ),

        //interrupt
        .hardware_int            ( intrpt                 ),
        .has_interrupt_cpu       ( has_interrupt_cpu      ),
        .has_interrupt_idle      ( has_interrupt_idle     ),

        //MMU
        .translate_mode          ( translate_mode         ),
        .direct_i_mat            ( direct_i_mat           ),
        .direct_d_mat            ( direct_d_mat           ),

        .dmw0_plv0               ( dmw0_plv0              ),
        .dmw0_plv3               ( dmw0_plv3              ),
        .dmw0_mat                ( dmw0_mat               ),
        .dmw0_vseg               ( dmw0_vseg              ),
        .dmw0_pseg               ( dmw0_pseg              ),
        .dmw1_plv0               ( dmw1_plv0              ),
        .dmw1_plv3               ( dmw1_plv3              ),
        .dmw1_mat                ( dmw1_mat               ),
        .dmw1_vseg               ( dmw1_vseg              ),
        .dmw1_pseg               ( dmw1_pseg              ),

        .tlb_index_out           ( tlb_index_out          ),
        .tlb_ps_out              ( tlb_ps_out             ),
        .tlb_ne_out              ( tlb_ne_out             ),
        .tlb_vppn_out            ( tlb_vppn_out           ),
        .tlb_valid_0_out         ( tlb_valid_0_out        ),
        .tlb_valid_1_out         ( tlb_valid_1_out        ),
        .tlb_dirty_0_out         ( tlb_dirty_0_out        ),
        .tlb_dirty_1_out         ( tlb_dirty_1_out        ),
        .tlb_priviledge_0_out    ( tlb_priviledge_0_out   ),
        .tlb_priviledge_1_out    ( tlb_priviledge_1_out   ),
        .tlb_mat_0_out           ( tlb_mat_0_out          ),
        .tlb_mat_1_out           ( tlb_mat_1_out          ),
        .tlb_global_0_out        ( tlb_global_0_out       ),
        .tlb_global_1_out        ( tlb_global_1_out       ),
        .tlb_ppn_0_out           ( tlb_ppn_0_out          ),
        .tlb_ppn_1_out           ( tlb_ppn_1_out          ),

        .asid_out                ( asid_out               ),
        .asid_in                 ( asid_in                ),
        .asid_wen                ( asid_wen               ),

        .tlb_index_in            ( tlb_index_in           ),
        .tlb_index_we            ( tlb_index_we           ),
        .tlb_ps_in               ( tlb_ps_in              ),
        .tlb_ps_we               ( tlb_ps_we              ),
        .tlb_ne_in               ( tlb_ne_in              ),
        .tlb_ne_we               ( tlb_ne_we              ),
        .tlb_vppn_in             ( tlb_vppn_in            ),
        .tlb_vppn_we             ( tlb_vppn_we            ),
        .tlb_valid_0_in          ( tlb_valid_0_in         ),
        .tlb_valid_1_in          ( tlb_valid_1_in         ),
        .tlb_valid_0_wen         ( tlb_valid_0_wen        ),
        .tlb_valid_1_wen         ( tlb_valid_1_wen        ),
        .tlb_dirty_0_in          ( tlb_dirty_0_in         ),
        .tlb_dirty_1_in          ( tlb_dirty_1_in         ),
        .tlb_dirty_0_wen         ( tlb_dirty_0_wen        ),
        .tlb_dirty_1_wen         ( tlb_dirty_1_wen        ),
        .tlb_priviledge_0_in     ( tlb_priviledge_0_in    ),
        .tlb_priviledge_1_in     ( tlb_priviledge_1_in    ),
        .tlb_priviledge_0_wen    ( tlb_priviledge_0_wen   ),
        .tlb_priviledge_1_wen    ( tlb_priviledge_1_wen   ),
        .tlb_mat_0_in            ( tlb_mat_0_in           ),
        .tlb_mat_1_in            ( tlb_mat_1_in           ),
        .tlb_mat_0_wen           ( tlb_mat_0_wen          ),
        .tlb_mat_1_wen           ( tlb_mat_1_wen          ),
        .tlb_global_0_in         ( tlb_global_0_in        ),
        .tlb_global_1_in         ( tlb_global_1_in        ),
        .tlb_global_0_wen        ( tlb_global_0_wen       ),
        .tlb_global_1_wen        ( tlb_global_1_wen       ),
        .tlb_ppn_0_in            ( tlb_ppn_0_in           ),
        .tlb_ppn_1_in            ( tlb_ppn_1_in           ),
        .tlb_ppn_0_wen           ( tlb_ppn_0_wen          ),
        .tlb_ppn_1_wen           ( tlb_ppn_1_wen          ),
        
        //ll bit
        .llbit                   ( llbit                  ),
        .llbit_set               ( llbit_set              ),
        .llbit_clear_by_eret     ( llbit_clear_by_eret    ),
        .llbit_clear_by_other    ( llbit_clear_by_other   ),
        
        //timer
        .tid                     ( tid                    )

        `ifdef CLAP_CONFIG_DIFFTEST
        ,
        .crmd_diff      (csr_crmd_diff     ),
        .prmd_diff      (csr_prmd_diff     ),
        .ectl_diff      (csr_ectl_diff     ),
        .estat_diff     (csr_estat_diff    ),
        .era_diff       (csr_era_diff      ),
        .badv_diff      (csr_badv_diff     ),
        .eentry_diff    (csr_eentry_diff   ),
        .tlbidx_diff    (csr_tlbidx_diff   ),
        .tlbehi_diff    (csr_tlbehi_diff   ),
        .tlbelo0_diff   (csr_tlbelo0_diff  ),
        .tlbelo1_diff   (csr_tlbelo1_diff  ),
        .asid_diff      (csr_asid_diff     ),
        .pgdl_diff      (csr_pgdl_diff     ),
        .pgdh_diff      (csr_pgdh_diff     ),
        .save0_diff     (csr_save0_diff    ),
        .save1_diff     (csr_save1_diff    ),
        .save2_diff     (csr_save2_diff    ),
        .save3_diff     (csr_save3_diff    ),
        .tid_diff       (csr_tid_diff      ),
        .tcfg_diff      (csr_tcfg_diff     ),
        .tval_diff      (csr_tval_diff     ),
        .ticlr_diff     (csr_ticlr_diff    ),
        .llbctl_diff    (csr_llbctl_diff   ),
        .tlbrentry_diff (csr_tlbrentry_diff),
        .dmw0_diff      (csr_dmw0_diff     ),
        .dmw1_diff      (csr_dmw1_diff     )
        `endif
    );

    wire if_buf_full;
    wire icache_ready;
    wire pc_stall_n=icache_ready & ~if_buf_full;
    
    reg [31:0] pc;
    wire [31:0] pc_next;
    wire set_pc_by_decoder,set_pc_by_executer,set_pc_by_writeback;
    wire [31:0] pc_decoder,pc_executer,pc_writeback,ex_pc_tar;
    always @(posedge clk) begin
        if(~aresetn)
            //龙芯架构32位精简版参考手册 v1.00 p. 53
            pc <= 32'h1C000000;
        else if(set_pc_by_writeback)
            pc <= pc_writeback;
        else if(set_pc_by_executer)
            pc <= pc_executer;
        else if(set_pc_by_decoder)
            pc <= pc_decoder;
        else if(pc_stall_n)
            pc <= pc_next;
    end
    
    wire id_feedback_valid;
    wire [31:0] id_pc_for_predict,ex_branch_pc;
    wire [31:0] id_jmpdist0,id_jmpdist1;
    wire [1:0] id_category0,id_category1,ex_br_category;
    wire ex_feedback_valid,ex_did_jump;
    wire pred_known0,pred_known1;
    wire [31:0] pred_record0,pred_record1;
    wire pd_branch,pd_reason;
    // reg id_feedback_valid_reg;
    // reg [31:0] id_pc_for_predict_reg;
    // reg [31:0] id_jmpdist0_reg,id_jmpdist1_reg;
    // reg [1:0] id_category0_reg,id_category1_reg;
    // always @(posedge clk)
    //     if(~aresetn) begin
    //         id_feedback_valid_reg<=0;
    //         id_pc_for_predict_reg<=0;
    //         id_jmpdist0_reg<=0;
    //         id_jmpdist1_reg<=0;
    //         id_category0_reg<=0;
    //         id_category1_reg<=0;
    //     end
    //     else begin
    //         id_feedback_valid_reg <= id_feedback_valid;
    //         id_pc_for_predict_reg <= id_pc_for_predict;
    //         id_jmpdist0_reg <= id_jmpdist0;
    //         id_jmpdist1_reg <= id_jmpdist1;
    //         id_category0_reg <= id_category0;
    //         id_category1_reg <= id_category1;
    //     end
    wire ex_branch_unknown;
    branch_unit the_branch_predict
    (
        .clk(clk),.rstn(aresetn),

        .ifVld(pc_stall_n),.ifPC(pc),

        .idVld(id_feedback_valid),
        .idPC(id_pc_for_predict),
        .idPCTar1(id_jmpdist0), .idPCTar2(id_jmpdist1),
        .idType1(id_category0), .idType2(id_category1),
        
        .exVld(ex_feedback_valid),
        .exPC(ex_branch_pc),
        .exPCTar(ex_pc_tar),
        .exType(ex_br_category),
        .exBranch(ex_did_jump),
        .exWrong(set_pc_by_executer),
        .exKnown(~ex_branch_unknown),

        .pdPC(pc_next),
        .pdKnown1(pred_known0),.pdKnown2(pred_known1),
        .pdAddrType1(pred_record0),.pdAddrType2(pred_record1),
        .pdBranch(pd_branch),
        .pdReason(pd_reason)
    );

    wire [1:0] ex_mem_cacop_code;
    wire ex_mem_l1i_en,ex_mem_l1d_en;
    /* verilator lint_off UNUSED */ //(useless because L2 cache is not implemented)
    wire ex_mem_l2_en;
    // verilator lint_on UNUSED
    wire ex_mem_l1i_ready,ex_mem_l1d_ready,ex_mem_l2_ready;
    wire ex_mem_l1i_complete,ex_mem_l1d_complete,ex_mem_l2_complete;
    wire [31:0] ex_mem_cacop_rj_plus_imm;
    wire use_tlb_s0_by_exe,use_tlb_s1_by_exe;

    wire [1:0] itlb_mat,dtlb_mat;

    wire data_valid_qt4WxiD7aL7;
    wire [63:0] r_data_CPU;
    wire [31:0] if_pc_qt4WxiD7aL7,if_pc_next_qt4WxiD7aL7;
    wire [31:0] p_pc;
    wire if_known0_qt4WxiD7aL7,if_known1_qt4WxiD7aL7;
    wire [31:0] if_pred_record0_qt4WxiD7aL7,if_pred_record1_qt4WxiD7aL7;
    wire first_inst_jmp_qt4WxiD7aL7;
    wire [6:0] if_exception_qt4WxiD7aL7;
    wire [31:0] if_badv_qt4WxiD7aL7;
    icache #(99) the_icache (
        .clk            (clk),
        .rstn           (aresetn),
        .flush          (set_pc_by_decoder|set_pc_by_executer|set_pc_by_writeback),
        .valid          (~if_buf_full&~clear_clock_gate_require),
        .uncache        (translate_mode[0]&&direct_i_mat==0 || translate_mode[1]&&itlb_mat==0),
        .pc_in          (ex_mem_l1i_en?ex_mem_cacop_rj_plus_imm:pc),
        .p_addr         (p_pc),
        .cookie_in      ({pred_record0,pred_record1,pd_branch&~pd_reason,pred_known0,pred_known1,pc_next}),
        .cookie_out     ({if_pred_record0_qt4WxiD7aL7,if_pred_record1_qt4WxiD7aL7,first_inst_jmp_qt4WxiD7aL7,if_known0_qt4WxiD7aL7,if_known1_qt4WxiD7aL7,if_pc_next_qt4WxiD7aL7}),
        .data_valid     (data_valid_qt4WxiD7aL7),
        .r_data_CPU     (r_data_CPU),
        .pc_out         (if_pc_qt4WxiD7aL7),
        .cache_ready    (icache_ready),
        .exception      (if_exception_qt4WxiD7aL7),
        .badv           (if_badv_qt4WxiD7aL7),
        .r_length       (i_axi_arlen),
        
        .r_req          (i_axi_arvalid),
        .r_addr         (i_axi_araddr),
        .r_rdy          (i_axi_arready),
        .ret_valid      (i_axi_rvalid),
        .ret_last       (i_axi_rlast),
        .r_data_ready   (i_axi_rready),
        .r_data_AXI     (i_axi_rdata),

        .cacop_en       (ex_mem_l1i_en),
        .cacop_code     (ex_mem_cacop_code),
        .cacop_ready    (ex_mem_l1i_ready),
        .cacop_complete (ex_mem_l1i_complete),

        .tlb_exception  (itlb_exp)    
    );
    
    assign i_axi_awid = 0;
    assign i_axi_awaddr = 0;
    assign i_axi_awlen = 0;
    assign i_axi_awsize = 0;
    assign i_axi_awburst = 2'b01;
    assign i_axi_awlock = 0;
    assign i_axi_awcache = 0;
    assign i_axi_awprot = 0;
    assign i_axi_awvalid = 0;
    assign i_axi_wdata = 0;
    assign i_axi_wstrb = 0;
    assign i_axi_wlast = 0;
    assign i_axi_wvalid = 0;
    assign i_axi_bid = 0;
    assign i_axi_bready = 0;
    assign i_axi_bresp = 0;
    assign i_axi_arid = 0;
    assign i_axi_arburst = 2'b01;
    //assign i_axi_arlen = 8'd15;
    assign i_axi_arsize = 3'b010;
    assign i_axi_arlock = 0;
    assign i_axi_arcache = 0;
    assign i_axi_arprot = 3'b100;

    wire [31:0] if_inst0,if_inst1;
    wire data_valid;
    wire [31:0] if_pc,if_pc_next;
    wire if_known0,if_known1;
    wire [31:0] if_pred_record0,if_pred_record1;
    wire first_inst_jmp;
    wire [6:0] if_exception;
    wire [31:0] if_badv;
    
    wire [1:0] id_read_en;
    wire [`WIDTH_UOP-1:0] id_uop0,id_uop1;
    wire [31:0] id_imm0,id_imm1;
    wire [4:0] id_rd0,id_rd1,id_rk0,id_rk1,id_rj0,id_rj1;
    wire [6:0] id_exception0,id_exception1;
    wire [31:0] id_badv0,id_badv1;
    wire [31:0] id_pc0,id_pc1,id_pc_next0,id_pc_next1;
    wire id_unknown0,id_unknown1;

    decode_unit_input_reg duir
    (
        .clk(clk),
        .rstn(aresetn),
        .flush(set_pc_by_decoder||set_pc_by_executer||set_pc_by_writeback),
        
        .input_valid_in(data_valid_qt4WxiD7aL7),
        .inst0_in(r_data_CPU[31:0]),
        .inst1_in(r_data_CPU[63:32]),
        .known0_in(if_known0_qt4WxiD7aL7),
        .known1_in(if_known1_qt4WxiD7aL7),
        .pred_record0_in(if_pred_record0_qt4WxiD7aL7),
        .pred_record1_in(if_pred_record1_qt4WxiD7aL7),
        .first_inst_jmp_in(first_inst_jmp_qt4WxiD7aL7),
        .exception_in(if_exception_qt4WxiD7aL7),
        .badv_in(if_badv_qt4WxiD7aL7),
        .pc_in(if_pc_qt4WxiD7aL7),
        .pc_next_in(if_pc_next_qt4WxiD7aL7),

        .input_valid_out(data_valid),
        .inst0_out(if_inst0),
        .inst1_out(if_inst1),
        .known0_out(if_known0),
        .known1_out(if_known1),
        .pred_record0_out(if_pred_record0),
        .pred_record1_out(if_pred_record1),
        .first_inst_jmp_out(first_inst_jmp),
        .exception_out(if_exception),
        .badv_out(if_badv),
        .pc_out(if_pc),
        .pc_next_out(if_pc_next)
    );
    
    id_stage the_decoder (
        .clk(clk), .rstn(aresetn),
        .flush(set_pc_by_executer||set_pc_by_writeback),
        .read_en(id_read_en),
        .full(if_buf_full),
        .plv(privilege),

        .input_valid(data_valid),
        .inst0(if_inst0),
        .inst1(if_inst1),
        .first_inst_jmp(first_inst_jmp),
        
        .uop0(id_uop0),.uop1(id_uop1),
        .imm0(id_imm0),.imm1(id_imm1),
        .rd0(id_rd0),.rd1(id_rd1),
        .rk0(id_rk0),.rk1(id_rk1),
        .rj0(id_rj0),.rj1(id_rj1),
        
        .pc_in(if_pc),.pc_next_in(if_pc_next),
        .pc0_out(id_pc0),.pc1_out(id_pc1),
        .pc_next0_out(id_pc_next0),.pc_next1_out(id_pc_next1),
        .exception_in(if_exception),
        .badv_in(if_badv),
        .exception0_out(id_exception0),.exception1_out(id_exception1),
        .badv0_out(id_badv0),.badv1_out(id_badv1),
        .pred_record0(if_pred_record0),.pred_record1(if_pred_record1),
        .unknown0_in(~if_known0),.unknown1_in(~if_known1),
        .unknown0_out(id_unknown0),.unknown1_out(id_unknown1),
       
        .feedback_valid(id_feedback_valid),
        .pc_for_predict(id_pc_for_predict),
        .jmpdist0(id_jmpdist0),.jmpdist1(id_jmpdist1),
        .category0(id_category0),.category1(id_category1),

        .probably_right_destination(pc_decoder),
        .set_pc(set_pc_by_decoder)
    );
    wire [0:0] ex_stall;
    wire [0:0] ex_stall3;
    wire [0:0] ex_stall4;
    wire is_eu0_en_3qW1U3J0hMn,is_eu1_en_3qW1U3J0hMn;
    wire [`WIDTH_UOP-1:0] is_eu0_uop_3qW1U3J0hMn,is_eu1_uop_3qW1U3J0hMn;
    wire [4:0] is_eu0_rd_3qW1U3J0hMn,is_eu0_rj_3qW1U3J0hMn,is_eu0_rk_3qW1U3J0hMn;
    wire [4:0] is_eu1_rd_3qW1U3J0hMn,is_eu1_rj_3qW1U3J0hMn,is_eu1_rk_3qW1U3J0hMn;
    wire [31:0] is_eu0_imm_3qW1U3J0hMn,is_eu1_imm_3qW1U3J0hMn;
    wire [31:0] is_eu0_pc_3qW1U3J0hMn,is_eu0_pc_next_3qW1U3J0hMn;
    wire [31:0] is_eu1_pc_3qW1U3J0hMn,is_eu1_pc_next_3qW1U3J0hMn;
    wire [6:0] is_eu0_exception_3qW1U3J0hMn,is_eu1_exception_3qW1U3J0hMn;
    wire [31:0] is_eu0_badv_3qW1U3J0hMn,is_eu1_badv_3qW1U3J0hMn;
    wire is_eu0_unknown_3qW1U3J0hMn,is_eu1_unknown_3qW1U3J0hMn;
    wire [0:0]stall_by_conflict;
 
    assign ex_stall = ex_stall3||ex_stall4;
    is_stage the_issue (
        // .clk(clk),.rstn(aresetn),
        .num_read(id_read_en),
        // .flush(set_pc_by_executer||set_pc_by_writeback),
        
        .uop0(id_uop0),.uop1(id_uop1),
        .rd0(id_rd0),.rd1(id_rd1),.rk0(id_rk0),.rk1(id_rk1),.rj0(id_rj0),.rj1(id_rj1),
        .imm0(id_imm0),.imm1(id_imm1),
        .exception0(id_exception0),.exception1(id_exception1),
        .badv0(id_badv0),.badv1(id_badv1),
        .unknown0(id_unknown0),.unknown1(id_unknown1),
        .pc0(id_pc0),.pc1(id_pc1),
        .pc_next0(id_pc_next0),.pc_next1(id_pc_next1),
        .has_interrupt(has_interrupt_cpu),
        
        .eu0_en(is_eu0_en_3qW1U3J0hMn),
        .eu0_ready(~(ex_stall||stall_by_conflict)),
        .eu0_uop(is_eu0_uop_3qW1U3J0hMn),
        .eu0_rd(is_eu0_rd_3qW1U3J0hMn),
        .eu0_rj(is_eu0_rj_3qW1U3J0hMn),
        .eu0_rk(is_eu0_rk_3qW1U3J0hMn),
        .eu0_imm(is_eu0_imm_3qW1U3J0hMn),
        .eu0_pc(is_eu0_pc_3qW1U3J0hMn),
        .eu0_pc_next(is_eu0_pc_next_3qW1U3J0hMn),
        .eu0_exception(is_eu0_exception_3qW1U3J0hMn),
        .eu0_badv(is_eu0_badv_3qW1U3J0hMn),
        .eu0_unknown(is_eu0_unknown_3qW1U3J0hMn),
        
        .eu1_en(is_eu1_en_3qW1U3J0hMn),
        .eu1_ready(~(ex_stall||stall_by_conflict)),
        .eu1_uop(is_eu1_uop_3qW1U3J0hMn),
        .eu1_rd(is_eu1_rd_3qW1U3J0hMn),
        .eu1_rj(is_eu1_rj_3qW1U3J0hMn),
        .eu1_rk(is_eu1_rk_3qW1U3J0hMn),
        .eu1_imm(is_eu1_imm_3qW1U3J0hMn),
        .eu1_pc(is_eu1_pc_3qW1U3J0hMn),
        .eu1_pc_next(is_eu1_pc_next_3qW1U3J0hMn),
        .eu1_exception(is_eu1_exception_3qW1U3J0hMn),
        .eu1_badv(is_eu1_badv_3qW1U3J0hMn),
        .eu1_unknown(is_eu1_unknown_3qW1U3J0hMn)
    );

    wire is_eu0_en,is_eu1_en;
    wire [`WIDTH_UOP-1:0] is_eu0_uop,is_eu1_uop;
    wire [4:0] is_eu0_rd,is_eu0_rj,is_eu0_rk;
    wire [4:0] is_eu1_rd,is_eu1_rj,is_eu1_rk;
    wire [31:0] is_eu0_imm,is_eu1_imm;
    wire [31:0] is_eu0_pc,is_eu0_pc_next;
    wire [31:0] is_eu1_pc,is_eu1_pc_next;
    wire [6:0] is_eu0_exception,is_eu1_exception;
    wire [31:0] is_eu0_badv,is_eu1_badv;
    wire is_eu0_unknown,is_eu1_unknown;

    execute_unit_input_reg euir0
    (
        .clk(clk),.rstn(aresetn),.flush(set_pc_by_executer||set_pc_by_writeback),.stall(ex_stall||stall_by_conflict),
        
        .en_in(is_eu0_en_3qW1U3J0hMn),.en_out(is_eu0_en),
        .uop_in(is_eu0_uop_3qW1U3J0hMn),.uop_out(is_eu0_uop),
        .rd_in(is_eu0_rd_3qW1U3J0hMn),.rd_out(is_eu0_rd),
        .rj_in(is_eu0_rj_3qW1U3J0hMn),.rj_out(is_eu0_rj),
        .rk_in(is_eu0_rk_3qW1U3J0hMn),.rk_out(is_eu0_rk),
        .imm_in(is_eu0_imm_3qW1U3J0hMn),.imm_out(is_eu0_imm),
        .pc_in(is_eu0_pc_3qW1U3J0hMn),.pc_out(is_eu0_pc),
        .pc_next_in(is_eu0_pc_next_3qW1U3J0hMn),.pc_next_out(is_eu0_pc_next),
        .exception_in(is_eu0_exception_3qW1U3J0hMn),.exception_out(is_eu0_exception),
        .badv_in(is_eu0_badv_3qW1U3J0hMn),.badv_out(is_eu0_badv),
        .unknown_in(is_eu0_unknown_3qW1U3J0hMn),.unknown_out(is_eu0_unknown)
    );

    execute_unit_input_reg euir1
    (
        .clk(clk),.rstn(aresetn),.flush(set_pc_by_executer||set_pc_by_writeback),.stall(ex_stall||stall_by_conflict),
        
        .en_in(is_eu1_en_3qW1U3J0hMn),.en_out(is_eu1_en),
        .uop_in(is_eu1_uop_3qW1U3J0hMn),.uop_out(is_eu1_uop),
        .rd_in(is_eu1_rd_3qW1U3J0hMn),.rd_out(is_eu1_rd),
        .rj_in(is_eu1_rj_3qW1U3J0hMn),.rj_out(is_eu1_rj),
        .rk_in(is_eu1_rk_3qW1U3J0hMn),.rk_out(is_eu1_rk),
        .imm_in(is_eu1_imm_3qW1U3J0hMn),.imm_out(is_eu1_imm),
        .pc_in(is_eu1_pc_3qW1U3J0hMn),.pc_out(is_eu1_pc),
        .pc_next_in(is_eu1_pc_next_3qW1U3J0hMn),.pc_next_out(is_eu1_pc_next),
        .exception_in(is_eu1_exception_3qW1U3J0hMn),.exception_out(is_eu1_exception),
        .badv_in(is_eu1_badv_3qW1U3J0hMn),.badv_out(is_eu1_badv),
        .unknown_in(is_eu1_unknown_3qW1U3J0hMn),.unknown_out(is_eu1_unknown)
    );

    reg [63:0] stable_counter;
    always @(posedge aclk)
        if(~aresetn) stable_counter<=0;
        else stable_counter <= stable_counter+1;
    
    wire  [0:0]  rf_eu0_en,rf_eu1_en;
    wire  [`WIDTH_UOP-1:0]  rf_eu0_uop,rf_eu1_uop;
    wire  [4:0]  rf_eu0_rd,rf_eu1_rd;
    wire  [4:0]  rf_eu0_rj,rf_eu1_rj;
    wire  [4:0]  rf_eu0_rk,rf_eu1_rk;
    wire  [31:0]  rf_eu0_pc,rf_eu1_pc;
    wire  [31:0]  rf_eu0_pc_next;
    wire  [6:0]  rf_eu0_exp;
    wire  [31:0]  rf_eu0_read_dataj, rf_eu1_read_dataj;
    wire  [31:0]  rf_eu0_read_datak, rf_eu1_read_datak;
    wire  [31:0]  rf_eu0_imm, rf_eu1_imm;
    wire  [31:0]  rf_eu0_badv;
    wire rf_eu0_unknown;

    /* verilator lint_off UNUSED */ //(useless, reserved for future optimization)
    wire  [31:0] rf_eu1_pc_next;
    wire  [6:0]  rf_eu1_exp;
    wire  [31:0]  rf_eu1_badv;
    wire rf_eu1_unknown;
    // verilator lint_on UNUSED

    wire rf_wen0;
    wire rf_wen1;
    wire [4:0]rf_waddr0;
    wire [4:0]rf_waddr1;
    wire [31:0]rf_wdata0;
    wire [31:0]rf_wdata1;

    `ifdef CLAP_CONFIG_DIFFTEST
    wire [31:0] reg_diff[31:0];
    `endif

    register_file  the_register (
        .clk                     ( clk               ),
        .rstn                    ( aresetn           ),
        .stall                   ( ex_stall          ),
        .flush                   ( set_pc_by_executer||set_pc_by_writeback ),
        .stall_by_conflict       ( stall_by_conflict ),
        
        .stable_counter(stable_counter),
        .counter_id(tid),
        .eu0_en_in     (is_eu0_en     ), .eu1_en_in     (is_eu1_en     ),
        .eu0_uop_in    (is_eu0_uop    ), .eu1_uop_in    (is_eu1_uop    ),
        .eu0_rd_in     (is_eu0_rd     ), .eu1_rd_in     (is_eu1_rd     ),
        .eu0_rj_in     (is_eu0_rj     ), .eu1_rj_in     (is_eu1_rj     ),
        .eu0_rk_in     (is_eu0_rk     ), .eu1_rk_in     (is_eu1_rk     ),
        .eu0_pc_in     (is_eu0_pc     ), .eu1_pc_in     (is_eu1_pc     ),
        .eu0_pc_next_in(is_eu0_pc_next), .eu1_pc_next_in(is_eu1_pc_next),
        .eu0_exp_in    (is_eu0_exception),.eu1_exp_in   (is_eu1_exception),
        .eu0_imm_in    (is_eu0_imm    ), .eu1_imm_in    (is_eu1_imm    ),
        .eu0_badv_in   (is_eu0_badv),    .eu1_badv_in   (is_eu1_badv),
        .eu0_unknown_in(is_eu0_unknown), .eu1_unknown_in(is_eu1_unknown),

        .eu0_en_out     (rf_eu0_en        ), .eu1_en_out     (rf_eu1_en        ),
        .eu0_uop_out    (rf_eu0_uop       ), .eu1_uop_out    (rf_eu1_uop       ),
        .eu0_rd_out     (rf_eu0_rd        ), .eu1_rd_out     (rf_eu1_rd        ),
        .eu0_rj_out     (rf_eu0_rj        ), .eu1_rj_out     (rf_eu1_rj        ),
        .eu0_rk_out     (rf_eu0_rk        ), .eu1_rk_out     (rf_eu1_rk        ),
        .eu0_pc_out     (rf_eu0_pc        ), .eu1_pc_out     (rf_eu1_pc        ),
        .eu0_pc_next_out(rf_eu0_pc_next   ), .eu1_pc_next_out(rf_eu1_pc_next   ),
        .eu0_exp_out    (rf_eu0_exp       ), .eu1_exp_out    (rf_eu1_exp       ),
        .read_data00    (rf_eu0_read_dataj), .read_data10    (rf_eu1_read_dataj),
        .read_data01    (rf_eu0_read_datak), .read_data11    (rf_eu1_read_datak),
        .eu0_imm_out    (rf_eu0_imm       ), .eu1_imm_out    (rf_eu1_imm),
        .eu0_badv_out   (rf_eu0_badv),       .eu1_badv_out   (rf_eu1_badv),
        .eu0_unknown_out(rf_eu0_unknown),    .eu1_unknown_out(rf_eu1_unknown),

        .write_en_0   (rf_wen0  ),
        .write_en_1   (rf_wen1  ),
        .write_addr_0 (rf_waddr0),
        .write_addr_1 (rf_waddr1),
        .write_data_0 (rf_wdata0),
        .write_data_1 (rf_wdata1)

        `ifdef CLAP_CONFIG_DIFFTEST
        , .reg_diff(reg_diff),
        . stable_counter_diff(rf_stable_counter)
        `endif
    );

    wire  ex_eu0_en, ex_eu1_en;
    wire  [31:0]  ex_eu0_data,ex_eu1_data;
    wire  [4:0]  ex_eu0_rd,ex_eu1_rd;
    wire  [6:0] ex_eu0_exp;
    wire  [31:0] ex_eu0_badv;
    wire  [31:0] ex_eu0_pc,ex_eu1_pc;
    wire  [31:0] ex_eu0_inst,ex_eu1_inst;
    
    wire  ex_mem_valid;
    wire  [0:0]  ex_mem_op;
    wire  [ 31:0 ]  ex_mem_addr, ex_mem_paddr;
    wire  [0:0]  ex_signed_ext;
    wire  [ 3:0 ]  ex_mem_write_type;
    wire  [ 31:0 ]  ex_mem_w_data_CPU,ex_mem_r_data_CPU;
    wire ex_mem_data_valid;
    wire [31:0] ex_mem_badv;
    wire [6:0] ex_mem_exception;
    wire ex_mem_dcache_ready;
    wire fill_mode, check_mode, tlb_we, tlb_other_we;
    wire [9:0] clear_asid;
    wire [31:0] clear_vaddr;
    wire[2:0] clear_mem;
    wire[0:0]ex_is_atom;
    wire[31:0] tlb_fill_index;
    wire [31:0] vaddr_diff;
    wire [31:0] paddr_diff;
    wire [31:0] data_diff;
    wire [31:0] ex_vaddr_diff;
    wire [31:0] ex_paddr_diff;
    wire [31:0] ex_data_diff;

    exe the_exe(
        .clk           (clk           ),
        .rstn          (aresetn       ),
        .flush_by_writeback(set_pc_by_writeback),
        .eu0_en_in     (rf_eu0_en     ), .eu1_en_in (rf_eu1_en ),
        .eu0_uop_in    (rf_eu0_uop    ), .eu1_uop_in(rf_eu1_uop),
        .eu0_rd_in     (rf_eu0_rd     ), .eu1_rd_in (rf_eu1_rd ),
        .eu0_rj_in     (rf_eu0_rj     ), .eu1_rj_in (rf_eu1_rj ),
        .eu0_rk_in     (rf_eu0_rk     ), .eu1_rk_in (rf_eu1_rk ),
        .eu0_imm_in    (rf_eu0_imm     ),.eu1_imm_in(rf_eu1_imm),
        .eu0_pc_in     (rf_eu0_pc     ), .eu1_pc_in(rf_eu1_pc),
        .eu0_pc_next_in(rf_eu0_pc_next),
        .eu0_exp_in    (rf_eu0_exp    ), //.eu1_exp_in    ( rf_eu1_exp    ),
        .eu0_badv_in   (rf_eu0_badv   ), //.eu1_badv_in   ( rf_eu1_badv   ),
        .eu0_unknown_in(rf_eu0_unknown), //.eu1_unknown_in( rf_eu1_unknown),
        .data00        (rf_eu0_read_dataj), .data10(rf_eu1_read_dataj),
        .data01        (rf_eu0_read_datak), .data11(rf_eu1_read_datak),

        `ifdef CLAP_CONFIG_DIFFTEST
        .stable_counter_diff_in(rf_stable_counter),
        .stable_counter_diff_out(ex_stable_counter),
        `endif
        
        .en_out0  (ex_eu0_en  ), .en_out1  (ex_eu1_en  ),
        .data_out0(ex_eu0_data), .data_out1(ex_eu1_data),
        .addr_out0(ex_eu0_rd  ), .addr_out1(ex_eu1_rd  ),
        .exp_out  (ex_eu0_exp ), //.exp_out  (ex_eu1_exp ),
        .badv_out (ex_eu0_badv), //.badv_out (ex_eu1_badv),
        .eu0_pc_out(ex_eu0_pc),  .eu1_pc_out(ex_eu1_pc),
        .eu0_inst(ex_eu0_inst),  .eu1_inst(ex_eu1_inst),

        .stall3                  ( ex_stall3              ),
        .stall4                  ( ex_stall4              ),
        .flush                   ( set_pc_by_executer    ),
        .branch_status           ( ex_did_jump ),
        .branch_valid            ( ex_feedback_valid ),
        .branch_pc               ( ex_branch_pc ),
        .branch_unknown          ( ex_branch_unknown),
        .category_out            ( ex_br_category ),
        .correct_pc_next         ( pc_executer   ),
        .ex_pc_tar               ( ex_pc_tar),

        .valid                   ( ex_mem_valid                    ),
        .op                      ( ex_mem_op                       ),
        .addr                    ( ex_mem_addr ),
        .signed_ext              ( ex_signed_ext ),
        .write_type              ( ex_mem_write_type               ),
        .w_data_CPU              ( ex_mem_w_data_CPU               ),
        .data_valid              ( ex_mem_data_valid ),
        .r_data_CPU              ( ex_mem_r_data_CPU ),
        .dcache_badv             ( ex_mem_badv ),
        .icache_badv             ( if_badv_qt4WxiD7aL7 ),
        .dcache_exception        ( ex_mem_exception ),
        .icache_exception        ( if_exception_qt4WxiD7aL7 ),
        .is_atom_out             ( ex_is_atom ),
        .dcache_ready            ( ex_mem_dcache_ready ),
        .icache_ready            ( icache_ready ),

        .csr_software_query_en(csr_software_query_en),
        .csr_addr   (csr_addr),
        .csr_rdata  (csr_rdata),
        .csr_wen    (csr_wen),
        .csr_wdata  (csr_wdata),

        .era(csr_era_out),
        .restore_state(csr_restore_state),
        .llbit_clear_by_eret(llbit_clear_by_eret),

        .cacop_code(ex_mem_cacop_code),
        .l1i_en(ex_mem_l1i_en),
        .l1i_ready(ex_mem_l1i_ready),
        .l1i_complete(ex_mem_l1i_complete),
        .l1d_en(ex_mem_l1d_en),
        .l1d_ready(ex_mem_l1d_ready),
        .l1d_complete(ex_mem_l1d_complete),
        .l2_en(ex_mem_l2_en),
        .l2_ready(ex_mem_l2_ready),
        .l2_complete(ex_mem_l2_complete),
        .cacop_rj_plus_imm(ex_mem_cacop_rj_plus_imm),
        .use_tlb_s0(use_tlb_s0_by_exe),
        .use_tlb_s1(use_tlb_s1_by_exe),

        .fill_mode              (fill_mode),
        .check_mode             (check_mode),
        .tlb_we                 (tlb_we),
        .tlb_index_we           (tlb_index_we),
        .tlb_e_we               (tlb_ne_we),
        .tlb_other_we           (tlb_other_we),
        .clear_vaddr            (clear_vaddr),
        .clear_asid             (clear_asid),
        .clear_mem              (clear_mem),
        .fill_index             (tlb_fill_index),

        .clear_clock_gate_require(clear_clock_gate_require),
        .clear_clock_gate(clear_clock_gate),

        .vaddr_diff_in(vaddr_diff),
        .paddr_diff_in(paddr_diff),
        .data_diff_in(data_diff),
        .vaddr_diff_out(ex_vaddr_diff),
        .paddr_diff_out(ex_paddr_diff),
        .data_diff_out(ex_data_diff)
    );
    assign tlb_ps_we = tlb_other_we;
    assign tlb_vppn_we = tlb_other_we;
    assign tlb_valid_0_wen = tlb_other_we;
    assign tlb_valid_1_wen = tlb_other_we;
    assign tlb_dirty_0_wen = tlb_other_we;
    assign tlb_dirty_1_wen = tlb_other_we;
    assign tlb_priviledge_0_wen = tlb_other_we;
    assign tlb_priviledge_1_wen =tlb_other_we;
    assign tlb_mat_0_wen = tlb_other_we;
    assign tlb_mat_1_wen = tlb_other_we;
    assign tlb_global_0_wen = tlb_other_we;
    assign tlb_global_1_wen = tlb_other_we;
    assign tlb_ppn_0_wen = tlb_other_we;
    assign tlb_ppn_1_wen = tlb_other_we;
    assign asid_wen = tlb_other_we;
    dcache the_dcache
    (
        .clk            (clk),
        .rstn           (aresetn),
        .valid          (ex_mem_valid&~clear_clock_gate_require),
        .cache_ready    (ex_mem_dcache_ready),
        .op             (ex_mem_op),
        .uncache        (translate_mode[0]&&direct_d_mat==0 || translate_mode[1]&&dtlb_mat==0),
        //.uncache        (1'b1),


        .addr           (ex_mem_l1d_en?ex_mem_cacop_rj_plus_imm:ex_mem_addr),
        .p_addr         (ex_mem_paddr),
        .signed_ext     (ex_signed_ext),
        .write_type     (ex_mem_write_type),
        .data_valid     (ex_mem_data_valid),
        .r_data_CPU     (ex_mem_r_data_CPU),
        .w_data_CPU     (ex_mem_w_data_CPU),
        .badv           (ex_mem_badv),
        .exception      (ex_mem_exception),

        .r_req          (d_axi_arvalid),
        .r_data_ready   (d_axi_rready),
        .r_addr         (d_axi_araddr),
        .r_size         (d_axi_arsize),
        .r_length       (d_axi_arlen),
        .r_rdy          (d_axi_arready),
        .ret_valid      (d_axi_rvalid),
        .ret_last       (d_axi_rlast),
        .r_data_AXI     (d_axi_rdata),

        .w_req          (d_axi_awvalid),
        .w_data_ready   (d_axi_wready),
        .w_data_req     (d_axi_wvalid),
        .w_last         (d_axi_wlast),
        .b_ready        (d_axi_bready),
        .w_size         (d_axi_awsize),
        .w_length       (d_axi_awlen),
        .w_addr         (d_axi_awaddr),
        .w_strb         (d_axi_wstrb),
        .w_data_AXI     (d_axi_wdata),
        .w_rdy          (d_axi_awready),
        .b_valid        (d_axi_bvalid),

        .cacop_code     (ex_mem_cacop_code),
        .cacop_en       (ex_mem_l1d_en),
        .cacop_ready    (ex_mem_l1d_ready),
        .cacop_complete (ex_mem_l1d_complete),

        .tlb_exception  (dtlb_exp),
        .is_atom        (ex_is_atom),
        .llbit          (llbit),
        .llbit_set      (llbit_set),
        .llbit_clear    (llbit_clear_by_other),

        .vaddr_diff     (vaddr_diff),
        .paddr_diff     (paddr_diff),
        .data_diff      (data_diff)
    );
    wire tlb_e_in;
    wire tlb_g_in;

    assign tlb_global_0_in = tlb_g_in;
    assign tlb_global_1_in = tlb_g_in;
    assign tlb_ne_in = ~tlb_e_in;
    assign tlb_ppn_0_in[23:20] = 0;
    assign tlb_ppn_1_in[23:20] = 0;

    TLB the_tlb(
        .clk            (clk),
        .rstn           (aresetn),
        .ad_mode        (translate_mode),

        .s0_vaddr       (use_tlb_s0_by_exe?ex_mem_cacop_rj_plus_imm:pc),
        .s0_paddr       (p_pc),
        .s0_asid        (asid_out),
        .s0_plv         (privilege),
        .s0_mem_type    (use_tlb_s0_by_exe?0:2),
        .s0_en          (!if_buf_full&&translate_mode[1] || use_tlb_s0_by_exe),
        .s0_exception   (itlb_exp),
        .s0_mat         (itlb_mat),

        .s1_vaddr       (use_tlb_s1_by_exe?ex_mem_cacop_rj_plus_imm:ex_mem_addr),
        .s1_paddr       (ex_mem_paddr),
        .s1_asid        (asid_out),
        .s1_plv         (privilege),
        .s1_mem_type    (use_tlb_s1_by_exe?0:{1'b0, ex_mem_op}),
        .s1_en          (ex_mem_valid&&translate_mode[1] || use_tlb_s1_by_exe),
        .s1_exception   (dtlb_exp),
        .s1_mat         (dtlb_mat),


        //CSR.TLBINDEX
        .r_index        (tlb_index_out),
        .w_index        (tlb_index_out),
        .r_ps           (tlb_ps_in),
        .w_ps           (tlb_ps_out),
        .rs_e           (tlb_e_in),
        .w_e            (csr_ecode==6'h3F ? 1'b1:~tlb_ne_out),

        //CSR.TLBEHI
        .r_vpn2         (tlb_vppn_in),
        .w_vpn2         (tlb_vppn_out),

        //CSR.TLBLO0
        .r_v0           (tlb_valid_0_in),
        .w_v0           (tlb_valid_0_out),
        .r_d0           (tlb_dirty_0_in),
        .w_d0           (tlb_dirty_0_out),
        .r_plv0         (tlb_priviledge_0_in),
        .w_plv0         (tlb_priviledge_0_out),
        .r_mat0         (tlb_mat_0_in),
        .w_mat0         (tlb_mat_0_out),
        .r_g            (tlb_g_in),
        .w_g            (tlb_global_0_out & tlb_global_1_out),
        .r_pfn0         (tlb_ppn_0_in[19:0]),
        .w_pfn0         (tlb_ppn_0_out[19:0]),

        //CSR.TLBO1
        .r_v1           (tlb_valid_1_in),
        .w_v1           (tlb_valid_1_out),
        .r_d1           (tlb_dirty_1_in),
        .w_d1           (tlb_dirty_1_out),
        .r_plv1         (tlb_priviledge_1_in),
        .w_plv1         (tlb_priviledge_1_out),
        .r_mat1         (tlb_mat_1_in),
        .w_mat1         (tlb_mat_1_out),
        .r_pfn1         (tlb_ppn_1_in[19:0]),
        .w_pfn1         (tlb_ppn_1_out[19:0]),  

        //CSR.ASID      
        .r_asid         (asid_in),
        .w_asid         (asid_out),  

        
        .f_index        (tlb_fill_index[TLBIDX_WIDTH-1:0]),
        .s_vpn2         (tlb_vppn_out),
        .s_index        (tlb_index_in),
        .s_asid         (asid_out),
        .we             (tlb_we),

        .fill_mode      (fill_mode),
        .check_mode     (check_mode),

        .clear_mem      (clear_mem),
        .clear_vaddr    (clear_vaddr),
        .clear_asid     (clear_asid),

        .dmw0_plv0      (dmw0_plv0),
        .dmw0_plv3      (dmw0_plv3),
        .dmw0_mat       (dmw0_mat ),
        .dmw0_vseg      (dmw0_vseg),
        .dmw0_pseg      (dmw0_pseg),
        .dmw1_plv0      (dmw1_plv0),
        .dmw1_plv3      (dmw1_plv3),
        .dmw1_mat       (dmw1_mat ),
        .dmw1_vseg      (dmw1_vseg),
        .dmw1_pseg      (dmw1_pseg)
    );

    assign d_axi_awid = 1;
    //assign d_axi_awlen = 8'd15;
    //assign d_axi_awsize = 3'b010;
    assign d_axi_awburst = 2'b01;
    assign d_axi_awlock = 0;
    assign d_axi_awcache = 0;
    assign d_axi_awprot = 0;
    assign d_axi_bid = 1;
    assign d_axi_bresp = 0;
    assign d_axi_arid = 1;
    //assign d_axi_arlen = 8'd15;
    assign d_axi_arburst = 2'b01;
    //assign d_axi_arsize = 3'b010;
    assign d_axi_arlock = 0;
    assign d_axi_arcache = 0;
    assign d_axi_arprot = 0;

    writeback the_writeback
    (
        //to run difftest, one instruction cannot be written back for multiple times
        .eu0_valid(ex_eu0_en),
        .eu1_valid(ex_eu1_en),
        .eu0_data(ex_eu0_data),.eu1_data(ex_eu1_data),
        .eu0_rd(ex_eu0_rd),    .eu1_rd(ex_eu1_rd),
        .eu0_pc(ex_eu0_pc),    .eu1_pc(ex_eu1_pc),
        .eu0_inst(ex_eu0_inst),.eu1_inst(ex_eu1_inst),
        .eu0_exception(ex_eu0_exp),
        .eu0_badv(ex_eu0_badv),

        .wen0(rf_wen0),.wen1(rf_wen1),
        .waddr0(rf_waddr0),.waddr1(rf_waddr1),
        .wdata0(rf_wdata0),.wdata1(rf_wdata1),

        .debug0_wb_pc(debug0_wb_pc),
        .debug0_wb_rf_wen(debug0_wb_rf_wen),
        .debug0_wb_rf_wnum(debug0_wb_rf_wnum),
        .debug0_wb_rf_wdata(debug0_wb_rf_wdata),
        .debug0_wb_inst(debug0_wb_inst),

        .debug1_wb_pc(debug1_wb_pc),
        .debug1_wb_rf_wen(debug1_wb_rf_wen),
        .debug1_wb_rf_wnum(debug1_wb_rf_wnum),
        .debug1_wb_rf_wdata(debug1_wb_rf_wdata),
        .debug1_wb_inst(debug1_wb_inst),

        .set_pc(set_pc_by_writeback),
        .pc(pc_writeback),

        .eentry(csr_eentry),
        .tlbrentry(csr_tlbrentry),
        .era(csr_era_in),
        .era_wen(csr_era_wen),
        .store_state(csr_store_state),
        .back_to_direct_translate(csr_back_to_direct_translate),
        .vppn(csr_exp_vppn_in),
        .vppn_we(csr_exp_vppn_we),
        .expcode_out(csr_expcode_in),
        .expcode_wen(csr_expcode_wen),
        .badv(csr_badv_in),
        .badv_wen(csr_badv_wen),
        .pgdl(pgdl_out),
        .pgdh(pgdh_out),
        .pgd(csr_pgd_in),
        .pgd_wen(csr_pgd_wen)
    );

    //L2 cache is not implemented
    assign ex_mem_l2_ready = 1;
    assign ex_mem_l2_complete = 1;

`ifdef CLAP_CONFIG_DIFFTEST
    reg cmt_valid0,cmt_valid1;
    reg [31:0] cmt_pc0,cmt_pc1;
    reg [31:0] cmt_inst0,cmt_inst1;
    reg [31:0] cmt_wen0,cmt_wen1;
    reg [4:0] cmt_wdest0,cmt_wdest1;
    reg [31:0] cmt_wdata0,cmt_wdata1;
    reg cmt_excp_valid;
    reg [5:0] cmt_ecode;
    reg [63:0] cmt_stable_counter;
    reg [TLBIDX_WIDTH-1:0] fill_index_diff;
    reg [31:0]cmt_vaddr_diff;
    reg [31:0]cmt_paddr_diff;
    reg [31:0]cmt_data_diff;
    always @(posedge clk)
        if(fill_mode&&tlb_we)
            fill_index_diff<=tlb_fill_index;

    always @(posedge aclk)
        if(~aresetn) begin
            {cmt_valid0,cmt_valid1,cmt_pc0,cmt_pc1,cmt_inst0,cmt_inst1,cmt_wen0,cmt_wen1,cmt_wdest0,
            cmt_wdest1,cmt_wdata0,cmt_wdata1,cmt_excp_valid,cmt_ecode,cmt_vaddr_diff,cmt_paddr_diff,cmt_data_diff}<=0;
        end else begin
            //防止出现eu0不提交但eu1提交
            cmt_stable_counter <= ex_stable_counter;
            if(ex_eu0_en==0&&ex_eu1_en!=0) begin
                cmt_valid0  <= ex_eu1_en;
                cmt_pc0     <= debug1_wb_pc;
                cmt_inst0   <= debug1_wb_inst;
                cmt_wen0    <= debug1_wb_rf_wen!=0;
                cmt_wdest0  <= debug1_wb_rf_wnum;
                cmt_wdata0  <= debug1_wb_rf_wdata;
                cmt_excp_valid<=0;
                cmt_ecode   <= 0;
                cmt_valid1  <= 0;
            end else begin
                //有异常时不置valid
                cmt_valid0  <= ex_eu0_en&&!set_pc_by_writeback;
                cmt_pc0     <= debug0_wb_pc;
                cmt_inst0   <= debug0_wb_inst;
                cmt_wen0    <= debug0_wb_rf_wen!=0;
                cmt_wdest0  <= debug0_wb_rf_wnum;
                cmt_wdata0  <= debug0_wb_rf_wdata;
                cmt_excp_valid<=set_pc_by_writeback;
                cmt_ecode   <= csr_expcode_in[5:0];

                cmt_valid1  <= ex_eu1_en&&!set_pc_by_writeback;
                cmt_pc1     <= debug1_wb_pc;
                cmt_inst1   <= debug1_wb_inst;
                cmt_wen1    <= debug1_wb_rf_wen!=0;
                cmt_wdest1  <= debug1_wb_rf_wnum;
                cmt_wdata1  <= debug1_wb_rf_wdata;
                cmt_vaddr_diff<=ex_vaddr_diff;
                cmt_paddr_diff<=ex_paddr_diff;
                cmt_data_diff<=ex_data_diff;
            end
        end

    DifftestInstrCommit DifftestInstrCommit0
    (
        .clock(aclk),
        .coreid(0),
        .index(0),
        .valid(cmt_valid0),
        .pc({32'd0,cmt_pc0}),
        .instr(cmt_inst0),
        .skip(0),
        .is_TLBFILL(cmt_inst0[31:10]=='b0000011001001000001101),
        .TLBFILL_index(fill_index_diff),
        .is_CNTinst(cmt_inst0[31:11]=='b000000000000000001100),
        .timer_64_value(cmt_stable_counter),
        .wen(cmt_wen0),
        .wdest({3'd0,cmt_wdest0}),
        .wdata({32'd0,cmt_wdata0}),
        .csr_rstat(0),
        .csr_data(0)
    );

    DifftestInstrCommit DifftestInstrCommit1
    (
        .clock(aclk),
        .coreid(0),
        .index(1),
        .valid(cmt_valid1),
        .pc({32'd0,cmt_pc1}),
        .instr(cmt_inst1),
        .skip(0),
        .is_TLBFILL(0),
        .TLBFILL_index(0),
        .is_CNTinst(cmt_inst1[31:11]=='b000000000000000001100),
        .timer_64_value(cmt_stable_counter),
        .wen(cmt_wen1),
        .wdest({3'd0,cmt_wdest1}),
        .wdata({32'd0,cmt_wdata1}),
        .csr_rstat(0),
        .csr_data(0)
    );

    DifftestExcpEvent DifftestExcpEvent
    (
        .clock(aclk),
        .coreid(0),
        .excp_valid(cmt_excp_valid),
        .eret(cmt_inst0=='b00000110010010000011100000000000),
        .intrNo(csr_estat_diff[12:2]),
        .cause(cmt_ecode),
        .exceptionPC({32'd0,cmt_pc0}),
        .exceptionInst(cmt_inst0)
    );

    DifftestTrapEvent DifftestTrapEvent
    (
        .clock(aclk),
        .coreid(0),
        .valid(0),
        .code(0),
        .pc(0),
        .cycleCnt(0),
        .instrCnt(0)
    );
    
    wire [31:0]cmt_data_diff_trimmed;
    assign cmt_data_diff_trimmed=cmt_inst0[31:22] == 10'b0010100100 ?
                                (cmt_paddr_diff[1:0]==0 ?
                                    ({24'b0,cmt_data_diff[7:0]}):
                                    (cmt_paddr_diff[1:0]==1 ?
                                        ({16'b0,cmt_data_diff[7:0],8'b0}):
                                        (cmt_paddr_diff[1:0]==2 ?
                                            ({8'b0,cmt_data_diff[7:0],16'b0}):
                                            ({cmt_data_diff[7:0],24'b0})))):
                                (cmt_inst0[31:22] == 10'b0010100101 ?
                                    (cmt_paddr_diff[1]==0 ?
                                        ({16'b0,cmt_data_diff[15:0]}):
                                        ({cmt_paddr_diff[15:0],16'b0})):
                                    (cmt_data_diff));
    
    // always @(*) begin
    //     case (cmt_inst0[31:22])
    //         10'b0010100100:begin
    //         case (cmt_paddr_diff[1:0])
    //             0: cmt_data_diff_trimmed=
    //             1:cmt_data_diff_trimmed=
    //             2:cmt_data_diff_trimmed=
    //             3: cmt_data_diff_trimmed=
    //         endcase
    //         end
    //         10'b0010100101:begin
    //           case (cmt_paddr_diff[1:0])
    //             0: 
    //             2:
    //         endcase
    //         end 
    //     endcase
    // end
    DifftestStoreEvent DifftestStoreEvent
    (
        .clock(aclk),
        .coreid(0),
        .index(0),
        //.valid({4'b0, csr_llbctl_diff && (cmt_inst0[31:24] == 8'b00100001), cmt_inst0[31:22] == 10'b0010100110, 
               // cmt_inst0[31:22] == 10'b0010100101, cmt_inst0[31:22] == 10'b0010100100}),
        // .storePAddr(cmt_paddr_diff),
        // .storeVAddr(cmt_vaddr_diff),
        // .storeData(  cmt_data_diff_trimmed)
        .valid(0),
        .storePAddr(0),
        .storeVAddr(0),
        .storeData(0)
    );

    DifftestLoadEvent DifftestLoadEvent
    (
        .clock(aclk),
        .coreid(0),
        .index(0),
        .valid({2'b0, cmt_inst0[31:24] == 8'b00100000, cmt_inst0[31:22] == 10'b0010100010, 
                cmt_inst0[31:22] == 10'b0010101001, cmt_inst0[31:22] == 10'b0010100001,
                cmt_inst0[31:22] == 10'b0010101000, cmt_inst0[31:22] == 10'b0010100000}),
        .paddr(cmt_paddr_diff),
        .vaddr(cmt_vaddr_diff)
        // .valid(0),
        // .paddr(0),
        // .vaddr(0)
    );

    DifftestGRegState DifftestGRegState(
        .clock              (aclk       ),
        .coreid             (0          ),
        .gpr_0              (0          ),
        .gpr_1              (reg_diff[1]    ),
        .gpr_2              (reg_diff[2]    ),
        .gpr_3              (reg_diff[3]    ),
        .gpr_4              (reg_diff[4]    ),
        .gpr_5              (reg_diff[5]    ),
        .gpr_6              (reg_diff[6]    ),
        .gpr_7              (reg_diff[7]    ),
        .gpr_8              (reg_diff[8]    ),
        .gpr_9              (reg_diff[9]    ),
        .gpr_10             (reg_diff[10]   ),
        .gpr_11             (reg_diff[11]   ),
        .gpr_12             (reg_diff[12]   ),
        .gpr_13             (reg_diff[13]   ),
        .gpr_14             (reg_diff[14]   ),
        .gpr_15             (reg_diff[15]   ),
        .gpr_16             (reg_diff[16]   ),
        .gpr_17             (reg_diff[17]   ),
        .gpr_18             (reg_diff[18]   ),
        .gpr_19             (reg_diff[19]   ),
        .gpr_20             (reg_diff[20]   ),
        .gpr_21             (reg_diff[21]   ),
        .gpr_22             (reg_diff[22]   ),
        .gpr_23             (reg_diff[23]   ),
        .gpr_24             (reg_diff[24]   ),
        .gpr_25             (reg_diff[25]   ),
        .gpr_26             (reg_diff[26]   ),
        .gpr_27             (reg_diff[27]   ),
        .gpr_28             (reg_diff[28]   ),
        .gpr_29             (reg_diff[29]   ),
        .gpr_30             (reg_diff[30]   ),
        .gpr_31             (reg_diff[31]   )
    );

    DifftestCSRRegState DifftestCSRRegState(
        .clock              (aclk             ),
        .coreid             (0                ),
        .crmd               (csr_crmd_diff    ),
        .prmd               (csr_prmd_diff    ),
        .euen               (0                ),
        .ecfg               (csr_ectl_diff    ),
        .estat              (csr_estat_diff   ),
        .era                (csr_era_diff     ),
        .badv               (csr_badv_diff    ),
        .eentry             (csr_eentry_diff  ),
        .tlbidx             (csr_tlbidx_diff  ),
        .tlbehi             (csr_tlbehi_diff  ),
        .tlbelo0            (csr_tlbelo0_diff ),
        .tlbelo1            (csr_tlbelo1_diff ),
        .asid               (csr_asid_diff    ),
        .pgdl               (csr_pgdl_diff    ),
        .pgdh               (csr_pgdh_diff    ),
        .save0              (csr_save0_diff   ),
        .save1              (csr_save1_diff   ),
        .save2              (csr_save2_diff   ),
        .save3              (csr_save3_diff   ),
        .tid                (csr_tid_diff     ),
        .tcfg               (csr_tcfg_diff    ),
        .tval               (csr_tval_diff    ),
        .ticlr              (csr_ticlr_diff   ),
        .llbctl             (csr_llbctl_diff  ),
        .tlbrentry          (csr_tlbrentry_diff),
        .dmw0               (csr_dmw0_diff    ),
        .dmw1               (csr_dmw1_diff    )
    );
`endif //CLAP_CONFIG_DIFFTEST

`ifdef CLAP_CONFIG_INST_PROFILE
    profile_inst_statisic profile_inst_statisic
    (
        .clk(clk),
        .cmt_valid0(ex_eu0_en),
        .cmt_inst0(debug0_wb_inst),
        .cmt_pc0(debug0_wb_pc),
        .cmt_excp0(ex_eu0_exp),
        .cmt_valid1(ex_eu1_en),
        .cmt_inst1(debug1_wb_inst),
        .cmt_excp1(0),
        .cmt_pc1(debug1_wb_pc)
    );
`endif

`ifdef CLAP_CONFIG_BR_PROFILE
    profile_branch profile_branch
    (
        .clk(clk),
        .id_valid(id_feedback_valid&&(id_category0!=0||id_category1!=0)),
        .id_wrong(set_pc_by_decoder),
        .id_pc(id_pc_for_predict),
        .ex_valid(ex_feedback_valid),
        .ex_wrong(set_pc_by_executer),
        .ex_pc(ex_branch_pc)
    );
`endif
endmodule 
