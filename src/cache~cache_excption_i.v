`include "exception.vh"
module cache_excption_i(
    input [31:0] addr_rbuf,
    output reg [6:0] exception
    );
    always @(*) begin
        if(addr_rbuf[1:0]) exception = `EXP_ADEF;
        else exception = 0;
    end
endmodule
