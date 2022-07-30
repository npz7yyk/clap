`include "clap_config.vh"

module profile_branch
#(
    FILENAME = "../profile_branch.log"
)(
    input clk,
    input id_valid,id_wrong,
    input [31:0] id_pc,
    input ex_valid,ex_wrong,
    input [31:0] ex_pc
);
    integer fd;
    initial begin
        fd = $fopen(FILENAME,"wb");
        $fdisplay(fd, "%m: Simulation begin.");
    end

    always @(posedge clk) begin
        if(id_valid) begin
            $fdisplay(fd, "id %h %d",id_pc,id_wrong);
        end
        if(ex_valid) begin
            $fdisplay(fd,"ex %h %d",ex_pc,ex_wrong);
        end
        if(id_valid||ex_valid)
            $fflush(fd);
    end
endmodule
