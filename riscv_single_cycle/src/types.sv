package types;

typedef enum logic [10:0] {
  R_TYPE     = 11'b000_0000_0001,
  I_TYPE     = 11'b000_0000_0010,
  L_TYPE     = 11'b000_0000_0100,
  S_TYPE     = 11'b000_0000_1000,
  B_TYPE     = 11'b000_0001_0000,
  JAL_TYPE   = 11'b000_0010_0000,
  JALR_TYPE  = 11'b000_0100_0000,
  LUI_TYPE   = 11'b000_1000_0000,
  AUIPC_TYPE = 11'b001_0000_0000,
  SYS_TYPE   = 11'b010_0000_0000,
  NOP_TYPE   = 11'b100_0000_0000
} cu_inst_type;

typedef enum logic [3:0] {
  ALU_ADD  = 4'b0000,
  ALU_SUB  = 4'b0001,
  ALU_AND  = 4'b0010,
  ALU_OR   = 4'b0011,
  ALU_XOR  = 4'b0100,
  ALU_SLL  = 4'b0101,
  ALU_SRL  = 4'b0110,
  ALU_SRA  = 4'b0111,
  ALU_SLT  = 4'b1000,
  ALU_SLTU = 4'b1001
} alu_op_t;

endpackage
