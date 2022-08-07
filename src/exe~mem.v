`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module mem0 (
    //从exe0段输入
    input  [4:0]       mem_rd_in,
    input  [31:0]      mem_data_in,
    input  [ 0:0 ]     mem_en_in,
    input  [ 31:0 ]    mem_sr,
    input  [ 31:0 ]    mem_imm,
    input  [ 0:0 ]     mem_write,
    input  [ 1:0 ]     mem_width_in,
    input  [6:0]       mem_exp_in,
    input  [0:0]       mem_sign,
    input  [0:0]       is_atom_in,
    input              is_preload,
    //向cache输出
    output [0:0]       valid,                 //    valid request
    output [0:0]       op,                    //    write: 1, read: 0
    output [31:0]      addr,
    output reg [ 3:0 ] write_type,          //    byte write enable
    output [ 31:0 ]    w_data_CPU,         //    write data
    output [0:0]       is_atom_out,
    //向exe0段后输出
    output [6:0]       mem_exp_out,
    output [4:0]       mem_rd_out,
    output [0:0]       mem_en_out,
    output [0:0]       signed_ext
);
    assign valid = mem_en_in;
    assign op    = mem_write;
    wire [31:0] addr_tmp = mem_sr + mem_imm;
    assign addr  = {addr_tmp[31:3],addr_tmp[2:0]&~{3{is_preload}}};

    always @(*) begin
        case (mem_width_in)
            0:       write_type = 'b0001;
            1:       write_type = 'b0011;
            2:       write_type = 'b1111;
            default: write_type = 'b1111;
        endcase
    end
    assign is_atom_out  = is_atom_in;
    assign w_data_CPU   = mem_data_in;
    assign mem_en_out   = mem_en_in;
    assign mem_exp_out  = mem_exp_in;
    assign mem_rd_out   = mem_en_out?mem_rd_in:0;
    assign signed_ext   = mem_sign;
endmodule

module mem1 (
    //从exe0段后输入
    input [6:0]    mem_exp_in,
    input [4:0]    mem_rd_in,
    input [0:0]    mem_en_in,
    //从cache输入
    //input addr_valid,                  //    read: addr has been accepted; write: addr and data have been accepted
    input [0:0]    data_valid,                   //    read: data has returned; write: data has been written in
    input [ 31:0 ] r_data_CPU,          //    read data to CPU
    input [31:0]   cache_badv_in,
    input [6:0]    cache_exception,
    `ifdef CLAP_CONFIG_DIFFTEST
    input [31:0]vaddr_diff_in,
    input [31:0]paddr_diff_in,
    input [31:0]data_diff_in,
    `endif
    //向exe1后输出
    output [6:0]   mem_exp_out,
    output [4:0]   mem_rd_out,
    output [31:0]  mem_data_out,
    output [0:0]   mem_en_out,
    output [31:0]  cache_badv_out,
    `ifdef CLAP_CONFIG_DIFFTEST
    output [31:0] vaddr_diff_out,
    output [31:0] paddr_diff_out,
    output [31:0] data_diff_out,
    `endif
    //向全局输出
    output [0:0]   stall_by_cache
);

    assign stall_by_cache = mem_en_in&!(data_valid | (|cache_exception));
    assign mem_exp_out         = mem_exp_in|cache_exception;

    assign mem_data_out        = {32{mem_en_out}}&{32{data_valid}}&r_data_CPU;
    assign mem_rd_out          = {5{mem_en_out}}&mem_rd_in;
    assign mem_en_out          = mem_en_in;
    assign cache_badv_out      = {32{mem_en_in}}&cache_badv_in;

`ifdef CLAP_CONFIG_DIFFTEST
assign vaddr_diff_out={32{data_valid}}&vaddr_diff_in;
assign paddr_diff_out={32{data_valid}}&paddr_diff_in;
assign data_diff_out={32{data_valid}}&data_diff_in;
`endif

endmodule
