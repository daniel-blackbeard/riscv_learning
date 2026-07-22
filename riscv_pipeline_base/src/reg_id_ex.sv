`timescale 1ns / 1ps

import riscv_pkg::*;

module reg_id_ex(
    input  logic                          clk,
    input  logic                          rstb,
    input  logic                   [31:0] i_pc,
    input  logic                   [31:0] i_rs1,
    input  logic                   [31:0] i_rs2,
    input  logic                   [31:0] i_imm,
    input  logic                    [4:0] i_rd_addr,
    input  logic                    [4:0] i_rs1_addr,
    input  logic                    [4:0] i_rs2_addr,
    input  ex_ctrl_t                      i_ex_ctrl,
    input  mem_ctrl_t                     i_mem_ctrl,
    input  wb_ctrl_t                      i_wb_ctrl,
    input  if_ctrl_t                      i_if_ctrl,
    input  cu_inst_t                      i_inst_type,
    input  logic                          flush,
    output logic                   [31:0] o_pc,
    output logic                   [31:0] o_rs1,
    output logic                   [31:0] o_rs2,
    output logic                   [31:0] o_imm,
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
        o_rd_addr   <= '0;
        o_rs1_addr  <= '0;
        o_rs2_addr  <= '0;
        o_ex_ctrl   <= '{alu_op2: OP2_REG, alu_comp: NOC, alu_op: ADD};
        o_mem_ctrl  <= '{mem_w_en: 1'b0, mem_size: WIDE, mem_signed: SIGNED};
        o_wb_ctrl   <= '{reg_w_en: 1'b0, reg_src: REGSRC_ALU};
        o_if_ctrl   <= '{pc_src: PCSRC_PC_4};
        o_inst_type <= I_TYPE;
    end else begin
        o_pc <= i_pc;
        o_imm       <= flush ? 32'h0 : i_imm;
        o_rd_addr   <= flush ? 5'b0 : i_rd_addr;
        o_rs1_addr  <= flush ? 5'b0 : i_rs1_addr;
        o_rs2_addr  <= flush ? 5'b0 : i_rs2_addr;
        o_ex_ctrl   <= flush ? '{alu_op2: OP2_REG, alu_comp: NOC, alu_op: ADD} : i_ex_ctrl;
        o_mem_ctrl  <= flush ? '{mem_w_en: 1'b0, mem_size: WIDE, mem_signed: SIGNED} : i_mem_ctrl;
        o_wb_ctrl   <= flush ? '{reg_w_en: 1'b0, reg_src: REGSRC_ALU} : i_wb_ctrl;
        o_if_ctrl   <= flush ? '{pc_src: PCSRC_PC_4} : i_if_ctrl;
        o_inst_type <= flush ? I_TYPE : i_inst_type;
    end

end

assign o_rs1 = i_rs1;
assign o_rs2 = i_rs2;

endmodule
