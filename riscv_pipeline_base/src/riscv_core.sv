`timescale 1ns / 1ps

// Top module

module riscv_core(
  input  logic       sysclk,
  output logic [3:0] led
);

logic [31:0] counter = 32'b0;

always @(posedge sysclk) begin
  counter <= counter + 32'b1;
end

riscv_datapath u_riscv32(
    .clk(sysclk),
    .rstb(1'b1),
    .status(led[0])
);

endmodule
