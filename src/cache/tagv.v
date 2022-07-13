//  Xilinx True Dual Port RAM, Write First with Single Clock
//  This code implements a parameterizable true dual port memory (both ports can read and write).
//  This implements write-first mode where the data being written to the RAM also resides on
//  the output port.  If the output data is not needed during writes or the last read value is
//  desired to be retained, it is suggested to use no change as it is more power efficient.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.

module TagV #(
  parameter RAM_WIDTH = 21,                       // Specify RAM data width
  parameter RAM_DEPTH = 64,                      // Specify RAM depth (number of entries)
  parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
) (
  input [clogb2(RAM_DEPTH-1)-1:0] addra, // Write address bus, width determined from RAM_DEPTH
  input [clogb2(RAM_DEPTH-1)-1:0] addrb, // Read address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0] dina,          // RAM input data
  input clka,                          // Clock
  input wea,                           // Write enable
  output [RAM_WIDTH-1:0] doutb         // RAM output data
);

  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data_a = {RAM_WIDTH{1'b0}};
  reg [RAM_WIDTH-1:0] ram_data_b = {RAM_WIDTH{1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

    always @(posedge clka)
        if (wea) begin
          BRAM[addra] <= dina;
          ram_data_a <= dina;
        end else
        ram_data_a <= BRAM[addra];

    always @(posedge clka)
        ram_data_b <= BRAM[addrb];

    reg last_addr_eq;
    always @(posedge clka)
        last_addr_eq <= addra==addrb;
    assign doutb = last_addr_eq?ram_data_a:ram_data_b;


  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule
