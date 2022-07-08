module div(
    input clk,
    input rstn,
    
    input div_en_in,
    input div_op,   
    input div_sign,
    input [ 31:0 ] div_sr0,
    input [ 31:0 ] div_sr1,
    input [ 4:0 ]div_addr_in,

    output div_en_out,
    output stall_because_div,
    output reg [ 31:0 ] div_result,
    output reg[ 4:0 ]div_addr_out
);
    // reg[ 63:0 ] temp_a;
    // reg[ 63:0 ] temp_b;
    // reg[ 5:0 ] i;
    // reg div_op_r;
    // reg done_r;
    // reg sign_a;
    // reg sign_b;
    // //    ------------------------------------------------
    // always @( posedge clk )
    // begin
    //     if ( !rstn ||div_validn ) i      <= 6'd0;
    //     else if ( div_start && i < 6'd34 ) i <= i+1'b1;
    //     else i                           <= 6'd0;
    // end
    // //    ------------------------------------------------
    // always @( posedge clk )
    // begin
    //     if ( !rstn ||div_validn ) done_r <= 1'b0;
    //     else if ( i == 6'd33 ) done_r <= 1'b1;
    //     else if ( i == 6'd34 ) done_r <= 1'b0;
    // end
    // assign div_done = done_r;
    // //    ------------------------------------------------
    // always @ ( posedge clk )
    // begin
    //     if ( !rstn ||div_validn )
    //     begin
    //         temp_a <= 64'h0;
    //         temp_b <= 64'h0;
    //     end
    //     else if ( div_start )
    //     begin
    //         div_from_addr <= div_from_addr_in;
    //         if ( i == 6'd0 )
    //         begin
    //             if ( div_sign == 0 )
    //             begin
    //                 temp_a <= {32'h00000000,div_sr0};
    //                 temp_b <= {div_sr1,32'h00000000};
    //                 sign_a <= 0;
    //                 sign_b <= 0;
    //                 div_op_r<=div_op;
    //             end
    //             else
    //             begin
    //                 if ( div_sr0[ 31 ] )temp_a <= {32'h00000000,~div_sr0+1};
    //                 else temp_a          <= {32'h0,div_sr0};
    //                 if ( div_sr1[ 31 ] )temp_b <= {~div_sr1+1,32'h0};
    //                 else temp_b          <= {div_sr1,32'h00000000};
    //                 sign_a               <= div_sr0[ 31 ];
    //                 sign_b               <= div_sr1[ 31 ];
    //             end
    //         end
    //         else if ( i == 34 )
    //         begin
    //             case ( {sign_a,sign_b} )
    //                 0:
    //                 begin
    //                     temp_a[ 31:0 ]  <= temp_a[ 31:0 ];
    //                     temp_a[ 63:32 ] <= temp_a[ 63:32 ];
    //                 end
    //                 1:
    //                 begin
    //                     temp_a[ 31:0 ]  <= ~temp_a[ 31:0 ]+1;
    //                     temp_a[ 63:32 ] <= ~temp_a[ 63:32 ]+1;
    //                 end
    //                 2:
    //                 begin
    //                     temp_a[ 31:0 ]  <= ~temp_a[ 31:0 ]+1;
    //                     temp_a[ 63:32 ] <= temp_a[ 63:32 ];
    //                 end
    //                 3:
    //                 begin
    //                     temp_a[ 31:0 ]  <= temp_a[ 31:0 ];
    //                     temp_a[ 63:32 ] <= ~temp_a[ 63:32 ]+1;
    //                 end
    //             endcase
    //         end
    //         else
    //         begin
    //             temp_a        = {temp_a[ 63:1 ],1'b0};
    //             if ( temp_a >= temp_b ) temp_a = temp_a - temp_b + 1'b1;
    //             else temp_a   = temp_a;
    //         end
    //     end
    //         end
            
    //         assign qoucient = temp_a[ 31:0 ];
    //         assign remains  = temp_a[ 63:32 ];
    //         always @(posedge clk) begin
    //             if(div_op_r)
    //                 div_result<=qoucient;
    //                 else
    //                 div_result<=remains;
    //         end
            
endmodule
