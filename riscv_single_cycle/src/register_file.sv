`timescale 1ns / 1ps

module register_file(
  input  logic        clk,
  input  logic        rstb,
  input  logic  [4:0] addr_rs1,
  input  logic  [4:0] addr_rs2,
  input  logic  [4:0] addr_rd,
  input  logic        wen,
  input  logic [31:0] rd_data_w,
  output logic [31:0] rs1_data_r,
  output logic [31:0] rs2_data_r,
  output logic [31:0] rd_data_r
);

logic [31:0] registers[31:0];

always_comb begin
  rs1_data_r = registers[addr_rs1];
  rs2_data_r = registers[addr_rs2];
  rd_data_r  = registers[addr_rd];
end

always @(posedge clk) begin
  if(~rstb) begin
    for(int i=0; i < 32; i++)
      registers[i] <= 32'b0;
    end
  else if(wen) begin
    registers[addr_rd] <= (addr_rd == 5'b0) ? 32'b0 : rd_data_w;
  end
end

endmodule
