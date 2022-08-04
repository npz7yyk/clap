`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module TLB_out(
    input [1:0] ad_mode,
    input s0_dmw_hit,
    input s1_dmw_hit,
    input s0_dmw_hit_obuf,
    input s1_dmw_hit_obuf,
    input [31:0] s0_addr,
    input [31:0] s1_addr,
    input [1:0] s0_tlb_mat,
    input [1:0] s1_tlb_mat,
    input [1:0] s0_dmw_mat,
    input [1:0] s1_dmw_mat,
    input [31:0] s0_dmw_paddr,
    input [31:0] s1_dmw_paddr,
    input [19:0] s0_pfn,
    input [19:0] s1_pfn,
    input [5:0] found_ps0,
    input [5:0] found_ps1,
    output reg [31:0] s0_paddr,
    output reg [31:0] s1_paddr,
    output reg [1:0] s0_mat,
    output reg [1:0] s1_mat
    );
    parameter DIRECT = 2'b01;
    parameter MAP = 2'b10;
    always @(*) begin
        case(ad_mode)
        DIRECT: begin
            s0_paddr = s0_addr;
            s1_paddr = s1_addr;
        end
        MAP: begin

            if(s0_dmw_hit_obuf) begin
                s0_paddr = s0_dmw_paddr;
            end

            else begin
                case(found_ps0)
                6'd12: s0_paddr = {s0_pfn, s0_addr[11:0]};
                6'd21: s0_paddr = {s0_pfn[19:9], s0_addr[20:0]};
                default: s0_paddr = 0;
                endcase
            end

            if(s1_dmw_hit_obuf) begin
                s1_paddr = s1_dmw_paddr;
            end

            else begin
                case(found_ps1)
                6'd12: s1_paddr = {s1_pfn, s1_addr[11:0]};
                6'd21: s1_paddr = {s1_pfn[19:9], s1_addr[20:0]};
                default: s1_paddr = 0;
                endcase
            end

        end
        default: begin
            s0_paddr = 0;
            s1_paddr = 0;
        end
        endcase
    end

    always @(*) begin
        case(ad_mode)
        DIRECT: begin
            s0_mat = 0;
            s1_mat = 0;
        end
        MAP: begin
            if(s0_dmw_hit) begin
                s0_mat = s0_dmw_mat;
            end
            else begin
                s0_mat = s0_tlb_mat;
            end
            if(s1_dmw_hit) begin
                s1_mat = s1_dmw_mat;
            end
            else begin
                s1_mat = s1_tlb_mat;
            end
        end
        default: begin
            s0_mat = 0;
            s1_mat = 0;
        end
        endcase
    end
endmodule
