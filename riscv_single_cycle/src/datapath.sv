`timescale 1ns / 1ps

import types::*;

module datapath(
  input  logic        clk,
  input  logic        rstb,
  output logic [3:0]  alu_flags
);

logic [31:0] inst;
logic [31:0] rs1;
logic [31:0] rs2;
logic [31:0] imm_out;
logic [31:0] alu_op2;
logic [31:0] rd;
logic [31:0] alu_res;
logic [31:0] data_mem_out;
logic [31:0] reg_w_data;

logic  [3:0] alu_op_sel;
logic        alu_op2_src;
logic        reg_w_en;
logic  [2:0] reg_w_src;
logic  [2:0] imm_type;
//logic [3:0]  alu_flags;
logic [2:0]  comp_type;

logic        mem_w_en;
logic  [1:0] mem_d_width;
logic        mem_signext;

logic [31:0] pc;
logic [31:0] pc_next;
logic [31:0] pc_plus4;
logic [31:0] pc_plus_imm;
logic  [1:0] pc_src;


// PC register
always_ff @(posedge clk or negedge rstb) begin
  if (~rstb) pc <= 15'b0;
  else       pc <= pc_next;
end

instruction_memory u_inst_mem(
  .clk(clk),
  .addr(pc),
  .dout(inst)
);

control_unit u_cu(
  .opcode(inst[6:0]),
  .func3(inst[14:12]),
  .func7(inst[31:25]),
  .alu_op_sel(alu_op_sel),
  .alu_op2_src(alu_op2_src),
  .alu_op_signext(),
  .reg_w_en(reg_w_en),
  .reg_w_src(reg_w_src),
  .mem_w_en(mem_w_en),
  .mem_w_size(mem_d_width),
  .mem_w_signed(mem_signext),
  .imm_type(imm_type),
  .pc_src(pc_src),
  .branch_type(),
  .comp_type(comp_type)
);

immediate_decoder u_imm(
  .inst(inst), 
  .imm_type(imm_type),
  .imm_out(imm_out)
);

register_file u_reg(
  .clk(clk),
  .rstb(rstb),
  .addr_rs1(inst[19:15]),
  .addr_rs2(inst[24:20]),
  .addr_rd(inst[11:7]),
  .wen(reg_w_en),
  .rd_data_w(reg_w_data),
  .rs1_data_r(rs1),
  .rs2_data_r(rs2),
  .rd_data_r(rd)
);

alu u_alu(
  .op1(rs1),
  .op2(alu_op2),
  .op_sel(alu_op_sel),
  .comp_type(comp_type),
  .res(alu_res),
  .flags(alu_flags),
  .branch(branch)
);

data_memory u_data_mem(
  .clk(clk),
  .addr(alu_res),
  .w_en(mem_w_en),
  .d_width(mem_d_width),
  .mem_signext(mem_signext),
  .din(rs2),
  .dout(data_mem_out)
);

assign alu_op2 = alu_op2_src ? imm_out : rs2;
always_comb begin
  case(reg_w_src)
    3'b000  : reg_w_data = alu_res;
    3'b001  : reg_w_data = data_mem_out;
    3'b010  : reg_w_data = pc_plus4;
    3'b011  : reg_w_data = imm_out;      // LUI
    3'b100  : reg_w_data = pc_plus_imm;  // AUIPC
    default: reg_w_data = alu_res;
  endcase
end

always_comb begin
  case(pc_src)
    2'b00: pc_next = pc_plus4;      // normal
    2'b01: pc_next = pc_plus_imm;   // JAL
    2'b10: pc_next = alu_res & ~1;       // JALR
    2'b11: pc_next = branch ? pc_plus_imm : pc_plus4;  // conditional branches    
  endcase
end

assign pc_plus4   = pc + 32'd4;
assign pc_plus_imm = pc + imm_out;

endmodule
