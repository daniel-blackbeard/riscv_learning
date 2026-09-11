import riscv_pkg::*;

module instruction_memory#(
  parameter string MEM_INIT_FILE = "../../programs/fpga_program.mem"
)(
    input  logic                          clk,
    input  logic                   [31:0] addr,
    output logic                   [31:0] inst
);

(* rom_style = "block" *)
logic [31:0] rom [0:2**(INST_MEM_ADDR_SIZE-2)-1];

initial begin
  $readmemh(MEM_INIT_FILE, rom);
end

always_ff @(posedge clk) begin
    inst <= rom[addr[INST_MEM_ADDR_SIZE-1:2]];
end

endmodule
