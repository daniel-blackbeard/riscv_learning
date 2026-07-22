`timescale 1ns / 1ps

module riscv_cpu(
  input  logic       CLK100MHZ,
  output logic [3:0] led
);

logic [3:0]  alu_flags;

logic rstb = 1'b1;

datapath u_core(.clk(CLK100MHZ), .rstb(rstb), .alu_flags(alu_flags));

assign led = alu_flags;

endmodule
