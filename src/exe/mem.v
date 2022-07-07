module mem (
    input clk,
    input rstn,
    //从exe1段输入
    input[ 31:0 ]memory_sr,
    input[ 31:0 ]memory_imm,
    input [ 1:0 ]memory_op_0,
    //向exe2后输出
    output reg memory_cache_lack,
    output reg [ 31:0 ]memory_result,
    //向cache输出
    output reg valid,                 //    valid request
    output reg op,                    //    write: 1, read: 0
    output reg[ 5:0 ] index,          //    virtual addr[ 11:4 ]
    output reg[ 19:0 ] tag,           //    physical addr[ 31:12 ]
    output reg[ 5:0 ] offset,         //    bank offset:[ 3:2 ], byte offset[ 1:0 ]
    output reg[ 3:0 ] write_type,     //    byte write enable
    output reg[ 31:0 ] w_data_CPU,    //    write data
    //从cache输入
    input addr_valid,                 //    read: addr has been accepted; write: addr and data have been accepted
    input data_valid,                 //    read: data has returned; write: data has been written in
    input [ 31:0 ] r_data_CPU         //    read data to CPU
);

    parameter  LDB  = 0;
    parameter  LDH  = 1;
    parameter  LDW  = 2;
    parameter  LDBU = 3;
    parameter  LDHU = 4;
    parameter  STB  = 5;
    parameter  STH  = 6;
    parameter  STW  = 7;
    
    reg [ 2:0 ]memory_op_1;
    reg [ 5:0 ]memory_addr_1;
    reg memory_chosen_1;

    always @( posedge clk ) begin
        if ( !rstn )begin
            valid <= 0;
        end else if ( memory_validn )begin
            valid              <= 1;
            {tag,index,offset} <= memory_sr+memory_imm;
            if ( memory_op_0 == LDB||memory_op_0 == LDH||memory_op_0 == LDW||memory_op_0 == LDBU||memory_op_0 == LDHU )begin
                op              <= 0;
                memory_op_1     <= memory_op_0;
                memory_addr_1   <= memory_addr_1;
                memory_chosen_1 <= memory_to_chosen;
            end else if ( memory_op_0 == STB||memory_op_0 == STH||memory_op_0 == STW )begin
                op         <= 1;
                write_type <= memory_op_0;
            end
        end else begin
            valid <= 0;
        end
    end

    always @( posedge clk ) begin
        if ( addr_valid&&data_valid )begin
            memory_cache_lack <= 0;
            if ( memory_op_1 == LDB||memory_op_1 == LDH||memory_op_1 == LDW||memory_op_1 == LDBU||memory_op_1 == LDHU )begin
                memory_from_addr   <= memory_addr_1;
                memory_from_chosen <= memory_chosen_1;
                case ( memory_op_1 )
                    LDB:begin
                        memory_result <= {23'b0,r_data_CPU[ 7:0 ]};
                    end
                    LDH:begin
                        memory_result <= {15'b0,r_data_CPU[ 15:0 ]};
                    end
                    LDW:begin
                        memory_result <= r_data_CPU;
                    end
                    LDBU:begin
                        memory_result <= {{23{r_data_CPU[ 7 ]}},r_data_CPU[ 7:0 ]};
                    end
                    LDHU:begin
                        memory_result <= {{15{r_data_CPU[ 15 ]}},r_data_CPU[ 7:0 ]};
                    end
                    default: ;
                endcase
            end
            end else begin
            memory_cache_lack <= 1;
        end
    end
endmodule