`timescale 1ns / 1ps

import riscv_pkg::*;

module reg_if_id(
    input  logic                          clk,
    input  logic                          rstb,
    input  logic                   [31:0] i_pc,
    input  logic                   [31:0] i_inst,
    output logic                   [31:0] o_pc,
    output logic                   [31:0] o_inst
);

always_ff @(posedge clk) begin
    // o_pc <= ~rstb ? o_pc : i_pc;
    o_pc <= i_pc;
end

assign o_inst =  i_inst;

endmodule
