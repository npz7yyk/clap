module mem (
    input clk,
    input rstn,
    input stall,
    //从exe1段输入
    input [4:0]mem_rd_in,
    input [31:0]mem_data_in,
    input [ 0:0 ]mem_en_in,
    input [ 31:0 ]mem_sr,
    input [ 31:0 ]mem_imm,
    input [ 0:0 ]mem_write,
    input [ 1:0 ]mem_width,
    //向exe2后输出
    output [5:0]mem_exp,
    output [4:0]mem_rd_out,
    output [31:0]mem_data_out,
    output [0:0]mem_en_out,
    output mem_cache_lack,
    //向cache输出
    output [0:0] valid,                 //    valid request
    output [1:0] op,                    //    write: 1, read: 0
    output [ 5:0 ] index,               //    virtual addr[ 11:4 ]
    output [ 19:0 ] tag,                //    physical addr[ 31:12 ]
    output [ 5:0 ] offset,              //    bank offset:[ 3:2 ], byte offset[ 1:0 ]
    output [ 3:0 ] write_type,          //    byte write enable
    output [ 31:0 ] w_data_CPU,         //    write data
    //从cache输入
    input addr_valid,                   //    read: addr has been accepted; write: addr and data have been accepted
    input data_valid,                   //    read: data has returned; write: data has been written in
    input [ 31:0 ] r_data_CPU           //    read data to CPU
);

    reg [1:0]mem_width_mid;
    reg [0:0]mem_en_mid;
    reg [4:0]mem_rd_mid;

    assign valid=mem_en_in;
    assign op=mem_write;
    assign {tag,index,offset} = mem_sr+mem_imm;
    assign write_type = mem_width==00?'b0001:mem_width==10?'b0011:mem_width==11?'b1111:'b1111;
    assign w_data_CPU=mem_data_in;

    always @(posedge clk) begin
        if(!stall)begin
            mem_width_mid<=mem_width;
            mem_en_mid<=mem_en_in;
            mem_rd_mid<=mem_rd_in;
        end
    end
    
    assign mem_exp=addr_valid?0:1;
    assign mem_cache_lack=!mem_exp&data_valid;
    assign mem_data_out =r_data_CPU;
    
endmodule