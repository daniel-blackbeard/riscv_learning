`timescale 1ns / 1ps

import riscv_pkg::*;

module alu(
  input  logic     [31:0] op1,
  input  logic     [31:0] op2,
  input  alu_op_t         op_sel,
  input  alu_comp_t       comp_type,
  output logic     [31:0] res,
  output logic      [3:0] flags,  // z, l, lu, of
  output logic            branch
);

// Operations
always_comb begin
  case(op_sel)
    ADD  : res = op1 + op2;
    SUB  : res = op1 - op2;
    AND  : res = op1 & op2;
    OR   : res = op1 | op2;
    XOR  : res = op1 ^ op2;
    SLL  : res = op1 << op2[4:0];
    SRL  : res = op1 >> op2[4:0];
    SRA  : res = $signed(op1) >>> op2[4:0];
    SLT  : res = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0;
    SLTU : res = (op1 < op2) ? 32'b1 : 32'b0;
    default  : res = 32'b0;
  endcase
end

// Flags
always_comb begin
  flags = 4'b0000;
  case(op_sel)
    ADD  : flags[0] =  (op1[31] == op2[31]) && (res[31] != op1[31]);
    SUB  : begin
            flags[0] =  (op1[31] != op2[31]) && (res[31] != op1[31]);
            flags[1] = (op1 < op2);
            flags[2] = ($signed(op1) < $signed(op2));
    end
    SLT  : flags[2] = ($signed(op1) < $signed(op2));
    SLTU : flags[1] = (op1 < op2);
    default  : flags = 4'b0000;
  endcase
  flags[3] = (res == 32'b0);
end

always_comb begin
  case(comp_type)
    BEQ  : branch =  flags[3];
    BNE  : branch = ~flags[3];
    BLT  : branch =  flags[2];
    BGE  : branch = ~flags[2];
    BLTU : branch =  flags[1];
    BGEU : branch = ~flags[1];
    default: branch = 1'b0;
  endcase
end

endmodule
