`timescale 1ns / 1ps

import types::*;

module control_unit(
  input  logic [6:0] opcode,
  input  logic [2:0] func3,
  input  logic [6:0] func7,
  output logic [3:0] alu_op_sel,
  output logic       alu_op2_src,
  output logic       alu_op_signext,
  output logic       reg_w_en,
  output logic [2:0] reg_w_src,
  output logic       mem_w_en,
  output logic [1:0] mem_w_size,
  output logic       mem_w_signed,
  output logic [2:0] imm_type,
  output logic [1:0] pc_src,
  output logic [1:0] branch_type,
  output logic [2:0] comp_type
);

cu_inst_type inst_type;

always_comb begin
  // defaults
  alu_op_sel     = ALU_ADD;
  alu_op2_src    = 1'b0;
  alu_op_signext = 1'b0;
  reg_w_en       = 1'b1;
  reg_w_src      = 3'b0;
  mem_w_en       = 1'b0;
  mem_w_size     = 2'b0;
  mem_w_signed   = 1'b0;
  pc_src         = 2'b0;
  branch_type    = 2'b0;
  comp_type      = 3'b0;
  // silently droping bits [1:0] for now until C extension
  case(opcode[6:2])
    5'b01100 : begin
                 inst_type = R_TYPE;
                 imm_type  = 3'b000;
                 case(func3)
                   3'b000 : alu_op_sel = (func7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
                   3'b001 : alu_op_sel = ALU_SLL;
                   3'b010 : alu_op_sel = ALU_SLT;
                   3'b011 : alu_op_sel = ALU_SLTU;
                   3'b100 : alu_op_sel = ALU_XOR;
                   3'b101 : alu_op_sel = (func7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                   3'b110 : alu_op_sel = ALU_OR;
                   3'b111 : alu_op_sel = ALU_AND;
                 endcase
               end
    5'b00100 : begin
                 inst_type = I_TYPE;
                 imm_type  = 3'b001;
                 alu_op2_src = 1'b1;
                 case(func3)
                   3'b000 : alu_op_sel = ALU_ADD;
                   3'b001 : alu_op_sel = ALU_SLL;
                   3'b010 : alu_op_sel = ALU_SLT;
                   3'b011 : alu_op_sel = ALU_SLTU;
                   3'b100 : alu_op_sel = ALU_XOR;
                   3'b101 : alu_op_sel = (func7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                   3'b110 : alu_op_sel = ALU_OR;
                   3'b111 : alu_op_sel = ALU_AND;
                 endcase
               end
    5'b00000 : begin
                 inst_type = L_TYPE;
                 imm_type  = 3'b001;
                 alu_op2_src = 1'b1;
                 reg_w_src = 3'b001;
                 case(func3)
                   3'b000 : begin
                              mem_w_size = 2'b01;
                              mem_w_signed = 1'b1;
                            end
                   3'b001 : begin
                              mem_w_size = 2'b10;
                              mem_w_signed = 1'b1;
                            end
                   3'b010 : begin
                              mem_w_size = 2'b11;
                              mem_w_signed = 1'b1;
                            end
                   3'b100 : begin
                              mem_w_size = 2'b01;
                              mem_w_signed = 1'b0;
                            end
                   3'b101 : begin
                              mem_w_size = 2'b10;
                              mem_w_signed = 1'b0;
                            end
                   default: begin
                              mem_w_size = 2'b00;
                              mem_w_signed = 1'b0;
                            end
                 endcase
               end
    5'b01000 : begin
                 inst_type = S_TYPE;
                 imm_type  = 3'b010;
                 alu_op2_src = 1'b1;
                 reg_w_en = 1'b0;
                 mem_w_en = 1'b1;
                 case(func3)
                   3'b000 : mem_w_size = 2'b01;
                   3'b001 : mem_w_size = 2'b10;
                   3'b010 : mem_w_size = 2'b11;
                   default: mem_w_size = 2'b00;
                 endcase
               end
    5'b11000 : begin
                 inst_type = B_TYPE;
                 imm_type  = 3'b011;
                 reg_w_en = 1'b0;
                 pc_src = 2'b11;
                 branch_type = 2'b01;
                 alu_op_sel = 4'b0001;
                 case(func3)
                   3'b000 : comp_type = 3'b001;
                   3'b001 : comp_type = 3'b010;
                   3'b100 : comp_type = 3'b011;
                   3'b101 : comp_type = 3'b100;
                   3'b110 : comp_type = 3'b101;
                   3'b111 : comp_type = 3'b110;
                   default: comp_type = 3'b000;
                 endcase
               end
    5'b11011 : begin
                 inst_type = JAL_TYPE;
                 imm_type  = 3'b101;
                 alu_op2_src = 1'b1;
                 reg_w_src = 3'b010;
                 pc_src  = 2'b01;
                 branch_type = 2'b10;
               end
    5'b11001 : begin
                 inst_type = JALR_TYPE;
                 imm_type  = 3'b001;    // JALR uses I-type immediate
                 alu_op2_src = 1'b1;
                 reg_w_src = 3'b010;
                 pc_src  = 2'b10;
                 branch_type = 2'b10;
               end
    5'b01101 : begin
                 inst_type = LUI_TYPE;
                 imm_type  = 3'b100;
                 reg_w_src = 3'b011;
                 alu_op2_src = 1'b1;
               end
    5'b00101 : begin
                 inst_type = AUIPC_TYPE;
                 imm_type  = 3'b100;
                 alu_op2_src = 1'b1;
                 reg_w_src = 3'b100;
               end
    5'b11100 : begin
                 inst_type = SYS_TYPE;
                 imm_type  = 3'b000;
               end
    default : begin
                 inst_type = NOP_TYPE;
                 imm_type  = 3'b000;
               end
  endcase
  
end
endmodule
