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
  unique case(op_sel)
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
// always_comb begin
//   flags = 4'b0000;
//   case(op_sel)
//     ADD  : flags[0] =  (op1[31] == op2[31]) && (res[31] != op1[31]);
//     SUB  : begin
//             flags[0] =  (op1[31] != op2[31]) && (res[31] != op1[31]);
//             flags[1] = (op1 < op2);
//             flags[2] = ($signed(op1) < $signed(op2));
//     end
//     SLT  : flags[2] = ($signed(op1) < $signed(op2));
//     SLTU : flags[1] = (op1 < op2);
//     default  : flags = 4'b0000;
//   endcase
//   flags[3] = (res == 32'b0);
// end

// Flags — all computed directly from op1/op2, independent of op_sel/res
assign flags[3] = (op1 == op2);                              // zero / equal
assign flags[2] = ($signed(op1) < $signed(op2));              // slt
assign flags[1] = (op1 < op2);                                // sltu
assign flags[0] = (op1[31] == op2[31]) && (res[31] != op1[31]); // overflow (arith-only, not on branch path)

always_comb begin
  unique case(comp_type)
    BEQ  : branch =  flags[3];
    BNE  : branch = ~flags[3];
    BLT  : branch =  flags[2];
    BGE  : branch = ~flags[2];
    BLTU : branch =  flags[1];
    BGEU : branch = ~flags[1];
    default: branch = 1'b0;
  endcase
end

// logic sel_result;

// always_comb begin
//   unique case (comp_type[2])
//     1'b0: sel_result = flags[3];                     // equality family → zero flag
//     1'b1: sel_result = comp_type[1] ? flags[1] : flags[2]; // magnitude family → unsigned/signed
//   endcase
// end

// assign branch = comp_type[0] ? ~sel_result : sel_result; // invert bit flips BEQ->BNE, BLT->BGE, etc.

endmodule
