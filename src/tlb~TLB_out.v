/* verilator lint_off DECLFILENAME */
module TLB_out(
    input [1:0] ad_mode,
    input s0_dmw_hit,
    input s1_dmw_hit,
    input [31:0] s0_addr,
    input [31:0] s1_addr,
    input [31:0] s0_dmw_paddr,
    input [31:0] s1_dmw_paddr,
    input [19:0] s0_pfn,
    input [19:0] s1_pfn,
    input [5:0] found_ps0,
    input [5:0] found_ps1,
    output reg [31:0] s0_paddr,
    output reg [31:0] s1_paddr
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
            if(s0_dmw_hit) s0_paddr = s0_dmw_paddr;
            else begin
                case(found_ps0)
                6'd12: s0_paddr = {s0_pfn, s0_addr[11:0]};
                6'd22: s0_paddr = {s0_pfn[9:0], s0_addr[21:0]};
                default: s0_paddr = 0;
                endcase
            end
            if(s1_dmw_hit) s1_paddr = s1_dmw_paddr;
            else
                case(found_ps1)
                6'd12: s1_paddr = {s1_pfn, s1_addr[11:0]};
                6'd22: s1_paddr = {s1_pfn[9:0], s1_addr[21:0]};
                default: s1_paddr = 0;
                endcase
            end 
        default: begin
            s0_paddr = 0;
            s1_paddr = 0;
        end
        endcase
    end
endmodule
