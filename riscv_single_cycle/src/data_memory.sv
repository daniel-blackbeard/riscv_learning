`timescale 1ns / 1ps

module data_memory(
  input  logic        clk,
  input  logic [15:0] addr,
  input  logic        w_en,
  input  logic  [1:0] d_width,
  input  logic        mem_signext,
  input  logic [31:0] din,
  output logic [31:0] dout
);

(* ram_style = "distributed" *)
logic [7:0] ram [0:4095];

always_comb begin
  case(d_width)
    2'b01   : dout = mem_signext ? {{24{ram[addr][7]}},ram[addr]} : {24'b0,ram[addr]};
    2'b10   : dout = mem_signext ? {{16{ram[addr+1][7]}},ram[addr+1],ram[addr]} : {16'b0,ram[addr+1], ram[addr]};
    2'b11   : dout = {ram[addr+3],ram[addr+2],ram[addr+1],ram[addr]};
    default : ;
  endcase
end

always_ff @(posedge clk) begin
  
  if (w_en) begin
    case(d_width)
      2'b01   : ram[addr]                                       <= din[7:0];
      2'b10   : {ram[addr+1],ram[addr]}                         <= din[15:0];
      2'b11   : {ram[addr+3],ram[addr+2],ram[addr+1],ram[addr]} <= din;
      default : ;
    endcase
  end 
end

endmodule
