import riscv_pkg::*;

module imm_decoder(
  input  logic [31:0] inst,
  input  imm_t        imm_type,
  output logic [31:0] imm_out
);

always_comb begin
  case(imm_type)
    IMM_I : imm_out = {{21{inst[31]}},inst[30:25],inst[24:21],inst[20]};                   // I-type
    IMM_S : imm_out = {{21{inst[31]}},inst[30:25],inst[11:8],inst[7]};                     // S-type
    IMM_B : imm_out = {{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};                // B-type
    IMM_U : imm_out = {inst[31],inst[30:20],inst[19:12],12'b0};                            // U-type
    IMM_J : imm_out = {{12{inst[31]}},inst[19:12],inst[20],inst[30:25],inst[24:21],1'b0};  // J-type
    default  : imm_out = 32'b0;
  endcase
end

endmodule
