module TLB_out(
    input [1:0] ad_mode,
    input [31:0] s0_addr,
    input [31:0] s1_addr,
    input [19:0] s0_pfn,
    input [19:0] s1_pfn,
    output reg [31:0] s0_paddr,
    output reg [31:0] s1_paddr
    );
    parameter DIRECT = 2'd0;
    parameter PAGE_4KB = 2'd1;
    parameter PAGE_4MB = 2'd2;
    always @(*) begin
        case(ad_mode)
        DIRECT: begin
            s0_paddr = s0_addr;
            s1_paddr = s1_addr;
        end
        PAGE_4KB: begin
            s0_paddr = {s0_pfn, s0_addr[11:0]};
            s1_paddr = {s1_pfn, s1_addr[11:0]};
        end
        PAGE_4MB: begin
            s0_paddr = {s0_pfn[9:0], s0_addr[21:0]};
            s1_paddr = {s1_pfn[9:0], s1_addr[21:0]};
        end
        default: begin
            s0_paddr = 0;
            s1_paddr = 0;
        end
        endcase
    end
endmodule
