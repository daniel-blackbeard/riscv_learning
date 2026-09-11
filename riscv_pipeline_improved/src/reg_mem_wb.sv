`timescale 1ns / 1ps

import riscv_pkg::*;

module reg_mem_wb(
    input  logic                          clk,
    input  logic                          rstb,
    input  logic                   [31:0] i_data_out,
    input  logic                   [31:0] i_alu_result,
    input  logic                    [4:0] i_rd_addr,
    input  wb_ctrl_t                      i_wb_ctrl,
    output logic                   [31:0] o_data_out,
    output logic                   [31:0] o_alu_result,
    output logic                    [4:0] o_rd_addr,
    output wb_ctrl_t                      o_wb_ctrl
);

always_ff @(posedge clk) begin
    if(~rstb) begin
        o_alu_result  <= '0;
        o_rd_addr     <= '0;
        o_wb_ctrl     <= '{reg_w_en: 1'b0, reg_src: REGSRC_ALU};
        o_data_out    <= '0;
    end else begin
        o_alu_result  <= i_alu_result;
        o_rd_addr     <= i_rd_addr;
        o_wb_ctrl     <= i_wb_ctrl;
        o_data_out    <= i_data_out;
    end

end

// assign o_data_out = i_data_out;

endmodule
