`include "clap_config.vh"

`ifdef CLAP_CONFIG_CACHE_PROFILE
module profile_cache
#(
    FILENAME = "../profile_cache.log"
)(
    input clk,
    input icache_valid,
    input [31:0] icache_addr,
    input icache_hit,
    input dcache_valid,
    input [31:0] dcache_addr,
    input dcache_hit
);
    integer fd;
    initial begin
        fd = $fopen(FILENAME,"wb");
    end

    always @(posedge clk) begin
        if(icache_valid) begin
            $fdisplay(fd, "i %h %d",icache_addr,icache_hit);
        end
        if(dcache_addr) begin
            $fdisplay(fd,"d %h %d",dcache_addr,dcache_hit);
        end
        if(icache_valid||dcache_addr)
            $fflush(fd);
    end
endmodule
`endif
