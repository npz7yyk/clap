module mem0 (
    //从exe1段输入
    input [4:0]mem_rd_in,
    input [31:0]mem_data_in,
    input [ 0:0 ]mem_en_in,
    input [ 31:0 ]mem_sr,
    input [ 31:0 ]mem_imm,
    input [ 0:0 ]mem_write,
    input [ 1:0 ]mem_width_in,
    input [6:0]mem_exp_in,
    input [0:0]mem_sign,
    //向cache输出
    output [0:0] valid,                 //    valid request
    output [0:0] op,                    //    write: 1, read: 0
    output [31:0]addr,
    // output [ 5:0 ] index,               //    virtual addr[ 11:4 ]
    // output [ 19:0 ] tag,                //    physical addr[ 31:12 ]
    // output [ 5:0 ] offset,              //    bank offset:[ 3:2 ], byte offset[ 1:0 ]
    output [ 3:0 ] write_type,          //    byte write enable
    output [ 31:0 ] w_data_CPU,         //    write data
    //向exe1段后输出
    output [6:0]mem_exp_out,
    output [4:0]mem_rd_out,
    output [0:0]mem_en_out,
    output [1:0]mem_width_out,
    output [0:0]signed_ext
);
    assign valid=mem_en_in;
    assign op=mem_write;
    assign addr=mem_sr+mem_imm;
    //assign {tag,index,offset} = mem_sr+mem_imm;
    assign write_type = mem_width_in==00?'b0001:
                        mem_width_in==01?'b0011:
                        mem_width_in==10?'b1111:'b1111;
    assign w_data_CPU=mem_data_in;
    assign mem_width_out=mem_width_in;
    assign mem_en_out=mem_en_in;
    assign mem_exp_out=mem_exp_in;
    assign mem_rd_out=mem_exp_out?mem_rd_in:0;
    assign signed_ext=mem_sign;
endmodule

module mem1 (
    //从exe1段后输入
    input [6:0]mem_exp_in,
    input [4:0]mem_rd_in,
    input [0:0]mem_en_in,
    input [1:0]mem_width_in,
    //从cache输入
    //input addr_valid,                   //    read: addr has been accepted; write: addr and data have been accepted
    input data_valid,                   //    read: data has returned; write: data has been written in
    input [ 31:0 ] r_data_CPU,          //    read data to CPU
    //向exe2后输出
    output [6:0]mem_exp_out,
    output [4:0]mem_rd_out,
    output [31:0]mem_data_out,
    output [0:0]mem_en_out,
    //向全局输出
    output stall_because_cache
);
    assign stall_because_cache=mem_en_in&!data_valid;
    assign mem_exp_out=mem_exp_in;
    //assign mem_data_out =mem_width_in=='b01 ?{24'b0,r_data_CPU[7:0]}:
    //                     mem_width_in=='b10 ?{16'b0,r_data_CPU[15:0]}:
    //                     r_data_CPU[31:0];
    assign mem_data_out=mem_en_out?(data_valid?r_data_CPU:0):0;
    assign mem_rd_out=mem_en_out?mem_rd_in:0;
    assign mem_en_out=mem_en_in;


endmodule
