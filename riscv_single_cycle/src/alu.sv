`timescale 1ns / 1ps

import types::*;

module alu(
  input  logic     [31:0] op1,
  input  logic     [31:0] op2,
  input  alu_op_t         op_sel,
  input  logic      [2:0] comp_type,
  output logic     [31:0] res,
  output logic      [3:0] flags,  // z, l, lu, of
  output logic            branch
);

// Operations
always_comb begin
  case(op_sel)
    ALU_ADD  : res = op1 + op2;
    ALU_SUB  : res = op1 - op2;
    ALU_AND  : res = op1 & op2;
    ALU_OR   : res = op1 | op2;
    ALU_XOR  : res = op1 ^ op2;
    ALU_SLL  : res = op1 << op2[4:0];
    ALU_SRL  : res = op1 >> op2[4:0];
    ALU_SRA  : res = $signed(op1) >>> op2[4:0];
    ALU_SLT  : res = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0;
    ALU_SLTU : res = (op1 < op2) ? 32'b1 : 32'b0;
    default  : res = 32'b0;
  endcase
end

// Flags
always_comb begin
  flags = 4'b0000;
  case(op_sel)
    ALU_ADD  : flags[0] =  (op1[31] == op2[31]) && (res[31] != op1[31]);
    ALU_SUB  : begin
                 flags[0] =  (op1[31] != op2[31]) && (res[31] != op1[31]);
                 flags[1] = (op1 < op2);
                 flags[2] = ($signed(op1) < $signed(op2));
               end
    ALU_SLT  : flags[2] = ($signed(op1) < $signed(op2));
    ALU_SLTU : flags[1] = (op1 < op2);
    default  : flags = 4'b0000;
  endcase
  flags[3] = (res == 32'b0);
end

always_comb begin
  case(comp_type)
    3'b001 : branch =  flags[3];  // BEQ
    3'b010 : branch = ~flags[3];  // BNE
    3'b011 : branch =  flags[2];  // BLT
    3'b100 : branch = ~flags[2];  // BGE
    3'b101 : branch =  flags[1];  // BLTU
    3'b110 : branch = ~flags[1];  // BGEU
    default: branch = 1'b0;
  endcase
end

endmodule
