`include "clap_config.vh"
`include "uop.vh"

//执行特权指令
/* verilator lint_off DECLFILENAME */
module exe_privliedged(
    input clk,
    input rstn,
    input flush_by_writeback,
    
    input en_in,
    input [31:0] pc_next,
    input is_csr,is_tlb,is_cache,is_idle,is_ertn,is_bar,
    input [31:0] inst,
    input [31:0] sr0,   //data from rj
    input [31:0] sr1,   //data from rk
    input [4:0] addr_in,
    input [31:0] imm,

    output reg en_out,
    output reg [31:0] pc_target,
    output reg flush,
    output reg stall_by_priv,
    output reg [31:0] result,
    output reg [4:0] addr_out,
    output reg [6:0] exp_out,
    output reg [31:0] badv_out,

    //CSR
    output reg csr_software_query_en,
    output reg [13:0] csr_addr,
    input [31:0] csr_rdata,//read first
    output reg [31:0] csr_wen,      //bit write enable
    output reg [31:0] csr_wdata,

    //ertn
    input [31:0] era,
    output reg restore_state,
    output reg llbit_clear_by_eret,

    //cache
    output reg [1:0] cacop_code,// code[4:3]
    output reg l1i_en,l1d_en,l2_en,
    input l1i_ready,l1d_ready,l2_ready,
    input l1i_complete,l1d_complete,l2_complete,
    output reg [31:0] cacop_rj_plus_imm,
    output reg use_tlb_s0,use_tlb_s1,
    input [6:0] cacop_dexp_in,
    input [6:0] cacop_iexp_in,
    input [31:0] cacop_dbadv_in,
    input [31:0] cacop_ibadv_in,

    //TLB
    output reg fill_mode,
    output reg check_mode,
    output reg tlb_we,
    output reg tlb_index_we,
    output reg tlb_e_we,
    output reg tlb_other_we,
    output reg [31:0] clear_vaddr,
    output reg [9:0] clear_asid,
    output reg [2:0] clear_mem,
    output reg [31:0] fill_index,

    //IDLE
    //进入
    output reg clear_clock_gate_require,//请求清除clock gate
    output reg clear_clock_gate,        //真正清除clock gate
    input icache_idle,dcache_idle
); 
    reg [31:0] fill_index_next;
    // Xorshift random number generator
    always @* begin
        fill_index_next = fill_index;
        fill_index_next = fill_index_next^(fill_index_next<<13);
        fill_index_next = fill_index_next^(fill_index_next>>17);
        fill_index_next = fill_index_next^(fill_index_next<<5);
    end
    localparam
        S_INIT      = 33'b000000000000000000000000000000001,
        S_CSR       = 33'b000000000000000000000000000000010,
        S_CACOP     = 33'b000000000000000000000000000000100,
        S_TLB       = 33'b000000000000000000000000000001000,
        S_IDLE      = 33'b000000000000000000000000000010000,
        S_ERTN      = 33'b000000000000000000000000000100000,
        S_DONE_CSR  = 33'b000000000000000000000000001000000,
        S_DONE_ERTN = 33'b000000000000000000000000010000000,
        S_DONE_TLB  = 33'b000000000000000000000000100000000,
        S_L1I_REQ   = 33'b000000000000000000000001000000000,
        S_L1D_REQ   = 33'b000000000000000000000010000000000,
        S_L2_REQ    = 33'b000000000000000000000100000000000,
        S_L1I_WAIT  = 33'b000000000000000000001000000000000,
        S_L1D_WAIT  = 33'b000000000000000000010000000000000,
        S_L2_WAIT   = 33'b000000000000000000100000000000000,
        S_DONE_L1I  = 33'b000000000000000001000000000000000,
        S_DONE_L1D  = 33'b000000000000000010000000000000000,
        S_DONE_L2   = 33'b000000000000000100000000000000000,
        S_TLB_SRCH  = 33'b000000000000001000000000000000000,
        S_TLB_RD    = 33'b000000000000010000000000000000000,
        S_TLB_WR    = 33'b000000000000100000000000000000000,
        S_TLB_FILL  = 33'b000000000001000000000000000000000,
        S_INVTLB    = 33'b000000000010000000000000000000000,
        S_DONE_IDLE = 33'b000000000100000000000000000000000,
        S_IDLE_WAIT1= 33'b000000001000000000000000000000000,
        S_IDLE_WAIT2= 33'b000000010000000000000000000000000,
        S_IDLE_PERF = 33'b000000100000000000000000000000000,
        S_IDLE_WAIT3= 33'b000001000000000000000000000000000,
        S_IDLE_WAIT4= 33'b000010000000000000000000000000000,
        S_BAR       = 33'b000100000000000000000000000000000,
        S_BAR_REQ  =  33'b001000000000000000000000000000000,
        S_BAR_WAIT =  33'b010000000000000000000000000000000,
        S_DONE_BAR  = 33'b100000000000000000000000000000000;
    reg [32:0] state,next_state;

    reg [1:0] which_cache;
    reg [0:0] inst_16;
    reg [1:0] inst_11_10;
    reg [4:0] inst_4_0;
    reg [31:0] sr0_save,imm_save;
    reg ibar_en, ibar_reset;

    always @(posedge clk)
        if(~rstn) state <= S_INIT;
        else state <= next_state;
    
    always @ * begin
        next_state = S_INIT;
        case(state)
        S_INIT: begin
            next_state = 0;
            next_state[$clog2(S_INIT)] = !(en_in&&(is_csr||is_cache||is_tlb||is_idle||is_ertn||is_bar));
            next_state[$clog2(S_CSR)] = en_in&&is_csr;
            next_state[$clog2(S_CACOP)] = en_in&&is_cache;
            next_state[$clog2(S_TLB)] = en_in&&is_tlb;
            next_state[$clog2(S_IDLE)] = en_in&&is_idle;
            next_state[$clog2(S_ERTN)] = en_in&&is_ertn;
            next_state[$clog2(S_BAR)] = en_in&&is_bar;
        end
        S_CSR: next_state = S_DONE_CSR;
        S_ERTN: next_state = S_DONE_ERTN;
        S_TLB:
            if(inst_16) begin
                next_state = S_INVTLB;
            end else begin
                case(inst_11_10)
                2'b10: next_state = S_TLB_SRCH;
                2'b11: next_state = S_TLB_RD;
                2'b00: next_state = S_TLB_WR;
                2'b01: next_state = S_TLB_FILL;
                endcase
            end
        S_INVTLB, S_TLB_SRCH, S_TLB_RD, S_TLB_WR, S_TLB_FILL:
            next_state = S_DONE_TLB;
        S_CACOP: begin 
            case(which_cache)
            0: next_state = S_L1I_REQ;
            1: next_state = S_L1D_REQ;
            default: next_state = S_L2_REQ;
            endcase
        end
        S_L1I_REQ :next_state = l1i_ready?(l1i_complete?S_DONE_L1I:S_L1I_WAIT):S_L1I_REQ ;
        S_L1D_REQ :next_state = l1d_ready?(l1d_complete?S_DONE_L1D:S_L1D_WAIT):S_L1D_REQ ;
        S_L2_REQ  :next_state = l2_ready ?(l2_complete ?S_DONE_L2 :S_L2_WAIT ):S_L2_REQ  ;
        S_L1I_WAIT:next_state = l1i_complete? S_DONE_L1I:S_L1I_WAIT;
        S_L1D_WAIT:next_state = l1d_complete? S_DONE_L1D:S_L1D_WAIT;
        S_L2_WAIT :next_state = l2_complete ? S_DONE_L2 :S_L2_WAIT ;
        S_IDLE: next_state = S_IDLE_WAIT1;
        S_IDLE_WAIT1: next_state = S_IDLE_WAIT2;
        S_IDLE_WAIT2: next_state = icache_idle&&dcache_idle? S_IDLE_PERF:S_IDLE_WAIT2;
        S_IDLE_PERF: next_state = S_IDLE_WAIT3;
        S_IDLE_WAIT3: next_state = S_IDLE_WAIT4;
        S_IDLE_WAIT4: next_state = S_DONE_IDLE;
        S_BAR: next_state = S_DONE_BAR;
        S_DONE_CSR,S_DONE_ERTN,S_DONE_TLB,S_DONE_L1I,S_DONE_L1D,S_DONE_L2,S_DONE_IDLE,S_DONE_BAR:
            next_state = S_INIT;
        endcase
    end
    always @(posedge clk)
        if(~rstn)fill_index<=20220803;
        else if(next_state==S_DONE_TLB) fill_index <= fill_index_next;
    always @(posedge clk)
        if(!rstn||flush_by_writeback) begin
            en_out<=0;
            pc_target<=0;
            flush<=0;
            stall_by_priv<=0;
            result<=0;
            addr_out<=0;
            csr_software_query_en<=0;
            csr_addr<=0;
            csr_wen<=0;
            csr_wdata<=0;
            restore_state<=0;
            fill_mode <= 0;
            check_mode <= 0;
            clear_mem <= 0;
            tlb_we <= 0;
            tlb_index_we <= 0;
            tlb_e_we <= 0;
            tlb_other_we <= 0;
            cacop_code <= 0;
            {l1i_en,l1d_en,l2_en} <= 0;
            sr0_save <= 0;
            imm_save <= 0;
            {use_tlb_s0,use_tlb_s1}<= 0;
            exp_out<=0;
            badv_out<=0;
            clear_clock_gate_require<=0;
            clear_clock_gate<=0;
            llbit_clear_by_eret<=0;
        end else case(next_state)
            S_INIT: begin
                en_out<=0;
                flush<=0;
                addr_out<=0;
                result <=0;
                exp_out<=0;
                badv_out<=0;
            end
            S_CSR: begin
                pc_target<=pc_next;
                stall_by_priv<=1;
                addr_out<=addr_in;
                csr_software_query_en<=1;
                csr_addr<=imm[13:0];
                csr_wen<=inst[9:5]==1 ? 32'hFFFFFFFF:sr0;
                csr_wdata<=sr1;
            end
            S_DONE_CSR: begin
                en_out<=1;
                flush<=1;
                stall_by_priv<=0;
                result<=csr_rdata;
                csr_software_query_en<=0;
            end
            S_TLB: begin
                stall_by_priv<=1;
                pc_target<=pc_next;
                inst_16 <= inst[16];
                inst_11_10 <= inst[11:10];
                inst_4_0 <= inst[4:0];
                clear_asid <= sr0[9:0];
                clear_vaddr <= sr1;
            end
            S_TLB_SRCH: begin
                check_mode <= 1;
                tlb_index_we <= 1;
                tlb_e_we <= 1;
            end
            S_TLB_RD: begin
                check_mode <= 0;
                tlb_e_we <= 1;
                tlb_other_we <= 1;
            end
            S_TLB_WR: begin
                fill_mode <= 0;
                tlb_we <= 1;
            end
            S_TLB_FILL: begin
                fill_mode <= 1;
                tlb_we <= 1;
            end
            S_INVTLB: begin
                clear_mem <= inst_4_0==5'd0 ? 3'd1:inst_4_0[2:0];
            end
            S_ERTN: begin
                pc_target <= era;
                restore_state <= 1;
                stall_by_priv<=1;
                llbit_clear_by_eret<=1;
            end
            S_DONE_ERTN: begin
                restore_state <= 0;
                en_out<=1;
                flush<=1;
                llbit_clear_by_eret<=0;
                stall_by_priv<=0;
            end
            S_DONE_TLB: begin
                tlb_we <= 0;
                tlb_e_we <= 0;
                tlb_index_we <= 0;
                tlb_other_we <= 0;
                en_out<=1;
                stall_by_priv<=0;
                flush <= 1;
                clear_mem <= 0;
            end
            S_CACOP: begin
                which_cache <= inst[1:0];
                stall_by_priv<=1;
                pc_target<=pc_next;
                cacop_code <= inst[4:3];
                sr0_save <= sr0;
                imm_save <= imm;
            end
            S_L1I_REQ: begin
                l1i_en <= 1;
                use_tlb_s0 <= 1;
                cacop_rj_plus_imm <= sr0_save+imm_save;
            end
            S_L1I_WAIT: begin
                l1i_en <= 0;
            end
            S_DONE_L1I: begin
                l1i_en <= 0;
                stall_by_priv<=0;
                flush <= 1;
                use_tlb_s0 <= 0;
                en_out<=1;
                exp_out<=cacop_iexp_in;
                badv_out<=cacop_ibadv_in;
            end
            S_L1D_REQ: begin
                l1d_en <= 1;
                use_tlb_s1 <= 1;
                cacop_rj_plus_imm <= sr0_save+imm_save;
            end
            S_L1D_WAIT: begin
                l1d_en <= 0;
            end
            S_DONE_L1D: begin
                l1d_en <= 0;
                stall_by_priv<=0;
                flush <= 1;
                use_tlb_s1 <= 0;
                en_out<=1;
                exp_out<=cacop_dexp_in;
                badv_out<=cacop_dbadv_in;
            end
            S_L2_REQ: begin
                l2_en <= 1;
                cacop_rj_plus_imm <= sr0_save+imm_save;
            end
            S_L2_WAIT: begin
                l2_en <= 0;
            end
            S_DONE_L2: begin
                l2_en <= 0;
                stall_by_priv<=0;
                flush <= 1;
                en_out<=1;
            end
            S_IDLE: begin
                stall_by_priv<=1;
                pc_target<=pc_next;
                clear_clock_gate_require <= 1;
            end
            S_IDLE_WAIT1: begin

            end
            S_IDLE_WAIT2: begin

            end
            S_IDLE_PERF: begin
                clear_clock_gate <= 1;
            end
            S_IDLE_WAIT3: begin
                clear_clock_gate <= 0;
            end
            S_IDLE_WAIT4: begin
            end
            S_DONE_IDLE: begin
                clear_clock_gate_require <= 0;
                clear_clock_gate <= 0;
                stall_by_priv<=0;
                flush <= 1;
                en_out<=1;
            end
            S_BAR: begin
                stall_by_priv<=1;
                pc_target<=pc_next;
            end
            S_DONE_BAR: begin
                stall_by_priv<=0;
                flush <= 1;
                en_out<=1;
            end
        endcase
    // localparam
    //     I_IDLE = 4'b0001,
    //     I_REQ  = 4'b0010,
    //     I_WAIT = 4'b0100,
    //     I_DONE = 4'b1000;
    // localparam
    //     D_IDLE = 4'b0001,
    //     D_REQ  = 4'b0010,
    //     D_WAIT = 4'b0100,
    //     D_DONE = 4'b1000;
    // reg [3:0] i_crt, d_crt;
    // reg [3:0] i_nxt, d_nxt;
    // reg [7:0] 
    // always @(posedge clk) begin
    //     if(!rstn) begin
    //         i_crt <= I_IDLE;
    //         d_crt <= D_IDLE;
    //     end
    //     else begin
    //         i_crt <= i_nxt;
    //         d_crt <= d_nxt;
    //     end
    // end
    // always @(*) begin
    //     case(i_crt) 
    //     I_IDLE: begin
    //         if(ibar_en)     i_nxt = I_REQ;
    //         else            i_nxt = I_IDLE;
    //     end
    //     I_REQ: begin
    //         if(l1i_ready)   i_nxt = I_WAIT;
    //         else            i_nxt = I_REQ;
    //     end
    //     I_WAIT: begin
    //         if(l1i_complete)    i_nxt = I_DONE;
    //         else                i_nxt = I_WAIT;
    //     end
    //     I_DONE: begin
    //         if(ibar_reset)     i_nxt = I_IDLE;
    //         else                i_nxt = I_DONE;
    //     end
    //     endcase
    //     case(d_crt) 
    //     D_IDLE: begin
    //         if(ibar_en)     d_nxt = D_REQ;
    //         else            d_nxt = D_IDLE;
    //     end
    //     D_REQ: begin
    //         if(l1d_ready)   d_nxt = D_WAIT;
    //         else            d_nxt = D_REQ;
    //     end
    //     D_WAIT: begin
    //         if(l1d_complete)    d_nxt = D_DONE;
    //         else                d_nxt = D_WAIT;
    //     end
    //     D_DONE: begin
    //         if(ibar_reset)      d_nxt = D_IDLE;
    //         else                d_nxt = D_DONE;
    //     end
    //     endcase
    // end
    // always @(posedge clk) begin
    //     case(i_crt)
    //     I_REQ: 
    // end

endmodule
