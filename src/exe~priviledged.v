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
    output reg restore_state

    //cache

    //tlb
); 
    localparam
        S_INIT      = 8'b00000001,
        S_CSR       = 8'b00000010,
        S_CACOP     = 8'b00000100,
        S_TLB       = 8'b00001000,
        S_IDLE      = 8'b00010000,
        S_ERTN      = 8'b00100000,
        S_DONE_CSR  = 8'b01000000,
        S_DONE_ERTN = 8'b10000000;
    reg [7:0] state,next_state;

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
        S_DONE_CSR,S_DONE_ERTN:
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
        endcase
endmodule
