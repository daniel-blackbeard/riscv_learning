`timescale 1ns / 1ps

module instruction_memory(
  input  logic        clk,
  input  logic [15:0] addr,
  output logic [31:0] dout
);

(* rom_style = "distributed" *)
logic [7:0] rom [0:65535];

initial begin
  $readmemh("../../programs/fpga_program.mem", rom);
end

always_comb begin
  dout = {rom[addr+3],rom[addr+2],rom[addr+1],rom[addr]}; // 1-cycle latency
end

endmodule
