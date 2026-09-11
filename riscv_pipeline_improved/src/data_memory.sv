`timescale 1ns / 1ps

import riscv_pkg::*;

module data_memory(
    input  logic                          clk,
    input  logic                          w_en,
    input  logic [DATA_MEM_ADDR_SIZE-1:0] addr,
    input  logic                   [31:0] data_in,
    output logic                   [31:0] data_out
);
// RISCV addressing is per byte, however this module will return an entire word of 4bytes
// Processing of this word happens outside this block

localparam int WORD_DEPTH = 2**(DATA_MEM_ADDR_SIZE-2);

logic [DATA_MEM_ADDR_SIZE-3:0] word_addr;
assign word_addr = addr[DATA_MEM_ADDR_SIZE-1:2];

(* ram_style = "block" *)
logic [31:0] ram [0:WORD_DEPTH-1];

always_ff @(posedge clk) begin
    if(w_en)
        ram[word_addr] <= data_in;
        
    data_out <= ram[word_addr];
end
 
endmodule
