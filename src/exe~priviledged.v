`include "uop.vh"

//执行特权指令
module exe_privliedged(
    input clk,
    input rstn,
    
    input en_in,
    input [31:0] pc_next,
    input is_csr,is_tlb,is_cache,is_idle,is_ertn,
    input [31:0] inst,
    input [31:0] sr0,   //data from rj
    input [31:0] sr1,   //data from rk
    input [4:0] addr_in,
    input [31:0] imm,

    output reg en_out,
    output reg [31:0] pc_target,
    output reg flush,
    output reg stall_because_priv,
    output reg [ 31:0 ] result,
    output reg[ 4:0 ]addr_out,

    //CSR
    output reg csr_software_query_en,
    output reg [13:0] csr_addr,
    input [31:0] csr_rdata,//read first
    output reg [31:0] csr_wen,      //bit write enable
    output reg [31:0] csr_wdata,

    input [31:0] era,
    output reg restore_state,

    //cache

    //tlb
    output reg fill_mode,
    output reg check_mode,
    output reg tlb_we,
    output reg tlb_index_we,
    output reg tlb_e_we,
    output reg tlb_other_we,
    output reg [31:0] clear_vaddr,
    output reg [9:0] clear_asid,
    output reg [2:0] clear_mem
); 
    localparam
        S_INIT      = 9'b000000001,
        S_CSR       = 9'b000000010,
        S_CACOP     = 9'b000000100,
        S_TLB       = 9'b000001000,
        S_IDLE      = 9'b000010000,
        S_ERTN      = 9'b000100000,
        S_DONE_CSR  = 9'b001000000,
        S_DONE_ERTN = 9'b010000000,
        S_DONE_TLB  = 9'b100000000;
    reg [8:0] state,next_state;

    always @(posedge clk)
        if(~rstn) state <= S_INIT;
        else state <= next_state;
    
    always @ * begin
        next_state = state;
        case(state)
        S_INIT: begin
            next_state = 0;
            next_state[$clog2(S_INIT)] = !(en_in&&(is_csr||is_cache||is_tlb||is_idle||is_ertn));
            next_state[$clog2(S_CSR)] = en_in&&is_csr;
            next_state[$clog2(S_CACOP)] = en_in&&is_cache;
            next_state[$clog2(S_TLB)] = en_in&&is_tlb;
            next_state[$clog2(S_IDLE)] = en_in&&is_idle;
            next_state[$clog2(S_ERTN)] = en_in&&is_ertn;
        end
        S_CSR: next_state = S_DONE_CSR;
        S_ERTN: next_state = S_DONE_ERTN;
        S_TLB: next_state = S_DONE_TLB;
        S_DONE_CSR,S_DONE_ERTN,S_DONE_TLB:
            next_state = S_INIT;
        endcase
    end

    always @(posedge clk)
        if(~rstn) begin
            en_out<=0;
            pc_target<=0;
            flush<=0;
            stall_because_priv<=0;
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
        end else case(next_state)
            S_INIT: begin
                en_out<=0;
                flush<=0;
                addr_out<=0;
                result <=0;
            end
            S_CSR: begin
                pc_target<=pc_next;
                stall_because_priv<=1;
                addr_out<=addr_in;
                csr_software_query_en<=1;
                csr_addr<=imm[13:0];
                csr_wen<=inst[9:5]==1 ? 32'hFFFFFFFF:sr0;
                csr_wdata<=sr1;
            end
            S_DONE_CSR: begin
                en_out<=1;
                flush<=1;
                stall_because_priv<=0;
                result<=csr_rdata;
                csr_software_query_en<=0;
            end
            S_TLB: begin
                stall_because_priv<=1;
                pc_target<=pc_next;
                if(inst[16:15] == 2'b00) begin
                    case(inst[12:10])
                    3'b010: begin
                        check_mode <= 1;
                        tlb_index_we <= 1;
                        tlb_e_we <= 1;
                    end
                    3'b011: begin
                        check_mode <= 0;
                        tlb_e_we <= 1;
                        tlb_other_we <= 1;
                    end
                    3'b100: begin
                        fill_mode <= 0;
                        tlb_we <= 1;
                    end
                    3'b101: begin 
                        fill_mode <= 1;
                        tlb_we <= 1;
                    end
                    endcase
                end
                else if(inst[16:15] == 2'b11) begin
                    clear_asid <= sr0;
                    clear_vaddr <= sr1;
                    if(inst[4:0] == 5'd0) clear_mem <= 3'd1;
                    else if(inst[4:0] >= 5'd7) clear_mem <= 3'd7;
                    else clear_mem <= inst[2:0];
                end
            end
            S_ERTN: begin
                pc_target <= era;
                restore_state <= 1;
                stall_because_priv<=1;
            end
            S_DONE_ERTN: begin
                restore_state <= 0;
                en_out<=1;
                flush<=1;
                stall_because_priv<=0;
            end
            S_DONE_TLB: begin
                tlb_we <= 0;
                tlb_e_we <= 0;
                tlb_index_we <= 0;
                tlb_other_we <= 0;
                stall_because_priv<=0;
                flush <= 1;
                clear_mem <= 0;
            end
        endcase
endmodule
