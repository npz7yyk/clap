`include "clap_config.vh"
`include "exception.vh"

/* verilator lint_off DECLFILENAME */
module cache_exception_d(
    input [31:0] addr_rbuf,
    input [3:0] type_,
    input cacop_en_rbuf,
    input is_atom_rbuf,
    input llbit_rbuf,
    input op_rbuf,
    output [6:0] exception
    );
    //parameter BYTE = 4'b0001;
    parameter HALF = 4'b0011;
    parameter WORD = 4'b1111;
    reg [6:0] exception_temp;
    always @(*) begin
        exception_temp = 0;
        case(type_)
        WORD: begin
            if(addr_rbuf[1:0]!=0) exception_temp = `EXP_ALE;
        end
        HALF: begin
            if(addr_rbuf[0]) exception_temp = `EXP_ALE;
        end
        default: exception_temp = 0;
        endcase
    end
    assign exception =  ({7{!(op_rbuf && !llbit_rbuf && is_atom_rbuf)}} | {7{~cacop_en_rbuf}}) & exception_temp;
endmodule
