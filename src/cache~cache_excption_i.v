`include "exception.vh"
module cache_excption_i(
    input [31:0] addr_rbuf,
    input cacop_en_rbuf,
    output [6:0] exception
    );
    reg [6:0] exception_temp;
    always @(*) begin
        if(addr_rbuf[1:0]) exception_temp = `EXP_ADEF;
        else exception_temp = 0;
    end
    assign exception = {7{~cacop_en_rbuf}} & exception_temp;
endmodule
