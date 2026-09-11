`timescale 1ns / 1ps

import riscv_pkg::*;

module reg_id_ex(
    input  logic                          clk,
    input  logic                          rstb,
    input  logic                   [31:0] i_pc,
    input  logic                   [31:0] i_rs1,
    input  logic                   [31:0] i_rs2,
    input  logic                   [31:0] i_imm,
    input  logic                   [31:0] i_alu_op2,
    input  logic                    [4:0] i_rd_addr,
    input  logic                    [4:0] i_rs1_addr,
    input  logic                    [4:0] i_rs2_addr,
    input  ex_ctrl_t                      i_ex_ctrl,
    input  mem_ctrl_t                     i_mem_ctrl,
    input  wb_ctrl_t                      i_wb_ctrl,
    input  if_ctrl_t                      i_if_ctrl,
    input  cu_inst_t                      i_inst_type,
    output logic                   [31:0] o_pc,
    output logic                   [31:0] o_rs1,
    output logic                   [31:0] o_rs2,
    output logic                   [31:0] o_imm,
    output logic                   [31:0] o_alu_op2,
    output logic                    [4:0] o_rd_addr,
    output logic                    [4:0] o_rs1_addr,
    output logic                    [4:0] o_rs2_addr,
    output ex_ctrl_t                      o_ex_ctrl,
    output mem_ctrl_t                     o_mem_ctrl,
    output wb_ctrl_t                      o_wb_ctrl,
    output if_ctrl_t                      o_if_ctrl,
    output cu_inst_t                      o_inst_type
);

always_ff @(posedge clk) begin
    if(~rstb) begin
        o_pc        <= '0;
        o_imm       <= '0;
        o_alu_op2   <= '0;
        o_rd_addr   <= '0;
        o_rs1_addr  <= '0;
        o_rs2_addr  <= '0;
        o_ex_ctrl   <= '{alu_op2: OP2_REG, alu_comp: NOC, alu_op: ADD};
        o_mem_ctrl  <= '{mem_w_en: 1'b0, mem_size: WIDE, mem_signed: SIGNED};
        o_wb_ctrl   <= '{reg_w_en: 1'b0, reg_src: REGSRC_ALU};
        o_if_ctrl   <= '{pc_src: PCSRC_PC_4};
        o_inst_type <= I_TYPE;
        o_rs1       <= '0;
        o_rs2       <= '0;
    end else begin
        o_pc <= i_pc;
        o_imm       <= i_imm;
        o_alu_op2   <= i_alu_op2;
        o_rd_addr   <= i_rd_addr;
        o_rs1_addr  <= i_rs1_addr;
        o_rs2_addr  <= i_rs2_addr;
        o_ex_ctrl   <= i_ex_ctrl;
        o_mem_ctrl  <= i_mem_ctrl;
        o_wb_ctrl   <= i_wb_ctrl;
        o_if_ctrl   <= i_if_ctrl;
        o_inst_type <= i_inst_type;
        o_rs1       <= i_rs1;
        o_rs2       <= i_rs2;
    end

end

endmodule
