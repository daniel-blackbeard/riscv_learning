`timescale 1ns / 1ps

package riscv_pkg;

localparam int INST_MEM_ADDR_SIZE = 12;
localparam int DATA_MEM_ADDR_SIZE = 12;


typedef enum logic [11:0] {
  R_TYPE     = 12'b0000_0000_0001,
  I_TYPE     = 12'b0000_0000_0010,
  L_TYPE     = 12'b0000_0000_0100,
  S_TYPE     = 12'b0000_0000_1000,
  B_TYPE     = 12'b0000_0001_0000,
  JAL_TYPE   = 12'b0000_0010_0000,
  JALR_TYPE  = 12'b0000_0100_0000,
  LUI_TYPE   = 12'b0000_1000_0000,
  AUIPC_TYPE = 12'b0001_0000_0000,
  SYS_TYPE   = 12'b0010_0000_0000,
  FENCE_TYPE = 12'b0100_0000_0000,
  NOP_TYPE   = 12'b1000_0000_0000
} cu_inst_t;

typedef enum logic [9:0] {
  ADD  = 10'b00_0000_0001,
  SUB  = 10'b00_0000_0010,
  AND  = 10'b00_0000_0100,
  OR   = 10'b00_0000_1000,
  XOR  = 10'b00_0001_0000,
  SLL  = 10'b00_0010_0000,
  SRL  = 10'b00_0100_0000,
  SRA  = 10'b00_1000_0000,
  SLT  = 10'b01_0000_0000,
  SLTU = 10'b10_0000_0000
} alu_op_t;

typedef enum logic [4:0] {
  IMM_NONE   = 5'b00000,
  IMM_I      = 5'b00001,
  IMM_S      = 5'b00010,
  IMM_B      = 5'b00100,
  IMM_U      = 5'b01000,
  IMM_J      = 5'b10000
} imm_t;

typedef enum logic [4:0] {
  REGSRC_ALU    = 5'b00001,
  REGSRC_IMM    = 5'b00010,
  REGSRC_MEM    = 5'b00100,
  REGSRC_PC_4   = 5'b01000,
  REGSRC_PC_IMM = 5'b10000
} reg_w_src_t;

typedef enum logic [4:0] {
  PCSRC_PC_4   = 5'b00001,
  PCSRC_PC     = 5'b00010,
  PCSRC_PC_IMM = 5'b00100,
  PCSRC_ALU    = 5'b01000,
  PCSRC_BRANCH = 5'b10000
} pc_src_t;

typedef enum logic [6:0] {
  NOC  = 7'b0000001,
  BEQ  = 7'b0000010,
  BNE  = 7'b0000100,
  BLT  = 7'b0001000,
  BGE  = 7'b0010000,
  BLTU = 7'b0100000,
  BGEU = 7'b1000000
} alu_comp_t;

typedef enum logic [1:0] {
  OP2_REG = 2'b01,
  OP2_IMM = 2'b10
} alu_op2_t;

typedef enum logic [2:0] {
  WIDE = 3'b001,
  HALF = 3'b010,
  BYTE = 3'b100
} mem_d_size_t;

typedef enum logic [1:0] {
  SIGNED   = 2'b01,
  UNSIGNED = 2'b10
} mem_d_sign_t;


typedef enum logic [2:0] {
  NO_FORWARD   = 3'b001,
  MEM_FORWARD  = 3'b010,
  WB_FORWARD   = 3'b100
} reg_fw_t;

typedef struct packed {
  pc_src_t pc_src;
} if_ctrl_t;

typedef struct packed {
  imm_t imm;
} id_ctrl_t;

typedef struct packed {
  alu_op2_t  alu_op2;
  alu_comp_t alu_comp;
  alu_op_t   alu_op;
} ex_ctrl_t;

typedef struct packed {
  logic        mem_w_en;
  mem_d_size_t mem_size;
  mem_d_sign_t mem_signed;
} mem_ctrl_t;

typedef struct packed {
  logic reg_w_en;
  reg_w_src_t reg_src;
} wb_ctrl_t;

endpackage
