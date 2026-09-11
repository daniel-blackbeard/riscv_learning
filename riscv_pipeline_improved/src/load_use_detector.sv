`timescale 1ns / 1ps

import riscv_pkg::*;

module load_use_detector (
    input  logic     [4:0] next_rs1,
    input  logic     [4:0] next_rs2,
    input  logic     [4:0] curr_rd,
    input  cu_inst_t       curr_inst_type,
    output logic           stall
);

//assign stall = (curr_inst_type == L_TYPE) & ((next_rs1 == curr_rd) | (next_rs2 == curr_rd));
assign stall = (curr_inst_type == L_TYPE) & (curr_rd != 5'b0) & ((next_rs1 == curr_rd) | (next_rs2 == curr_rd));

endmodule
