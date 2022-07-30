`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module mem_wrt_ctrl_d(
    input [31:0] w_data_CPU,
    input [511:0] w_data_AXI,
    input [31:0] addr_rbuf,
    input [3:0] wrt_type,
    input wrt_data_sel,
    output reg [511:0] mem_din,
    output reg [63:0] mem_we_normal,
    output reg [3:0] AXI_we
    );
    parameter BYTE = 4'b0001;
    parameter HALF = 4'b0011;
    parameter WORD = 4'b1111;
    always @(*) begin
        case(wrt_data_sel)
        1'b0: mem_din = w_data_AXI;
        1'b1: begin
            case(wrt_type)
            BYTE: mem_din = {64{w_data_CPU[7:0]}};
            HALF: mem_din = {32{w_data_CPU[15:0]}};
            WORD: mem_din = {16{w_data_CPU}};
            default: mem_din = 0;            
        endcase
        end 
        endcase
    end
    always @(*) begin
        case(addr_rbuf[1:0])
        2'd0: AXI_we = wrt_type;
        2'd1: AXI_we = {wrt_type[2:0], 1'b0};
        2'd2: AXI_we = {wrt_type[1:0], 2'b0};
        2'd3: AXI_we = {wrt_type[0], 3'b0};
        endcase
    end
    always @(*) begin
        case(addr_rbuf[5:2])
        4'h0: mem_we_normal = {60'b0,AXI_we       };
        4'h1: mem_we_normal = {56'b0,AXI_we, 4'b0 };
        4'h2: mem_we_normal = {52'b0,AXI_we, 8'b0 };
        4'h3: mem_we_normal = {48'b0,AXI_we, 12'b0};
        4'h4: mem_we_normal = {44'b0,AXI_we, 16'b0};
        4'h5: mem_we_normal = {40'b0,AXI_we, 20'b0};
        4'h6: mem_we_normal = {36'b0,AXI_we, 24'b0};
        4'h7: mem_we_normal = {32'b0,AXI_we, 28'b0};
        4'h8: mem_we_normal = {28'b0,AXI_we, 32'b0};
        4'h9: mem_we_normal = {24'b0,AXI_we, 36'b0};
        4'ha: mem_we_normal = {20'b0,AXI_we, 40'b0};
        4'hb: mem_we_normal = {16'b0,AXI_we, 44'b0};
        4'hc: mem_we_normal = {12'b0,AXI_we, 48'b0};
        4'hd: mem_we_normal = {8'b0, AXI_we, 52'b0};
        4'he: mem_we_normal = {4'b0, AXI_we, 56'b0};
        4'hf: mem_we_normal = {      AXI_we, 60'b0};
        endcase
    end
endmodule
