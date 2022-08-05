`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module main_FSM_d(
    input clk, 
    input rstn,
    // avalid
    input i_avalid,
    input d_avalid,
    // aready
    output reg i_ready,
    output reg d_ready,


    );
    localparam 
        IDLE = 'd0;
        LOOKUP = 'd1;
        MISS   = 'd2;
        REPLACE = 'd3;
        REFILL = 'd4;
        
endmodule
