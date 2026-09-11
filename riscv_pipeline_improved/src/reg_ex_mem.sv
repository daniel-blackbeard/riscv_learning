`timescale 1ns / 1ps

import riscv_pkg::*;

module reg_ex_mem(
    input  logic                          clk,
    input  logic                          rstb,
    input  logic                   [31:0] i_alu_res,
    input  logic                   [31:0] i_rs2,
    input  logic                   [31:0] i_pc_plus_4,
    input  logic                   [31:0] i_pc_plus_imm,
    input  logic                   [31:0] i_imm,
    input  logic                    [4:0] i_rd_addr,
    input  logic                          i_alu_branch,
    input  mem_ctrl_t                     i_mem_ctrl,
    input  wb_ctrl_t                      i_wb_ctrl,
    input  if_ctrl_t                      i_if_ctrl,
    input  cu_inst_t                      i_inst_type,
    output logic                   [31:0] o_alu_res,
    output logic                   [31:0] o_rs2,
    output logic                   [31:0] o_pc_plus_4,
    output logic                   [31:0] o_pc_plus_imm,
    output logic                   [31:0] o_imm,
    output logic                    [4:0] o_rd_addr,
    output logic                          o_alu_branch,
    output mem_ctrl_t                     o_mem_ctrl,
    output wb_ctrl_t                      o_wb_ctrl,
    output if_ctrl_t                      o_if_ctrl,
    output cu_inst_t                      o_inst_type
);

always_ff @(posedge clk) begin
    if(~rstb) begin
        o_alu_branch  <= '0;
        o_rd_addr     <= '0;
        o_pc_plus_4   <= '0;
        o_pc_plus_imm <= '0;
        o_imm         <= '0;
        o_mem_ctrl    <= '{mem_w_en: 1'b0, mem_size: WIDE, mem_signed: SIGNED};
        o_wb_ctrl     <= '{reg_w_en: 1'b0, reg_src: REGSRC_ALU};
        o_if_ctrl     <= '{pc_src: PCSRC_PC_4};
        o_inst_type   <= I_TYPE;
    end else begin
        o_alu_branch  <= i_alu_branch;
        o_rd_addr     <= i_rd_addr;
        o_pc_plus_4   <= i_pc_plus_4;
        o_pc_plus_imm <= i_pc_plus_imm;
        o_imm         <= i_imm;
        o_mem_ctrl    <= i_mem_ctrl;
        o_wb_ctrl     <= i_wb_ctrl;
        o_if_ctrl     <= i_if_ctrl;
        o_inst_type   <= i_inst_type;
        o_alu_res     <= i_alu_res;
    end
end

assign o_rs2     = i_rs2;

endmodule
